// Đóng gói nội dung theo từng series cho app Flutter.
//
//   node pack.js --english-only          # mọi bài đã crawl, chỉ bản gốc tiếng Anh
//   node pack.js                         # chỉ các bài đã dịch
//   node pack.js --include-untranslated  # kèm cả bài chưa dịch (hiển thị bản gốc)
//
// Kết quả:
//   dist/series-N.db.gz + dist/manifest.json   -> tải lên GitHub Releases
//   app/assets/db/series-1.db.gz + series-1.json -> Series I nhúng sẵn trong app
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import zlib from 'node:zlib';
import { DatabaseSync } from 'node:sqlite';
import { APP_DB_FILE, INDEX_FILE, RAW_DIR, VI_DIR, parseArgs, readJson } from './lib.js';

const args = parseArgs();
const englishOnly = Boolean(args['english-only']);
const index = readJson(INDEX_FILE, []);
const titleOverrides = readJson(new URL('./title_overrides.json', import.meta.url), {});

const DIST_DIR = new URL('./dist/', import.meta.url).pathname.replace(/^\/([A-Za-z]:)/, '$1');
const APP_ASSET_DIR = path.dirname(APP_DB_FILE);
fs.rmSync(DIST_DIR, { recursive: true, force: true });
fs.mkdirSync(DIST_DIR, { recursive: true });
fs.mkdirSync(APP_ASSET_DIR, { recursive: true });

const SCHEMA = `
  CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT);
  CREATE TABLE scp (
    id TEXT PRIMARY KEY,
    number INTEGER NOT NULL,
    series INTEGER NOT NULL,
    title_en TEXT,
    title_vi TEXT,
    object_class TEXT,
    author TEXT,
    url TEXT,
    tags TEXT,
    html_en TEXT,
    html_vi TEXT
  );
`;

function rowsFor(series) {
  const rows = [];
  for (const entry of index) {
    if (entry.series !== series) continue;
    const raw = readJson(path.join(RAW_DIR, `${entry.id}.json`));
    if (!raw) continue;
    const vi = englishOnly ? null : readJson(path.join(VI_DIR, `${entry.id}.json`));
    if (!vi && !args['include-untranslated'] && !englishOnly) continue;
    rows.push([
      raw.id, raw.number, raw.series, raw.titleEn ?? '',
      englishOnly ? null : titleOverrides[raw.id] ?? vi?.titleVi ?? null,
      raw.objectClass ?? null, raw.author ?? null, raw.url, (raw.tags ?? []).join(','),
      raw.htmlEn, vi?.htmlVi ?? null,
    ]);
  }
  return rows;
}

function buildPack(series, rows) {
  // Phiên bản = hash nội dung, để series không đổi thì app không báo cập nhật.
  const version = crypto.createHash('sha256').update(JSON.stringify(rows)).digest('hex').slice(0, 16);
  const dbFile = path.join(DIST_DIR, `series-${series}.db`);
  const db = new DatabaseSync(dbFile);
  db.exec(SCHEMA);
  const insert = db.prepare(`
    INSERT INTO scp (id, number, series, title_en, title_vi, object_class, author, url, tags, html_en, html_vi)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `);
  db.exec('BEGIN');
  for (const r of rows) insert.run(...r);
  db.prepare('INSERT INTO meta (key, value) VALUES (?, ?)').run('version', version);
  db.prepare('INSERT INTO meta (key, value) VALUES (?, ?)').run('series', String(series));
  db.exec('COMMIT');
  db.exec('VACUUM');
  db.close();

  const gzFile = `${dbFile}.gz`;
  const gz = zlib.gzipSync(fs.readFileSync(dbFile), { level: 9 });
  fs.writeFileSync(gzFile, gz);
  fs.rmSync(dbFile);

  return {
    series,
    file: path.basename(gzFile),
    version,
    count: rows.length,
    translated: rows.filter((r) => r[10]).length,
    size: gz.length,
    sha256: crypto.createHash('sha256').update(gz).digest('hex'),
  };
}

const packs = [];
for (let series = 1; series <= 10; series++) {
  const rows = rowsFor(series);
  if (!rows.length) continue;
  const pack = buildPack(series, rows);
  packs.push(pack);
  console.log(`Series ${series}: ${pack.count} bài (${pack.translated} đã dịch), ${(pack.size / 1024 / 1024).toFixed(1)} MB`);
}

const manifest = { version: new Date().toISOString(), packs };
fs.writeFileSync(path.join(DIST_DIR, 'manifest.json'), JSON.stringify(manifest, null, 2), 'utf8');

for (const old of ['scp_vn.db', 'version.json']) fs.rmSync(path.join(APP_ASSET_DIR, old), { force: true });
const bundled = packs.find((p) => p.series === 1);
if (bundled) {
  fs.copyFileSync(path.join(DIST_DIR, bundled.file), path.join(APP_ASSET_DIR, bundled.file));
  fs.writeFileSync(path.join(APP_ASSET_DIR, 'series-1.json'), JSON.stringify(bundled), 'utf8');
  console.log(`Đã nhúng Series I vào ${APP_ASSET_DIR}`);
}
console.log(`Xong: ${packs.length} gói trong ${DIST_DIR}`);

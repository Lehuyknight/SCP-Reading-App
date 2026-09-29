import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));

export const DATA_DIR = path.join(here, 'data');
export const RAW_DIR = path.join(DATA_DIR, 'raw');
export const VI_DIR = path.join(DATA_DIR, 'vi');
export const INDEX_FILE = path.join(DATA_DIR, 'index.json');
export const GLOSSARY_FILE = path.join(here, 'glossary_vn.json');
export const APP_DB_FILE = path.resolve(here, '..', '..', 'app', 'assets', 'db', 'scp_vn.db');

export const WIKI_BASE = 'https://scp-wiki.wikidot.com';

for (const dir of [DATA_DIR, RAW_DIR, VI_DIR]) fs.mkdirSync(dir, { recursive: true });

export const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

export function parseArgs(argv = process.argv.slice(2)) {
  const args = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (!a.startsWith('--')) continue;
    const key = a.slice(2);
    const next = argv[i + 1];
    if (next === undefined || next.startsWith('--')) args[key] = true;
    else {
      args[key] = next;
      i++;
    }
  }
  return args;
}

/** "1,2" | "1-3" | "all" -> [1,2,3] */
export function parseSeries(value) {
  if (!value || value === true) return [1];
  if (value === 'all') return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  const out = new Set();
  for (const part of String(value).split(',')) {
    const [a, b] = part.split('-').map(Number);
    if (b) for (let i = a; i <= b; i++) out.add(i);
    else out.add(a);
  }
  return [...out].filter((n) => n >= 1 && n <= 10).sort((x, y) => x - y);
}

export function seriesPageName(series) {
  return series === 1 ? 'scp-series' : `scp-series-${series}`;
}

export function seriesOfNumber(n) {
  return n < 1000 ? 1 : Math.floor(n / 1000) + 1;
}

export async function fetchText(url, { retries = 4 } = {}) {
  let lastErr;
  for (let attempt = 0; attempt <= retries; attempt++) {
    try {
      const res = await fetch(url, {
        headers: { 'User-Agent': 'SCP-Reading-App/1.0 (personal offline reader)' },
      });
      if (res.status === 404) return null;
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return await res.text();
    } catch (err) {
      lastErr = err;
      await sleep(2000 * (attempt + 1));
    }
  }
  throw new Error(`Không tải được ${url}: ${lastErr?.message}`);
}

export function readJson(file, fallback = null) {
  try {
    return JSON.parse(fs.readFileSync(file, 'utf8'));
  } catch {
    return fallback;
  }
}

export function writeJson(file, data) {
  const tmp = `${file}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(data, null, 2), 'utf8');
  fs.renameSync(tmp, file);
}

export function filterIndex(index, args) {
  const series = parseSeries(args.series);
  const from = args.from ? Number(args.from) : -Infinity;
  const to = args.to ? Number(args.to) : Infinity;
  let items = index.filter((e) => series.includes(e.series) && e.number >= from && e.number <= to);
  if (args.only) {
    const only = new Set(String(args.only).split(',').map((s) => s.trim().toLowerCase()));
    items = index.filter((e) => only.has(e.id));
  }
  if (args.limit) items = items.slice(0, Number(args.limit));
  return items;
}

// Lấy danh sách SCP theo Series và tải nội dung từng bài từ SCP Wiki tiếng Anh.
//
//   node crawl.js --series 1              # Series I
//   node crawl.js --series 1-3 --limit 50
//   node crawl.js --only scp-173,scp-096
//   node crawl.js --series 1 --refresh-index   # tải lại danh sách
import fs from 'node:fs';
import path from 'node:path';
import * as cheerio from 'cheerio';
import {
  INDEX_FILE, RAW_DIR, WIKI_BASE, fetchText, filterIndex, parseArgs, parseSeries,
  readJson, seriesOfNumber, seriesPageName, sleep, writeJson,
} from './lib.js';

const args = parseArgs();
const DELAY_MS = Number(args.delay ?? 1500);

const OBJECT_CLASS_TAGS = [
  'safe', 'euclid', 'keter', 'thaumiel', 'apollyon', 'archon', 'neutralized',
  'explained', 'decommissioned', 'pending', 'esoteric-class', 'uncontained',
];

async function buildIndex(seriesList) {
  const index = readJson(INDEX_FILE, []);
  const byId = new Map(index.map((e) => [e.id, e]));

  for (const series of seriesList) {
    const url = `${WIKI_BASE}/${seriesPageName(series)}`;
    console.log(`[index] ${url}`);
    const html = await fetchText(url);
    if (!html) continue;
    const $ = cheerio.load(html);
    let count = 0;
    $('#page-content li').each((_, li) => {
      const a = $(li).children('a').first();
      const href = a.attr('href') ?? '';
      const m = /^\/(scp-(\d{3,4}))$/i.exec(href);
      if (!m || a.hasClass('newpage')) return;
      const number = Number(m[2]);
      if (number === 1 || seriesOfNumber(number) !== series) return;
      const text = $(li).text();
      const dash = text.indexOf(' - ');
      const title = dash >= 0 ? text.slice(dash + 3).trim() : '';
      byId.set(m[1].toLowerCase(), { id: m[1].toLowerCase(), number, series, title });
      count++;
    });
    console.log(`[index] Series ${series}: ${count} bài`);
    await sleep(DELAY_MS);
  }

  const out = [...byId.values()].sort((a, b) => a.number - b.number);
  writeJson(INDEX_FILE, out);
  return out;
}

function cleanArticle(html) {
  const $ = cheerio.load(html);
  const content = $('#page-content');
  if (!content.length) return null;

  const tags = $('.page-tags a')
    .map((_, a) => $(a).text().trim())
    .get()
    .filter((t) => t && !t.startsWith('_'));

  let author = null;
  const cite = content.find('.licensebox blockquote').first().text();
  const am = /"\s*by\s+(.+?),\s+from the/i.exec(cite) || /\bby\s+(.+?),\s+from the/i.exec(cite);
  if (am) author = am[1].trim();

  content.find(
    '.page-rate-widget-box, .creditRate, .rate-box-with-credit-button, .credit-rate, ' +
      '.footer-wikiwalk-nav, .licensebox, script, style, .modal-wrapper, .info-container, ' +
      '.creditButton, .credit-button, .anom-bar-container',
  ).remove();

  content.find('.collapsible-block').each((_, el) => {
    const block = $(el);
    const label = block.find('.collapsible-block-folded .collapsible-block-link').first().text()
      .replace(/\u00a0/g, ' ').replace(/^[+\-\s▸►]+/, '').trim() || 'Xem thêm';
    const inner = block.find('.collapsible-block-content').first().html() ?? '';
    block.replaceWith(`<details><summary>${label}</summary>${inner}</details>`);
  });

  content.find('.yui-navset').each((_, el) => {
    const nav = $(el);
    const titles = nav.find('.yui-nav li').map((_, li) => $(li).text().trim()).get();
    const panes = nav.find('.yui-content > div').map((_, d) => $(d).html() ?? '').get();
    const merged = panes.map((p, i) => `<h3>${titles[i] ?? ''}</h3><div>${p}</div>`).join('');
    nav.replaceWith(`<div>${merged}</div>`);
  });

  content.find('img').each((_, el) => {
    const img = $(el);
    const src = img.attr('src');
    if (src && src.startsWith('/')) img.attr('src', `${WIKI_BASE}${src}`);
  });

  const KEEP = new Set(['href', 'src', 'alt', 'colspan', 'rowspan']);
  content.find('*').each((_, el) => {
    const node = $(el);
    const attrs = { ...(el.attribs ?? {}) };
    for (const [name, value] of Object.entries(attrs)) {
      if (KEEP.has(name)) continue;
      if (name === 'style') {
        const align = /text-align\s*:\s*(left|right|center|justify)/i.exec(value);
        if (align) node.attr('style', `text-align: ${align[1].toLowerCase()}`);
        else node.removeAttr('style');
        continue;
      }
      node.removeAttr(name);
    }
    const href = node.attr('href');
    if (href && href.startsWith('javascript:')) node.removeAttr('href');
  });

  content.find('div, span, p').each((_, el) => {
    const node = $(el);
    if (!node.text().trim() && !node.find('img, hr, br, table').length) node.remove();
  });

  const text = content.text();
  let objectClass = tags.find((t) => OBJECT_CLASS_TAGS.includes(t)) ?? null;
  const cm = /Object Class:\s*([A-Za-z\-]+)/.exec(text) || /Containment Class:\s*([A-Za-z\-]+)/i.exec(text);
  if (cm) objectClass = cm[1].toLowerCase();

  const htmlEn = content.html().replace(/\n{2,}/g, '\n').trim();
  return { htmlEn, tags, author, objectClass };
}

async function crawlArticles(items) {
  let done = 0;
  for (const item of items) {
    const file = path.join(RAW_DIR, `${item.id}.json`);
    done++;
    if (fs.existsSync(file) && !args.force) continue;
    const url = `${WIKI_BASE}/${item.id}`;
    try {
      const html = await fetchText(url);
      if (!html) {
        console.warn(`[${done}/${items.length}] ${item.id}: không tồn tại`);
        continue;
      }
      const cleaned = cleanArticle(html);
      if (!cleaned || !cleaned.htmlEn) {
        console.warn(`[${done}/${items.length}] ${item.id}: không có nội dung`);
        continue;
      }
      writeJson(file, {
        id: item.id,
        number: item.number,
        series: item.series,
        titleEn: item.title,
        url,
        author: cleaned.author,
        objectClass: cleaned.objectClass,
        tags: cleaned.tags,
        htmlEn: cleaned.htmlEn,
      });
      console.log(`[${done}/${items.length}] ${item.id} OK (${cleaned.htmlEn.length} ký tự)`);
    } catch (err) {
      console.error(`[${done}/${items.length}] ${item.id}: ${err.message}`);
    }
    await sleep(DELAY_MS);
  }
}

const seriesList = parseSeries(args.series);
let index = readJson(INDEX_FILE, []);
const missing = seriesList.some((s) => !index.some((e) => e.series === s));
if (args['refresh-index'] || missing) index = await buildIndex(seriesList);

if (!args['index-only']) {
  const items = filterIndex(index, args);
  console.log(`Sẽ tải ${items.length} bài...`);
  await crawlArticles(items);
}
console.log('Xong.');

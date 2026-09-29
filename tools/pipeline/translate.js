// Dịch các bài đã crawl sang tiếng Việt bằng Ollama chạy local.
//
//   node translate.js --series 1
//   node translate.js --only scp-173 --model qwen2.5:7b
//   node translate.js --series 1 --from 100 --to 199
//
// Bài nào đã có file trong data/vi sẽ được bỏ qua, nên có thể dừng (Ctrl+C) và chạy lại bất cứ lúc nào.
import fs from 'node:fs';
import path from 'node:path';
import * as cheerio from 'cheerio';
import {
  GLOSSARY_FILE, INDEX_FILE, RAW_DIR, VI_DIR, filterIndex, parseArgs, readJson, writeJson,
} from './lib.js';

const args = parseArgs();
const OLLAMA = (args.host ?? process.env.OLLAMA_URL ?? 'http://127.0.0.1:11434').replace(/\/$/, '');
const MODEL = args.model ?? process.env.OLLAMA_MODEL ?? 'qwen2.5:7b';
const TITLE_MODEL = args['title-model'] ?? process.env.OLLAMA_TITLE_MODEL ?? 'gemma3:4b';
const MAX_CHUNK = Number(args.chunk ?? 1400);
const NUM_CTX = Number(args.ctx ?? 4096);

const glossary = readJson(GLOSSARY_FILE, {});
const glossaryText = Object.entries(glossary).map(([en, vi]) => `- ${en} => ${vi}`).join('\n');

const SYSTEM_PROMPT = `Bạn là dịch giả của Tổ Chức SCP chi nhánh Tiếng Việt (scp-vn.wikidot.com).
Nhiệm vụ: dịch đoạn HTML tiếng Anh sang tiếng Việt theo văn phong của SCP-VN.

Quy tắc bắt buộc:
1. Văn phong hồ sơ khoa học, lạnh lùng, trang trọng, khách quan như tài liệu mật. Câu văn tự nhiên, đúng ngữ pháp tiếng Việt, không dịch word-by-word.
2. GIỮ NGUYÊN toàn bộ thẻ HTML, thuộc tính (href, src...) và cấu trúc. Chỉ dịch phần chữ hiển thị.
3. Giữ nguyên mã định danh: SCP-173, D-9341, O5-7, SCP-096-1, các con số, đơn vị đo, tên riêng người.
4. Tên phân loại vật thể (Safe, Euclid, Keter, Thaumiel, Apollyon...) giữ nguyên tiếng Anh.
5. Dùng đúng bảng thuật ngữ dưới đây. "Dr. X" dịch thành "Ts. X". "Site-XX" dịch thành "Điểm-XX".
6. Trong nhật ký phỏng vấn/thí nghiệm, lời thoại dịch tự nhiên theo tính cách nhân vật; nhãn người nói giữ nguyên dạng.
7. Chỉ viết bằng chữ tiếng Việt (Latin có dấu). TUYỆT ĐỐI không dùng chữ Hán, Nhật, Hàn. Không để sót từ tiếng Anh thông thường.
8. CHỈ trả về HTML đã dịch. Không giải thích, không thêm lời mở đầu, không bọc trong \`\`\`.

Bảng thuật ngữ (tiếng Anh => tiếng Việt):
${glossaryText}`;

async function ollamaChat(messages, { temperature = 0.2, model = MODEL } = {}) {
  const res = await fetch(`${OLLAMA}/api/chat`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      model,
      messages,
      stream: false,
      keep_alive: '30m',
      think: false,
      options: { temperature, num_ctx: NUM_CTX, num_predict: 2048 },
    }),
  });
  if (!res.ok) throw new Error(`Ollama HTTP ${res.status}: ${await res.text()}`);
  const data = await res.json();
  return data.message?.content ?? '';
}

function stripWrapper(text) {
  let t = text.trim();
  t = t.replace(/^```(?:html)?\s*/i, '').replace(/```\s*$/i, '').trim();
  t = t.replace(/^(Here is|Dưới đây là|Bản dịch)[^<]*:\s*/i, '');
  return t;
}

const countTags = (html) => (html.match(/<[a-z][^>]*>/gi) ?? []).length;
const textOf = (html) => cheerio.load(html, null, false).text();
const hasLetters = (html) => /[A-Za-z]{2,}/.test(textOf(html));
const CJK = /[\u3040-\u30ff\u3400-\u9fff\uac00-\ud7af\uff00-\uffef]/g;

/** Từ tiếng Anh viết thường, dài, không có trong glossary giữ nguyên: gần như chắc chắn là sót chưa dịch. */
function leftoverEnglish(sourceText, outText) {
  const src = new Set((sourceText.match(/\b[a-z]{7,}\b/g) ?? []));
  return [...new Set(outText.match(/\b[a-z]{7,}\b/g) ?? [])].filter((w) => src.has(w));
}

function assess(html, out) {
  const issues = [];
  let score = 0;
  const expected = countTags(html);
  const got = countTags(out);
  if (expected === 0 ? got > 2 : Math.abs(got - expected) > Math.max(1, expected * 0.15)) {
    issues.push('Giữ nguyên đúng các thẻ HTML như bản gốc.');
    score += 100;
  }
  if (out.length < html.length * 0.4 || out.length > html.length * 3) score += 100;
  const text = textOf(out);
  const cjk = text.match(CJK) ?? [];
  if (cjk.length) {
    issues.push(`Không được dùng chữ Trung/Nhật/Hàn (đã có: ${[...new Set(cjk)].join('')}).`);
    score += 50 + cjk.length;
  }
  const left = leftoverEnglish(textOf(html), text);
  if (left.length) {
    issues.push(`Dịch nốt các từ tiếng Anh còn sót: ${left.join(', ')}.`);
    score += 10 * left.length;
  }
  return { score, issues };
}

async function translateWithChecks(userContent, source, clean = (s) => s) {
  let best = null;
  let feedback = [];
  for (let attempt = 0; attempt < 3; attempt++) {
    const messages = [
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: userContent },
    ];
    if (feedback.length && best) {
      messages.push({ role: 'assistant', content: best.out });
      messages.push({ role: 'user', content: `Bản dịch trên có lỗi. ${feedback.join(' ')} Hãy dịch lại toàn bộ, chỉ trả về kết quả.` });
    }
    const out = clean(stripWrapper(await ollamaChat(messages, { temperature: attempt === 0 ? 0.2 : 0.35 })));
    if (!out) continue;
    const { score, issues } = assess(source, out);
    if (!best || score < best.score) best = { out, score };
    if (score === 0) break;
    feedback = issues;
  }
  if (!best) return null;
  return best.out.replace(CJK, '');
}

async function translateHtml(html) {
  if (!hasLetters(html)) return html;
  return (await translateWithChecks(html, html)) ?? html;
}

const TITLE_SYSTEM = `Bạn đặt tên tiếng Việt cho hồ sơ SCP theo phong cách SCP-VN: ngắn gọn, tự nhiên, giữ sắc thái (bí ẩn, mỉa mai, chơi chữ) của bản gốc. Chỉ dùng chữ Việt, không chữ Hán. Chỉ trả về đúng một dòng tiêu đề.
Ví dụ:
- "Skeleton Key" => Chìa Khóa Vạn Năng
- "The Plague Doctor" => Bác Sĩ Dịch Hạch
- "Hard-To-Destroy Reptile" => Loài Bò Sát Khó Tiêu Diệt
- "The Old Man" => Ông Lão
- "Red Ice" => Băng Đỏ
- "Collars of Control" => Vòng Cổ Khống Chế`;

async function translateTitle(title, contextText) {
  if (!title) return '';
  const prompt = `Tiêu đề gốc: "${title}"\nNgữ cảnh (trích hồ sơ): ${contextText.slice(0, 700)}\n\nTiêu đề tiếng Việt:`;
  const clean = (s) =>
    s.split('\n')[0].replace(/^(Tiêu đề tiếng Việt:)\s*/i, '').replace(/^["“'«]+|["”'»]+$/g, '').trim();
  let best = title;
  for (let attempt = 0; attempt < 3; attempt++) {
    const out = clean(stripWrapper(await ollamaChat(
      [{ role: 'system', content: TITLE_SYSTEM }, { role: 'user', content: prompt }],
      { temperature: 0.3 + attempt * 0.15, model: TITLE_MODEL },
    )));
    const bad = !out || CJK.test(out) || /[\/\\]/.test(out) || out.length > title.length * 3 + 20;
    CJK.lastIndex = 0;
    if (!bad) return out;
  }
  return best;
}

/** Dịch nội dung của một container theo từng nhóm phần tử anh em có tổng độ dài <= MAX_CHUNK. */
async function translateContainer($, container, progress) {
  const children = $(container).contents().toArray();
  let group = [];
  let size = 0;

  const flush = async () => {
    if (!group.length) return;
    const html = group.map((n) => $.html(n)).join('');
    const vi = await translateHtml(html);
    $(group[0]).before(vi);
    for (const n of group) $(n).remove();
    progress.done += html.length;
    process.stdout.write(`\r   ${Math.min(100, Math.round((progress.done / progress.total) * 100))}%   `);
    group = [];
    size = 0;
  };

  for (const child of children) {
    const len = $.html(child).length;
    const splittable = child.type === 'tag' && $(child).children().length > 1;
    if (len > MAX_CHUNK && splittable) {
      await flush();
      await translateContainer($, child, progress);
      continue;
    }
    if (size + len > MAX_CHUNK) await flush();
    group.push(child);
    size += len;
  }
  await flush();
}

async function translateArticle(raw) {
  const $ = cheerio.load(`<div id="root">${raw.htmlEn}</div>`, null, false);
  const root = $('#root')[0];
  const progress = { done: 0, total: raw.htmlEn.length || 1 };
  await translateContainer($, root, progress);
  process.stdout.write('\n');
  const context = textOf(raw.htmlEn).replace(/\s+/g, ' ');
  const descAt = context.search(/Description:/i);
  const titleVi = await translateTitle(raw.titleEn, descAt >= 0 ? context.slice(descAt) : context);
  return { titleVi, htmlVi: $('#root').html() };
}

async function checkOllama() {
  try {
    const res = await fetch(`${OLLAMA}/api/tags`);
    const data = await res.json();
    const names = (data.models ?? []).map((m) => m.name);
    for (const model of new Set([MODEL, TITLE_MODEL])) {
      if (!names.some((n) => n === model || n === `${model}:latest`)) {
        console.error(`Chưa có model "${model}". Chạy: ollama pull ${model}`);
        process.exit(1);
      }
    }
  } catch {
    console.error(`Không kết nối được Ollama tại ${OLLAMA}. Hãy mở Ollama rồi chạy lại.`);
    process.exit(1);
  }
}

await checkOllama();
const index = readJson(INDEX_FILE, []);

if (args['titles-only']) {
  const targets = filterIndex(index, args).filter((e) => fs.existsSync(path.join(VI_DIR, `${e.id}.json`)));
  for (const item of targets) {
    const raw = readJson(path.join(RAW_DIR, `${item.id}.json`));
    const viFile = path.join(VI_DIR, `${item.id}.json`);
    const vi = readJson(viFile);
    const context = textOf(raw.htmlEn).replace(/\s+/g, ' ');
    const descAt = context.search(/Description:/i);
    vi.titleVi = await translateTitle(raw.titleEn, descAt >= 0 ? context.slice(descAt) : context);
    writeJson(viFile, vi);
    console.log(`${item.id.toUpperCase()}: "${raw.titleEn}" => "${vi.titleVi}"`);
  }
  process.exit(0);
}
const items = filterIndex(index, args).filter((e) => fs.existsSync(path.join(RAW_DIR, `${e.id}.json`)));
const todo = items.filter((e) => args.force || !fs.existsSync(path.join(VI_DIR, `${e.id}.json`)));
console.log(`Model: ${MODEL} (tiêu đề: ${TITLE_MODEL}) | Đã crawl: ${items.length} | Cần dịch: ${todo.length}`);

let n = 0;
for (const item of todo) {
  n++;
  const raw = readJson(path.join(RAW_DIR, `${item.id}.json`));
  const started = Date.now();
  console.log(`[${n}/${todo.length}] ${item.id.toUpperCase()} - ${raw.titleEn}`);
  try {
    const { titleVi, htmlVi } = await translateArticle(raw);
    writeJson(path.join(VI_DIR, `${item.id}.json`), {
      id: item.id,
      titleVi,
      htmlVi,
      model: MODEL,
      translatedAt: new Date().toISOString(),
    });
    console.log(`   => "${titleVi}" (${Math.round((Date.now() - started) / 1000)}s)`);
  } catch (err) {
    console.error(`   Lỗi: ${err.message}`);
  }
}
console.log('Xong.');

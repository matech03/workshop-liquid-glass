// Dựng file pptx từ src/content.mjs bằng shape và text box gốc của PowerPoint (không chụp ảnh HTML),
// để chữ tự xuống dòng đúng và sửa được trực tiếp trong PowerPoint / Keynote.
//   cd tools && npm install && node build-pptx.mjs
import { writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import PptxGenJS from 'pptxgenjs';
import JSZip from 'jszip';
import { TITLE, SECTIONS, SLIDES, NOTES } from '../src/content.mjs';

const root = fileURLToPath(new URL('..', import.meta.url));
const OUT = 'Trai-nghiem-Liquid-Glass.pptx';
const CHROME = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome';

// Nền bìa cần backdrop-filter nên chụp từ HTML; mọi phần còn lại là shape và chữ gốc
function coverArt() {
  const png = '/tmp/lg-cover-art.png';
  execFileSync(CHROME, ['--headless=new', '--hide-scrollbars', '--force-device-scale-factor=2', '--window-size=700,1080',
    `--screenshot=${png}`, `file://${root}tools/cover-art.html`], { stdio: 'ignore' });
  return png;
}

// Bảng màu theme sáng; màu nhấn đổi theo level
const C = {
  bg: 'F6F7FA', paper: 'FFFFFF', ink: '12151C', ink2: '2A303C', mute: '5D6576', dim: '8C94A4',
  line: 'E3E6EC', code: 'EEF1F6', warn: 'A64B00', warnBg: 'FFF3E2', soft: 'E8EEFF',
};
const ACCENT = { 0: '2457F5', 1: '2457F5', 2: '0B8F7C', 3: 'D9640A', 4: 'C92A6A' };
const F = { display: 'Bricolage Grotesque 96pt', displaySemi: 'Bricolage Grotesque 96pt SemiBold',
  body: 'Be Vietnam Pro', bodyMed: 'Be Vietnam Pro Medium', bodySemi: 'Be Vietnam Pro SemiBold', mono: 'JetBrains Mono' };

// Khung 13,333 × 7,5 in
const M = 0.62;                 // lề trái/phải
const COL_L = { x: M, w: 7.15 };   // cột nội dung
const COL_R = { x: 8.35, w: 4.36 }; // cột 3 card
const TOP = 0.95, BOTTOM = 6.85;

// `code` và **đậm** thành các run của pptxgenjs
function runs(text, base) {
  const out = [];
  for (const part of text.split(/(`[^`]+`|\*\*[^*]+\*\*|\^[^^]+\^)/)) {
    if (!part) continue;
    if (part.startsWith('`')) out.push({ text: part.slice(1, -1), options: { ...base, fontFace: F.mono, fontSize: base.fontSize * 0.86, color: base.codeColor ?? base.color, highlight: base.codeBg ?? C.code } });
    else if (part.startsWith('**')) out.push({ text: part.slice(2, -2), options: { ...base, fontFace: F.bodySemi, color: base.strongColor ?? C.ink } });
    else if (part.startsWith('^')) out.push({ text: part.slice(1, -1), options: { ...base, superscript: true } });
    else out.push({ text: part, options: base });
  }
  return out.map(r => { const { codeColor, codeBg, strongColor, ...o } = r.options; return { text: r.text, options: o }; });
}

// Ước lượng số dòng để xếp các khối từ trên xuống mà không chồng nhau
function lines(text, widthIn, pt, perEm = 0.5) {
  const plain = text.replace(/[`*^]/g, '');
  const perLine = Math.max(8, Math.floor((widthIn * 72) / (pt * perEm)));
  return plain.split('\n').reduce((n, l) => n + Math.max(1, Math.ceil(l.length / perLine)), 0);
}
const lh = pt => (pt * 1.32) / 72;

function rail(slide, sec, demo, accent) {
  slide.addText('Liquid Glass · Level by Level', { x: M, y: 0.32, w: 4, h: 0.3, fontFace: F.mono, fontSize: 10, color: C.mute, margin: 0 });
  const items = SECTIONS.map((s, i) => ({ text: (i ? '   ' : '') + s, options: { color: s === sec ? accent : C.dim, fontFace: s === sec ? F.bodySemi : F.body } }));
  slide.addText(items, { x: 4.4, y: 0.32, w: 7.0, h: 0.3, fontSize: 10, align: 'right', margin: 0 });
  // Khoá màn hình demo trong app (`-demo KEY`)
  if (demo) {
    slide.addShape('roundRect', { x: 11.6, y: 0.27, w: 1.11, h: 0.36, rectRadius: 0.08, fill: { color: accent }, line: { type: 'none' } });
    slide.addText(`DEMO ${demo}`, { x: 11.6, y: 0.27, w: 1.11, h: 0.36, fontFace: F.mono, fontSize: 10, color: 'FFFFFF', align: 'center', valign: 'middle', margin: 0 });
  }
}

function levelBar(slide, level) {
  // 4 ô ở chân slide: level hiện tại tô màu, các level trước đậm hơn các level sau
  const names = ['Phản hồi chạm', 'Chuyển trạng thái', 'Chuyển động vật lý', 'Biến dạng tại điểm chạm'];
  const w = 2.6, gap = 0.12;
  names.forEach((name, i) => {
    const on = i + 1 === level, done = i + 1 < level;
    const x = M + i * (w + gap);
    slide.addShape('rect', { x, y: 7.0, w, h: 0.05, fill: { color: on ? ACCENT[i + 1] : done ? 'C9CED8' : C.line }, line: { type: 'none' } });
    slide.addText([{ text: `LEVEL ${i + 1}  `, options: { fontFace: F.mono, bold: false } }, { text: name, options: { fontFace: on ? F.bodySemi : F.body } }],
      { x, y: 7.08, w, h: 0.26, fontSize: 9, color: on ? ACCENT[i + 1] : C.dim, margin: 0 });
  });
}

function cards(slide, list, accent) {
  const gap = 0.22, h = (BOTTOM - TOP - 0.6 - gap * 2) / 3;
  list.forEach(([key, text], i) => {
    const y = TOP + 0.3 + i * (h + gap);
    slide.addShape('roundRect', { x: COL_R.x, y, w: COL_R.w, h, rectRadius: 0.16, fill: { color: C.paper }, line: { color: C.line, width: 0.75 },
      shadow: { type: 'outer', color: '1C2433', opacity: 0.08, blur: 10, offset: 3, angle: 90 } });
    slide.addShape('rect', { x: COL_R.x, y: y + 0.22, w: 0.07, h: h - 0.44, fill: { color: accent }, line: { type: 'none' } });
    slide.addText(key, { x: COL_R.x + 0.32, y: y + 0.24, w: COL_R.w - 0.55, h: 0.42, fontFace: F.mono, fontSize: key.length > 30 ? 11.5 : key.length > 24 ? 13 : 15, color: accent, margin: 0, valign: 'top', fit: 'shrink' });
    slide.addText(runs(text, { fontFace: F.body, fontSize: 14, color: C.ink2 }), { x: COL_R.x + 0.32, y: y + 0.7, w: COL_R.w - 0.55, h: h - 0.88, margin: 0, valign: 'top', lineSpacingMultiple: 1.15 });
  });
}

function content(slide, s, accent) {
  const w = COL_L.w, x = COL_L.x;
  const blocks = [];
  blocks.push(['kicker', 0.32]);
  const titlePt = 34, titleH = lines(s.title, w, titlePt, 0.48) * lh(titlePt) * 0.88 + 0.08;
  blocks.push(['title', titleH]);
  const sumPt = 16, sumH = lines(s.sum, w - 0.3, sumPt) * lh(sumPt) + 0.2;
  blocks.push(['sum', sumH]);
  if (s.formula) blocks.push(['formula', 0.5]);
  if (s.table) blocks.push(['table', 0.38 * (s.table.rows.length + 1)]);
  if (s.steps) blocks.push(['steps', s.steps.reduce((t, l) => t + Math.max(0.4, lines(l, w - 0.6, 15) * lh(15) + 0.1), 0)]);
  if (s.bullets) blocks.push(['bullets', s.bullets.reduce((t, l) => t + lines(l, w - 0.35, 14) * lh(14) + 0.08, 0)]);
  if (s.trap) blocks.push(['trap', lines(s.trap, w - 1.2, 13) * lh(13) + 0.3]);
  if (s.quote) blocks.push(['quote', 0.75]);

  const gap = 0.24;
  const total = blocks.reduce((t, [, h]) => t + h, 0) + gap * (blocks.length - 1);
  let y = Math.max(TOP, TOP + (BOTTOM - TOP - total) / 2);

  for (const [kind, h] of blocks) {
    if (kind === 'kicker') slide.addText(s.kicker.toUpperCase(), { x, y, w, h, fontFace: F.mono, fontSize: 11, color: accent, charSpacing: 1.5, margin: 0, valign: 'middle' });
    if (kind === 'title') slide.addText(runs(s.title, { fontFace: F.display, fontSize: titlePt, bold: true, color: C.ink, codeColor: accent, codeBg: C.bg }),
      { x, y, w, h, margin: 0, valign: 'top', lineSpacingMultiple: 0.95, fit: 'shrink' });
    if (kind === 'sum') {
      slide.addShape('rect', { x, y, w: 0.06, h, fill: { color: accent }, line: { type: 'none' } });
      slide.addText(runs(s.sum, { fontFace: F.bodyMed, fontSize: sumPt, color: C.ink2 }), { x: x + 0.24, y, w: w - 0.24, h, margin: 0, valign: 'middle', lineSpacingMultiple: 1.2 });
    }
    if (kind === 'formula') {
      slide.addShape('roundRect', { x, y, w, h, rectRadius: 0.1, fill: { color: C.paper }, line: { color: C.line, width: 1 } });
      slide.addText(runs(s.formula, { fontFace: F.mono, fontSize: 15, color: C.ink }), { x: x + 0.2, y, w: w - 0.4, h, margin: 0, valign: 'middle' });
    }
    if (kind === 'table') {
      const [head, ...rows] = [s.table.head, ...s.table.rows];
      slide.addTable([
        head.map(t => ({ text: t.toUpperCase(), options: { fontFace: F.mono, fontSize: 9, color: C.mute, fill: { color: 'EEF1F6' } } })),
        ...rows.map(r => r.map((t, i) => ({ text: t, options: { fontFace: i ? F.mono : F.displaySemi, fontSize: i ? 12 : 16, color: i ? C.dim : C.ink, fill: { color: C.paper } } }))),
      ], { x, y, w, colW: [1.6, 1.85, 1.85, 1.85], rowH: 0.38, border: { type: 'solid', color: C.line, pt: 0.75 }, valign: 'middle', margin: [0, 0.12, 0, 0.12] });
    }
    if (kind === 'steps') {
      let yy = y;
      s.steps.forEach((t, i) => {
        const hh = Math.max(0.4, lines(t, w - 0.6, 15) * lh(15) + 0.1);
        slide.addShape('ellipse', { x, y: yy + (hh - 0.32) / 2, w: 0.32, h: 0.32, fill: { color: accent }, line: { type: 'none' } });
        slide.addText(String(i + 1), { x, y: yy + (hh - 0.32) / 2, w: 0.32, h: 0.32, fontFace: F.mono, fontSize: 11, color: 'FFFFFF', align: 'center', valign: 'middle', margin: 0 });
        slide.addText(runs(t, { fontFace: F.body, fontSize: 15, color: C.ink2 }), { x: x + 0.48, y: yy, w: w - 0.48, h: hh, margin: 0, valign: 'middle' });
        yy += hh;
      });
    }
    if (kind === 'bullets') {
      let yy = y;
      for (const t of s.bullets) {
        const hh = lines(t, w - 0.35, 14) * lh(14) + 0.08;
        slide.addShape('rect', { x: x + 0.04, y: yy + 0.1, w: 0.09, h: 0.09, fill: { color: accent }, line: { type: 'none' } });
        slide.addText(runs(t, { fontFace: F.body, fontSize: 14, color: C.ink2 }), { x: x + 0.3, y: yy, w: w - 0.3, h: hh, margin: 0, valign: 'top' });
        yy += hh;
      }
    }
    if (kind === 'trap') {
      slide.addShape('roundRect', { x, y, w, h, rectRadius: 0.1, fill: { color: C.warnBg }, line: { type: 'none' } });
      slide.addShape('roundRect', { x: x + 0.18, y: y + 0.15, w: 0.62, h: 0.28, rectRadius: 0.06, fill: { color: C.warn }, line: { type: 'none' } });
      slide.addText('BẪY', { x: x + 0.18, y: y + 0.15, w: 0.62, h: 0.28, fontFace: F.mono, fontSize: 10, color: 'FFFFFF', align: 'center', valign: 'middle', margin: 0 });
      slide.addText(runs(s.trap, { fontFace: F.body, fontSize: 13, color: C.warn, codeColor: C.warn, codeBg: 'FBE6CC', strongColor: C.warn }),
        { x: x + 0.98, y: y + 0.12, w: w - 1.15, h: h - 0.24, margin: 0, valign: 'middle' });
    }
    if (kind === 'quote') {
      slide.addShape('roundRect', { x, y, w, h, rectRadius: 0.12, fill: { color: C.soft }, line: { type: 'none' } });
      slide.addText(`“${s.quote}”`, { x: x + 0.3, y, w: w - 0.6, h, fontFace: F.display, bold: true, fontSize: 20, color: C.ink, margin: 0, valign: 'middle' });
    }
    y += h + gap;
  }
}

function cover(slide, s) {
  slide.background = { color: C.paper };
  slide.addImage({ path: coverArt(), x: 8.47, y: 0, w: 4.863, h: 7.5 });
  slide.addText(s.eyebrow.toUpperCase(), { x: 0.85, y: 1.45, w: 7, h: 0.3, fontFace: F.mono, fontSize: 12, color: C.mute, charSpacing: 3, margin: 0 });
  slide.addText([{ text: 'Trải nghiệm người dùng xuất sắc với ', options: { color: C.ink, breakLine: false } }, { text: 'Liquid Glass', options: { color: ACCENT[0] } }],
    { x: 0.85, y: 1.9, w: 7.3, h: 2.6, fontFace: F.display, bold: true, fontSize: 52, margin: 0, valign: 'top', lineSpacingMultiple: 0.95 });
  slide.addText(s.lead, { x: 0.85, y: 4.6, w: 6.8, h: 0.9, fontFace: F.body, fontSize: 19, color: C.mute, margin: 0, valign: 'top' });
  let x = 0.85;
  for (const m of s.meta) {
    const w = 0.3 + m.length * 0.105;
    slide.addShape('roundRect', { x, y: 5.75, w, h: 0.4, rectRadius: 0.08, fill: { color: C.bg }, line: { color: C.line, width: 0.75 } });
    slide.addText(m, { x, y: 5.75, w, h: 0.4, fontFace: F.mono, fontSize: 11, color: C.ink2, align: 'center', valign: 'middle', margin: 0 });
    x += w + 0.14;
  }
}

function levelIntro(slide, s) {
  const a = ACCENT[s.level];
  slide.background = { color: C.paper };
  slide.addShape('rect', { x: 0, y: 0, w: 0.22, h: 7.5, fill: { color: a }, line: { type: 'none' } });
  slide.addShape('ellipse', { x: M, y: 1.35, w: 1.25, h: 1.25, fill: { color: a }, line: { type: 'none' } });
  slide.addText(String(s.level), { x: M, y: 1.35, w: 1.25, h: 1.25, fontFace: F.display, bold: true, fontSize: 48, color: 'FFFFFF', align: 'center', valign: 'middle', margin: 0 });
  slide.addText(`LEVEL ${s.level} / 4`, { x: M + 1.5, y: 1.42, w: 5.5, h: 0.35, fontFace: F.mono, fontSize: 13, color: a, charSpacing: 3, margin: 0 });
  slide.addText(s.title, { x: M + 1.5, y: 1.8, w: 5.95, h: 0.8, fontFace: F.display, bold: true, fontSize: 33, color: C.ink, margin: 0, valign: 'top', fit: 'shrink' });
  slide.addShape('rect', { x: M, y: 3.0, w: 0.06, h: 0.95, fill: { color: a }, line: { type: 'none' } });
  slide.addText(runs(s.sum, { fontFace: F.bodyMed, fontSize: 17, color: C.ink2 }), { x: M + 0.24, y: 3.0, w: 6.9, h: 0.95, margin: 0, valign: 'middle' });
  slide.addText('NỘI DUNG', { x: M, y: 4.25, w: 6, h: 0.3, fontFace: F.mono, fontSize: 10, color: C.mute, charSpacing: 1.5, margin: 0 });
  s.steps.forEach((t, i) => {
    const y = 4.65 + i * 0.46;
    slide.addShape('ellipse', { x: M, y: y + 0.04, w: 0.3, h: 0.3, fill: { color: a }, line: { type: 'none' } });
    slide.addText(String(i + 1), { x: M, y: y + 0.04, w: 0.3, h: 0.3, fontFace: F.mono, fontSize: 10, color: 'FFFFFF', align: 'center', valign: 'middle', margin: 0 });
    slide.addText(t, { x: M + 0.46, y, w: 6.6, h: 0.38, fontFace: F.body, fontSize: 15, color: C.ink2, margin: 0, valign: 'middle' });
  });
  cards(slide, s.cards, a);
}

function end(slide, s) {
  slide.background = { color: C.bg };
  slide.addShape('rect', { x: 6.17, y: 2.6, w: 1.0, h: 0.08, fill: { color: ACCENT[0] }, line: { type: 'none' } });
  slide.addText(s.title, { x: 1, y: 2.95, w: 11.33, h: 1.2, fontFace: F.display, bold: true, fontSize: 56, color: C.ink, align: 'center', margin: 0 });
  slide.addText(runs(s.lead, { fontFace: F.body, fontSize: 18, color: C.mute }), { x: 0.8, y: 4.3, w: 11.73, h: 0.6, align: 'center', margin: 0 });
}

function notesText(id) {
  const n = NOTES[id] ?? {};
  const plain = t => t.replace(/[`*]/g, '').replace(/\^/g, '');
  const sec = (label, items) => items?.length ? `${label}\n${items.map(i => `• ${plain(i)}`).join('\n')}` : '';
  return [[n.time, n.mode].filter(Boolean).join(' · '), sec('NÓI', n.say), sec('LÀM', n.do), sec('BẪY', n.trap), n.files && `XCODE\n${n.files.join(', ')}`]
    .filter(Boolean).join('\n\n');
}

// pptxgenjs ghi notes vào một <a:t> chứa "\n"; tách thành mỗi dòng một đoạn để PowerPoint và Keynote hiển thị đúng
async function splitNotes(buffer) {
  const zip = await JSZip.loadAsync(buffer);
  const body = /(<p:ph type="body" idx="1"\/>[\s\S]*?<p:txBody><a:bodyPr\/><a:lstStyle\/>)([\s\S]*?)(<\/p:txBody>)/;
  for (const name of Object.keys(zip.files).filter(n => /^ppt\/notesSlides\/notesSlide\d+\.xml$/.test(n))) {
    const xml = await zip.file(name).async('string');
    zip.file(name, xml.replace(body, (_, head, paras, tail) => {
      const text = [...paras.matchAll(/<a:t>([\s\S]*?)<\/a:t>/g)].map(m => m[1]).join('');
      const lines = text.split(/\r?\n/).map(line => line
        ? `<a:p><a:r><a:rPr lang="vi-VN" dirty="0"/><a:t>${line}</a:t></a:r></a:p>`
        : '<a:p><a:endParaRPr lang="vi-VN" dirty="0"/></a:p>');
      return head + lines.join('') + tail;
    }));
  }
  return zip.generateAsync({ type: 'nodebuffer', compression: 'DEFLATE' });
}

const pptx = new PptxGenJS();
pptx.layout = 'LAYOUT_WIDE';
pptx.title = TITLE;
pptx.subject = '4 level Liquid Glass, tích hợp, performance, lưu ý';

for (const s of SLIDES) {
  const slide = pptx.addSlide();
  const accent = ACCENT[s.level ?? 0];
  if (s.kind === 'cover') cover(slide, s);
  else if (s.kind === 'end') end(slide, s);
  else {
    slide.background = { color: s.kind === 'level' ? C.paper : C.bg };
    if (s.kind === 'level') levelIntro(slide, s);
    else { content(slide, s, accent); cards(slide, s.cards, accent); }
    rail(slide, s.sec, s.demo, accent);
    if (s.level) levelBar(slide, s.level);
  }
  slide.addNotes(notesText(s.id));
}

writeFileSync(root + OUT, await splitNotes(await pptx.write({ outputType: 'nodebuffer' })));
console.log(`${OUT}: ${SLIDES.length} slide`);

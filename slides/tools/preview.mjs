// Render từng slide của file pptx thành PNG bằng Quick Look (qlmanage) để kiểm tra mà không cần PowerPoint.
// Quick Look chỉ vẽ slide đầu tiên, nên với mỗi slide: đưa slide đó lên đầu danh sách rồi chụp.
//   node preview.mjs ../Trai-nghiem-Liquid-Glass.pptx /tmp/preview
import { readFileSync, writeFileSync, mkdirSync, renameSync, rmSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import JSZip from 'jszip';

const [file, out = '/tmp/preview'] = process.argv.slice(2);
rmSync(out, { recursive: true, force: true });
mkdirSync(out, { recursive: true });
const zip = await JSZip.loadAsync(readFileSync(file));
const xml = await zip.file('ppt/presentation.xml').async('string');
const ids = [...xml.matchAll(/<p:sldId [^>]*\/>/g)].map(m => m[0]);
for (const [i, id] of ids.entries()) {
  const order = [id, ...ids.filter(x => x !== id)].join('');
  zip.file('ppt/presentation.xml', xml.replace(/(<p:sldIdLst>)[\s\S]*?(<\/p:sldIdLst>)/, `$1${order}$2`));
  const tmp = `${out}/slide.pptx`;
  writeFileSync(tmp, await zip.generateAsync({ type: 'nodebuffer' }));
  execFileSync('qlmanage', ['-t', '-s', '1600', '-o', out, tmp], { stdio: 'ignore' });
  renameSync(`${tmp}.png`, `${out}/${String(i + 1).padStart(2, '0')}.png`);
}
rmSync(`${out}/slide.pptx`, { force: true });
console.log(`${ids.length} slide → ${out}`);

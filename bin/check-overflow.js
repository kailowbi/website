#!/usr/bin/env node
// ビルド済みのサイトの全ページを、スマホ幅で開いて横にはみ出していないか調べる。
// はみ出すと、スマホでページ全体が横スクロールできてしまい読みにくい。
//
// 使い方:
//   bundle exec jekyll build
//   node bin/check-overflow.js [サイトのディレクトリ（省略時は _site）]
//
// playwright が必要（npm install --no-save playwright）。
// はみ出しているページがあれば、原因の要素を表示して終了コード 1 で終わる。

const { chromium } = require('playwright');
const fs = require('fs');
const http = require('http');
const path = require('path');

const root = path.resolve(process.argv[2] || '_site');
// iPhone SE（初代）と iPhone mini の幅
const widths = [320, 375];

const types = { '.html': 'text/html; charset=utf-8', '.css': 'text/css', '.js': 'text/javascript', '.svg': 'image/svg+xml', '.png': 'image/png', '.json': 'application/json' };

function listPages(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((e) => {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) return listPages(p);
    return e.name.endsWith('.html') ? ['/' + path.relative(root, p).split(path.sep).join('/')] : [];
  });
}

const server = http.createServer((req, res) => {
  const file = path.join(root, decodeURIComponent(new URL(req.url, 'http://x').pathname));
  if (!file.startsWith(root) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
    res.writeHead(404).end();
    return;
  }
  res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream' });
  fs.createReadStream(file).pipe(res);
});

(async () => {
  await new Promise((r) => server.listen(0, '127.0.0.1', r));
  const base = `http://127.0.0.1:${server.address().port}`;
  const pages = listPages(root);
  const browser = await chromium.launch();
  let failures = 0;

  for (const width of widths) {
    const page = await browser.newPage({ viewport: { width, height: 800 } });
    // 広告など外部のスクリプトは読み込まない（結果がぶれないように）
    await page.route((url) => !url.href.startsWith(base), (route) => route.abort());

    for (const p of pages) {
      await page.goto(base + p);
      const result = await page.evaluate((width) => {
        const scrollWidth = document.documentElement.scrollWidth;
        if (scrollWidth <= width) return null;
        // 横スクロールできる親（表やコードブロック）の中にある要素は、はみ出しても問題ないので除く
        const scrollsInside = (el) => {
          for (let a = el.parentElement; a; a = a.parentElement) {
            if (['auto', 'scroll', 'hidden'].includes(getComputedStyle(a).overflowX)) return true;
          }
          return false;
        };
        const culprits = [...document.querySelectorAll('body *')]
          .filter((el) => el.getBoundingClientRect().right > width + 1 && !scrollsInside(el))
          .slice(-3)
          .map((el) => `<${el.tagName.toLowerCase()}> ${(el.textContent || '').trim().slice(0, 60)}`);
        return { scrollWidth, culprits };
      }, width);

      if (result) {
        failures++;
        console.log(`NG ${width}px ${p}（ページの幅 ${result.scrollWidth}px）`);
        for (const c of result.culprits) console.log(`   ${c}`);
      }
    }
    await page.close();
  }

  await browser.close();
  server.close();
  console.log(failures ? `\n${failures} 件、横にはみ出しているページがあります` : `OK: ${pages.length} ページとも、${widths.join('px / ')}px で横にはみ出していません`);
  process.exit(failures ? 1 : 0);
})();

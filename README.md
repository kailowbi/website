# website

GitHub Pages(Jekyll)で公開する個人サイト兼ブログです。

## 構成

- `index.md` — トップページ
- `blog.md` — ブログ記事の一覧(`/blog/`)
- `about.md` — About ページ
- `privacy-policy.md` — プライバシーポリシー
- `_posts/` — ブログ記事本体(`YYYY-MM-DD-タイトル.md` の形式)
- `_config.yml` — サイト全体の設定

## 記事の追加方法

`_posts/` に `YYYY-MM-DD-タイトル.md` というファイル名で Markdown ファイルを作成し、先頭に

```yaml
---
title: "記事タイトル"
---
```

を書いてから本文を記述します。`main` ブランチに push すると GitHub Pages が自動でビルド・公開します。

## GitHub Pages の設定(初回のみ・リポジトリ設定画面での手動作業)

1. GitHub のリポジトリ画面 → Settings → Pages を開く
2. "Build and deployment" の Source を `Deploy from a branch` に設定
3. Branch を `main` / `/(root)` に設定して Save

## 独自ドメインを使う場合

1. リポジトリ直下に `CNAME` というファイルを作成し、中身にドメイン名(例: `example.com`)だけを1行書く
2. Route 53 側で、そのドメインの A レコードを GitHub Pages の IP に、`www` サブドメインを使うなら CNAME レコードを `<username>.github.io` に向ける
   (GitHub Pages の最新の IP アドレス・設定手順は https://docs.github.com/pages を参照)
3. Settings → Pages の "Custom domain" にも同じドメインを入力し、"Enforce HTTPS" を有効にする

## ローカルプレビュー(任意)

```bash
gem install bundler jekyll
bundle init
echo 'gem "github-pages", group: :jekyll_plugins' >> Gemfile
bundle install
bundle exec jekyll serve
```

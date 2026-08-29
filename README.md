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

### Markdown エンジンについて

このサイトは Markdown エンジンとして [jekyll-commonmark-ghpages](https://github.com/github/jekyll-commonmark-ghpages)(`commonmarker` 経由で GitHub 本体と同じ `cmark-gfm` を使う)を採用しています。`_config.yml` で `markdown: CommonMarkGhPages` を指定し、`github-pages` gem に含まれる形で利用しています。GitHub の Issue/PR/README、Qiita、Zenn などと同じ GFM(GitHub Flavored Markdown)なので、以下がそのまま書けます。

- 見出しやリストの直後にテーブル・コードブロックを続けて書いても(間に空行がなくても)正しく認識されます。
- テーブル、取り消し線(`~~text~~`)、オートリンク、タスクリスト(`- [ ]` / `- [x]`)が素の記法で使えます。
- 脚注は `[^1]` のように書き、本文末尾に `[^1]: 脚注の内容` を置きます(従来どおり)。
- コードブロックは ```` ```言語名 ```` で始めるとシンタックスハイライト(Rouge)が付きます(例: ```` ```ruby ````)。

一点だけ他の Markdown エンジンとも共通の注意点として、`<key>` のように山括弧 `<...>` を含む文章をそのまま書くと生の HTML タグとみなされ表示から消えてしまうことがあります。地の文で使うときはバッククォートで囲んでコード表記にしてください(例: `` `cmd + <key>` ``)。これは GitHub 本体でも同様の挙動です。

なお、kramdown 固有だった `{:toc}` 記法(自動目次生成)はこのエンジンには存在しないため使えません。

## GitHub Pages の設定(初回のみ・リポジトリ設定画面での手動作業)

1. GitHub のリポジトリ画面 → Settings → Pages を開く
2. "Build and deployment" の Source を `GitHub Actions` に設定(`.github/workflows/jekyll-gh-pages.yml` が `main` への push をトリガーにビルド・デプロイします)

## 独自ドメインを使う場合

1. リポジトリ直下に `CNAME` というファイルを作成し、中身にドメイン名(例: `example.com`)だけを1行書く
2. Route 53 側で、そのドメインの A レコードを GitHub Pages の IP に、`www` サブドメインを使うなら CNAME レコードを `<username>.github.io` に向ける
   (GitHub Pages の最新の IP アドレス・設定手順は https://docs.github.com/pages を参照)
3. Settings → Pages の "Custom domain" にも同じドメインを入力し、"Enforce HTTPS" を有効にする

## ローカルプレビュー(任意)

```bash
gem install bundler
bundle install
bundle exec jekyll serve
```

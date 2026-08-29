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

### Markdown を書くときのコツ(Qiita/Zenn などと違う点)

このサイトは GitHub Pages 標準の Markdown エンジン([kramdown](https://kramdown.gettalong.org/))を使っています。Qiita や Zenn が使っているエンジンよりも記法にやや厳格なので、以下を守るときれいに表示されます。

- **見出し・リストの直後にテーブルやコードブロックを書くときは、間に必ず空行を1行入れる。** 空行がないとテーブルとして認識されず、ただの文章として表示されてしまいます。
- 目次を出したいときは、見出しの下に以下を書く(`{:toc}` の行は独立させ、前後に空行を入れる)。

  ```markdown
  * 目次
  {:toc}
  ```

- 脚注は `[^1]` のように書き、本文末尾に `[^1]: 脚注の内容` を置く。
- コードブロックは ```` ```言語名 ```` で始めるとシンタックスハイライトが付く(例: ```` ```ruby ````)。
- `<key>` のように山括弧 `<...>` を含む文章をそのまま書くと HTML タグとして解釈されてしまうことがあるため、バッククォートで囲んでコード表記にする(例: `` `cmd + <key>` ``)。

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

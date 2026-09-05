---
name: sync-post
description: dotfiles の記事 md を _posts に同期して PR を作成する。「記事を更新」「記事を公開」「sync-post /path/to/file.md」等で使う
---

# 記事同期スキル

dotfiles 等の外部 md ファイルを `_posts/` に同期し、PR を作成する。

## 入力

引数またはユーザーの発言からソース md のパスを取得する。パスが不明なら聞く。

## 前提

- ソースファイル名（.md 除く）= 記事の title
- ソースに frontmatter はない（本文のみ）

## 手順

### 1. 既存記事の検索

ソースファイル名（.md 除く）を title とし、`_posts/` 内の全 `.md` ファイルの frontmatter `title:` と比較する。

- **一致あり**: そのファイルを更新対象にする
- **一致なし**: 新規作成。ファイル名は `YYYY-MM-DD-<slug>.md` 形式で、日付は今日、slug はタイトルから英語で生成する（ユーザーに slug を確認する）

### 2. ファイルの組み立て

frontmatter（`title` のみ）+ ソースの本文全体で構成する。既存記事の場合も frontmatter は `title` だけなので丸ごと上書きする。

```
---
title: "<ソースファイル名(.md除く)>"
---

<ソースの本文>
```

### 3. 差分確認

更新後の内容に実質的な変更がなければ「変更なし」と伝えて終了する。

### 4. ブランチ作成・コミット・PR

```bash
# ブランチ名: update-post/<slug> または new-post/<slug>
git switch -c <branch-name>
git add <_posts/ファイル>
git commit -m "<コミットメッセージ>"
git push -u origin <branch-name>
gh pr create --title "<PRタイトル>" --body "<PR本文>"
```

- コミットメッセージ: 更新なら `記事を更新: <タイトル>`、新規なら `記事を追加: <タイトル>`
- PR タイトル: コミットメッセージと同じ
- PR 本文: 変更の要約を簡潔に書く

### 注意事項

- main ブランチで直接コミットしない。必ずブランチを切る
- ソースファイルは読み取りのみ。書き換えない

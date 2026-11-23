---
layout: page
title: About
permalink: /about/
redirect_from:
  # 旧「サイトを立ち上げました」記事(hello-world)は中身が無いので削除し、About へ寄せる
  - /2026/08/26/hello-world.html
---

このサイトでは、Mac の操作でマウスや遠いキーに手を伸ばす回数を減らすために、自分で作って毎日使っている設定とスクリプトを公開しています。

## 前提の環境

- macOS 26（記事ごとに、動作を確認したバージョンを書いています）
- JIS 配列のキーボード
- キーの割り当ては Karabiner-Elements、自動化は AppleScript
- キーバインドの考え方は Windows でも使えます。Caps Lock の位置を control、スペース横の親指キーを command と読み替えてください

## 困りごとから探す

| こんなとき | 記事 |
|---|---|
| 矢印キー・Enter・Backspace に手を伸ばしたくない | [seiha式キーバインドの考え方]({% post_url 2026-11-22-keybindings-that-keep-hands-on-home-row %}) |
| 英語のページで、翻訳と原文を何度も行き来する | [Chrome の翻訳を 1 キーで切り替える]({% post_url 2026-11-07-chrome-translate-toggle-applescript %}) |
| イヤホンとスピーカーの切り替えが面倒 | [音声出力先を 1 キーで出して矢印キーで選ぶ]({% post_url 2026-11-08-pick-mac-sound-output-with-arrow-keys %}) |
| Claude Code にアプリの動作確認までさせたい | [iOS シミュレータを Claude に操作させる]({% post_url 2026-11-07-let-claude-operate-ios-simulator %}) |
| Mac の標準ショートカットを一度整理したい | [Mac のキーボードショートカットを把握する]({% post_url 2026-08-29-mac-keyboard-shortcuts %}) |

テーマごとの一覧は [テーマ別の記事](/tags/) にあります。

## すぐ使えるもの

- [chrome_translate.applescript](/assets/files/chrome-translate-toggle-applescript/chrome_translate.applescript)：Chrome の翻訳を切り替える
- [open_sound_output.applescript](/assets/files/pick-mac-sound-output-with-arrow-keys/open_sound_output.applescript)：音声出力先を一覧から選ぶ
- [じゃんけんの勝ち癖を読む AI](https://janken-training-app.playgroundsss.workers.dev)：ブラウザで遊べます

## 記事どうしの関係

自動化の記事は、どれも「右 command を押しながら 1 キー → AppleScript を実行」という同じ仕組みでできています。右 command に何を割り当てているかの全体像は、[seiha式キーバインド]({% post_url 2026-11-22-keybindings-that-keep-hands-on-home-row %}) にまとめています。

| キー | 動作 | 記事 |
|---|---|---|
| 右 command + H | Chrome の翻訳を切り替える | [Chrome の翻訳を 1 キーで切り替える]({% post_url 2026-11-07-chrome-translate-toggle-applescript %}) |
| 右 command + A | 音声出力先を選ぶ | [音声出力先を 1 キーで出して矢印キーで選ぶ]({% post_url 2026-11-08-pick-mac-sound-output-with-arrow-keys %}) |
| 右 command + I / K | 音量を上げる / 下げる | [seiha式キーバインドの考え方]({% post_url 2026-11-22-keybindings-that-keep-hands-on-home-row %}) |

## 運営者

運営は seihasync です。連絡は [GitHub](https://github.com/kailowbi) からどうぞ。更新のお知らせは [X](https://x.com/seihasync)、RSS は [/feed.xml](/feed.xml) で受け取れます。

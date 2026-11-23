---
title: "commandの単押しでEnterとBackspaceを打つKarabiner設定【seiha式キーバインド 設定編1】"
description: "左 command の単押しで Enter、右 command の単押しで Backspace にする Karabiner-Elements の設定。ワンクリックで読み込める JSON と、to_if_alone まわりの設定の意味、使ってみて詰まった点を書く。"
tags: [keyboard]
---

【要記入：書き出し。親指でEnterを押すようになって何が変わったか、1〜2文】

[「seiha式キーバインド」の考え方]({% post_url 2026-11-22-keybindings-that-keep-hands-on-home-row %})で書いた配置のうち、この記事では一番効果が大きい親指キーの設定を書く。

- 左`command`の単押し → Enter
- 右`command`の単押し → Backspace
- 押しながら他のキーを押す → 普通の`command`

## とりあえず試したい人向け

Karabiner-Elementsが入っていれば、下のリンクから読み込める。

**[Karabiner-Elementsに読み込む](karabiner://karabiner/assets/complex_modifications/import?url=https%3A%2F%2Fbeanz.click%2Fassets%2Ffiles%2Fkarabiner-command-tap-to-enter-backspace%2Fseiha-thumb-keys.json)**

1. リンクを押すとKarabiner-Elementsが開き、読み込むか聞かれるので「Import」を押す
2. 「Complex Modifications」の画面で、使いたいルールの「Enable」を押す

左右のルールは分けてあるので、Enterだけ、Backspaceだけ試すこともできる。

リンクが開かない場合は、JSONをダウンロードして`~/.config/karabiner/assets/complex_modifications/`に置けば、同じ画面の「Add predefined rule」から選べる。

[seiha-thumb-keys.json をダウンロード](/assets/files/karabiner-command-tap-to-enter-backspace/seiha-thumb-keys.json)

### 元に戻すとき

「Complex Modifications」の画面で、ルールの「Remove」を押せば元の`command`に戻る。

【要確認：Karabiner-Elementsのバージョン。記事を書いた時点で動かしているもの】

## 設定の中身

左`command`のルールはこう。右は`left_command`が`right_command`に、`return_or_enter`が`delete_or_backspace`に変わるだけ。

```json
{
  "type": "basic",
  "from": { "key_code": "left_command", "modifiers": { "optional": ["any"] } },
  "to": [{ "key_code": "left_command" }],
  "to_if_alone": [{ "key_code": "return_or_enter" }],
  "to_if_held_down": [{ "key_code": "left_command", "halt": true }],
  "parameters": { "basic.to_if_alone_timeout_milliseconds": 200 }
}
```

### `to`：押した瞬間は普通のcommand

`to`に`left_command`を入れているので、押した時点ではただの`command`として動く。`command` + `c`のようなショートカットも、`command` + クリックも、今までどおり使える。

### `to_if_alone`：すぐ離したらEnter

他のキーを押さずに離すと、`to_if_alone`のEnterが送られる。「すぐ」の長さが`basic.to_if_alone_timeout_milliseconds`で、ここでは200ミリ秒にしている。

【要記入：200ミリ秒にした理由。デフォルト（1000ミリ秒）や他の値を試したなら、そのときどうだったか】

### `optional: any`：shiftと一緒に押せばshift + Enter

`from`の`modifiers`に`optional: ["any"]`を入れているので、他の修飾キーを押しながらでも単押しが効く。`shift`を押しながら左`command`を単押しすればshift + Enterになる。

【要記入：shift + Enter（チャットでの改行など）を実際に使っているか】

### `to_if_held_down`

【要確認：`to_if_held_down`に`halt: true`を入れている理由。長押ししたあとに離してもEnterが出ないようにするため、など】

## 使ってみて詰まったところ

【要記入：ここが記事の中心。たとえば次のような話】

- 【チャットで、`command`を押しかけてやめただけでEnterが出て送信してしまった件。どう慣れたか、何か対策したか】
- 【Backspaceを押しっぱなしにしても1文字しか消えない件。元のdeleteキーと使い分けるようになったか】
- 【設定を入れてから、指が慣れるまでの期間】
- 【Karabinerの入っていないMacを触ったときの話】

## 次は

次の設定編では、`control`を押しながら`i` / `j` / `k` / `l`で矢印にするcontrolレイヤーの設定を書く。

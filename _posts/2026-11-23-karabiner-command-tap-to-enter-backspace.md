---
title: "commandの単押しでEnterとBackspaceを打つKarabiner設定【seiha式キーバインド 設定編1】"
description: "左 command の単押しで Enter、右 command の単押しで Backspace にする Karabiner-Elements の設定。ワンクリックで読み込める JSON と、to_if_alone まわりの設定の意味、使ってみて困った点を書く。"
tags: [keyboard]
---

EnterとBackspaceを親指で押すようにしてから、文字を打っている間に手がほとんど動かなくなった。Backspaceのたびに右手を上に伸ばして、戻ってきたら指の位置を探し直す、ということがない。ここ数年、ずっとこの設定で使っている。

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

元に戻すときは、「Complex Modifications」の画面でルールの「Remove」を押せば普通の`command`に戻る。

## 設定の中身

左`command`のルールはこう。右は`left_command`が`right_command`に、`return_or_enter`が`delete_or_backspace`に変わるだけ。

```json
{
  "type": "basic",
  "from": { "key_code": "left_command", "modifiers": { "optional": ["any"] } },
  "to": [{ "key_code": "left_command" }],
  "to_if_alone": [{ "key_code": "return_or_enter" }],
  "parameters": { "basic.to_if_alone_timeout_milliseconds": 200 }
}
```

### 押した瞬間は普通のcommand

`to`に`left_command`を入れているので、押した時点ではただの`command`として動く。`command` + `c`のようなショートカットも、`command` + クリックも、今までどおり使える。

### すぐ離したらEnter

他のキーを押さずに離すと、`to_if_alone`のEnterが送られる。この「すぐ」の長さが`basic.to_if_alone_timeout_milliseconds`。

最初はKarabinerの標準の1000ミリ秒のまま使っていた。これだと、`command`を押して「やっぱりやめた」と離したときにもEnterが出てしまう。1秒は思ったより長くて、ショートカットを押しかけて考え直す、くらいの間は余裕で収まる。何度か試して200ミリ秒まで縮めた。これくらいなら、意識してポンと押したときだけEnterになる。

### shiftと一緒に押せばshift + Enter

`from`の`modifiers`に`optional: ["any"]`を入れているので、他の修飾キーを押しながらでも単押しが効く。`shift`を押しながら左`command`を単押しすれば、shift + Enterになる。

これはけっこう使っている。チャットで送信せずに改行したいときは、`shift`を押したまま親指でポン。Enterの位置が変わっても、shift + Enterの使い方はそのまま持ってこられる。

## 使ってみて困ったところ

一番困るのは、Backspaceを押しっぱなしにしても1文字しか消えないこと。`to_if_alone`は「押して離した」ときに1回送るだけなので、普通のBackspaceのようなキーリピートが効かない。

なので、まとめて消したいときは左`command`を押しながら右`command`を単押ししている。右`command`のルールにも`optional: ["any"]`が入っているので、これは`command` + Backspaceになる。macOSでは`command` + Backspaceは行頭まで削除なので、1行ぶんなら一発で消える。

## 次は

次の設定編では、`control`を押しながら`i` / `j` / `k` / `l`で矢印にするcontrolレイヤーの設定を書く。

---
title: "Macの音声出力先を1キーで出して矢印キーで選ぶ"
---

Windowsでは `Win+Ctrl+V` を押すと、サウンド出力のクイック設定が開く。そこで矢印キーでスピーカーかイヤホンかを選んで Enter。マウスに手を伸ばさずに出力先を切り替えられるので、かなり重宝していた。

Macにも同じものが欲しくなったので、右Command + A で出力デバイスの一覧を出して、矢印キーで選べるようにした。キーの割り当てはKarabiner-Elements、一覧はAppleScriptの `choose from list`、切り替えは `SwitchAudioSource` でやっている。

動かしているのは macOS 26.6.1。

## とりあえず動かしたい人向け

完成版はここに置いておく。

[open_sound_output.applescript をダウンロード](/assets/files/pick-mac-sound-output-with-arrow-keys/open_sound_output.applescript)

手順はこれだけ。

1. `SwitchAudioSource` を入れる

   ```sh
   brew install switchaudio-osx
   ```

2. スクリプトを好きな場所に置く（以下では `~/scripts/` に置いた前提で書く）
3. Karabiner-Elementsに後述のルールを足す

Intel Macだと Homebrew の場所が `/usr/local/bin` なので、スクリプト1行目の `/opt/homebrew/bin/SwitchAudioSource` を書き換える。`which SwitchAudioSource` で場所はわかる。

右Command + A を押すと「出力デバイス」というダイアログが出て、今の出力先が最初から選ばれている。矢印キーで選んで Enter で切り替わり、Esc なら何もせずに閉じる。

## スクリプトの中身

```applescript
-- 出力デバイスを一覧から選んで切り替える（矢印キーで選んで Enter）
-- コントロールセンターのサウンドは矢印キーで選べないため、choose from list を使う
set switchAudio to "/opt/homebrew/bin/SwitchAudioSource"
set devices to paragraphs of (do shell script switchAudio & " -a -t output")
set current to do shell script switchAudio & " -c -t output"

set picked to choose from list devices with prompt "出力デバイス" default items {current}
if picked is false then return
do shell script switchAudio & " -t output -s " & quoted form of (item 1 of picked)
```

`SwitchAudioSource -a -t output` が出力デバイスの名前を1行1件で返してくれるので、それをそのまま `choose from list` に渡しているだけ。`-c` で今の出力先、`-s <名前>` で切り替え。デバイス名を自前で集める必要がないのは楽だった。

Karabinerのルールはこう。

```json
{
  "description": "サウンド出力デバイスを一覧から選ぶ",
  "type": "basic",
  "from": { "key_code": "a", "modifiers": { "mandatory": ["right_command"] } },
  "to": [
    {
      "shell_command": "f=~/scripts/open_sound_output; [ $f.app -nt $f.applescript ] || osacompile -o $f.app $f.applescript; open $f.app"
    }
  ]
}
```

`osascript` で直接実行するのではなく、スクリプトを `.app` にコンパイルしてから `open` で開いている。ここが今回いちばんハマったところで、理由は後で書く。

`.app` が無いとき（初回）と、`.applescript` のほうが新しいとき（書き換えた後）だけ `osacompile` で作り直す。それ以外は既にある `.app` を開くだけ。dotfilesなどで管理しているなら、`.app` は自動で作られるものなので `.gitignore` に入れておくとよい。

ちなみに作り直しを飛ばしたところで、速くなるのは0.07〜0.09秒くらい（`osacompile` を3回測った）。体感ではまずわからない。待ち時間のほとんどは `.app` の起動と `SwitchAudioSource` の呼び出しで、こっちは毎回かかる。

## 最初はコントロールセンターを開いていた

最初の版は、メニューバーの「サウンド」をクリックしてコントロールセンターのパネルを開くだけのスクリプトだった。Windowsのクイック設定にいちばん近いのはこれだと思ったので。

```applescript
tell application "System Events" to tell process "ControlCenter"
	repeat with menuItem in (menu bar items of menu bar 1)
		try
			if value of attribute "AXIdentifier" of menuItem is "com.apple.menuextra.sound" then
				click menuItem
				return
			end if
		end try
	end repeat
end tell
```

メニューバーの項目を名前ではなく `com.apple.menuextra.sound` というIDで探しているので、表示言語が変わっても動く。パネルはちゃんと開いた。

ところが、開いたパネルの中を矢印キーで移動できない。Tab でしか項目を移れない。Windowsでは「矢印で選んで Enter」が手に染みついているので、これだと結局使わなくなる。AppleScript側ではどうにもならないので、パネルを開くのはやめて、`choose from list` で自前の一覧を出すことにした。

## ダイアログにフォーカスが当たらない

`choose from list` 版にしたら、今度はダイアログは出るのにフォーカスが当たらない。いちいちクリックしてから矢印キーを押すことになるので、パネルのときより悪くなっている。

`osascript` は裏で動くプロセスなので、`activate` を書いても前面に出られないらしい。いくつか試した結果はこうだった。

| ダイアログを出させたもの | フォーカス |
|---|---|
| `osascript` 自身（`activate` あり） | 当たらない |
| System Events | 当たらない |
| Finder（`tell application "Finder"` の中で出す） | 当たる |

Finderに出させればフォーカスは取れる。ただ、閉じた後もFinderが前面に残るので、元の作業に戻るのにまたクリックが要る。Finderを使わない形に戻してKarabinerから押してみたら、やっぱりフォーカスは当たらなかった。

投了です。

## .app にして open で開く

最終的に落ち着いたのが、スクリプトを `osacompile` でアプレット（`.app`）にして、`open` で起動するやり方。`open` で起動したアプリは普通のアプリとして前面に出られるので、ダイアログにフォーカスが当たる。しかもダイアログを閉じるとアプレット自体が終了するので、元のアプリに勝手に戻ってくれる。Finder案で困っていたところがまとめて消えた。

ついでに、この形ならSystem Eventsも使っていないので、アクセシビリティの許可も要らない。メニューバーに「サウンド」を表示しておく必要もなくなった。

## やってみて思ったこと

最初は「コントロールセンターを開けば同じことができる」と思っていたけど、欲しかったのはパネルそのものではなく、「1キーで出して矢印で選んで Enter」という手の動きのほうだった。そこに気づいてからは、見た目がWindowsに似ているかどうかはどうでもよくなった。

フォーカスの件は、`activate` を書けば前に出るものだと思い込んでいたのが敗因。`osascript` から出すダイアログで同じ目にあったら、`.app` にして `open` するのを試してみてほしい。

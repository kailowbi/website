---
title: "Chromeの翻訳を1キーでトグルするAppleScript"
---

英語のドキュメントを読んでいると、「ここだけ日本語で読みたい」と「やっぱり原文で確認したい」を何度も行き来する。Chromeの翻訳は便利だけど、毎回アドレスバーの翻訳アイコンを押して、ポップアップで言語を選び直すのが地味に面倒だった。

なので、右Command + H の1キーで翻訳を切り替えられるようにしている。中身はAppleScriptで、Karabiner-Elementsから呼んでいる。

## とりあえず動かしたい人向け

完成版はここに置いておく。

[chrome_translate.applescript をダウンロード](/assets/files/chrome-translate-toggle-applescript/chrome_translate.applescript)

```sh
osascript ~/Downloads/chrome_translate.applescript
```

Chromeを前面に出した状態で実行すると、翻訳が切り替わる。前提はこのあたり。

- Chromeの表示言語が日本語（ボタンやポップアップを日本語のラベルで探しているため）
- 実行するアプリ（ターミナルやKarabiner-Elements）に、システム設定の「プライバシーとセキュリティ」→「アクセシビリティ」で許可を出しておく

キーに割り当てるなら、後述のKarabinerの設定をそのまま使える。

## 仕組み

ベースは sttk3.com さんの「Chrome翻訳の言語を交互に切り替える」スクリプト（v2.2.0）。これを自分の環境向けにいじって使っている。

やっていることは、人間が手でやる操作をそのままSystem Events経由でなぞるだけ。

1. ページ内検索のバーが出ていたら Escape で閉じる
2. 翻訳ポップアップが出ていなければ、アドレスバーの「このページを翻訳」ボタンを押して出す
3. ポップアップの中の言語タブ（「日本語」と「英語」or「検出された言語」）を名前で探して押す
4. Escape でポップアップを閉じる

ポップアップは「このページを翻訳しますか？」か「翻訳済み」という名前のウインドウとして取れるので、それで見分けている。

```applescript
on get_popup_window(key_name)
	set popup_window to missing value
	tell application "System Events"
		tell application process "Google Chrome"
			set nameless_windows to every window whose name of it is key_name
			if (nameless_windows is not {}) then
				set popup_window to item 1 of nameless_windows
			end if
		end tell
	end tell
	return popup_window
end get_popup_window
```

Karabiner側は、Chromeが最前面のときだけ発火するようにしている。

```json
{
  "description": "(Chrome)で翻訳トグル",
  "type": "basic",
  "conditions": [
    { "type": "frontmost_application_if", "bundle_identifiers": ["^com.google.Chrome"] }
  ],
  "from": { "key_code": "h", "modifiers": { "mandatory": ["right_command"] } },
  "to": [
    { "shell_command": "osascript ~/dotfiles/mac/scripts/apple_scripts/chrome_translate.applescript" }
  ]
}
```

## ある日、効かなくなった

しばらく快適に使っていたら、ある日キーを押しても何も起きなくなった。エラーも出ない。

原因はすぐわかった。「このページを翻訳」ボタンを、UI階層の位置で決め打ちして取っていたのだ。

```applescript
set translate_button to checkbox 2 of group 4 of group 3 of toolbar 1 of group 1 of group 1 of group 1 of group 1 of group 1 of target_window
```

`group 1` が5段。Chromeのアップデートでツールバーの構造が少し変わったら、そりゃ取れなくなる。しかも全体を `try` で囲っていたので、失敗しても黙って終わる。

投了です。

ちなみにこのパスは、デバッグ用の関数でUI要素を何層も掘ってダンプして見つけたものだった。その関数は手元のスクリプトにまだ残っていて、if と repeat のネストが7層くらいある。正直もう読みたくない。配布版からは消してある。

## 位置ではなく description で探す

直し方はシンプルで、ボタンの位置ではなく、ボタンの description（アクセシビリティ上のラベル）に「このページを翻訳」が含まれる要素を再帰的に探すようにした。

```applescript
-- UI階層はChromeの更新で変わるため，位置ではなくdescriptionで探す
on find_by_description(parent_element, keyword)
	tell application "System Events"
		try
			set child_elements to UI elements of parent_element
		on error
			return missing value
		end try
		repeat with child in child_elements
			set child_role to ""
			try
				set child_role to role of child
			end try
			-- ページ本文の中まで潜ると極端に遅くなるので飛ばす
			if (child_role is not "AXWebArea") then
				try
					if ((description of child) as text) contains keyword then return contents of child
				end try
				set found_element to my find_by_description(child, keyword)
				if (found_element is not missing value) then return found_element
			end if
		end repeat
	end tell
	return missing value
end find_by_description
```

ハマりかけたのは速度。何も考えずに全要素をたどると、Webページの本文（`AXWebArea`）の中まで潜りにいくので、極端に遅くなる。ボタンはツールバー側にしかないので、`AXWebArea` はまるごと飛ばしている。

ポップアップ内の言語タブのほうは、もともと `entire contents` で全要素から radio button を拾って名前で照合していたので、今回の変更では壊れなかった。ポップアップは要素数が少ないので、こっちは雑に全部なめても遅くならない。

## やってみて思ったこと

UIを外から操作するスクリプトは、どうしてもアプリの更新で壊れる。それでも位置ではなくラベルで探すようにしておけば、見た目の配置が多少変わっても動き続ける。逆に、Chromeの表示言語を英語にしたら「このページを翻訳」で見つからなくなるので、そこは割り切っている。

翻訳の切り替えなんて1回あたり数秒の話だけど、英語のドキュメントを読む日は何十回も押すので、1キーで済むのはやっぱり快適。

---
title: "iOSシミュレータをClaudeに操作させる"
---

Claude Code から iOS シミュレータ上のアプリを動かして動作確認する方法のメモ。
computer-use MCP（Claude が Mac の画面を見てマウス・キーボードを操作する仕組み）を使ってうまくいったときの手順をまとめた。

## 2 つのやり方

| | computer-use MCP | XcodeBuildMCP |
|---|---|---|
| 操作の仕組み | Mac の画面を撮り、Simulator ウィンドウを座標でクリックする | シミュレータに直接タップなどのイベントを送る |
| 画面の読み取り | スクリーンショットの画像だけ | スクリーンショットに加えて、アクセシビリティ情報で UI の要素も取れる |
| ビルド・インストール | できないので Bash（`xcodebuild` / `simctl`）でやる | MCP のツールでできる |
| 向いているもの | Unity などのゲームエンジン製アプリや WebView の画面。UI の要素情報が取れない画面でも、見えていれば押せる | UIKit / SwiftUI のネイティブ画面だけでできたアプリ |
| 使うときの準備 | 操作するアプリ（Simulator）を毎回 `request_access` で許可する | MCP サーバーを設定する |

Unity 製アプリでは、アクセシビリティ情報からボタンが見えない。どちらのやり方でも結局「画像を見て座標を押す」ことになるので、computer-use で十分だった。

WebView の画面も同じで、XcodeBuildMCP ではうまく操作できず、かなり試行錯誤した。画面に見えているものを押すだけの computer-use のほうが、迷わずに済んで楽だった。
ネイティブ画面と WebView が混ざったアプリでも、最初から computer-use でよい。

## computer-use での流れ

`request_access` や `screenshot`、`left_click`、`computer_batch`（複数の操作をまとめて実行する）は、computer-use MCP のツール名。

1. シミュレータを起動してアプリを入れる（Bash）
   ```bash
   xcrun simctl boot "iPhone 16 Pro" && open -a Simulator
   xcrun simctl install booted path/to/App.app
   xcrun simctl launch booted <bundle id>
   ```
   ビルドからここまでをスクリプトにまとめておくと、Claude に毎回同じ手順で準備してもらえる
2. `request_access` で `Simulator` だけ許可してもらう
3. `screenshot` で画面を撮る（許可していないアプリは隠れて写る）
4. 画像からボタンの座標を読み、`left_click` で押す。Simulator はクリックを iOS のタッチとして渡す
5. 「クリック → 数秒待つ → スクリーンショット」を `computer_batch` でまとめて実行し、毎回の画像で結果を判断する

## ハマりどころ

- **見えないウィンドウに弾かれる**: 許可していないアプリ（通知センターなど）のウィンドウがクリック位置に重なっていると、クリックが拒否される。スクリーンショットには写らないので、少し位置をずらして押し直す
- **速い操作はできない**: 1 回ごとに画像を見て判断するので、ゲームのように素早い反応が必要な操作は無理。その先の画面まで確かめたいなら、アプリ側にデバッグ用の操作（目的の画面まで飛ばす、など）を用意する
- **Unity のログは見えない**: Unity の `Debug.Log` は iOS の標準ログに出ない。`simctl spawn booted log show` を見ても例外は拾えず、言えるのは「落ちなかった」ことまで
- **シミュレータでは確かめられないもの**: 振動（Haptics）、署名、実機ならではの性能や Safe Area の差

## Unity でシミュレータ向けにビルドするには

`PlayerSettings.iOS.sdkVersion = iOSSdkVersion.SimulatorSDK` にしてから iOS 向けにビルドする。
ProjectSettings に残さないよう、ビルド後に元へ戻す。Editor スクリプトにビルド用のメソッドを用意しておき、`-executeMethod` でコマンドラインから呼べるようにしておくと、Claude からも実行できる。

-- 出力デバイスを一覧から選んで切り替える（矢印キーで選んで Enter）
-- コントロールセンターのサウンドは矢印キーで選べないため、choose from list を使う
set switchAudio to "/opt/homebrew/bin/SwitchAudioSource"
set devices to paragraphs of (do shell script switchAudio & " -a -t output")
set current to do shell script switchAudio & " -c -t output"

set picked to choose from list devices with prompt "出力デバイス" default items {current}
if picked is false then return
do shell script switchAudio & " -t output -s " & quoted form of (item 1 of picked)

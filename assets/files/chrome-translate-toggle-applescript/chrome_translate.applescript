(**
  * @file Chrome翻訳の言語を交互に切り替える
  * @version 2.2.0
  * @author sttk3.com
  * @copyright © 2022 sttk3.com
  * 上記をベースに改変。デバッグ用の処理を除き、翻訳ボタンを description で探すようにしたもの
*)

on run
	set sleep_seconds to 0.3
	set key_translate_window1 to "このページを翻訳しますか？"
	set key_translate_window2 to "翻訳済み"

	tell application "System Events"
		tell application process "Google Chrome"
			try
				-- 検索バーが出ているとポップアップが取れないので閉じる
				if (name of window 1 contains "ページ内を検索") then
					key code 53
					delay sleep_seconds
				end if

				set target_window to my get_translate_popup(key_translate_window1, key_translate_window2)

				if (target_window is missing value) then
					-- なぜか空のウインドウに邪魔されるので，タイトルがあるものに限定する
					set main_window to item 1 of (every window whose title of it is not "")
					set translate_button to my find_by_description(main_window, "このページを翻訳")
					if (translate_button is missing value) then return
					click translate_button
					delay sleep_seconds

					set target_window to my get_translate_popup(key_translate_window1, key_translate_window2)
					if (target_window is missing value) then return
				end if

				set japanese_radio_button to my find_radio_button(target_window, {"日本語"})
				if (japanese_radio_button is not missing value) then
					click japanese_radio_button
					delay sleep_seconds
				end if

				set base_language_radio_button to my find_radio_button(target_window, {"検出された言語", "英語"})
				if (base_language_radio_button is not missing value) then
					click base_language_radio_button
					delay sleep_seconds
				end if

				key code 53
			on error error_message
				log error_message
			end try
		end tell
	end tell
end run

on get_translate_popup(key_name1, key_name2)
	tell application "System Events"
		tell application process "Google Chrome"
			set popup_windows to every window whose name of it is key_name1
			if (popup_windows is {}) then set popup_windows to every window whose name of it is key_name2
			if (popup_windows is {}) then return missing value
			return item 1 of popup_windows
		end tell
	end tell
end get_translate_popup

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

on find_radio_button(target_window, keywords)
	tell application "System Events"
		repeat with elem in (entire contents of target_window)
			try
				if class of elem is radio button then
					set elem_name to name of elem as text
					repeat with keyword in keywords
						if elem_name contains keyword then return contents of elem
					end repeat
				end if
			end try
		end repeat
	end tell
	return missing value
end find_radio_button

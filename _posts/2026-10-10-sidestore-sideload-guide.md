---
title: "SideStore導入ガイド"
---

最終更新: 2026-10-10

## 1. 事前準備
- 対応OS確認: iOS / iPadOS 18.0〜26.x(SideInstallerを使う場合はiOS 27が必須)
- Apple ID を用意(無料IDでも可。ただし証明書は7日で失効する制約あり)
- VPNアプリは`LocalDevVPN`を使う(`StosVPN`は古く不安定なので避ける)
- JITが必要なアプリを使うなら`StikDebug`も準備

## 2. インストール方法を選ぶ(唯一の分岐点)

### 方法A: クラシック(PCを使う)
1. PCに`iLoader`等のツールを入れる
2. Windowsの場合、非ストア版の iCloud / iTunes を用意
3. iPhoneをケーブルでPCに接続し「信頼する」を選択
4. iLoaderで「ペアリングファイル生成」を実行 →**ここでPC上に作られる**
5. SideStoreのIPAをサイドロード
6. 生成したファイルをAirDrop等でiPhoneに転送

### 方法B: PC不要(SideInstaller)
1. iPhoneで`LocalDevVPN`をインストールしVPN接続をON
2. 別手段(Sideloadly等)で`SideInstaller`のIPAを用意
3. SideInstallerをインストール・起動(詳細は巻末の付録)
4. VPN経由でペアリング処理が実行される →**ここでiPhone上に作られる**
5. そのままSideStore本体を導入

## 3. 初期セットアップ(共通)
1. 設定 → 一般 → VPNとデバイス管理 → SideStoreを信頼する
2. SideStoreの設定で、方法A/Bで作成したペアリングファイルをインポート
3. Apple IDでログイン(stable版推奨。nightly版はログイン不安定の報告あり)
4. リフレッシュ・インストール前に必ずVPN接続を確認する

## 4. 日常運用 — 2種類の「期限」を区別する
混同しやすいが原因が違うので対処も違う。

| 種類 | 失効周期 | 対処 |
|---|---|---|
| 証明書(署名) | 約7日 | SideStoreのリフレッシュで再署名(「Refresh Now」を許可するだけ) |
| ペアリングファイル | 不定期(iOS更新・リセット時、またはApple側都合) | 下記「再生成の手順」を実施(自動更新されない) |

Appleの仕様により、ペアリングファイルは何もしなくても失効することがある(SideStore側では修正不可)。

### ペアリングファイル再生成の手順

**PCを使っていた場合(方法Aで導入した人)**
1. iPhoneとPCを同じWiFi(またはケーブル)で接続
2. iPhone側のLocalDevVPNを接続しておく
3. PCで`iLoader`を起動し、デバイスが認識されているか確認
4. 「ペアリングファイル生成」を実行 → 新しい`.mobiledevicepairing`ファイルがPC上に作られる
5. SideStoreアプリを開き、設定から「ペアリングファイルをインポート」
6. 手順4のファイルを選んで読み込む
7. リフレッシュを試し、エラーが出ないか確認

**PC不要だった場合(方法Bで導入した人)**
1. iPhoneでLocalDevVPNを接続しておく
2. SideInstallerを開く
3. ペアリング処理を再実行(新しいペアリングコードが表示される)
4. 設定 → プライバシーとセキュリティ → Apple ID(デベロッパーApp)を信頼
5. SideInstallerに戻りペアリングコードを入力、必要ならApple IDでサインイン
6. 「許可(Allow)」をタップ → 新しいペアリングファイルがiPhone上に作られ、SideStoreに反映される

共通のコツ: VPNを接続した状態で行う。失効サインは「WiFi/VPNに接続していません」というエラーでリフレッシュが止まること。

## 5. 制限回避(任意)
- `LiveContainer`併用で3アプリ制限を回避(「リフレッシュ不要」という触れ込みは過信しない。実際は定期更新が必要な場合がある)
- JITが必要なアプリには`StikDebug`を併用

## 6. トラブルシューティング

| 症状 | 対処 |
|---|---|
| リフレッシュ失敗 | VPN接続を確認 → ペアリングファイルを再生成 |
| Apple IDログイン失敗 | nightly版→stable版に切替 |
| minimuxerエラー/heartbeat失敗 | Anisetteサーバーを切替 → ペアリングファイル再生成 |
| 直らない | GitHub Issue/Discordへバージョン・iOSバージョン・エラー文言とともに報告 |

---

## 付録: SideInstaller詳細
SideInstallerはiOS 27のワイヤレスペアリング機能に依存するため、iOS 26以下では使えない。

1. 公式サイト`sideinstaller.com`でIPAを入手(非公式のGitHubフォークが複数出回っているので公式以外は避ける)
2. IPA自体を`iLoader`や`Sideloadly`などの別ツールでサイドロード(多くの場合、初回だけPCが必要)
3. 設定 → プライバシーとセキュリティ → Apple ID(デベロッパーApp)を信頼
4. SideInstallerに戻り、表示されたペアリングコードを入力し、必要に応じてApple IDでサインイン
5. 「許可(Allow)」をタップしてペアリング完了

補足: v1.2.0以降は「Side by Side」機能で、すでにSideInstallerが入っている別のiPhone/iPadから無線でインストールしてもらうことも可能。

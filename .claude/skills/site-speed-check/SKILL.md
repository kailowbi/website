---
name: site-speed-check
description: Webサイトの表示速度を数値で計測する。接続タイミング(DNS/TCP/TLS/TTFB)とPageSpeed Insightsのスコア・Core Web Vitalsを取得する。"サイトが遅い"「表示速度を見て」「PageSpeed」「Core Web Vitals」等で使う
---

# サイト速度チェック

対象URLの表示速度を2段階で数値化する。

## 1. 接続タイミング(DNS/TCP/TLS/TTFB)

```bash
curl -o /dev/null -s -w "DNS: %{time_namelookup}s\nTCP接続: %{time_connect}s\nTLS: %{time_appconnect}s\nTTFB: %{time_starttransfer}s\n合計: %{time_total}s\nHTTPステータス: %{http_code}\n" <URL>
```

HTML本文取得までの時間しか測れない点に注意する。CSS/JS/画像/フォントの読み込みは含まれない。

## 2. PageSpeed Insights (スコア・Core Web Vitals)

PageSpeed Insightsの結果画面(pagespeed.web.dev)はJSで後から描画されるSPAなので、WebFetchでは中身が読めない。**必ず公開APIを直接叩く**こと。

```bash
curl -s "https://www.googleapis.com/pagespeedonline/v5/runPagespeed?url=<URL>&strategy=mobile&category=performance" \
  | jq '{
      score: .lighthouseResult.categories.performance.score,
      FCP: .lighthouseResult.audits["first-contentful-paint"].displayValue,
      LCP: .lighthouseResult.audits["largest-contentful-paint"].displayValue,
      TBT: .lighthouseResult.audits["total-blocking-time"].displayValue,
      CLS: .lighthouseResult.audits["cumulative-layout-shift"].displayValue,
      SpeedIndex: .lighthouseResult.audits["speed-index"].displayValue
    }'
```

- `strategy` は `mobile` か `desktop` を指定する(両方見たいときは2回叩く)。
- APIキーなしでも動くが、レート制限が厳しいので連続実行は避ける。ユーザーが自分のAPIキーを持っていれば `&key=<API_KEY>` を付ける。
- スコアは0〜1の小数で返る(0.9なら90点)。

## 出力の見せ方

2つの結果を並べて、どちらの区間が遅いか(ネットワーク接続 vs レンダリング)を一言で添える。

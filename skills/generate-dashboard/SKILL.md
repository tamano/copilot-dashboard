---
name: generate-dashboard
description: >
  GitHub Copilot の Premium Request 利用状況CSVファイルからHTMLダッシュボードを生成する。
  ユーザーが「Copilotの利用状況を可視化したい」「premium requestのCSVからダッシュボードを作りたい」
  「Copilotの使用量レポートを見たい」「CSVからCopilot利用レポートを生成して」「クォータの消化状況を確認したい」
  と言った場合にこのスキルを使用すること。copilot, premium request, 利用状況, ダッシュボード,
  クォータ, usage report といったキーワードが含まれる場合も積極的にこのスキルを適用する。
---

# Premium Request Dashboard

GitHub Copilot の Premium Request 利用状況CSVファイルを読み込み、単体HTMLファイルのダッシュボードを生成する。

## 使い方

1. ユーザーからCSVファイルのパスを受け取る
2. 以下のコマンドでダッシュボードを生成する

```bash
ruby {{PLUGIN_DIR}}/scripts/generate_dashboard.rb <CSVファイルパス> [出力先HTMLパス]
```

- 第1引数: CSVファイルのパス（必須）
- 第2引数: 出力先HTMLファイルのパス（省略時はカレントディレクトリに `dashboard_YYYYMMDD_YYYYMMDD.html` を自動生成。日付はCSV内の期間開始日・終了日）

3. 生成されたHTMLファイルをブラウザで開くようユーザーに案内する

## CSVフォーマット

GitHub の Copilot Premium Request Usage Report のCSVを想定している。必要なカラム:

- `date` — 利用日
- `username` — ユーザー名
- `model` — 使用モデル名
- `quantity` — リクエスト数
- `net_amount` — コスト（ドル）
- `total_monthly_quota` — 月間クォータ上限
- `organization` — 組織名

## ダッシュボードの内容

- **サマリーカード**: 総リクエスト数、総コスト、アクティブユーザー数、平均クォータ消化率
- **日別トレンドチャート**: 日ごとのリクエスト数推移（折れ線）＋ クォータ超過ユーザー数（棒グラフ重畳）
- **ユーザーランキング**: リクエスト数順のテーブル（ソート可能）、クォータ消化率バー付き
- **モデル別利用割合**: 横棒グラフでモデルごとのリクエスト数を表示
- **クォータアラート**: クォータ80%以上のユーザーを警告表示、100%以上は超過表示

## 注意事項

- 出力は完全にスタンドアロンなHTMLファイル（外部依存なし）
- テンプレートは `scripts/template.html` に固定されており、デザイン・構成は毎回同一
- Ruby標準ライブラリのみ使用（csv, json）、追加gemは不要

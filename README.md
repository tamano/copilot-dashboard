# GitHub Copilot Premium Request Analyse

GitHub Copilot の Premium Request 利用状況 CSV から HTML ダッシュボードを生成するツール。

## 必要環境

- Ruby (標準ライブラリのみ使用、追加 gem 不要)
- Claude Code (プラグインとして利用する場合)

## 使い方

### Claude Code プラグインとして使う

1. `--plugin-dir` オプションを指定して Claude Code を起動する

```bash
claude --plugin-dir /path/to/github_copilot_premium_request_analyse
```

2. `/github-copilot-premium-request-dashboard:copilot-dashboard` コマンドを実行する（`data/` 配下の CSV を自動検出）

### コマンドラインから直接使う

1. GitHub から Premium Request Usage Report の CSV をダウンロードし、`data/` に配置する
2. ダッシュボードを生成する

```bash
ruby scripts/generate_dashboard.rb data/<CSVファイル名>
```

カレントディレクトリに `dashboard_YYYYMMDD_YYYYMMDD.html` が生成される（日付は CSV 内の期間）。

出力先を指定する場合は第 2 引数にパスを渡す:

```bash
ruby scripts/generate_dashboard.rb data/<CSVファイル名> output/report.html
```

3. 生成された HTML をブラウザで開く

## ダッシュボードの内容

- **Summary Cards** — Total Requests、Total Cost、Active Users、Avg Quota Usage（クォータ超過ユーザー数も表示）
- **Daily Trend** — 日ごとのリクエスト数推移（折れ線）+ クォータ超過率（折れ線・全ユーザーに占める割合%）、ツールチップ対応
- **User Ranking** — リクエスト数順テーブル（各カラムでソート可能）、クォータ消化率バー付き（80% 以上で警告色、100% 以上で超過色）
- **Model Breakdown** — モデルごとのリクエスト数を横棒グラフで表示
- **User Model Breakdown** — ユーザーごとの全モデル利用状況をクォータ上限に対する割合で積み上げ表示

# GitHub Copilot Premium Request Dashboard

GitHub Copilot の Premium Request 利用状況 CSV から HTML ダッシュボードを生成するツール。

## 必要環境

- Ruby（標準ライブラリのみ使用、追加 gem 不要）

## プロジェクト構成

- `scripts/generate_dashboard.rb` — ダッシュボード生成スクリプト（メインロジック）
- `scripts/template.html` — HTML テンプレート
- `data/` — CSV ファイル置き場
- `skills/generate-dashboard/SKILL.md` — スキル定義（詳細な仕様はこちらを参照）
- `commands/copilot-dashboard.md` — Claude Code 用スラッシュコマンド

## 基本的な使い方

`data/` 配下の CSV ファイルからダッシュボードを生成する:

```bash
ruby scripts/generate_dashboard.rb data/<CSVファイル名>
```

カレントディレクトリに `dashboard_YYYYMMDD_YYYYMMDD.html` が生成される。

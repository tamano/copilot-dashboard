---
name: copilot-dashboard
description: GitHub Copilot Premium Request のダッシュボードを生成する
allowed-tools:
  - Bash
  - Glob
  - Read
arguments:
  - name: csv_path
    description: CSVファイルのパス（省略時はdata/配下のCSVを自動検出）
    required: false
---

GitHub Copilot Premium Request のダッシュボードを生成してください。

## 手順

1. CSVファイルのパスが指定されていない場合は、`data/` 配下の `*.csv` ファイルを Glob で検索する
2. CSVファイルが複数ある場合はユーザーに選択を求める
3. 以下のコマンドでダッシュボードを生成する

```bash
ruby {{PLUGIN_DIR}}/scripts/generate_dashboard.rb <CSVファイルパス>
```

4. 生成されたHTMLファイルのパスをユーザーに案内し、ブラウザで開くか確認する

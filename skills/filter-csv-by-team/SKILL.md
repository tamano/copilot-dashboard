---
name: filter-csv-by-team
description: >
  GitHub Organization の Team に所属するメンバーの利用データのみを Premium Request Usage Report CSV から抽出する。
  ユーザーが「○○チームのメンバーだけのCSVを作って」「特定チームの利用状況だけ抽出して」「team-slug に絞り込んで」
  「組織のチームメンバーを取得してCSVをフィルタして」と言った場合にこのスキルを使用すること。
  github team, organization, marty-team, メンバー絞り込み, チーム別CSV, premium request, copilot
  といったキーワードが含まれる場合も積極的にこのスキルを適用する。
---

# Filter CSV by GitHub Team

GitHub Organization の Team メンバーを `gh` CLI で取得し、Premium Request Usage Report CSV から該当ユーザーの行のみを抽出して新しい CSV を出力する。

## 使い方

1. ユーザーから以下を受け取る
   - GitHub Organization 名 (例: `eLicenseSystems`)
   - Team slug (例: `marty-team`)
   - 入力 CSV のパス (例: `data/premiumRequestUsageReport_202604.csv`)
   - (任意) 出力 CSV のパス
2. 以下のコマンドを実行する

```bash
ruby skills/filter-csv-by-team/scripts/filter_by_team.rb <org> <team-slug> <入力CSV> [出力CSV]
```

- 第1引数: Organization 名
- 第2引数: Team slug
- 第3引数: 入力 CSV パス（必須）
- 第4引数: 出力 CSV パス（省略時は入力CSVと同じディレクトリに `<team-slug>_<YYYYMM|YYYYMMDD>.csv` を自動生成。元ファイル名から年月/日付トークンを抽出）

3. 出力結果に表示される、CSV に利用記録があるユーザー数とチーム所属だが利用記録がないユーザー一覧をそのままユーザーに報告する

## 前提条件

- `gh` CLI がインストール済みかつ Organization の team 読み取り権限がある状態で認証済み (`gh auth status` で確認可能)
- 入力 CSV は `username` カラムを含む形式 (Premium Request Usage Report 標準フォーマット)

## 出力仕様

- 入力 CSV のヘッダーを保持し、`username` がチームメンバー (大文字小文字を無視) と一致する行のみを書き出す
- すべてのフィールドをダブルクォートで囲んだ UTF-8 (BOM なし) CSV として出力
- 標準出力に以下を表示
  - チーム総メンバー数
  - 書き出した行数と利用記録のあったユーザー数、出力ファイルパス
  - 期間中に利用記録のなかったメンバー一覧

## 注意事項

- Ruby 標準ライブラリのみを使用 (`csv`, `open3`, `pathname`, `set`)
- `gh` API の呼び出しは `--paginate` 付きでメンバー全件を取得
- ユーザー名の比較は大文字小文字を区別しない (GitHub のログイン名は case-insensitive のため)

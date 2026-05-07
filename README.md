# GitHub Copilot Premium Request Dashboard

GitHub Copilot の Premium Request 利用状況 CSV から HTML ダッシュボードを生成するツール。

## 必要環境

- Ruby (標準ライブラリのみ使用、追加 gem 不要)
- Claude Code (プラグインとして利用する場合)
- GitHub Copilot CLI (スキルとして利用する場合)

## 使い方

### Claude Code プラグインとして使う

1. `--plugin-dir` オプションを指定して Claude Code を起動する

```bash
claude --plugin-dir /path/to/copilot-dashboard
```

2. `/copilot-dashboard:copilot-dashboard` コマンドを実行する（`data/` 配下の CSV を自動検出）

### GitHub Copilot CLI のスキルとして使う

1. このリポジトリのディレクトリで Copilot CLI を起動する

```bash
cd /path/to/copilot-dashboard
copilot
```

2. ダッシュボード生成を依頼する（例: 「Copilotの利用状況を可視化して」「premium requestのCSVからダッシュボードを作って」）
   - `skills/generate-dashboard/SKILL.md` が自動で適用される
   - `data/` 配下の CSV を自動検出してダッシュボードを生成する
3. チームメンバーで CSV を絞り込みたい場合は依頼する（例: 「marty-team のメンバーだけのCSVを作って」）
   - `skills/filter-csv-by-team/SKILL.md` が自動で適用される
   - `gh` CLI で Organization の Team メンバーを取得し、CSV から該当ユーザーの行のみを抽出する

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

#### 特定の GitHub Team メンバーだけに絞り込む

`gh` CLI で Team メンバー一覧を取得し、CSV を該当ユーザーの行だけに絞り込む:

```bash
ruby skills/filter-csv-by-team/scripts/filter_by_team.rb <org> <team-slug> data/<CSVファイル名> [出力CSV]
```

- 第 4 引数を省略すると入力 CSV と同じディレクトリに `<team-slug>_<YYYYMM>.csv` が生成される
- 標準出力にチーム総メンバー数、書き出し行数、期間中に利用記録がなかったメンバー一覧が表示される
- 前提: `gh auth status` で Organization の team 読み取り権限がある状態で認証済みであること

絞り込んだ CSV を `generate_dashboard.rb` に渡せば、チーム単位のダッシュボードが作れる:

```bash
ruby scripts/generate_dashboard.rb data/<team-slug>_<YYYYMM>.csv dashboard-<team-slug>_<YYYYMM>.html
```

## ダッシュボードの内容

- **Summary Cards** — Total Requests、Total Cost、Active Users、Avg Quota Usage（クォータ超過ユーザー数も表示）
- **Daily Trend** — 日ごとのリクエスト数推移（折れ線）+ クォータ超過率（折れ線・全ユーザーに占める割合%）、ツールチップ対応
- **User Model Breakdown** — ユーザーごとの全モデル利用状況をクォータ上限に対する割合で積み上げ表示
- **User Ranking** / **Model Breakdown** — 2カラム横並びで表示。User Ranking はリクエスト数順テーブル（各カラムでソート可能）、クォータ消化率バー付き（80% 以上で警告色、100% 以上で超過色）。Model Breakdown はモデルごとのリクエスト数を横棒グラフで表示

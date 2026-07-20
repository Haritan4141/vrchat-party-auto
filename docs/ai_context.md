# AI Context

## プロジェクト概要

このプロジェクトは、VRChat内のパーティー/ダンジョン周回操作を補助するAutoHotkey v2マクロ集です。Autoスキル有効化、再入場クリック、転生アクション、売却アクション、サブスキル実行、特殊な無限ダンジョン用ループをファイルごとに分けています。

主な技術スタック:

- AutoHotkey v2: マクロ本体
- Python 3 + tkinter: 設定GUI
- Windows PowerShell: 検証・Git操作
- Git/GitHub: バージョン管理

起動方法:

- GUI起動: `start_macro_gui.bat`
- AHKを直接起動: 対象の `vrchat_party_macro_*.ahk` をAutoHotkey v2で実行
- GUIは `vrchat_party_macro_gui.py` を使い、共通設定を書き換えて選択したAHKを起動する

検証方法:

```powershell
$files = rg --files -g '*.ahk'
foreach ($f in $files) {
    & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /ErrorStdOut /Validate $f
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED $f"; exit $LASTEXITCODE }
}
python -m py_compile .\vrchat_party_macro_gui.py
```

## 現在の作業目的

直近の依頼は、`vrchat_party_macro_skill_ascend_Vclass_minion_laps_fast.ahk` を新規作成することです。

最終的に達成したい状態:

- 新規マクロがGUIのAHK候補に表示される
- F8開始時と転生後のみAutoスキルをクリックする
- 通常ループはAutoスキル位置へ毎回戻らず、メインスキル1と再入場ボタンを直接往復する。転生タイミングのみAutoスキル位置へ戻す。メインスキル1の連打間隔は約50ms、メインスキル1と再入場の移動時間は80ms、再入場クリック後待機は50ms、通常ループのVRChatアクティブ化後待機は20ms
- ファイル名に `_sale` がないため、売却ロジックは入れない

変更対象:

- `vrchat_party_macro_skill_ascend_Vclass_minion_laps_fast.ahk`
- `README.md`
- `docs/ai_context.md`

## これまでに実施した作業

主要な実装・整理:

- 共通設定を `vrchat_party_macro_common_config.ahk` に集約
- 共通アクションを `vrchat_party_macro_common_actions.ahk` に集約
- 売却/転生の共通処理を `vrchat_party_macro_common_interval_actions.ahk` に集約
- `DoStartAction()` は `EnableAutoSkill()` にリネーム済み
- Autoスキル位置を中心位置として扱う方針に変更済み
- `EnableAutoSkill()` はAutoスキルをクリックするだけで、カーソル位置はAutoスキル位置に維持する
- `DoAction(reentryClickCount := 2)` はAutoスキル位置から再入場位置へ一時移動してクリックし、Autoスキル位置へ戻る。2回クリックは「調べる」→「再入場」、1回クリックは「再入場」のみのパターン
- `vrchat_party_macro_skill_ascend_Vclass_minion_laps.ahk` は、再入場ボタン1回クリックの通常周回に転生ロジックを追加したマクロ
- `vrchat_party_macro_skill_ascend_Vclass_minion_laps_fast.ahk` は、F8開始時と転生後のみAutoスキルをクリックする。通常ループではAutoスキル位置へ毎回戻らず、メインスキル1位置と再入場位置を直接往復する。転生タイミングのみAutoスキル位置へ戻す。メインスキル1はクリック保持30ms + 待機20msで押し始め基準約50ms間隔。再入場クリック後待機は50ms、通常ループのVRChatアクティブ化後待機は20ms。売却なし
- `DoSaleAction()` / `DoAscendAction()` はAutoスキル位置開始・Autoスキル位置終了を前提にし、逃げる、売却または転生、ダンジョン選択までを担当する。Autoスキルクリックとサブスキルクリックは各マクロ本体側で行う
- `ReturnPositionToAutoSkill()` は残しているが、通常の転生・売却・独自ループからは呼び出さない
- `MoveClickAndReturn(dx, dy, clickCount, moveMs)` により、移動、クリック、戻りを共通化済み
- マウス移動後、クリック前に `afterMoveClickWaitMs := 50` だけ待機する。通常の `MoveClickAndReturn()` と `vrchat_party_macro_skill_infinite_dungeon.ahk` の直接移動クリックの両方に適用
- 共通クリック後待機は `afterClickWaitMs := 50`、同じ位置を複数回クリックするときの間隔は `betweenRepeatClickMs := 50`
- `ClickMainSkill(clickCount)` / `ClickSubSkill(clickCount)` により、スキルボタン座標をconfig経由で利用する
- `TestSaleAction()` / `TestAscendAction()` はF6/F7用の共通単体テスト。売却/転生アクションのみを実行し、Autoスキルクリックやサブスキルクリックは行わない
- `RunAscendActionIfDue()` / `RunSaleActionIfDue()` は、転生/売却アクションが実行された場合のみ `true` を返す。呼び出し元マクロは `true` のときにAutoスキルやサブスキルの再開処理を行う
- `ResetAscendActionTimer()` / `ResetSaleActionTimer()` / `RunAscendActionIfDue()` / `RunSaleActionIfDue()` は `vrchat_party_macro_common_interval_actions.ahk` に共通化済み
- サブスキル座標は `subSkillMoveX := 300`, `subSkillMoveY := -50`。メインスキル1暫定座標は `mainSkillMoveX := 80`, `mainSkillMoveY := -40`
- `vrchat_party_macro_skill_infinite_dungeon.ahk` のクリック後待機も共通 `afterClickWaitMs := 50` に揃えた。同じ位置の複数回クリックはないため `betweenRepeatClickMs` は通常使わない。スキル間の移動時間はこのマクロ専用で `infiniteDungeonSkillMoveMs := 80`。ループ末尾待機は `infiniteDungeonLoopSleepMs := 10`、通常ループのVRChatアクティブ化後待機は `infiniteDungeonActivateWaitMs := 20`
- `SmoothMouseMoveRel()` は累積目標位置との差分で移動する。短い移動時間で分割数が少ない場合でも、`mainSkillMoveY := -40` などの設定値どおりの合計移動量になる
- `vrchat_party_macro_skill_ascend_sale_modified_dungeon.ahk` はF8開始時と転生/売却後のみAutoスキルをクリックする。通常ループはダンジョンクリア待機、サブスキル1、再入場1回クリック
- `vrchat_party_macro_skill_infinite_dungeon_laps.ahk` は無限ダンジョン用で、毎ループでサブスキル2回クリック、Autoスキル有効化、再入場位置クリック、Autoスキル位置戻しを行う
- `vrchat_party_macro_skill_ascend_secret_dungeon.ahk` は、サブスキル2回クリック、Autoスキル有効化、`dungeonClearIntervalMs` 待機、再入場ボタン1回クリックを繰り返す。売却は行わず、`ascendIntervalMs` ごとに逃げる、転生、ダンジョン選択を行う
- `vrchat_party_macro_skill_infinite_dungeon.ahk` は、初回だけAutoスキル位置を起点にし、その後はメインスキル位置とサブスキル位置を直接行き来して交互に1回ずつクリックする。転生/売却なし
- GUIで秒単位の間隔設定とダンジョンボタン位置選択が可能。選択したAHKに応じて未使用のダンジョンクリア/転生/売却間隔欄とダンジョンボタン位置を非活性化する
- GUI実行時は既知のマクロを閉じてから選択したAHKを起動し、多重起動を避ける

調査して分かったこと:

- AutoHotkey v2は通常 `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe` または `AutoHotkey.exe` にある
- AHKファイルの日本語コメントを扱うため、文字コードはUTF-8 BOM付きが安全
- 共通部品ファイルは直接実行しない想定で、直接実行時はメッセージを出して終了する
- 作業ディレクトリはIDE表示では `C:\Users\Haritan\Documents\VRChat-Macro` になる場合があるが、実際のGitリポジトリは `C:\Users\Haritan\Documents\vrchat-party-auto`

採用した方針:

- 既存動作を壊さないため、共通処理の変更は影響範囲を確認してから行う
- 特殊ファイルは無理に共通化しすぎず、必要に応じて個別関数を持たせる
- ユーザーの手元変更や未コミット差分は勝手に破棄しない
- Git操作は明示依頼がある場合のみ行う

## 未完了タスク

現時点で明確に残っている作業:

- 新規追加した `vrchat_party_macro_skill_ascend_secret_dungeon.ahk` の実際のVRChat上での動作確認
- `docs/ai_context.md` と新規マクロをGit管理に含めるか、pushするかはユーザー確認が必要

次に確認すべきこと:

- `README.md` の共通設定例が現在の `vrchat_party_macro_common_config.ahk` と一致しているか確認する
  - README例: `dungeonClearIntervalMs := 4500`, `reentryMoveY := -37`, `escapeMoveY := 38`
  - 現在のローカル設定: `dungeonClearIntervalMs := 3000`, `reentryMoveY := -37`, `escapeMoveY := 38`, `ascendIntervalMs := 200000`
  - ダンジョンボタン位置候補: 上から1つ目 `(80, 130)`, 上から2つ目 `(80, 98)`, 上から3つ目 `(80, 60)`, 上から4つ目 `(80, 22)`, 上から5つ目 `(80, -16)`, 永傷の女王:V級 `(-80, 80)`
- GUIのAHK候補に新規追加ファイルが必要になった場合、`macro_files()` の抽出条件で表示されるか確認する
- サブスキルON専用の `skill_ascend_sale` 派生ファイルが必要な場合は、ファイル作成、検証、README更新、push要否を確認する

保留中の判断:

- READMEに現在値そのものを書くか、例として扱うか
- 新しいマクロファイルを追加した場合、READMEの「現在のマクロ本体」一覧へ追記するか

既知の問題・注意:

- AutoHotkeyの `#Warn` で未定義グローバル警告が出やすい。共通ファイル化した関数内では必要な `global` 宣言を忘れないこと
- Autoスキル位置を中心位置として統一しているため、Autoスキル位置にいる状態で `ReturnPositionToAutoSkill()` を呼ぶとカーソル位置がずれる
- 既存マクロに `ReturnPositionToAutoSkill()` を戻す場合は、呼び出し前の位置が再入場位置であることを必ず確認する

## 動作確認・検証状況

今回の `docs/ai_context.md` 作成時に実行した確認:

```powershell
git status -sb
rg --files
Get-Content .\README.md
Get-Content .\vrchat_party_macro_common_config.ahk
Get-Content .\vrchat_party_macro_common_actions.ahk
Get-Content .\vrchat_party_macro_common_interval_actions.ahk
Get-Content .\vrchat_party_macro_skill_ascend_sale.ahk
Get-Content .\vrchat_party_macro_skill_infinite_dungeon_laps.ahk
Get-Content .\vrchat_party_macro_gui.py -TotalCount 220
```

確認できたこと:

- 作成前の作業ツリーは `main...origin/main` でclean
- `docs/` フォルダは存在しなかった
- 現在の主要設定、共通関数、特殊マクロの実装を確認済み

今回の `vrchat_party_macro_skill_ascend_secret_dungeon.ahk` 追加時に実行した確認:

```powershell
python -c "import vrchat_party_macro_gui as gui; print('\n'.join(p.name for p in gui.macro_files()))"
$files = rg --files -g '*.ahk'
foreach ($f in $files) {
    & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /ErrorStdOut /Validate $f
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED $f"; exit $LASTEXITCODE }
}
python -m py_compile .\vrchat_party_macro_gui.py
```

確認できたこと:

- GUIのAHK候補に `vrchat_party_macro_skill_ascend_secret_dungeon.ahk` が表示される
- AutoHotkey v2のValidateは全AHK 10ファイルで成功
- `vrchat_party_macro_gui.py` のPythonコンパイルは成功

まだ確認できていないこと:

- 実際のVRChat上での動作確認
- GUIを起動しての目視確認

通常の変更後に推奨する検証:

```powershell
$files = rg --files -g '*.ahk'
foreach ($f in $files) {
    & 'C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe' /ErrorStdOut /Validate $f
    if ($LASTEXITCODE -ne 0) { Write-Host "FAILED $f"; exit $LASTEXITCODE }
}
python -m py_compile .\vrchat_party_macro_gui.py
git status -sb
```

## 重要なファイル・ディレクトリ

- `README.md`: セットアップ、GUI、共通設定、操作方法の説明
- `start_macro_gui.bat`: GUI起動用
- `vrchat_party_macro_gui.py`: tkinter GUI。秒単位設定、ダンジョンボタン位置選択、AHK起動、多重起動回避を担当
- `vrchat_party_macro_common_config.ahk`: 共通設定。間隔、クリック時間、移動量、VRChatタイトルなど
- `vrchat_party_macro_common_actions.ahk`: Autoスキル有効化、位置戻し、通常メイン動作、クリック/移動/待機の共通関数
- `vrchat_party_macro_common_interval_actions.ahk`: 売却アクション、転生アクション
- `vrchat_party_macro_skill.ahk`: スキル通常周回
- `vrchat_party_macro_skill_ascend.ahk`: スキル周回 + 転生
- `vrchat_party_macro_skill_ascend_Vclass_minion_laps.ahk`: Vclass minion向け通常周回 + 転生。再入場ボタン1回クリック
- `vrchat_party_macro_skill_ascend_Vclass_minion_laps_fast.ahk`: Vclass minion向け高速周回 + 転生。メインスキル1と再入場を80ms移動で直接往復し、メインスキル1は約50ms間隔で連打。再入場クリック後待機は50ms。転生前だけAutoスキル位置へ戻る。売却なし
- `vrchat_party_macro_skill_sale.ahk`: スキル周回 + 売却。転生はコメントアウトで無効化されている箇所がある
- `vrchat_party_macro_skill_ascend_sale.ahk`: スキル周回 + 転生 + 売却
- `vrchat_party_macro_skill_ascend_sale_modified_dungeon.ahk`: 改変ダンジョン用。ダンジョンクリア待機、サブスキル1、再入場1回クリックのループ + 転生 + 売却
- `vrchat_party_macro_skill_ascend_secret_dungeon.ahk`: サブスキル、Autoスキル、待機、再入場ボタン1回クリックのループ + 転生。売却なし。Autoスキル位置中心
- `vrchat_party_macro_skill_infinite_dungeon.ahk`: 初回だけAutoスキル位置を起点にし、その後はメインスキルとサブスキルを80ms移動で直接行き来して交互に1回ずつクリック
- `vrchat_party_macro_skill_infinite_dungeon_laps.ahk`: 無限ダンジョン用。毎ループでサブスキル、Autoスキル、再入場位置クリック、Autoスキル位置戻し
- `docs/ai_context.md`: AI引き継ぎ用ドキュメント。このファイル

## 注意事項・制約

- 既存仕様を壊さないこと
- 共通関数の変更は複数マクロに影響するため、呼び出し元を `rg` で必ず確認すること
- 相対マウス移動の前提位置を崩さないこと
- 影響範囲が大きい変更は、理由と影響範囲を明確にすること
- ユーザーが作成・変更したファイルを勝手に上書きしないこと
- 自分が変更していない差分を勝手に修正・削除しないこと
- 不明点がある場合は推測で大きく進めず、必要に応じて確認すること
- AHKファイル編集時は文字化けに注意し、UTF-8 BOM付きの既存文字コードを壊さないこと
- 手動編集は原則 `apply_patch` を使うこと
- ファイル探索は原則 `rg` / `rg --files` を使うこと

## Git 操作に関する厳守事項

危険なGit操作は絶対に行わないこと。

特に以下は禁止:

- `git reset`
- `git reset --hard`
- `git clean`
- `git checkout -- .`
- `git restore .`
- `git push --force`
- `git push -f`
- `git rebase`
- 履歴を書き換える操作
- ユーザーの許可なくファイルを削除する操作

コミット、ブランチ作成、push、pull、merge、rebaseなどが必要そうな場合は、実行前に必ずユーザーに確認すること。

既存の変更を勝手に破棄しないこと。Git操作を提案する場合は、実行内容とリスクを説明すること。

作業前後に推奨する確認:

```powershell
git status -sb
git diff --stat
```

## 運用ルール

- 次回以降のAIエージェントは、作業開始時にまず `docs/ai_context.md` を読むこと
- 重要な進捗があったら `docs/ai_context.md` を随時更新すること
- 方針変更、重要な実装完了、問題の発見、未完了タスクの追加・解決があった場合は必ず追記すること
- 作業を中断する前、または一段落したタイミングで、最新状況を反映すること
- 更新内容は簡潔かつ具体的に書くこと
- 古い情報を削除する場合は、判断理由が分かるようにすること
- この文書自体の更新も通常の変更と同じく、差分確認と必要な検証を行うこと

## 更新履歴

- 2026-07-21: `永傷の女王:V級` のボタン位置変更に合わせ、Y座標を `25` から `80` へ変更。画面上では55px上方向へ調整。
- 2026-07-04: 古いconfig対応を削除。現行の `reentryMoveX/Y`、`escapeMoveX/Y`、`afterClickWaitMs`、`betweenRepeatClickMs` を必須設定として扱う。
- 2026-07-04: 再入場と逃げるのY座標を分離。再入場は `reentryMoveY := -37`、逃げるは `escapeMoveY := 38`。
- 2026-07-04: `vrchat_party_macro_skill_infinite_dungeon.ahk` の通常ループ末尾待機を10ms、通常ループのVRChatアクティブ化後待機を20msに短縮。F9停止時の100ms待機は維持。
- 2026-07-04: `vrchat_party_macro_skill_infinite_dungeon.ahk` のメインスキル/サブスキル間の直接移動時間を、このマクロ専用の `infiniteDungeonSkillMoveMs := 80` に変更。
- 2026-07-04: `vrchat_party_macro_skill_infinite_dungeon.ahk` の専用クリック後待機を廃止し、共通 `afterClickWaitMs := 50` を使うように変更。configとREADMEから専用設定を削除。
- 2026-07-04: 共通クリック待機を `afterClickWaitMs := 50` と `betweenRepeatClickMs := 50` に分離。
- 2026-07-04: `vrchat_party_macro_skill_ascend_Vclass_minion_laps_fast.ahk` を追加。F8開始時と転生後のみAutoスキルをクリックし、通常ループはAutoスキル位置へ戻らずメインスキル1と再入場を直接往復する。転生前のみAutoスキル位置へ戻す。メインスキル1は約50ms間隔、メインスキル1と再入場の移動時間は80ms、再入場クリック後待機は50ms、通常ループのVRChatアクティブ化後待機は20ms。READMEへAutoスキル分類と説明を追記。
- 2026-07-02: `vrchat_party_macro_skill_ascend_sale_modified_dungeon.ahk` を、F8開始時と転生/売却後のみAutoスキルをクリックし、通常ループはダンジョンクリア待機、サブスキル1、再入場1回クリックだけに変更。未使用になったメインスキル2設定と改変ダンジョンWP待機設定を削除。
- 2026-07-01: 未使用になった `vrchat_party_macro_skill_ascend_sale_overlord.ahk` を削除。READMEへAutoスキルクリックタイミングの3分類を追加。
- 2026-07-01: `vrchat_party_macro_skill_ascend_sale_modified_dungeon.ahk` の転生/売却後Autoスキル再開を削除。通常ループ先頭でAutoスキルをクリックする設計のため、二重クリックでAutoが解除されないようにした。
- 2026-07-01: F6/F7の売却/転生テストを `TestSaleAction()` / `TestAscendAction()` に共通化。テスト時はAutoスキル/サブスキル再開処理を行わず、通常ループ側だけが再開責務を持つように整理。
- 2026-07-01: 転生/売却共通処理からAutoスキルクリックとサブスキルクリックを分離。`DoSaleAction()` / `DoAscendAction()` は逃げる、売却または転生、ダンジョン選択までに限定し、各マクロ側で従来と同じタイミングにAutoスキル/サブスキル再開処理を配置。
- 2026-07-01: `vrchat_party_macro_skill_ascend_sale_modified_dungeon.ahk` を追加。改変ダンジョン向けにAutoスキル、ダンジョンクリア待機、メインスキル2、サブスキル1、WP回復18秒、再入場1回クリックのループを実装。`mainSkill2MoveX/Y` と `modifiedDungeonWpRecoveryWaitMs` をconfigへ追加。
- 2026-07-01: 転生ボタン位置の微調整として `ascendLeftMoveX` を `950` から `970` に変更。ボタンが右へ移動していたため前回の左方向調整を修正。
- 2026-07-01: ダンジョンボタン位置候補に上から5つ目 `(80, -16)` を追加。GUIのプルダウンから選択可能。
- 2026-07-01: READMEへ前提条件、基本使用方法、ファイル名規則、主要マクロ別の用途と推奨編成を追記。Markdown表で見やすく整理。
- 2026-07-01: クリック抜け対策として `afterMoveClickWaitMs := 50` を追加。マウス移動後、クリック前に短く待つように `MoveClickAndReturn()` と `vrchat_party_macro_skill_infinite_dungeon.ahk` の専用クリック処理へ適用。
- 2026-07-01: 再入場処理を `DoAction(reentryClickCount)` / `ClickReentryButton(clickCount)` に共通化。2回クリックは「調べる」→「再入場」、1回クリックは「再入場」のみのパターンとしてコメントを追加。転生/売却タイマー関数も共通化し、売却専用マクロから転生テストと転生タイマー残骸を削除。`common_interval_actions` 側にconfig値を上書きしないguarded defaultを置き、`#Warn` の未代入警告を回避。
- 2026-07-01: 共通化レビューにあわせて不要になった `vrchat_party_macro_skill_Vclass_minion_laps.ahk` を削除。READMEと引き継ぎメモの一覧・説明を更新。
- 2026-07-01: GUIで `_ascend` と `_sale` のどちらも含まないマクロを選択した場合、ダンジョンボタン位置プルダウンも非活性化。保存時は現在のconfig値を維持。
- 2026-07-01: GUIで選択中AHKに応じて未使用の間隔欄を非活性化。`_ascend` を含むマクロだけ転生間隔、`_sale` を含むマクロだけ売却間隔を有効化し、`vrchat_party_macro_skill_infinite_dungeon.ahk` はダンジョンクリア間隔も無効化。
- 2026-07-01: `vrchat_party_macro_skill_infinite_dungeon.ahk` だけクリック後待機を短縮。後に共通 `afterClickWaitMs := 50` へ統合済み。
- 2026-07-01: `vrchat_party_macro_skill_infinite_dungeon.ahk` を、毎回Autoスキル位置へ戻さず、初回Auto起点後はメインスキル/サブスキル間を直接往復する動作に変更。
- 2026-07-01: メインスキル座標のYは維持し、Xを `80` に変更。上から1〜4つ目のダンジョンボタンXに合わせた。
- 2026-07-01: GUIの初期幅を広げ、AHK選択コンボボックスを長いファイル名が見える幅に調整。横方向のリサイズも許可。
- 2026-07-01: `vrchat_party_macro_skill_infinite_dungeon.ahk` を新規作成。メインスキル/サブスキル座標を `vrchat_party_macro_common_config.ahk` に集約し、既存サブスキル直書き箇所を `ClickSubSkill()` 経由に変更。
- 2026-07-01: `vrchat_party_macro_skill_infinite_dungeon.ahk` を `vrchat_party_macro_skill_infinite_dungeon_laps.ahk` にリネーム。READMEと引き継ぎメモ内の参照も更新。
- 2026-06-30: `vrchat_party_macro_skill_ascend_Vclass_minion_laps.ahk` を追加。ダンジョンボタン位置をX/Yペア化し、`永傷の女王:V級` を `(-80, 25)` で追加。
- 2026-06-30: `vrchat_party_macro_skill_Vclass_minion_laps.ahk` を追加。通常周回と同じ構成で、再入場ボタンは1回クリック。
- 2026-06-29: `vrchat_party_macro_skill_ascend_secret_dungeon.ahk` の通常ループを、逃げる・ダンジョン選択ではなく再入場ボタン1回クリックに変更。転生タイミングのみ逃げる・転生・ダンジョン選択を維持。
- 2026-06-29: `vrchat_party_macro_skill_secret_dungeon_ascend.ahk` を `vrchat_party_macro_skill_ascend_secret_dungeon.ahk` にリネーム。`dungeonClearIntervalMs` は `4500`、ダンジョンボタン位置は上から1つ目を有効化。
- 2026-06-29: `dungeonButtonMoveY` に `22 ; 上から4つ目` を追加。GUIのダンジョンボタン位置プルダウンから選択可能。
- 2026-06-25: Autoスキル位置を中心位置として統一。`EnableAutoSkill()` は位置移動しないようにし、再入場クリックや独自ループは `MoveClickAndReturn()` でAutoスキル位置へ戻る形に変更。
- 2026-06-22: `vrchat_party_macro_skill_ascend_secret_dungeon.ahk` を追加。READMEへ追記し、逃げるクリック後の追加待機は入れない初期動作に戻した。
- 2026-06-22: `docs/ai_context.md` を新規作成。プロジェクト概要、主要設計、未完了タスク、検証方法、Git運用ルールを整理。

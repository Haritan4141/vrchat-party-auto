# vrchat-party-auto

VRChat向けのAutoHotkey v2マクロ集です。

## pull後に必要なもの

追加のPythonパッケージは不要です。

必要なもの:

- Git
- AutoHotkey v2
- Python 3

GUIはPython標準ライブラリの `tkinter` だけを使っています。通常のWindows向けPythonであれば追加インストールなしで動きます。

## AutoHotkey v2

以下のどちらかにAutoHotkey v2があれば、そのままGUIから実行できます。

```text
C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe
C:\Program Files\AutoHotkey\v2\AutoHotkey.exe
```

別の場所にある場合は、環境変数 `AUTOHOTKEY_EXE` にAutoHotkey実行ファイルのパスを設定してください。

例:

```powershell
$env:AUTOHOTKEY_EXE = "C:\path\to\AutoHotkey64.exe"
```

## セットアップ

```powershell
cd C:\Users\Haritan\Documents
git clone https://github.com/Haritan4141/vrchat-party-auto.git
cd vrchat-party-auto
```

既にclone済みの場合:

```powershell
cd C:\Users\Haritan\Documents\vrchat-party-auto
git pull
```

## GUIで設定して実行

`start_macro_gui.bat` をダブルクリックしてください。

GUIで変更できる設定:

- ダンジョンクリア間隔
- 転生間隔
- 売却間隔
- ダンジョンボタン位置

使い方:

1. 実行するAHKファイルを選択
2. 間隔を秒で入力
3. ダンジョンボタン位置を選択
4. `適用して実行` を押す

`適用して実行` は、共通設定ファイルを書き換えたあと、既に起動している既知のマクロを閉じてから、選択したAHKを起動します。タスクトレイに同じマクロが多重起動しにくいようにしています。

## 共通設定ファイル

共通設定は以下にあります。

```text
vrchat_party_macro_common_config.ahk
```

主な設定:

```ahk
dungeonClearIntervalMs := 4500   ; ダンジョンクリア間隔
ascendIntervalMs := 600000       ; 転生間隔
saleIntervalMs := 300000         ; 売却間隔
```

クリックや移動量などの操作設定も共通化しています。

```ahk
topLeftMoveX := 60       ; Autoスキルから再入場までの量X
topLeftMoveY := 35       ; Autoスキルから再入場までの量Y
ascendLeftMoveX := 950   ; 転生ボタン方向に動かす量X
ascendLeftMoveY := 45    ; 転生ボタン方向に動かす量Y
dungeonLeftMoveX := 80   ; ダンジョンボタン方向に動かす量X
clickHoldMs := 60        ; クリックを押している時間
betweenClickMs := 300    ; ダブルクリック間隔
moveStepMs := 16         ; マウス移動の刻み
vrchatTitle := "VRChat"
```

ダンジョンボタン位置のY方向も共通化しています。

```ahk
dungeonButtonMoveY := 130   ; 上から1つ目
;dungeonButtonMoveY := 98    ; 上から2つ目
;dungeonButtonMoveY := 60     ; 上から3つ目
;dungeonButtonMoveY := 22     ; 上から4つ目
dungeonLeftMoveY := dungeonButtonMoveY
```

GUIの `ダンジョンボタン位置` プルダウンは、この `dungeonButtonMoveY` の行から自動で作られます。

- `;` が付いていない1行が現在有効な設定
- `;` が付いている行は候補だが無効な設定
- `;` の後ろの説明文がGUIの選択肢名

例えば、共通設定を以下のように変更すると、GUIの選択肢も `上段 / 中段 / 下段` になります。

```ahk
;dungeonButtonMoveY := 140   ; 上段
dungeonButtonMoveY := 105    ; 中段
;dungeonButtonMoveY := 70    ; 下段
```

GUIで選択して保存すると、選んだ1行だけが有効化され、他の候補はコメントアウトされます。

## 共通アクションファイル

共通処理は以下に分けています。

```text
vrchat_party_macro_common_actions.ahk
vrchat_party_macro_common_interval_actions.ahk
```

これらは部品ファイルなので、直接実行せず、マクロ本体の `.ahk` を実行してください。GUIの実行候補にも表示されません。

各マクロはAutoスキル位置を中心位置として扱います。再入場、逃げる、転生、売却、ダンジョン選択、サブスキルは、Autoスキル位置から一時的に移動してクリックし、クリック後はAutoスキル位置へ戻ります。

`DoSaleAction()` と `DoAscendAction()` は、引数に `true` を渡すとダンジョン選択後にサブスキル（エクスヒール）をクリックします。引数なしの場合は従来通りサブスキルを使いません。

```ahk
DoSaleAction(true)
DoAscendAction(true)
```

現在のマクロ本体:

```text
vrchat_party_macro_skill.ahk
vrchat_party_macro_skill_Vclass_minion_laps.ahk
vrchat_party_macro_skill_ascend.ahk
vrchat_party_macro_skill_ascend_sale.ahk
vrchat_party_macro_skill_ascend_sale_overlord.ahk
vrchat_party_macro_skill_ascend_secret_dungeon.ahk
vrchat_party_macro_skill_infinite_dungeon.ahk
vrchat_party_macro_skill_sale.ahk
```

`vrchat_party_macro_skill_ascend_secret_dungeon.ahk` は、サブスキル（エクスヒール）クリック、Autoスキル有効化、GUIのダンジョンクリア間隔だけ待機、再入場ボタン1回クリックを繰り返します。売却は行わず、転生だけGUIの転生間隔で実行します。

`vrchat_party_macro_skill_Vclass_minion_laps.ahk` は、通常周回マクロと同じ構成で、GUIのダンジョンクリア間隔だけ待機したあと、再入場ボタンを1回だけクリックします。

## 直接AHKを実行する場合

GUIを使わずに `.ahk` ファイルを直接実行しても動きます。

例:

```text
vrchat_party_macro_skill_ascend_sale.ahk
```

操作:

- `F8`: マクロ開始/停止
- `F9`: 緊急停止
- `F6`: 売却アクションのテストに対応しているファイルで使用
- `F7`: 転生アクションのテストに対応しているファイルで使用

## git管理対象外

以下は `.gitignore` で除外しています。

```text
AutoHotkey_2.0.19_setup.exe
bak/
__pycache__/
```

# vrchat-party-auto

VRChat向けのAutoHotkey v2マクロ集です。

## 前提条件

このマクロは製作者の環境を前提に作成しています。環境差によりクリック位置やタイミングに若干のずれが出る可能性があるため、必要に応じて各自で調整してください。

| 項目 | 前提 |
| --- | --- |
| アバター | Busy Home 1.19m |
| 視野角 | 70度 |
| ウィンドウ解像度 | 1600x900 |
| フレームレート | 高いほど安定するため無制限推奨 |

## 使用方法

1. リスポーン位置から動かず、ダンジョンに入ります。
2. Autoスキルの `o` にカーソルを合わせます。この位置をセンターポジションとして扱います。
3. `F8` でマクロを開始します。
4. `F9` で停止します。

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

実行するAHKに転生や売却ロジックがない場合、対応する間隔欄は非活性になります。転生と売却のどちらもない場合は、ダンジョンボタン位置も非活性になります。`vrchat_party_macro_skill_infinite_dungeon.ahk` はダンジョンクリア間隔も使わないため、ダンジョンクリア間隔、転生間隔、売却間隔、ダンジョンボタン位置が非活性になります。

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
ascendIntervalMs := 300000       ; 転生間隔
saleIntervalMs := 300000         ; 売却間隔
```

クリックや移動量などの操作設定も共通化しています。

```ahk
topLeftMoveX := 60       ; Autoスキルから再入場までの量X
topLeftMoveY := 38       ; Autoスキルから再入場までの量Y
ascendLeftMoveX := 930   ; 転生ボタン方向に動かす量X
ascendLeftMoveY := 45    ; 転生ボタン方向に動かす量Y
mainSkillMoveX := 80     ; Autoスキルからメインスキルボタンまでの量X（暫定）
mainSkillMoveY := -50    ; Autoスキルからメインスキルボタンまでの量Y（暫定）
subSkillMoveX := 300     ; Autoスキルからサブスキル（エクスヒール）ボタンまでの量X
subSkillMoveY := -50     ; Autoスキルからサブスキル（エクスヒール）ボタンまでの量Y
clickHoldMs := 60        ; クリックを押している時間
betweenClickMs := 300    ; ダブルクリック間隔
afterMoveClickWaitMs := 50  ; マウス移動後、クリック前の待機
infiniteDungeonSkillBetweenClickMs := 80  ; 無限ダンジョン交互スキルのクリック後待機
moveStepMs := 16         ; マウス移動の刻み
vrchatTitle := "VRChat"
```

ダンジョンボタン位置のX/Y方向も共通化しています。

```ahk
dungeonButtonMoveX := 80    ; 上から1つ目
dungeonButtonMoveY := 130   ; 上から1つ目
;dungeonButtonMoveX := 80    ; 上から2つ目
;dungeonButtonMoveY := 98    ; 上から2つ目
;dungeonButtonMoveX := 80    ; 上から3つ目
;dungeonButtonMoveY := 60     ; 上から3つ目
;dungeonButtonMoveX := 80    ; 上から4つ目
;dungeonButtonMoveY := 22     ; 上から4つ目
;dungeonButtonMoveX := 80    ; 上から5つ目
;dungeonButtonMoveY := -16    ; 上から5つ目
;dungeonButtonMoveX := -80   ; 永傷の女王:V級
;dungeonButtonMoveY := 25    ; 永傷の女王:V級
dungeonLeftMoveX := dungeonButtonMoveX
dungeonLeftMoveY := dungeonButtonMoveY
```

GUIの `ダンジョンボタン位置` プルダウンは、この `dungeonButtonMoveX` / `dungeonButtonMoveY` の候補ペアから自動で作られます。

- `;` が付いていないX/Yの2行セットが現在有効な設定
- `;` が付いているX/Yの2行セットは候補だが無効な設定
- `;` の後ろの説明文がGUIの選択肢名

例えば、共通設定を以下のように変更すると、GUIの選択肢も `上段 / 中段 / 下段` になります。

```ahk
;dungeonButtonMoveX := 80    ; 上段
;dungeonButtonMoveY := 140   ; 上段
dungeonButtonMoveX := 80     ; 中段
dungeonButtonMoveY := 105    ; 中段
;dungeonButtonMoveX := 80    ; 下段
;dungeonButtonMoveY := 70    ; 下段
```

GUIで選択して保存すると、選んだX/Yの2行セットだけが有効化され、他の候補はコメントアウトされます。

## 共通アクションファイル

共通処理は以下に分けています。

```text
vrchat_party_macro_common_actions.ahk
vrchat_party_macro_common_interval_actions.ahk
```

これらは部品ファイルなので、直接実行せず、マクロ本体の `.ahk` を実行してください。GUIの実行候補にも表示されません。

各マクロはAutoスキル位置を中心位置として扱います。再入場、逃げる、転生、売却、ダンジョン選択、メインスキル、サブスキルは、Autoスキル位置から一時的に移動してクリックし、クリック後はAutoスキル位置へ戻ります。例外として、`vrchat_party_macro_skill_infinite_dungeon.ahk` は初回だけAutoスキル位置を起点にし、その後はメインスキル位置とサブスキル位置を直接行き来します。

再入場クリックは `DoAction()` で共通化しています。通常は `DoAction()` の2回クリックで、同じ位置のボタン表示が `調べる` から `再入場` に変わるパターンです。`DoAction(1)` は `調べる` が出ず、最初から `再入場` だけを1回クリックするパターンで使います。

`DoSaleAction()` と `DoAscendAction()` は、引数に `true` を渡すとダンジョン選択後にサブスキル（エクスヒール）をクリックします。引数なしの場合は従来通りサブスキルを使いません。

```ahk
DoSaleAction(true)
DoAscendAction(true)
```

## 各ファイルの説明

ファイル名に `_ascend` が含まれるマクロは自動転生あり、`_sale` が含まれるマクロは自動売却ありです。自動売却は紫以下一括売却を行います。

現在のマクロ本体:

```text
vrchat_party_macro_skill.ahk
vrchat_party_macro_skill_ascend.ahk
vrchat_party_macro_skill_ascend_Vclass_minion_laps.ahk
vrchat_party_macro_skill_ascend_sale.ahk
vrchat_party_macro_skill_ascend_sale_overlord.ahk
vrchat_party_macro_skill_ascend_secret_dungeon.ahk
vrchat_party_macro_skill_infinite_dungeon.ahk
vrchat_party_macro_skill_infinite_dungeon_laps.ahk
vrchat_party_macro_skill_sale.ahk
```

### `vrchat_party_macro_skill.ahk`

Autoスキル実行後、ダンジョンクリアを待ち、`調べる`、`再入場` の順にクリックします。

### `vrchat_party_macro_skill_infinite_dungeon.ahk`

無限ダンジョン最上階登頂用です。初回だけAutoスキル位置を起点にし、その後はメインスキルとサブスキルを直接行き来して交互に1回ずつクリックします。

推奨編成:

| 枠 | 内容 |
| --- | --- |
| キャラクター | ミルティナ / 桔梗 |
| 武器 | エクスカリバー |
| 防具 | 巫女服 |
| カード | ルルネカード |
| 称号 | 聖戦士 |
| メインスキル1 | おもてなし |
| サブスキル1 | 大結界:攻 |

### `vrchat_party_macro_skill_ascend_secret_dungeon.ahk`

9面ダンジョンの雑魚狩り金策用です。サブスキル（エクスヒール）クリック、Autoスキル有効化、GUIのダンジョンクリア間隔だけ待機、再入場ボタン1回クリックを繰り返します。売却は行わず、転生だけGUIの転生間隔で実行します。

### `vrchat_party_macro_skill_ascend_Vclass_minion_laps.ahk`

永傷の女王:V級ダンジョンの雑魚狩り金策用です。GUIのダンジョンクリア間隔だけ待機したあと、再入場ボタンを1回だけクリックし、GUIの転生間隔で転生アクションを実行します。

2パン編成:

| 枠 | 内容 |
| --- | --- |
| キャラクター | エク / なんでも |
| 武器 | 黄金卿の支配者キューブ |
| 防具 | 聖なる巫女服 |
| カード | サナティアカード |
| 称号 | enx3.0 |
| メインスキル1 | イグナイト |

1パン編成:

| 枠 | 内容 |
| --- | --- |
| キャラクター | エク / なんでも |
| 武器 | エクスカリバー |
| 防具 | 聖なる巫女服 |
| カード | 火力系カード |
| 称号 | enx3.0 |
| メインスキル1 | イグナイト |

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

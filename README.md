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
reentryMoveX := -60      ; Autoスキルから再入場までの量X
reentryMoveY := -37      ; Autoスキルから再入場までの量Y
escapeMoveX := -58       ; Autoスキルから逃げるまでの量X
escapeMoveY := 40        ; Autoスキルから逃げるまでの量Y
ascendLeftMoveX := 970   ; 転生ボタン方向に動かす量X
ascendLeftMoveY := 43    ; 転生ボタン方向に動かす量Y
mainSkillMoveX := 80     ; Autoスキルからメインスキル1ボタンまでの量X
mainSkillMoveY := -40    ; Autoスキルからメインスキル1ボタンまでの量Y
subSkillMoveX := 300     ; Autoスキルからサブスキル1ボタンまでの量X
subSkillMoveY := -50     ; Autoスキルからサブスキル1ボタンまでの量Y
clickHoldMs := 60        ; クリックを押している時間
afterClickWaitMs := 50   ; 1クリック後の待機
betweenRepeatClickMs := 50  ; 同じ位置を複数回クリックするときの間隔
afterMoveClickWaitMs := 50  ; マウス移動後、クリック前の待機
moveStepMs := 16         ; マウス移動の刻み
vrchatTitle := "VRChat"
```

ダンジョンボタン位置のX/Y方向も共通化しています。

```ahk
dungeonButtonMoveX := 80    ; 上から1つ目
dungeonButtonMoveY := 140   ; 上から1つ目
;dungeonButtonMoveX := 80    ; 上から2つ目
;dungeonButtonMoveY := 98    ; 上から2つ目
;dungeonButtonMoveX := 80    ; 上から3つ目
;dungeonButtonMoveY := 60     ; 上から3つ目
;dungeonButtonMoveX := 80    ; 上から4つ目
;dungeonButtonMoveY := 22     ; 上から4つ目
;dungeonButtonMoveX := 80    ; 上から5つ目
;dungeonButtonMoveY := -16    ; 上から5つ目
;dungeonButtonMoveX := -80   ; 永傷の女王:V級
;dungeonButtonMoveY := 80    ; 永傷の女王:V級
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

`DoSaleAction()` と `DoAscendAction()` は、逃げる、売却または転生、ダンジョン選択までを担当し、Autoスキル位置へ戻って終了します。Autoスキルクリックやサブスキルクリックは、各マクロ本体側で必要なタイミングに実行します。

F6/F7のテストは `TestSaleAction()` / `TestAscendAction()` で共通化しています。テスト時は売却/転生アクション単体だけを実行し、Autoスキルクリックやサブスキルクリックは行いません。各ボタンへ800msで移動し、クリック前に500ms停止、中央へ戻った後に300ms停止するため、移動経路とクリック位置を目視確認できます。通常の自動転生・売却の速度には影響しません。

## 各ファイルの説明

ファイル名に `_ascend` が含まれるマクロは自動転生あり、`_sale` が含まれるマクロは自動売却ありです。自動売却は紫以下一括売却を行います。

Autoスキルクリックのタイミングは、マクロごとに以下の3系統です。

### 1. ループごとにAutoスキルをクリックする

```text
vrchat_party_macro_skill_ascend_secret_dungeon.ahk
vrchat_party_macro_skill_infinite_dungeon_laps.ahk
```

### 2. F8開始時 + 転生/売却後にAutoスキルをクリックする

```text
vrchat_party_macro_skill_ascend.ahk
vrchat_party_macro_skill_sale.ahk
vrchat_party_macro_skill_ascend_sale.ahk
vrchat_party_macro_skill_ascend_sale_modified_dungeon.ahk
vrchat_party_macro_skill_ascend_Vclass_minion_laps.ahk
vrchat_party_macro_skill_ascend_Vclass_minion_laps_fast.ahk
vrchat_party_macro_skill_ascend_Vclass_minion_laps_veryfast.ahk
```

### 3. Autoスキルをクリックしない / F8のみ

```text
vrchat_party_macro_skill_infinite_dungeon.ahk: Autoスキルクリックなし。メイン/サブスキル往復のみ。
vrchat_party_macro_skill.ahk: F8開始時のみAutoスキルクリック。転生/売却なし。
```

### Autoスキル実行、ダンジョンクリア後、調べる・再入場

`vrchat_party_macro_skill.ahk`

### 無限ダンジョン 最上階登頂

`vrchat_party_macro_skill_infinite_dungeon.ahk`

メインスキル1とサブスキル1を直接往復します。クリック後待機は共通の50ms、スキル間の移動時間はこのマクロ専用で80msです。ループ末尾待機は10ms、通常ループのVRChatアクティブ化後待機は20msです。

| 枠 | 内容 |
| --- | --- |
| キャラクター | ミルティナ / 桔梗 |
| 武器 | ★エクスカリバー |
| 防具 | ★九部の巫女服 |
| カード | ルルネカード |
| 称号 | 聖戦士 |
| メインスキル1 | おもてなし |
| サブスキル1 | 大結界:攻 |

### 9面ダンジョン 雑魚狩り金策

`vrchat_party_macro_skill_ascend_secret_dungeon.ahk`

### 永傷の女王:V級ダンジョン 雑魚狩り金策

`vrchat_party_macro_skill_ascend_Vclass_minion_laps.ahk`

| パターン | キャラクター | 武器 | 防具 | カード | 称号 | メインスキル1 |
| --- | --- | --- | --- | --- | --- | --- |
| 2パン編成 | エク / なんでも | 黄金卿の支配者キューブ | 聖なる巫女服 | レグニアカード | enx3.0 | イグナイト |
| 1パン編成 | エク / なんでも | ★エクスカリバー | 聖なる巫女服 | ビナコカード | enx3.0 | イグナイト |
| 1パン編成 | エク / なんでも | 黄金卿の支配者キューブ | ★ルルネの改変服 | ルルネカード | enx3.0 | イグナイト |

### 永傷の女王:V級ダンジョン 雑魚狩り金策（高速）

`vrchat_party_macro_skill_ascend_Vclass_minion_laps_fast.ahk`

F8開始時と転生後のみAutoスキルをクリックします。通常ループはAutoスキル位置へ毎回戻らず、メインスキル1と再入場ボタンを直接往復します。転生タイミングのみAutoスキル位置へ戻してから転生アクションへ入ります。`d4cc512`時点の安定設定で、メインスキル1の連打間隔は約50ms（押下30ms + 待機20ms）、移動時間は80ms、移動後待機は50msです。再入場クリックは押下60ms + 待機50ms、通常ループ末尾待機は50ms、VRChatアクティブ化後待機は20msです。

### 永傷の女王:V級ダンジョン 雑魚狩り金策（最速）

`vrchat_party_macro_skill_ascend_Vclass_minion_laps_veryfast.ahk`

メインスキル1を約20ms間隔（押下10ms + 待機10ms）で連打する最速版です。移動時間は48ms、メインスキル側の移動後待機は30msを維持します。再入場側は安定性を優先し、移動後待機50ms、クリック押下60ms + 待機50ms、ループ末尾待機50ms、VRChatアクティブ化後待機20msです。

### 改変ダンジョン

`vrchat_party_macro_skill_ascend_sale_modified_dungeon.ahk`

| 枠 | 内容 |
| --- | --- |
| キャラクター | プラム / イズール |
| 武器 | 追撃メタルキューブ |
| 防具 | ★プラムの改変服 |
| カード | ショコラカード |
| 称号 | 影の王 |
| メインスキル1 | 7連狐火 |
| サブスキル1 | 心眼 |

## 直接AHKを実行する場合

GUIを使わずに `.ahk` ファイルを直接実行しても動きます。

例:

```text
vrchat_party_macro_skill_ascend_sale.ahk
```

操作:

- `F8`: マクロ開始/停止
- `F9`: 緊急停止
- `F6`: 売却アクションの単体テストに対応しているファイルで使用
- `F7`: 転生アクションの単体テストに対応しているファイルで使用

## git管理対象外

以下は `.gitignore` で除外しています。

```text
AutoHotkey_2.0.19_setup.exe
bak/
__pycache__/
```

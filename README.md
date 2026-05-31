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

使い方:

1. 実行するAHKファイルを選択
2. 間隔を秒で入力
3. `適用して実行` を押す

`適用して実行` は、共通設定ファイルを書き換えたあと、既に起動している既知のマクロを閉じてから、選択したAHKを起動します。タスクトレイに同じマクロが多重起動しにくいようにしています。

## 共通設定ファイル

共通設定は以下にあります。

```text
vrchat_party_macro_common_config.ahk
```

主な設定:

```ahk
dungeonClearIntervalMs := 1500   ; ダンジョンクリア間隔
ascendIntervalMs := 30000        ; 転生間隔
saleIntervalMs := 300000         ; 売却間隔
```

ダンジョンボタン位置のY方向も共通化しています。

```ahk
;dungeonButtonMoveY := 130   ; 上から1つ目
;dungeonButtonMoveY := 98    ; 上から2つ目
dungeonButtonMoveY := 60     ; 上から3つ目
```

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

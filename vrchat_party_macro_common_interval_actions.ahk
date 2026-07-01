; VRChat party macro shared ascend/sale interval actions.

if (A_LineFile = A_ScriptFullPath) {
    running := false
    topLeftMoveX := 0
    topLeftMoveY := 0
    clickHoldMs := 0
    betweenClickMs := 0
    dungeonClearIntervalMs := 0
    ascendIntervalMs := 0
    saleIntervalMs := 0
    lastAscendActionTick := 0
    lastSaleActionTick := 0
    ascendLeftMoveX := 0
    ascendLeftMoveY := 0
    dungeonLeftMoveX := 0
    dungeonLeftMoveY := 0
    vrchatTitle := ""
    MsgBox "This file is shared parts. Run a macro .ahk file."
    ExitApp
}

#Include "vrchat_party_macro_common_actions.ahk"

; These are normally assigned by vrchat_party_macro_common_config.ahk before this file is included.
; Guarded defaults keep #Warn quiet without overwriting config values.
if (!IsSet(ascendIntervalMs))
    ascendIntervalMs := 0
if (!IsSet(saleIntervalMs))
    saleIntervalMs := 0

ResetAscendActionTimer()
{
    global lastAscendActionTick
    lastAscendActionTick := A_TickCount
}

ResetSaleActionTimer()
{
    global lastSaleActionTick
    lastSaleActionTick := A_TickCount
}

TestSaleAction()
{
    global running

    if (running) {
        ToolTip "Stop macro before F6 test"
        SetTimer () => ToolTip(), -800
        return
    }

    running := true
    ToolTip "Testing sale action"
    DoSaleAction()
    running := false
    NeutralizeInputs()

    ToolTip "Sale action test done"
    SetTimer () => ToolTip(), -800
}

TestAscendAction()
{
    global running

    if (running) {
        ToolTip "Stop macro before F7 test"
        SetTimer () => ToolTip(), -800
        return
    }

    running := true
    ToolTip "Testing ascend action"
    DoAscendAction()
    running := false
    NeutralizeInputs()

    ToolTip "Ascend action test done"
    SetTimer () => ToolTip(), -800
}

RunAscendActionIfDue()
{
    global running, lastAscendActionTick, ascendIntervalMs

    if (!running)
        return false

    if (A_TickCount - lastAscendActionTick < ascendIntervalMs)
        return false

    lastAscendActionTick := A_TickCount
    return DoAscendAction()
}

RunSaleActionIfDue()
{
    global running, lastSaleActionTick, saleIntervalMs

    if (!running)
        return false

    if (A_TickCount - lastSaleActionTick < saleIntervalMs)
        return false

    lastSaleActionTick := A_TickCount
    return DoSaleAction()
}

; =========================
; 売却アクション
; =========================
DoSaleAction()
{
    global running, topLeftMoveX, topLeftMoveY, dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    ; 逃げるボタンクリック
    if (!MoveClickAndReturn(-topLeftMoveX, topLeftMoveY, 1))
        return false

    ; メインメニューへ戻るボタンクリック
    if (!MoveClickAndReturn(100, 100, 1))
        return false

    ; 預かり所ボタンクリック
    if (!MoveClickAndReturn(50, 50, 1))
        return false

    ; 売却モードボタンクリック
    if (!MoveClickAndReturn(380, 100, 1))
        return false

    ; 紫以下売却ボタンクリック
    if (!MoveClickAndReturn(600, 100, 2))
        return false

    ; メインメニューへ戻るボタンクリック
    if (!MoveClickAndReturn(100, 100, 1))
        return false

    ; 冒険に出るボタンクリック
    if (!MoveClickAndReturn(50, -20, 1))
        return false

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return false

    ; Autoスキルとサブスキルの再開処理は各マクロ側で行う。
    return running
}

; =========================
; 転生アクション
; =========================
DoAscendAction()
{
    global running, topLeftMoveX, topLeftMoveY, ascendLeftMoveX, ascendLeftMoveY, dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    ; 逃げるボタンクリック
    if (!MoveClickAndReturn(-topLeftMoveX, topLeftMoveY, 1))
        return false

    ; 転生ボタンクリック
    if (!MoveClickAndReturn(-ascendLeftMoveX, -ascendLeftMoveY, 1))
        return false

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return false

    ; Autoスキルとサブスキルの再開処理は各マクロ側で行う。
    return running
}

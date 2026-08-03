; VRChat party macro shared ascend/sale interval actions.

if (A_LineFile = A_ScriptFullPath) {
    running := false
    reentryMoveX := 0
    reentryMoveY := 0
    escapeMoveX := 0
    escapeMoveY := 0
    clickHoldMs := 0
    afterClickWaitMs := 0
    betweenRepeatClickMs := 0
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

; F6/F7の単体テストだけ、各クリック位置と移動経路を目視しやすくする。
testActionMoveMs := 800
testActionBeforeClickWaitMs := 500
testActionAfterReturnWaitMs := 300

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
    global running, testActionMoveMs, testActionBeforeClickWaitMs, testActionAfterReturnWaitMs

    if (running) {
        ToolTip "Stop macro before F6 test"
        SetTimer () => ToolTip(), -800
        return
    }

    running := true
    ToolTip "Testing sale action"
    DoSaleAction(testActionMoveMs, testActionBeforeClickWaitMs, testActionAfterReturnWaitMs)
    running := false
    NeutralizeInputs()

    ToolTip "Sale action test done"
    SetTimer () => ToolTip(), -800
}

TestAscendAction()
{
    global running, testActionMoveMs, testActionBeforeClickWaitMs, testActionAfterReturnWaitMs

    if (running) {
        ToolTip "Stop macro before F7 test"
        SetTimer () => ToolTip(), -800
        return
    }

    running := true
    ToolTip "Testing ascend action"
    DoAscendAction(testActionMoveMs, testActionBeforeClickWaitMs, testActionAfterReturnWaitMs)
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
DoSaleAction(moveMs := 250, beforeClickWaitMs := -1, afterReturnWaitMs := 0)
{
    global running, escapeMoveX, escapeMoveY, dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    ; 逃げるボタンクリック
    if (!MoveClickAndReturn(escapeMoveX, escapeMoveY, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; メインメニューへ戻るボタンクリック
    if (!MoveClickAndReturn(80, 108, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; 預かり所ボタンクリック
    if (!MoveClickAndReturn(80, 40, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; 売却モードボタンクリック
    if (!MoveClickAndReturn(380, 110, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; 紫以下売却ボタンクリック
    if (!MoveClickAndReturn(590, 100, 2, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; メインメニューへ戻るボタンクリック
    if (!MoveClickAndReturn(100, 100, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; 冒険に出るボタンクリック
    if (!MoveClickAndReturn(80, -15, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; Autoスキルとサブスキルの再開処理は各マクロ側で行う。
    return running
}

; =========================
; 転生アクション
; =========================
DoAscendAction(moveMs := 250, beforeClickWaitMs := -1, afterReturnWaitMs := 0)
{
    global running, escapeMoveX, escapeMoveY, ascendLeftMoveX, ascendLeftMoveY, dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    ; 逃げるボタンクリック
    if (!MoveClickAndReturn(escapeMoveX, escapeMoveY, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; 転生ボタンクリック
    if (!MoveClickAndReturn(-ascendLeftMoveX, -ascendLeftMoveY, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1, moveMs, beforeClickWaitMs, afterReturnWaitMs))
        return false

    ; Autoスキルとサブスキルの再開処理は各マクロ側で行う。
    return running
}

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

RunAscendActionIfDue(useSubSkill := false)
{
    global running, lastAscendActionTick, ascendIntervalMs

    if (!running)
        return

    if (A_TickCount - lastAscendActionTick < ascendIntervalMs)
        return

    lastAscendActionTick := A_TickCount
    DoAscendAction(useSubSkill)
}

RunSaleActionIfDue(useSubSkill := false)
{
    global running, lastSaleActionTick, saleIntervalMs

    if (!running)
        return

    if (A_TickCount - lastSaleActionTick < saleIntervalMs)
        return

    lastSaleActionTick := A_TickCount
    DoSaleAction(useSubSkill)
}

; =========================
; 売却アクション
; =========================
DoSaleAction(useSubSkill := false)
{
    global running, topLeftMoveX, topLeftMoveY, dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return

    try WinActivate vrchatTitle
    Sleep 100

    ; 逃げるボタンクリック
    if (!MoveClickAndReturn(-topLeftMoveX, topLeftMoveY, 1))
        return

    ; メインメニューへ戻るボタンクリック
    if (!MoveClickAndReturn(100, 100, 1))
        return

    ; 預かり所ボタンクリック
    if (!MoveClickAndReturn(50, 50, 1))
        return

    ; 売却モードボタンクリック
    if (!MoveClickAndReturn(380, 100, 1))
        return

    ; 紫以下売却ボタンクリック
    if (!MoveClickAndReturn(600, 100, 2))
        return

    ; メインメニューへ戻るボタンクリック
    if (!MoveClickAndReturn(100, 100, 1))
        return

    ; 冒険に出るボタンクリック
    if (!MoveClickAndReturn(50, -20, 1))
        return

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return

    if (useSubSkill) {
        ; サブスキル（エクスヒール）ボタンクリック
        if (!ClickSubSkill(2))
            return
    }

    ; Autoスキル有効化
    if (!EnableAutoSkill())
        return
}

; =========================
; 転生アクション
; =========================
DoAscendAction(useSubSkill := false)
{
    global running, topLeftMoveX, topLeftMoveY, ascendLeftMoveX, ascendLeftMoveY, dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return

    try WinActivate vrchatTitle
    Sleep 100

    ; 逃げるボタンクリック
    if (!MoveClickAndReturn(-topLeftMoveX, topLeftMoveY, 1))
        return

    ; 転生ボタンクリック
    if (!MoveClickAndReturn(-ascendLeftMoveX, -ascendLeftMoveY, 1))
        return

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return

    if (useSubSkill) {
        ; サブスキル（エクスヒール）ボタンクリック
        if (!ClickSubSkill(2))
            return
    }

    ; Autoスキル有効化
    if (!EnableAutoSkill())
        return
}

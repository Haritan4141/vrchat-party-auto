#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetTitleMatchMode 2

CoordMode "Mouse", "Client"

#Include "vrchat_party_macro_common_config.ahk"

; =========================
; 状態
; =========================
global running := false
global lastAscendActionTick := 0
global lastSaleActionTick := 0

#Include "vrchat_party_macro_common_interval_actions.ahk"

; =========================
; F8: 開始/停止
; =========================
F8::
{
    global running
    running := !running

    if (running) {
        ResetAscendActionTimer()
        ResetSaleActionTimer()
        ToolTip "Macro: ON"
        if (!EnableAutoSkill())
            return
        SetTimer RunLoop, -1
    } else {
        ToolTip "Macro: OFF"
        NeutralizeInputs()
    }
    SetTimer () => ToolTip(), -800
}

; =========================
; F9: 緊急停止
; =========================
F9::
{
    global running
    running := false
    NeutralizeInputs()
    ToolTip "Macro: FORCE STOP"
    Sleep 100
;    ExitApp
}

; =========================
; F6: 売却アクションのテスト
; =========================
F6::
{
    global running

    if (running) {
        ToolTip "Stop macro before F6 test"
        SetTimer () => ToolTip(), -800
        return
    }

    running := true
    ToolTip "Testing sale action"
    DoSaleAction(true)
    running := false
    NeutralizeInputs()

    ToolTip "Sale action test done"
    SetTimer () => ToolTip(), -800
}

; =========================
; F7: 転生アクションのテスト
; =========================
F7::
{
    global running

    if (running) {
        ToolTip "Stop macro before F7 test"
        SetTimer () => ToolTip(), -800
        return
    }

    running := true
    ToolTip "Testing ascend action"
    DoAscendAction(true)
    running := false
    NeutralizeInputs()

    ToolTip "Ascend action test done"
    SetTimer () => ToolTip(), -800
}

; =========================
; メインループ
; =========================
RunLoop()
{
    global running

    if (!running)
        return

    while (running) {
        RunOverlordDungeon()
        RunAscendActionIfDue()
        RunSaleActionIfDue()
        Sleep 50
    }
}

; =========================
; オーバーロードダンジョン動作
; =========================
RunOverlordDungeon()
{
    global running, dungeonClearIntervalMs, clickHoldMs, topLeftMoveX, topLeftMoveY, dungeonLeftMoveX, dungeonLeftMoveY

    ; ダンジョンクリア待ち時間
    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return

    ; クリック
    LeftClick(clickHoldMs)
    if (!running)
        return false

    ; Autoスキルに位置を戻す
    if (!ReturnPositionToAutoSkill())
        return

    ; 逃げるボタンクリック
    if (!MoveClickAndReturn(-topLeftMoveX, topLeftMoveY, 1))
        return

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return

    ; サブスキル（エクスヒール）ボタンクリック
    if (!MoveClickAndReturn(300, -50, 1))
        return

    ; Autoスキル有効化
    if (!EnableAutoSkill())
        return

}

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

RunAscendActionIfDue()
{
    global running, lastAscendActionTick, ascendIntervalMs

    if (!running)
        return

    if (A_TickCount - lastAscendActionTick < ascendIntervalMs)
        return

    lastAscendActionTick := A_TickCount
    DoAscendAction(true)
}

RunSaleActionIfDue()
{
    global running, lastSaleActionTick, saleIntervalMs

    if (!running)
        return

    if (A_TickCount - lastSaleActionTick < saleIntervalMs)
        return

    lastSaleActionTick := A_TickCount
    DoSaleAction(true)
}

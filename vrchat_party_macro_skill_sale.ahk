#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetTitleMatchMode 2

CoordMode "Mouse", "Client"

#Include "vrchat_party_macro_common_config.ahk"

; =========================
; 設定
; =========================
topLeftMoveX := 60       ; 左上/左下方向に動かす量X
topLeftMoveY := 35       ; 左上/左下方向に動かす量Y
ascendLeftMoveX := 950   ; 転生ボタン方向に動かす量X
ascendLeftMoveY := 60    ; 転生ボタン方向に動かす量Y
dungeonLeftMoveX := 80   ; ダンジョンボタン方向に動かす量X
dungeonLeftMoveY := 98   ; ダンジョンボタン方向に動かす量Y
clickHoldMs := 60        ; クリックを押している時間
betweenClickMs := 300    ; ダブルクリック間隔
moveStepMs := 16         ; マウス移動の刻み
vrchatTitle := "VRChat"

; =========================
; 状態
; =========================
global running := false
global lastAscendActionTick := 0
global lastSaleActionTick := 0

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
    DoSaleAction()
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
    DoAscendAction()
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
        DoAction()
        ; RunAscendActionIfDue() ; 転生アクションは無効化
        RunSaleActionIfDue()
        Sleep 50
    }
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
    DoAscendAction()
}

RunSaleActionIfDue()
{
    global running, lastSaleActionTick, saleIntervalMs

    if (!running)
        return

    if (A_TickCount - lastSaleActionTick < saleIntervalMs)
        return

    lastSaleActionTick := A_TickCount
    DoSaleAction()
}

; =========================
; 売却アクション
; =========================
DoSaleAction()
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

    ; 領域/項目ボタンクリック
    if (!MoveClickAndReturn(50, 50, 1))
        return

    ; 売却モードボタンクリック
    if (!MoveClickAndReturn(400, 100, 1))
        return

    ; 紫以下売却ボタンクリック
    if (!MoveClickAndReturn(600, 100, 2))
        return

    ; メインメニューへ戻るボタンクリック
    if (!MoveClickAndReturn(100, 100, 1))
        return

    ; 再出撃ボタンクリック
    if (!MoveClickAndReturn(50, -20, 1))
        return

    ; ダンジョンボタンクリック
    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return
}

; =========================
; 転生アクション
; =========================
DoAscendAction()
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
}

; =========================
; メイン動作
; 左クリック、ダンジョンクリア間隔待機、左上へ移動、2回クリック、戻る
; =========================
DoAction()
{
    global running, dungeonClearIntervalMs, topLeftMoveX, topLeftMoveY, clickHoldMs, vrchatTitle

    try WinActivate vrchatTitle
    Sleep 100

    LeftClick(clickHoldMs)

    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return

    MoveClickAndReturn(-topLeftMoveX, -topLeftMoveY, 2)
}

LeftClick(holdMs := 60)
{
    Send "{LButton down}"
    Sleep holdMs
    Send "{LButton up}"
}

MoveClickAndReturn(dx, dy, clickCount := 1, moveMs := 250)
{
    global running, clickHoldMs, betweenClickMs

    if (!running)
        return false

    SmoothMouseMoveRel(dx, dy, moveMs)
    if (!running)
        return false

    Loop clickCount {
        LeftClick(clickHoldMs)
        SleepInterruptible(betweenClickMs)
        if (!running)
            return false
    }

    SmoothMouseMoveRel(-dx, -dy, moveMs)
    return running
}

SmoothMouseMoveRel(dx, dy, totalMs := 250, stepMs := 16)
{
    global running
    steps := Max(1, Floor(totalMs / stepMs))
    sx := dx / steps
    sy := dy / steps

    Loop steps {
        if (!running)
            return
        MouseMoveRel(Round(sx), Round(sy))
        Sleep stepMs
    }
}

MouseMoveRel(dx, dy)
{
    ; MOUSEEVENTF_MOVE = 0x0001, relative mouse move.
    DllCall("mouse_event", "UInt", 0x0001, "Int", dx, "Int", dy, "UInt", 0, "UPtr", 0)
}

SleepInterruptible(ms)
{
    global running
    remaining := ms
    while (running && remaining > 0) {
        chunk := Min(100, remaining)
        Sleep chunk
        remaining -= chunk
    }
}

NeutralizeInputs()
{
    Send "{LButton up}{MButton up}{RButton up}"
    Send "{Shift up}{Ctrl up}{Alt up}"
    Sleep 10
}

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetTitleMatchMode 2

CoordMode "Mouse", "Client"

#Include "vrchat_party_macro_common_config.ahk"

; =========================
; 設定
; =========================
topLeftMoveX := 200      ; 左上方向に動かす量X
topLeftMoveY := 150      ; 左上方向に動かす量Y
clickHoldMs := 60        ; クリックを押している時間
betweenClickMs := 120    ; ダブルクリック間隔
moveStepMs := 16         ; マウス移動の刻み
vrchatTitle := "VRChat"

; =========================
; 状態
; =========================
global running := false

; =========================
; F8: 開始/停止
; =========================
F8::
{
    global running
    running := !running

    if (running) {
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
; メインループ
; =========================
RunLoop()
{
    global running

    if (!running)
        return

    while (running) {
        DoAction()
        Sleep 50
    }
}

; =========================
; メイン動作
; 左クリック、ダンジョンクリア間隔待機、左上へ移動、2回クリック、戻る
; =========================
DoAction()
{
    global running, dungeonClearIntervalMs, topLeftMoveX, topLeftMoveY, clickHoldMs, betweenClickMs, vrchatTitle

    try WinActivate vrchatTitle
    Sleep 100

    LeftClick(clickHoldMs)

    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return

    SmoothMouseMoveRel(-topLeftMoveX, -topLeftMoveY, 250)
    if (!running)
        return

    LeftClick(clickHoldMs)
    Sleep betweenClickMs
    LeftClick(clickHoldMs)

    SmoothMouseMoveRel(topLeftMoveX, topLeftMoveY, 250)
}

LeftClick(holdMs := 60)
{
    Send "{LButton down}"
    Sleep holdMs
    Send "{LButton up}"
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
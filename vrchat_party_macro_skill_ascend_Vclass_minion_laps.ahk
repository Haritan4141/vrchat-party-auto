#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetTitleMatchMode 2

CoordMode "Mouse", "Client"

#Include "vrchat_party_macro_common_config.ahk"

; =========================
; State
; =========================
global running := false
global lastAscendActionTick := 0

#Include "vrchat_party_macro_common_interval_actions.ahk"

; =========================
; F8: Start/Stop
; =========================
F8::
{
    global running
    running := !running

    if (running) {
        ResetAscendActionTimer()
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
; F9: Force stop
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
; F7: Ascend action test
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
; Main loop
; =========================
RunLoop()
{
    global running

    if (!running)
        return

    while (running) {
        RunVclassMinionLapAction()
        RunAscendActionIfDue()
        Sleep 50
    }
}

; =========================
; Wait, click reentry once, return to Auto skill position
; =========================
RunVclassMinionLapAction()
{
    global running, dungeonClearIntervalMs, topLeftMoveX, topLeftMoveY, vrchatTitle

    try WinActivate vrchatTitle
    Sleep 100

    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return

    MoveClickAndReturn(-topLeftMoveX, -topLeftMoveY, 1)
}

ResetAscendActionTimer()
{
    global lastAscendActionTick
    lastAscendActionTick := A_TickCount
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

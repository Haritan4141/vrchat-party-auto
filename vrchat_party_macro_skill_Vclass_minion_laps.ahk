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

#Include "vrchat_party_macro_common_actions.ahk"

; =========================
; F8: Start/Stop
; =========================
F8::
{
    global running
    running := !running

    if (running) {
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
; Main loop
; =========================
RunLoop()
{
    global running

    if (!running)
        return

    while (running) {
        RunVclassMinionLapAction()
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

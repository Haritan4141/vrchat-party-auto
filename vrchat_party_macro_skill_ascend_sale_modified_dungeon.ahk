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
global lastSaleActionTick := 0

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
; F6: Sale action test
; =========================
F6::
{
    TestSaleAction()
}

; =========================
; F7: Ascend action test
; =========================
F7::
{
    TestAscendAction()
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
        RunModifiedDungeonAction()
        if (RunAscendActionIfDue()) {
            if (!EnableAutoSkill())
                return
        }
        if (RunSaleActionIfDue()) {
            if (!EnableAutoSkill())
                return
        }
        Sleep 50
    }
}

; =========================
; Modified dungeon loop
; Clear wait, sub skill 1, reentry
; =========================
RunModifiedDungeonAction()
{
    global running, dungeonClearIntervalMs, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return false

    if (!ClickSubSkill(1))
        return false

    return ClickReentryButton(1)
}

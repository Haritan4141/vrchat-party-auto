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
        RunModifiedDungeonAction()
        RunAscendActionIfDue()
        RunSaleActionIfDue()
        Sleep 50
    }
}

; =========================
; Modified dungeon loop
; Auto skill, clear wait, main skill 2, sub skill 1, WP recovery, reentry
; =========================
RunModifiedDungeonAction()
{
    global running, dungeonClearIntervalMs, modifiedDungeonWpRecoveryWaitMs, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    if (!EnableAutoSkill())
        return false

    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return false

    if (!ClickMainSkill2(1))
        return false

    if (!ClickSubSkill(1))
        return false

    SleepInterruptible(modifiedDungeonWpRecoveryWaitMs)
    if (!running)
        return false

    return ClickReentryButton(1)
}

#Requires AutoHotkey v2.0
#SingleInstance Force
SendMode "Input"
SetTitleMatchMode 2

#Include "vrchat_party_macro_common_config.ahk"

global clickRepeatIntervalMs := 100
#Include *i "vrchat_party_macro_common_click_repeater_config.ahk"

global running := false
global clickRepeaterHoldMs := 20

#Include "vrchat_party_macro_common_actions.ahk"

; F8: 開始/停止
F8::
{
    global running, clickRepeatIntervalMs
    running := !running

    if (running) {
        ToolTip "Click Repeater: ON (" clickRepeatIntervalMs "ms)"
        SetTimer RunClickRepeater, -1
    } else {
        ToolTip "Click Repeater: OFF"
        NeutralizeInputs()
    }
    SetTimer () => ToolTip(), -800
}

; F9: 緊急停止
F9::
{
    global running
    running := false
    NeutralizeInputs()
    ToolTip "Click Repeater: FORCE STOP"
    Sleep 100
}

RunClickRepeater()
{
    global running, clickRepeatIntervalMs, clickRepeaterHoldMs, vrchatTitle

    if (!running)
        return

    try WinActivate vrchatTitle
    Sleep 100

    while (running) {
        clickStartedAt := A_TickCount
        LeftClick(clickRepeaterHoldMs)
        if (!running)
            break

        elapsedMs := A_TickCount - clickStartedAt
        SleepInterruptible(Max(0, clickRepeatIntervalMs - elapsedMs))
    }

    NeutralizeInputs()
}

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

#Include "vrchat_party_macro_common_actions.ahk"

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
    RunEscapeAscendDungeonAction()
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
        RunSecretDungeonAction()
        Sleep 50
    }
}

; =========================
; Subskill, Auto skill, wait, escape, dungeon select
; =========================
RunSecretDungeonAction()
{
    global running, dungeonClearIntervalMs, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    if (!MoveClickAndReturn(300, -50, 2))
        return false

    if (!EnableAutoSkill())
        return false

    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return false

    if (ShouldRunAscendAction())
        return RunEscapeAscendDungeonAction()

    return RunEscapeDungeonAction()
}

; =========================
; Escape, dungeon select
; =========================
RunEscapeDungeonAction()
{
    global running, topLeftMoveX, topLeftMoveY, dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    if (!MoveClickAndReturn(-topLeftMoveX, topLeftMoveY, 1))
        return false

    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return false

    return running
}

; =========================
; Escape, ascend, dungeon select
; =========================
RunEscapeAscendDungeonAction()
{
    global running, topLeftMoveX, topLeftMoveY, ascendLeftMoveX, ascendLeftMoveY
    global dungeonLeftMoveX, dungeonLeftMoveY, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    if (!MoveClickAndReturn(-topLeftMoveX, topLeftMoveY, 1))
        return false

    if (!MoveClickAndReturn(-ascendLeftMoveX, -ascendLeftMoveY, 1))
        return false

    if (!MoveClickAndReturn(dungeonLeftMoveX, -dungeonLeftMoveY, 1))
        return false

    return running
}

ResetAscendActionTimer()
{
    global lastAscendActionTick
    lastAscendActionTick := A_TickCount
}

ShouldRunAscendAction()
{
    global running, lastAscendActionTick, ascendIntervalMs

    if (!running)
        return false

    if (A_TickCount - lastAscendActionTick < ascendIntervalMs)
        return false

    lastAscendActionTick := A_TickCount
    return true
}

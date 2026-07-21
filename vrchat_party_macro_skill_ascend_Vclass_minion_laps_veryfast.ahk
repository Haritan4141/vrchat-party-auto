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
global currentFastMoveX := 0
global currentFastMoveY := 0
global fastVclassMoveMs := 48
global fastVclassAfterMoveClickWaitMs := 30
global fastVclassReentryBeforeClickWaitMs := 50
global fastVclassLoopActivateWaitMs := 20
global fastVclassLoopSleepMs := 50
global fastVclassMainSkillClickHoldMs := 10
global fastVclassMainSkillClickIntervalMs := 20
global fastVclassReentryClickHoldMs := 60
global fastVclassReentryAfterClickWaitMs := 50

#Include "vrchat_party_macro_common_interval_actions.ahk"

; =========================
; F8: Start/Stop
; =========================
F8::
{
    global running, currentFastMoveX, currentFastMoveY
    running := !running

    if (running) {
        currentFastMoveX := 0
        currentFastMoveY := 0
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
    TestAscendAction()
}

; =========================
; Main loop
; =========================
RunLoop()
{
    global running, fastVclassLoopSleepMs

    if (!running)
        return

    while (running) {
        RunFastVclassMinionAction()
        if (FastVclassAscendActionIsDue()) {
            if (!ReturnFastVclassCursorToAuto())
                return
            if (!RunAscendActionIfDue())
                return
            if (!EnableAutoSkill())
                return
        }
        SleepInterruptible(fastVclassLoopSleepMs)
    }
}

; =========================
; Spam main skill 1 until the dungeon clear interval ends, then reenter.
; =========================
RunFastVclassMinionAction()
{
    global running, dungeonClearIntervalMs, vrchatTitle
    global mainSkillMoveX, mainSkillMoveY, reentryMoveX, reentryMoveY
    global fastVclassAfterMoveClickWaitMs, fastVclassReentryBeforeClickWaitMs
    global fastVclassLoopActivateWaitMs, fastVclassReentryClickHoldMs, fastVclassReentryAfterClickWaitMs

    if (!running)
        return false

    try WinActivate vrchatTitle
    SleepInterruptible(fastVclassLoopActivateWaitMs)
    if (!running)
        return false

    if (!MoveFastVclassCursorTo(mainSkillMoveX, mainSkillMoveY, fastVclassAfterMoveClickWaitMs))
        return false

    endTick := A_TickCount + dungeonClearIntervalMs
    while (running && A_TickCount < endTick) {
        if (!ClickFastVclassMainSkill())
            return false
    }

    if (!running)
        return false

    if (!MoveFastVclassCursorTo(reentryMoveX, reentryMoveY, fastVclassReentryBeforeClickWaitMs))
        return false

    return ClickFastVclassCurrentPosition(fastVclassReentryClickHoldMs, fastVclassReentryAfterClickWaitMs)
}

FastVclassAscendActionIsDue()
{
    global running, lastAscendActionTick, ascendIntervalMs
    return running && (A_TickCount - lastAscendActionTick >= ascendIntervalMs)
}

MoveFastVclassCursorTo(targetMoveX, targetMoveY, afterMoveWaitMs)
{
    global running, currentFastMoveX, currentFastMoveY
    global fastVclassMoveMs

    if (!running)
        return false

    dx := targetMoveX - currentFastMoveX
    dy := targetMoveY - currentFastMoveY
    if (dx != 0 || dy != 0) {
        SmoothMouseMoveRel(dx, dy, fastVclassMoveMs)
        if (!running)
            return false

        SleepInterruptible(afterMoveWaitMs)
        if (!running)
            return false
    }

    currentFastMoveX := targetMoveX
    currentFastMoveY := targetMoveY
    return running
}

ClickFastVclassMainSkill()
{
    global fastVclassMainSkillClickHoldMs, fastVclassMainSkillClickIntervalMs

    postClickWaitMs := Max(0, fastVclassMainSkillClickIntervalMs - fastVclassMainSkillClickHoldMs)
    return ClickFastVclassCurrentPosition(fastVclassMainSkillClickHoldMs, postClickWaitMs)
}

ClickFastVclassCurrentPosition(holdMs, postClickWaitMs)
{
    global running

    if (!running)
        return false

    LeftClick(holdMs)
    SleepInterruptible(postClickWaitMs)
    return running
}

ReturnFastVclassCursorToAuto()
{
    global fastVclassAfterMoveClickWaitMs
    return MoveFastVclassCursorTo(0, 0, fastVclassAfterMoveClickWaitMs)
}

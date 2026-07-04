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
global currentSkillMoveX := 0
global currentSkillMoveY := 0
global infiniteDungeonSkillMoveMs := 80
global infiniteDungeonLoopSleepMs := 10
global infiniteDungeonActivateWaitMs := 20

#Include "vrchat_party_macro_common_actions.ahk"

; =========================
; F8: 開始/停止
; =========================
F8::
{
    global running, currentSkillMoveX, currentSkillMoveY
    running := !running

    if (running) {
        currentSkillMoveX := 0
        currentSkillMoveY := 0
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
    global running, infiniteDungeonLoopSleepMs

    if (!running)
        return

    while (running) {
        RunAlternatingSkillAction()
        Sleep infiniteDungeonLoopSleepMs
    }
}

; =========================
; メインスキルとサブスキルを交互にクリック
; =========================
RunAlternatingSkillAction()
{
    global running, mainSkillMoveX, mainSkillMoveY, subSkillMoveX, subSkillMoveY, vrchatTitle
    global infiniteDungeonActivateWaitMs

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep infiniteDungeonActivateWaitMs

    if (!MoveToSkillAndClick(mainSkillMoveX, mainSkillMoveY))
        return false

    if (!MoveToSkillAndClick(subSkillMoveX, subSkillMoveY))
        return false

    return running
}

; =========================
; 現在位置から指定スキル位置へ移動してクリック
; 初回だけAutoスキル位置を起点にする
; =========================
MoveToSkillAndClick(targetMoveX, targetMoveY)
{
    global running, currentSkillMoveX, currentSkillMoveY, clickHoldMs
    global afterMoveClickWaitMs, afterClickWaitMs, infiniteDungeonSkillMoveMs

    if (!running)
        return false

    dx := targetMoveX - currentSkillMoveX
    dy := targetMoveY - currentSkillMoveY
    SmoothMouseMoveRel(dx, dy, infiniteDungeonSkillMoveMs)
    if (!running)
        return false

    SleepInterruptible(afterMoveClickWaitMs)
    if (!running)
        return false

    currentSkillMoveX := targetMoveX
    currentSkillMoveY := targetMoveY

    LeftClick(clickHoldMs)
    SleepInterruptible(afterClickWaitMs)

    return running
}

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

#Include "vrchat_party_macro_common_actions.ahk"

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
        ; サブスキル（エクスヒール）ボタンクリック
        if (!MoveClickAndReturn(300, -50, 2))
            return

        if (!EnableAutoSkill())
            return

        RunInfiniteDungeonAction()

        Sleep 50
    }
}

; =========================
; 無限ダンジョン動作
; ダンジョンクリア間隔待機、1回クリック
; =========================
RunInfiniteDungeonAction()
{
    global running, dungeonClearIntervalMs, topLeftMoveX, topLeftMoveY, vrchatTitle

    try WinActivate vrchatTitle
    Sleep 100

    ; ダンジョンクリア待ち時間
    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return

    ; クリック
    MoveClickAndReturn(-topLeftMoveX, -topLeftMoveY, 1)
}

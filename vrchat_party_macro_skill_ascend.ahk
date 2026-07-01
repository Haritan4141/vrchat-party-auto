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
global lastAscendActionTick := 0

#Include "vrchat_party_macro_common_interval_actions.ahk"

; =========================
; F8: 開始/停止
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
; F7: 転生アクションのテスト
; =========================
F7::
{
    TestAscendAction()
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
        if (RunAscendActionIfDue()) {
            if (!EnableAutoSkill())
                return
        }
        Sleep 50
    }
}


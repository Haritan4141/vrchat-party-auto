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
global lastSaleActionTick := 0

#Include "vrchat_party_macro_common_interval_actions.ahk"

; =========================
; F8: 開始/停止
; =========================
F8::
{
    global running
    running := !running

    if (running) {
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
; F6: 売却アクションのテスト
; =========================
F6::
{
    TestSaleAction()
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
        if (RunSaleActionIfDue()) {
            if (!EnableAutoSkill())
                return
        }
        Sleep 50
    }
}

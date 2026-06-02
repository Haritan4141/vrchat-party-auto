; VRChat party macro shared actions.

if (A_LineFile = A_ScriptFullPath) {
    running := false
    topLeftMoveX := 0
    topLeftMoveY := 0
    clickHoldMs := 0
    betweenClickMs := 0
    dungeonClearIntervalMs := 0
    vrchatTitle := ""
    MsgBox "This file is shared parts. Run a macro .ahk file."
    ExitApp
}


; =========================
; Autoスキル有効化
; クリックして左上へ移動
; =========================
EnableAutoSkill()
{
    global running, topLeftMoveX, topLeftMoveY, clickHoldMs, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    LeftClick(clickHoldMs)
    if (!running)
        return false

    SmoothMouseMoveRel(-topLeftMoveX, -topLeftMoveY, 250)
    return running
}

; =========================
; Autoスキル位置へ戻る
; 右下へ移動
; =========================
ReturnPositionToAutoSkill()
{
    global running, topLeftMoveX, topLeftMoveY

    if (!running)
        return false

    SmoothMouseMoveRel(topLeftMoveX, topLeftMoveY, 250)
    return running
}

; =========================
; メイン動作
; ダンジョンクリア間隔待機、2回クリック
; =========================
DoAction()
{
    global running, dungeonClearIntervalMs, clickHoldMs, betweenClickMs, vrchatTitle

    try WinActivate vrchatTitle
    Sleep 100

    ; ダンジョンクリア待ち時間
    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return

    ; ダブルクリック(再入場)
    LeftClick(clickHoldMs)
    SleepInterruptible(betweenClickMs)
    if (!running)
        return

    LeftClick(clickHoldMs)
}

LeftClick(holdMs := 60)
{
    Send "{LButton down}"
    Sleep holdMs
    Send "{LButton up}"
}

MoveClickAndReturn(dx, dy, clickCount := 1, moveMs := 250)
{
    global running, clickHoldMs, betweenClickMs

    if (!running)
        return false

    SmoothMouseMoveRel(dx, dy, moveMs)
    if (!running)
        return false

    Loop clickCount {
        LeftClick(clickHoldMs)
        SleepInterruptible(betweenClickMs)
        if (!running)
            return false
    }

    SmoothMouseMoveRel(-dx, -dy, moveMs)
    return running
}

SmoothMouseMoveRel(dx, dy, totalMs := 250, stepMs := 16)
{
    global running
    steps := Max(1, Floor(totalMs / stepMs))
    sx := dx / steps
    sy := dy / steps

    Loop steps {
        if (!running)
            return
        MouseMoveRel(Round(sx), Round(sy))
        Sleep stepMs
    }
}

MouseMoveRel(dx, dy)
{
    ; MOUSEEVENTF_MOVE = 0x0001, relative mouse move.
    DllCall("mouse_event", "UInt", 0x0001, "Int", dx, "Int", dy, "UInt", 0, "UPtr", 0)
}

SleepInterruptible(ms)
{
    global running
    remaining := ms
    while (running && remaining > 0) {
        chunk := Min(100, remaining)
        Sleep chunk
        remaining -= chunk
    }
}

NeutralizeInputs()
{
    Send "{LButton up}{MButton up}{RButton up}"
    Send "{Shift up}{Ctrl up}{Alt up}"
    Sleep 10
}

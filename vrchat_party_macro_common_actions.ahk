; VRChat party macro shared actions.

if (A_LineFile = A_ScriptFullPath) {
    running := false
    reentryMoveX := 0
    reentryMoveY := 0
    escapeMoveX := 0
    escapeMoveY := 0
    clickHoldMs := 0
    afterClickWaitMs := 0
    betweenRepeatClickMs := 0
    afterMoveClickWaitMs := 0
    dungeonClearIntervalMs := 0
    mainSkillMoveX := 0
    mainSkillMoveY := 0
    subSkillMoveX := 0
    subSkillMoveY := 0
    vrchatTitle := ""
    MsgBox "This file is shared parts. Run a macro .ahk file."
    ExitApp
}

; =========================
; Autoスキル有効化
; Autoスキル位置を中心位置として維持する
; =========================
EnableAutoSkill()
{
    global running, clickHoldMs, vrchatTitle

    if (!running)
        return false

    try WinActivate vrchatTitle
    Sleep 100

    LeftClick(clickHoldMs)
    if (!running)
        return false

    return running
}

; =========================
; メインスキル1ボタンクリック
; Autoスキル位置を中心位置として維持する
; =========================
ClickMainSkill(clickCount := 1)
{
    global mainSkillMoveX, mainSkillMoveY
    return MoveClickAndReturn(mainSkillMoveX, mainSkillMoveY, clickCount)
}

; サブスキル1ボタンクリック
; Autoスキル位置を中心位置として維持する
; =========================
ClickSubSkill(clickCount := 1)
{
    global subSkillMoveX, subSkillMoveY
    return MoveClickAndReturn(subSkillMoveX, subSkillMoveY, clickCount)
}

; =========================
; Autoスキル位置へ戻る
; 右下へ移動
; =========================
ReturnPositionToAutoSkill()
{
    global running, reentryMoveX, reentryMoveY

    if (!running)
        return false

    SmoothMouseMoveRel(-reentryMoveX, -reentryMoveY, 250)
    return running
}

; =========================
; メイン動作
; ダンジョンクリア間隔待機、再入場ボタンをクリック、Autoスキル位置へ戻る
; =========================
DoAction(reentryClickCount := 2)
{
    global running, dungeonClearIntervalMs, vrchatTitle

    try WinActivate vrchatTitle
    Sleep 100

    ; ダンジョンクリア待ち時間
    SleepInterruptible(dungeonClearIntervalMs)
    if (!running)
        return

    ClickReentryButton(reentryClickCount)
}

; =========================
; 再入場ボタンクリック
; clickCount = 2: 同じ位置のボタン表示が「調べる」→「再入場」に変わるパターン
; clickCount = 1: 「調べる」が出ず、最初から「再入場」のみを押すパターン
; =========================
ClickReentryButton(clickCount := 2)
{
    global reentryMoveX, reentryMoveY
    return MoveClickAndReturn(reentryMoveX, reentryMoveY, clickCount)
}

LeftClick(holdMs := 60)
{
    Send "{LButton down}"
    Sleep holdMs
    Send "{LButton up}"
}

MoveClickAndReturn(dx, dy, clickCount := 1, moveMs := 250)
{
    global running, clickHoldMs, afterClickWaitMs, betweenRepeatClickMs, afterMoveClickWaitMs

    if (!running)
        return false

    SmoothMouseMoveRel(dx, dy, moveMs)
    if (!running)
        return false

    SleepInterruptible(afterMoveClickWaitMs)
    if (!running)
        return false

    Loop clickCount {
        LeftClick(clickHoldMs)
        if (A_Index < clickCount) {
            SleepInterruptible(betweenRepeatClickMs)
        } else {
            SleepInterruptible(afterClickWaitMs)
        }
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
    movedX := 0
    movedY := 0

    Loop steps {
        if (!running)
            return
        targetX := Round(dx * A_Index / steps)
        targetY := Round(dy * A_Index / steps)
        MouseMoveRel(targetX - movedX, targetY - movedY)
        movedX := targetX
        movedY := targetY
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

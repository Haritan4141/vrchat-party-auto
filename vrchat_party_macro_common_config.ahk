; VRChat party macro shared interval settings.
dungeonClearIntervalMs := 4500   ; ダンジョンクリア間隔
ascendIntervalMs := 300000        ; 転生間隔
saleIntervalMs := 300000         ; 売却間隔

; VRChat party macro shared action settings.
topLeftMoveX := 60       ; Autoスキルから再入場までの量X
topLeftMoveY := 38       ; Autoスキルから再入場までの量Y
ascendLeftMoveX := 970   ; 転生ボタン方向に動かす量X
ascendLeftMoveY := 45    ; 転生ボタン方向に動かす量Y
mainSkillMoveX := 80     ; Autoスキルからメインスキルボタンまでの量X（暫定）
mainSkillMoveY := -50    ; Autoスキルからメインスキルボタンまでの量Y（暫定）
subSkillMoveX := 300     ; Autoスキルからサブスキル（エクスヒール）ボタンまでの量X
subSkillMoveY := -50     ; Autoスキルからサブスキル（エクスヒール）ボタンまでの量Y
; ダンジョンボタン位置
;dungeonButtonMoveX := 80    ; 上から1つ目
;dungeonButtonMoveY := 130   ; 上から1つ目
;dungeonButtonMoveX := 80    ; 上から2つ目
;dungeonButtonMoveY := 98    ; 上から2つ目
;dungeonButtonMoveX := 80    ; 上から3つ目
;dungeonButtonMoveY := 60     ; 上から3つ目
;dungeonButtonMoveX := 80    ; 上から4つ目
;dungeonButtonMoveY := 22     ; 上から4つ目
dungeonButtonMoveX := 80    ; 上から5つ目
dungeonButtonMoveY := -16    ; 上から5つ目
;dungeonButtonMoveX := -80   ; 永傷の女王:V級
;dungeonButtonMoveY := 25    ; 永傷の女王:V級
dungeonLeftMoveX := dungeonButtonMoveX
dungeonLeftMoveY := dungeonButtonMoveY

clickHoldMs := 60        ; クリックを押している時間
betweenClickMs := 300    ; ダブルクリック間隔
afterMoveClickWaitMs := 50  ; マウス移動後、クリック前の待機
infiniteDungeonSkillBetweenClickMs := 80  ; 無限ダンジョン交互スキルのクリック後待機
moveStepMs := 16         ; マウス移動の刻み
vrchatTitle := "VRChat"

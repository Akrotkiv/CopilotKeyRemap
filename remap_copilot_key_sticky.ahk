#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook

; ===========================================================================
; STICKY KEY BEHAVIOR FOR COPILOT -> RCONTROL REMAPPING
; ===========================================================================
; Single press: RControl becomes "sticky" - releases after pressing ONE key
; Double press: RControl LOCKED - stays pressed until pressed again
; ===========================================================================

InstallKeybdHook

; ========== SETTINGS ==========
; Time in milliseconds for double-tap detection (try values 250-500)
global DOUBLE_TAP_TIME := 400  ; Increased from 300 to 400ms

; Enable or disable sound beeps (true = on, false = off)
global ENABLE_SOUND := true  ; Set to false to disable all beeps
; ========== EOF SETTINGS ======

; States: 0 = off, 1 = sticky (one key), 2 = locked
global CtrlState := 0
global LastPressTime := 0
global StickyWaitingForKey := false
global FirstTapDetected := false

; Helper function to play beep only if enabled
PlayBeep(frequency, duration) {
    global ENABLE_SOUND
    if (ENABLE_SOUND) {
        SoundBeep(frequency, duration)
    }
}

; Reload script
^+!r:: Reload

; Main handler for Copilot key
*<+<#F23:: {
    global CtrlState, LastPressTime, StickyWaitingForKey, FirstTapDetected, DOUBLE_TAP_TIME
    
    ; Release original modifiers
    SendInput("{Blind}{LShift Up}{LWin Up}")
    
    ; Calculate time since last press
    currentTime := A_TickCount
    timeSinceLastPress := currentTime - LastPressTime
    LastPressTime := currentTime
    
    ; Wait for F23 release
    KeyWait("F23")
    
    ; Is this a double-tap? (less than DOUBLE_TAP_TIME ms from last press)
    isDoubleTap := (timeSinceLastPress < DOUBLE_TAP_TIME)
    
    if (isDoubleTap) {
        ; DOUBLE-TAP DETECTED!
        FirstTapDetected := false
        StickyWaitingForKey := false
        
        if (CtrlState = 2) {
            ; Already locked, unlock it
            CtrlState := 0
            SendInput("{RControl Up}")
            PlayBeep(400, 100)
            ShowTooltipAtCursor("✓ RControl released")
            SetTimer(() => ShowTooltipAtCursor(""), -1500)
        } else {
            ; Lock it (even if it was in sticky mode)
            CtrlState := 2
            SendInput("{RControl Down}")
            PlayBeep(800, 100)
            Sleep(50)
            PlayBeep(800, 100)
            ShowTooltipAtCursor("🔒 RControl LOCKED")
        }
    } else {
        ; FIRST PRESS
        FirstTapDetected := true
        
        if (CtrlState = 0) {
            ; Activate sticky mode
            CtrlState := 1
            StickyWaitingForKey := true
            SendInput("{RControl Down}")
            PlayBeep(600, 100)
            ShowTooltipAtCursor("⌨ RControl sticky (1 key)")
            
            ; Start monitor to watch for key presses
            SetTimer(MonitorKeyPress, 10)
            
        } else if (CtrlState = 1) {
            ; Cancel sticky
            FirstTapDetected := false
            StickyWaitingForKey := false
            CtrlState := 0
            SendInput("{RControl Up}")
            PlayBeep(400, 100)
            ShowTooltipAtCursor("✓ RControl released")
            SetTimer(() => ShowTooltipAtCursor(""), -1500)
        } else if (CtrlState = 2) {
            ; Unlock locked mode
            FirstTapDetected := false
            CtrlState := 0
            SendInput("{RControl Up}")
            PlayBeep(400, 100)
            ShowTooltipAtCursor("✓ RControl released")
            SetTimer(() => ShowTooltipAtCursor(""), -1500)
        }
    }
}

; Monitor function - checks if any key was pressed
MonitorKeyPress() {
    global CtrlState, StickyWaitingForKey
    
    if (!StickyWaitingForKey || CtrlState != 1) {
        SetTimer(MonitorKeyPress, 0)  ; Stop timer
        return
    }
    
    ; List of all common keys to check (including mouse buttons)
    keys := ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z",
             "0","1","2","3","4","5","6","7","8","9",
             "Space","Enter","Tab","Backspace","Delete","Escape",
             "Left","Right","Up","Down","Home","End","PgUp","PgDn",
             "F1","F2","F3","F4","F5","F6","F7","F8","F9","F10","F11","F12",
             ",",".","/",";","'","[","]","\","-","=","Insert",
             "LButton","RButton","MButton","XButton1","XButton2"]  ; Mouse buttons
    
    ; Check if any key is pressed
    for key in keys {
        if GetKeyState(key, "P") {
            ; Key was pressed! Wait for its release
            StickyWaitingForKey := false
            KeyWait(key)  ; Wait until released
            
            ; Now release Control
            CtrlState := 0
            SendInput("{RControl Up}")
            ShowTooltipAtCursor("✓ RControl released")
            SetTimer(() => ShowTooltipAtCursor(""), -1500)
            SetTimer(MonitorKeyPress, 0)  ; Stop timer
            return
        }
    }
}

; Function to show tooltip at text cursor position
ShowTooltipAtCursor(text) {
    if (text = "") {
        ToolTip()
        return
    }
    
    ; Get text cursor (caret) position
    try {
        CaretGetPos(&caretX, &caretY)
        ToolTip(text, caretX + 10, caretY + 20)
    } catch {
        MouseGetPos(&mouseX, &mouseY)
        ToolTip(text, mouseX + 10, mouseY + 20)
    }
}

; ========== INFO ==========
; If you have trouble with double-tap, change DOUBLE_TAP_TIME at the top:
; - Tapping too fast? Increase to 500 or 600
; - Tapping too slow? Decrease to 300 or 250
; Current value: 400ms
;
; To disable sound beeps, change ENABLE_SOUND to false
; Current value: true (sound enabled)

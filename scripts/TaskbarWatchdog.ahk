#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
; ==============================================================================
; scripts\TaskbarWatchdog.ahk  -  failsafe for OLED Engine's taskbar dimming
; ------------------------------------------------------------------------------
; Started by TaskbarDimming while taskbar dimming is ON; closed again when it is turned off.
; Every second it checks the main script (one cheap process check + one window-hung check).
; If the main script crashes, is killed, or stops responding, it puts the taskbar back to normal.
; It does nothing else, uses no CPU between checks, and exits by itself when the main script is gone.
; Args: 1 = main script's process id, 2 = main script's full path
; ==============================================================================
Persistent
ProcessSetPriority("Low")
DetectHiddenWindows(true)
SetTitleMatchMode(2)

if (A_Args.Length < 2) {
    ExitApp()
}
mainPid  := Integer(A_Args[1])
mainPath := A_Args[2]
hungCount := 0
restoredForHang := false

SetTimer(Check, 1000)

Check() {
    global hungCount, restoredForHang
    if !ProcessExist(mainPid) {
        SetTimer(Check, 0)
        SetTimer(AfterMainGone, -2000)     ; short wait: a reload starts a new main script right away
        return
    }
    hwnd := WinExist("ahk_pid " mainPid " ahk_class AutoHotkey")
    if (hwnd && DllCall("IsHungAppWindow", "Ptr", hwnd, "Int")) {
        hungCount += 1
        if (hungCount >= 2 && !restoredForHang) {      ; frozen for roughly 6-9 s
            Sweep()
            restoredForHang := true
        }
    } else {
        hungCount := 0
        restoredForHang := false                        ; main script is responsive again (it re-dims by itself)
    }
}

AfterMainGone() {
    ; A new main script (reload / restart) is already running: it launches its own watchdog, so just leave.
    if WinExist(mainPath " ahk_class AutoHotkey") {
        ExitApp()
    }
    Sweep()
    ExitApp()
}

; Restores any taskbar window that is still see-through (alpha below 255).
; Tried up to 3 times (0.4 s apart) in case Explorer re-applies its own state right after the first attempt.
Sweep() {
    Loop 3 {
        left := 0
        for cls in ["Shell_TrayWnd", "Shell_SecondaryTrayWnd"] {
            for hwnd in WinGetList("ahk_class " cls) {
                key := 0, alpha := 255, flags := 0
                if (DllCall("GetLayeredWindowAttributes", "Ptr", hwnd, "UInt*", &key, "UChar*", &alpha, "UInt*", &flags, "Int")
                    && (flags & 0x2) && alpha < 255) {
                    left += 1
                    DllCall("SetLayeredWindowAttributes", "Ptr", hwnd, "UInt", 0, "UChar", 255, "UInt", 0x2)   ; opacity back to 255 first
                    try WinSetTransparent("Off", "ahk_id " hwnd)                                              ; then drop the layered style
                }
            }
        }
        if !left {
            return
        }
        Sleep(400)
    }
}
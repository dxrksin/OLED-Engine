#Requires AutoHotkey v2.0
#SingleInstance Force
;@Ahk2Exe-SetMainIcon assets\OLED Engine.ico
Persistent
ListLines False
ProcessSetPriority("BelowNormal")
SetWinDelay(-1)
SetControlDelay(-1)
#Include %A_ScriptDir%\scripts\App Automation.ahk
#Include %A_ScriptDir%\scripts\Updater.ahk

; ##############################################################################
; ##                                                                          ##
; ##                  PART 1: USER SETTINGS (EDIT HERE)                       ##
; ##                                                                          ##
; ##  - Every adjustable setting is grouped below by monitor and feature.     ##
; ##  - After editing, save this file and click "Reload Script" in the tray.  ##
; ##  - Changes made in the Settings window also update these lines.          ##
; ##                                                                          ##
; ##############################################################################

; ==============================================================================
; [1] MONITOR 1 (PRIMARY DISPLAY) & INTERFACE
; ==============================================================================
Primary_Auto_Enabled          := true        ; [true / false] Enable automatic Monitor 1 idle dim / blackout
OLED_HDR_SDR_Mode_Enabled     := true        ; [true / false] true = Separate HDR & SDR profiles, false = Unified profile
Active_HDR_Mode               := false        ; [true / false] Tracks / sets Monitor 1 HDR vs SDR display output state
Comp_Game_Auto_SDR_Enabled    := true        ; [true / false] Switch Monitor 1 to SDR when a competitive game starts
Primary_Dim_Percent           := 100        ; [Percent 0-100] SDR / Unified dim level (100 = pure #000000 blackout, 0 = off)
Primary_HDR_Dim_Percent       := 100        ; [Percent 0-100] HDR dim level (100 = pure #000000 blackout, 0 = off)
Primary_Fade_Ms               := 350        ; [Milliseconds] Smooth fade speed for Monitor 1 (0 = instant)

; --- Display Care, Sounds, Theme & Debug Log ---
UI_Dark_Mode                  := true        ; [true / false] true = Dark Mode, false = Light Mode
Debug_Log_Enabled             := false        ; [true / false] Default OFF; write live state/context/HDR/dim telemetry to log file
Debug_Log_Path                := ""        ; [File path] Custom log file path (blank = logs\debug.log next to the app)
Sound_Volume_Step             := 1        ; 0, 1, 2, 3 (4 click positions total)
UI_Custom_Color               := ""        ; [Blank or RRGGBB hex] Custom background color for the menu / Settings UI (blank = plain Dark or Light mode)
OLED_Refresh_Reminder_Enabled := true        ; [true / false] Optional toggle for manual OSD pixel refresh reminders
OLED_Refresh_Reminder_Days    := 8        ; [Days] Days part of reminder interval
OLED_Refresh_Reminder_Hours   := 0        ; [Hours] Hours part of reminder interval
OLED_Refresh_Reminder_Minutes := 0        ; [Minutes 0-59] Minutes part of reminder interval
OLED_Refresh_Popup_Monitor    := 1        ; [Monitor 1-5] Target monitor for pixel refresh popup (defaults to main monitor)
OLED_Refresh_Alert_Style      := "Popup"        ; ["Popup" / "Notification"] Alert mode for pixel refresh reminder
OLED_Refresh_Popup_Sound      := "Calm Rise"        ; ["None" / "Soft Chime" / "Gentle Bell" / "Glass Drop" / "Calm Rise" / "Calm Fall" / "Windows Default" / "Windows Notify" / "Windows Ding"] Sound for the Popup alert

Dim_Sound_Enabled             := false        ; [true / false] Play a sound when a monitor dims or blacks out
Wake_Sound_Enabled            := false        ; [true / false] Play a sound when a monitor wakes
Dim_Sound_Name                := "Gentle Bell"        ; [Sound name, same list as above] Sound played on dim / blackout
Wake_Sound_Name               := "Calm Rise"        ; [Sound name, same list as above] Sound played on wake
; --- Monitor 1 SDR / Unified Idle Delays ---
Primary_SDR_Desktop_Sec       := 23        ; [Seconds] Monitor 1 idle delay on Desktop
Primary_SDR_Normal_Sec        := 35        ; [Seconds] Monitor 1 idle delay in Standard Games
Primary_SDR_Comp_Sec          := 45        ; [Seconds] Monitor 1 idle delay in Competitive Games
Primary_SDR_Paused_Sec        := 5        ; [Seconds] Monitor 1 idle delay when a Video is PAUSED

; --- Monitor 1 HDR Idle Delays (Used when Separate HDR & SDR Profiles is ON and in HDR) ---
Primary_HDR_Desktop_Sec       := 15        ; [Seconds] Monitor 1 idle delay on Desktop in HDR
Primary_HDR_Normal_Sec        := 23        ; [Seconds] Monitor 1 idle delay in Standard Games in HDR
Primary_HDR_Comp_Sec          := 23        ; [Seconds] Monitor 1 idle delay in Competitive Games in HDR
Primary_HDR_Paused_Sec        := 5        ; [Seconds] Monitor 1 idle delay when a Video is PAUSED in HDR

; ==============================================================================
; [2] ADDITIONAL MONITORS (PER-MONITOR DELAYS, DIM LEVELS & HDR PROFILES)
; ==============================================================================
; --- Monitor 2 ---
Extra_Auto_Enabled            := true        ; [true / false] Enable automatic idle dim / blackout on Monitor 2
Extra_HDR_SDR_Mode_Enabled    := false        ; [true / false] true = Separate HDR & SDR profiles (when HDR supported), false = Unified
Extra_Comp_Game_Auto_SDR      := false        ; [true / false] Switch Monitor 2 to SDR when a competitive game starts
Extra_Dim_Percent             := 73        ; [Percent 0-100] Monitor 2 SDR / Unified dim level (100 = pure #000000 blackout)
Extra_HDR_Dim_Percent         := 73        ; [Percent 0-100] Monitor 2 HDR dim level (100 = pure #000000 blackout)
Extra_Fade_Ms                 := 437        ; [Milliseconds] Smooth fade speed for Monitor 2 (0 = instant)
Extra_SDR_Desktop_Sec         := 15        ; [Seconds] Monitor 2 SDR idle delay on Desktop
Extra_SDR_Normal_Sec          := 5        ; [Seconds] Monitor 2 SDR idle delay in Standard Games
Extra_SDR_Comp_Sec            := 5        ; [Seconds] Monitor 2 SDR idle delay in Competitive Games
Extra_SDR_Paused_Sec          := 10        ; [Seconds] Monitor 2 SDR idle delay when a Video is PAUSED
Extra_HDR_Desktop_Sec         := 15        ; [Seconds] Monitor 2 HDR idle delay on Desktop in HDR
Extra_HDR_Normal_Sec          := 5        ; [Seconds] Monitor 2 HDR idle delay in Standard Games in HDR
Extra_HDR_Comp_Sec            := 5        ; [Seconds] Monitor 2 HDR idle delay in Competitive Games in HDR
Extra_HDR_Paused_Sec          := 10        ; [Seconds] Monitor 2 HDR idle delay when a Video is PAUSED in HDR
Extra_Game_Carryover_Enabled  := true        ; [true / false] true = Monitors 2-5 use their Game delays while a game runs on ANOTHER monitor (their Live Status says so); false = every monitor only uses its own window

; --- Monitor 3 ---
Mon3_Auto_Enabled             := true        
Mon3_HDR_SDR_Mode_Enabled     := false        
Mon3_Comp_Game_Auto_SDR       := false        
Mon3_Dim_Percent              := 73        
Mon3_HDR_Dim_Percent          := 73        
Mon3_Fade_Ms                  := 300        
Mon3_SDR_Desktop_Sec          := 15        
Mon3_SDR_Normal_Sec           := 5        
Mon3_SDR_Comp_Sec             := 5        
Mon3_SDR_Paused_Sec           := 10        
Mon3_HDR_Desktop_Sec          := 15        
Mon3_HDR_Normal_Sec           := 5        
Mon3_HDR_Comp_Sec             := 5        
Mon3_HDR_Paused_Sec           := 10        

; --- Monitor 4 ---
Mon4_Auto_Enabled             := true        
Mon4_HDR_SDR_Mode_Enabled     := false        
Mon4_Comp_Game_Auto_SDR       := false        
Mon4_Dim_Percent              := 73        
Mon4_HDR_Dim_Percent          := 73        
Mon4_Fade_Ms                  := 300        
Mon4_SDR_Desktop_Sec          := 15        
Mon4_SDR_Normal_Sec           := 5        
Mon4_SDR_Comp_Sec             := 5        
Mon4_SDR_Paused_Sec           := 10        
Mon4_HDR_Desktop_Sec          := 15        
Mon4_HDR_Normal_Sec           := 5        
Mon4_HDR_Comp_Sec             := 5        
Mon4_HDR_Paused_Sec           := 10        

; --- Monitor 5 ---
Mon5_Auto_Enabled             := true        
Mon5_HDR_SDR_Mode_Enabled     := false        
Mon5_Comp_Game_Auto_SDR       := false        
Mon5_Dim_Percent              := 73        
Mon5_HDR_Dim_Percent          := 73        
Mon5_Fade_Ms                  := 300        
Mon5_SDR_Desktop_Sec          := 15        
Mon5_SDR_Normal_Sec           := 5        
Mon5_SDR_Comp_Sec             := 5        
Mon5_SDR_Paused_Sec           := 10        
Mon5_HDR_Desktop_Sec          := 15        
Mon5_HDR_Normal_Sec           := 5        
Mon5_HDR_Comp_Sec             := 5        
Mon5_HDR_Paused_Sec           := 10        

; ==============================================================================
; [3] DESKTOP ICONS, CURSOR & STARTUP
; ==============================================================================
Desktop_Hide_Enabled          := true        ; [true / false] Hide cursor & fade desktop icons on idle
Desktop_Idle_Sec              := 5        ; [Seconds] Idle delay before hiding cursor & fading desktop icons
Icon_Fade_Ms                  := 350        ; [Milliseconds] Smooth fade speed for desktop icons (0 = instant)
Start_With_Windows            := true        ; [true / false] Launch automatically when signing in to Windows
Start_Minimized               := true        ; [true / false] Start silently in the system tray without opening Settings

; ==============================================================================
; [4] COMPETITIVE GAMES & NEVER-DIM EXCLUSIONS LIST
; ==============================================================================
Comp_Games_List               := "RainbowSix.exe"        ; [Comma-separated .exe names]
Excluded_Processes_List       := ""        ; [Comma-separated .exe names] Pause auto-dim/blackout while any listed process is running

; ==============================================================================
; [5] TRAY MENU ORDER & VISIBILITY (Settings & Exit are fixed; IDs: pause, auto_dim, hdr_toggle, hdr_sdr, refresh, blackout, sec_dim, desk_hide, edit, reload)
; ==============================================================================
Tray_Menu_Config              := "pause:1,auto_dim:1,hdr_toggle:1,hdr_sdr:0,refresh:1,blackout:1,sec_dim:1,desk_hide:1,edit:0,reload:1"        ; [Ordered comma-separated item:enabled(1/0)]

; ==============================================================================
; [6] PER-MONITOR HOTKEYS (BLANK = DISABLED; RESPECTS EACH MONITOR'S DIM LEVEL)
; ==============================================================================
Mon1_Hotkey                   := "Insert"        ; [AHK Hotkey] Toggle Dim / Blackout on Monitor 1
Mon2_Hotkey                   := "PgUp"        ; [AHK Hotkey] Toggle Dim / Blackout on Monitor 2
Mon3_Hotkey                   := ""        ; [AHK Hotkey] Toggle Dim / Blackout on Monitor 3
Mon4_Hotkey                   := ""        ; [AHK Hotkey] Toggle Dim / Blackout on Monitor 4
Mon5_Hotkey                   := ""        ; [AHK Hotkey] Toggle Dim / Blackout on Monitor 5

; ==============================================================================
; [6b] LONG-IDLE DISPLAY OFF, ADMIN & PRESETS (managed on the Presets tab)
; ==============================================================================
; These are saved by the Presets tab into <script>.presets.ini, which overrides these defaults at startup.
Taskbar_AutoHide_Enabled      := false
LongIdle_Off_Enabled          := false
LongIdle_Off_Min              := 10
LongIdle_Off_Monitors         := "all"        ; "all" or a comma list of monitor numbers (for example 1,3) that the long-idle display-off applies to
longIdleDdcOff                := Map()        ; monitors this script switched off through DDC/CI (monitor number -> failed wake attempts)
longIdleOffTick               := 0
Run_As_Admin                  := false
Presets                       := []
presetActiveIdx               := 0
presetCacheTick               := 0
presetPinned                  := ""        ; preset switched on by hand from the Presets tab (session only)
presetFgExe                   := ""        ; last known focused program, used by focus-only presets
originalTaskbarAutoHide       := ""
taskbarChangedByScript        := false
PresetsIniPath                := ""

; ==============================================================================
; [7] RECOGNIZED VIDEO PLAYERS & BROWSERS (editable on the General tab; blank = built-in list)
; ==============================================================================
Media_Players_List            := "mpc-hc64.exe, mpc-hc.exe, mpc-be64.exe, mpc-be.exe, stremio.exe, vlc.exe, mpv.exe, potplayermini64.exe, potplayermini.exe, kodi.exe, plex.exe, plexhtpc.exe, ApplicationFrameHost.exe"        ; [Comma-separated .exe names] Video players (blank = built-in list below)
Browsers_List                 := "chrome.exe, msedge.exe, firefox.exe, brave.exe, opera.exe, vivaldi.exe"        ; [Comma-separated .exe names] Browsers (blank = built-in list below)

Media_Player_Processes := [
    "mpc-hc64.exe", "mpc-hc.exe", "mpc-be64.exe", "mpc-be.exe",
    "stremio.exe", "vlc.exe", "mpv.exe",
    "potplayermini64.exe", "potplayermini.exe",
    "kodi.exe", "plex.exe", "plexhtpc.exe", "ApplicationFrameHost.exe"
]

Browser_Processes := [
    "chrome.exe", "msedge.exe", "firefox.exe", "brave.exe", "opera.exe", "vivaldi.exe"
]

; Built-in lists kept aside so a blank box on the General tab can always fall back to them
Default_Media_Player_Processes := Media_Player_Processes.Clone()
Default_Browser_Processes      := Browser_Processes.Clone()

; ##############################################################################
; ##                                                                          ##
; ##            PART 2: INTERNAL SCRIPT ENGINE (NO NEED TO EDIT)              ##
; ##                                                                          ##
; ##############################################################################

; ==============================================================================
; 1. CONSTANTS & DERIVED RUNTIME VALUES
; ==============================================================================
APP_VERSION           := "1.0.1"
MAX_MONITORS          := 8
ExtraDynamicMonCfg    := Map()

; ---- Folder layout: everything the app creates lives in one of these folders next to the exe / script ----
;   config\    settings.ini, presets, OLED-care stats
;   logs\      errors.log, debug log
;   backups\   manual backups; backups\auto\ holds the script copies made on every save
;   updates\   temporary staging area used by the updater
ConfigDir             := A_ScriptDir "\config"
LogsDir               := A_ScriptDir "\logs"
BackupsDir            := A_ScriptDir "\backups"
UpdatesDir            := A_ScriptDir "\updates"
IniPath               := ConfigDir "\settings.ini"

InitAppDirectoriesAndAssets()
LoadSettingsFromIni()

InitAppDirectoriesAndAssets() {
    global ConfigDir, LogsDir, BackupsDir
    DirCreate(ConfigDir)
    DirCreate(LogsDir)

    ; --- Tidy-up for older versions: pull stray files into their folders (never overwrites newer files) ---
    ; Old layout kept settings.ini in data\Config; everything now lives in config\.
    oldCfg := A_ScriptDir "\data\Config"
    if DirExist(oldCfg) {
        Loop Files, oldCfg "\*.*" {
            try FileMove(A_LoopFilePath, ConfigDir "\" A_LoopFileName, 0)
        }
    }
    for oldDir in [oldCfg, A_ScriptDir "\data\Assets", A_ScriptDir "\data"] {
        try DirDelete(oldDir)   ; only removes the folder if it is empty
    }

    ; Settings files that used to sit next to the script
    for iniName in ["OLED Engine.ini", "OLED Engine.oledcare.ini", "OLED Engine.presets.ini", "AutomationConfig.ini"] {
        oldIni := A_ScriptDir "\" iniName
        newIni := ConfigDir "\" iniName
        if FileExist(oldIni) {
            try FileMove(oldIni, newIni, FileExist(newIni) ? 0 : 1)
            if FileExist(oldIni) {
                try FileDelete(oldIni)
            }
        }
    }

    ; Debug log used to live in config\
    oldDbg := ConfigDir "\OLED Engine.debug.log"
    if FileExist(oldDbg) {
        try FileMove(oldDbg, LogsDir "\debug.log", 0)
    }

    ; Script backups (.bak / .YYYYMMDD.bak) used to pile up next to the .ahk
    if !A_IsCompiled {
        Loop Files, A_ScriptFullPath ".*" {
            if (A_LoopFileExt = "bak") {
                try DirCreate(BackupsDir "\auto")
                try FileMove(A_LoopFilePath, BackupsDir "\auto\" A_LoopFileName, 0)
            }
        }
    }

    ; To bundle your own .ico or .wav files inside the compiled .exe, uncomment the lines below,
    ; create an assets\ folder first, and match your exact filenames (Source MUST be a literal string):
    ; DirCreate(A_ScriptDir "\assets")
    ; FileInstall("Assets\tray.ico", A_ScriptDir "\assets\tray.ico", 0)
}
RING_LOG_MAX          := 50
RingLogBuffer         := []
ScriptBasePath        := ConfigDir "\OLED Engine"
ErrorLogPath          := LogsDir "\errors.log"
CareStateIniPath      := ScriptBasePath . ".oledcare.ini"
DefaultDebugLogPath   := LogsDir "\debug.log"
StartupRegKey         := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
StartupRegValueName   := "OLEDEngine"

Primary_Dim_Alpha     := Round(Max(0, Min(100, Primary_Dim_Percent)) * 2.55)
Primary_HDR_Dim_Alpha := Round(Max(0, Min(100, Primary_HDR_Dim_Percent)) * 2.55)
Extra_Dim_Alpha       := Round(Max(0, Min(100, Extra_Dim_Percent)) * 2.55)
Extra_HDR_Dim_Alpha   := Round(Max(0, Min(100, Extra_HDR_Dim_Percent)) * 2.55)
Comp_Game_Processes   := []
Excluded_Processes    := []
TrayMenuItems         := []
RegisteredHotkeysList := []
MANUAL_WAKE_GRACE_MS  := 750     ; Post-toggle grace window before a manual dim can be woken by activity
MANUAL_WAKE_MOVE_PX   := 8       ; Cursor travel (px) from the toggle anchor that counts as interaction
PRIMARY_POSTDIM_MS    := 150     ; Settle window after Monitor 1 auto-dims before it may wake again
PRIMARY_REDIM_MS      := 1500    ; Minimum time after a wake before Monitor 1 may auto-dim again (stops dim/wake bouncing)
DISPLAY_SETTLE_MS     := 1500    ; Settle window after a display / HDR topology change
ICON_ENFORCE_MS       := 500     ; How often hidden desktop icons get their layered alpha re-applied

                                 ; Wake hooks (must exist before anything calls SyncWakeHooks during startup)
wakeHookInitX         := 0
wakeHookInitY         := 0
      
ParseCompGamesList()
ParseExcludedProcessesList()
ParseMediaBrowserLists()
ParseTrayMenuConfig()
SyncStartupRegistry(Start_With_Windows)
OLED_Refresh_Popup_Sound := NormalizeSoundName(OLED_Refresh_Popup_Sound)    ; old names (Chime, Ding...) map to the new gentle sounds
Dim_Sound_Name           := NormalizeSoundName(Dim_Sound_Name)
Wake_Sound_Name          := NormalizeSoundName(Wake_Sound_Name)

; ==============================================================================
; 2. RUNTIME STATE, CARE, STATS, OVERLAYS & TIMERS
; ==============================================================================
isAutomationPaused                 := false
isSessionLocked                    := false
scriptStartTick                    := A_TickCount
lastDebugStateSig                  := ""

isManualBlackoutOn                 := false
isManualPrimaryDimOn               := false
isAutoPrimaryDimmed                := false
isTestingPrimaryDim                := false
currentPrimaryAlpha                := 0
targetPrimaryAlpha                 := 0
primaryFadeActive                  := false
primaryFadeFrom                    := 0
primaryFadeStartTick               := 0
primaryFadeMs                      := 1
primaryLastWakeTick                := 0
primaryLastWakeWhy                 := ""
primaryDimLogTick                  := 0

oledActiveMsSinceRefresh           := 0
primaryDimmedMs                    := 0
primaryUndimmedMs                  := 0
secondaryDimmedMs                  := 0
secondaryUndimmedMs                := 0
primaryWakeCount                   := 0
secondaryWakeCount                 := 0
primaryDimBlackoutTriggers         := 0
secondaryDimBlackoutTriggers       := 0
wasPrimaryDimOrBlackoutStat        := false
wasSecondaryDimStat                := false
lastOledCareTick                   := A_TickCount
lastRefreshPromptTick              := 0
pendingRefreshReminder             := false
RefreshPromptGui                   := ""

isCursorIdleHidden                 := false
areCursorsHidden                   := false

areDesktopIconsHidden              := false
currentIconAlpha                   := 255
targetIconAlpha                    := 255
activeIconFadeStep                 := 15

isAutoExtraDimmed                  := false
isManualExtraDimOn                 := false
isTestingExtraDim                  := false
manualExtraStartTick               := 0
currentExtraAlpha                  := 0
targetExtraAlpha                   := 0
manualExtraMonSet                  := Map()
extraMonDimmedSet                  := Map()
extraMonLastActiveTick             := Map()

manualPrimaryStartTick             := 0
manualExtraMonStartTick            := Map()
manualExtraMonAnchorPt             := Map()
primaryAutoDimTick                 := 0
lastDisplayChangeTick              := 0
lastPrimaryRealInputTick           := 0
lastCursorInputTick                := A_TickCount
lastIconEnforceTick                := 0
primaryFadeTimerFn                 := StepPrimaryOverlayFade
iconFadeTimerFn                    := StepDesktopIconFade
extraFadeTimerFn                   := ""
extraFadeProgress                  := 1.0
CareTabIdx                         := 0
manualPrimaryAnchorX                    := -99999
manualPrimaryAnchorY                    := -99999

lastPrimaryActiveTick              := A_TickCount
lastDesktopIconActiveTick          := A_TickCount
lastExtraActiveTick                := A_TickCount
wasOnExtraMonitor                  := false
prevTimeIdle                       := A_TimeIdle
prevLButtonDown                    := false
prevRButtonDown                    := false
lastMouseX                         := -99999
lastMouseY                         := -99999
lastGamepadPackets                 := [0, 0, 0, 0]

cachedDisplayTopo                  := ""
lastDisplayTopoTick                := 0
cachedHdrState                     := QueryWindowsPrimaryHdrState()
Active_HDR_Mode                    := cachedHdrState
lastHdrCheckTick                   := A_TickCount
isTogglingHdr                      := false
wasCompGameRunning                 := false
switchedToSdrForCompGame           := false
cachedCompRunning                  := false
lastCompCheckTick                  := 0
cachedExcludedRunning              := false
lastExcludedCheckTick              := 0
lastConnectedMonitorCount          := GetDetectedMonitorCount()

ExtraDimmerGuis                    := []
SettingsGui                        := ""
SettingsTabsCtrl                   := ""
SectionBoxTitles                   := Map()
SettingsTabDefaultBanner           := Map()
SettingsTabTipMap                  := Map()
SettingsApplyBtn                   := ""
SettingsHintCtrl                   := ""
SettingsLastBannerText             := ""
SettingsActiveTab                  := 1
HdrSwitchMap                       := Map()
CareUiRefs                         := Map()
StatsPromptGui                     := ""
StatsTimerActive                   := false

HoverTipMap                        := Map()
GroupTitleTips                     := []
LiveStatusRefs                     := []        ; Live Status boxes on the Monitor tabs (refreshed once a second while Settings is open)
lastHoveredKey                     := ""
dragTraySourceRow                  := 0
dragTrayHighlightRow               := 0
isDraggingTrayRow                  := false
trayListViewCtrl                   := ""
trayDraftRef                       := []
trayRefreshFn                      := ""

themeBgBrush                       := 0
themeSurfaceBrush                  := 0
ThemeBgRgb                         := 0
ThemeSurfaceRgb                    := 0
RefreshThemeColors()                ; builds the Dark / Light / custom-color palette used by every window

currentTrayBadgeState              := -1
hActiveTrayIcon                    := 0
hMenuAlertIcon                     := 0
hMinimalMonitorIcon                := CreateMinimalistMonitorIcon(0)

if hMinimalMonitorIcon {
    try TraySetIcon("HICON:" hMinimalMonitorIcon)
}

LoadOledCareState()
ResetAllIdleTimers()

RestoreDesktopIconsImmediate()
RestoreSystemCursors()

initPt := Buffer(8, 0)
if DllCall("GetCursorPos", "Ptr", initPt.Ptr) {
    lastMouseX        := NumGet(initPt, 0, "Int")
    lastMouseY        := NumGet(initPt, 4, "Int")
    wasOnExtraMonitor := IsPointOnExtraMonitor(lastMouseX, lastMouseY)
}

PrimaryOverlayGui := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale +E0x20 +E0x80000")
PrimaryOverlayGui.BackColor := "000000"

RegisterAllMonitorHotkeys()
RegisterSessionLockHook()

OnError(OnScriptRuntimeError)
OnMessage(0x007E, OnDisplayOrPowerChange)
OnMessage(0x0218, OnDisplayOrPowerChange)
OnMessage(0x02B1, OnSessionChangeMsg)
OnMessage(0x0138, OnCtlColor)           ; WM_CTLCOLORSTATIC
OnMessage(0x0133, OnCtlColor)           ; WM_CTLCOLOREDIT
OnMessage(0x0134, OnCtlColor)           ; WM_CTLCOLORLISTBOX
OnMessage(0x0135, OnCtlColor)           ; WM_CTLCOLORBTN
OnMessage(0x0200, OnMouseMoveMsg)       ; WM_MOUSEMOVE
OnMessage(0x0202, OnLeftButtonUp)       ; WM_LBUTTONUP
OnMessage(0x002B, OnTabDrawItem)        ; WM_DRAWITEM (rounded pill tabs)
PresetsIniPath := ScriptBasePath ".presets.ini"
LoadPresetsFromIni()
StartGameAutomation()
if (Run_As_Admin && !A_IsAdmin) {
    try {
        startupFlag := HasStartupArg() ? " /startup" : ""
        if A_IsCompiled {
            Run('*RunAs "' A_ScriptFullPath '"' startupFlag)
        } else {
            Run('*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"' startupFlag)
        }
        ExitApp()
    }
}
SyncWindowsTaskbarAutoHide(PresetTaskbarTarget(), true)
SetTimer(CheckLongIdle, 5000)
OnExit(CleanupOnExit)

InitUpdater()
DebugLogEvent("================ OLED Engine started ================")
DebugLogEvent("Monitors detected: " GetDetectedMonitorCount() " | Monitor 1 is in " (QueryWindowsPrimaryHdrState() ? "HDR" : "SDR") " mode | Auto-dim Monitor 1: " OnOff(Primary_Auto_Enabled) ", other monitors: " OnOff(Extra_Auto_Enabled))

ApplyMenuTheme(UI_Dark_Mode)
ApplyTrayMenuColor()
UpdateTrayRefreshVisuals(true)
SetupTrayMenu()
SetTimer(CheckIdleActivity, 120)
SetTimer(TickOledCare, 1000)
SetTimer(CheckStartupOledRefreshReminder, -800)

if !(Start_Minimized && HasStartupArg()) {
    OpenSettingsGui(1)
}

PushRingLog(msg, level := "INFO") {
    global RingLogBuffer, RING_LOG_MAX
    ms := Mod(A_TickCount, 1000)
    stamp := FormatTime(, "yyyy-MM-dd hh:mm:ss") "." Format("{:03}", ms) FormatTime(, " tt")
    entry := stamp " | " SubStr(level "     ", 1, 5) " | " msg
    RingLogBuffer.Push(entry)
    if (RingLogBuffer.Length > RING_LOG_MAX) {
        RingLogBuffer.RemoveAt(1)
    }
}

OpenErrorLogFile() {
    global ErrorLogPath
    if !FileExist(ErrorLogPath) {
        MsgBox("No runtime errors have been logged yet.`n`nExpected path:`n" ErrorLogPath, "OLED Engine Error Log", "Iconi")
        return
    }
    try Run('"' ErrorLogPath '"')
}

OnScriptRuntimeError(err, mode) {
    global ErrorLogPath, RingLogBuffer, APP_VERSION
    global isAutomationPaused, isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed, Active_HDR_Mode

    try RestoreSystemCursors()
    try RestoreDesktopIconsImmediate()

    errMsg := "Unhandled error (" mode "): " err.Message " | What: " err.What " | File: " err.File " (line " err.Line ")"
    PushRingLog(errMsg, "ERROR")
    DebugLogEvent(errMsg, "ERROR")

    try {
        logDir := A_ScriptDir "\logs"
        if !DirExist(logDir) {
            DirCreate(logDir)
        }
        if (FileExist(ErrorLogPath) && FileGetSize(ErrorLogPath) > 1048576) {
            try FileDelete(ErrorLogPath ".old")
            try FileMove(ErrorLogPath, ErrorLogPath ".old", 1)
        }

        stamp := FormatTime(, "yyyy-MM-dd hh:mm:ss tt")
        dump := "================================================================================`r`n"
        dump .= "[" stamp "] OLED Engine v" APP_VERSION " | AHK v" A_AhkVersion " | Mode: " mode "`r`n"
        dump .= "Message : " err.Message "`r`n"
        dump .= "What    : " err.What "`r`n"
        dump .= "Location: " err.File " (Line " err.Line ")`r`n"
        if (err.Extra != "") {
            dump .= "Extra   : " err.Extra "`r`n"
        }
        if (err.Stack != "") {
            dump .= "Stack   :`r`n" StrReplace(err.Stack, "`n", "`r`n") "`r`n"
        }
        dump .= "State   : Paused=" OnOff(isAutomationPaused) " | ManualBlk=" OnOff(isManualBlackoutOn) " | ManualDim=" OnOff(isManualPrimaryDimOn) " | AutoDim=" OnOff(isAutoPrimaryDimmed) " | HDR=" OnOff(Active_HDR_Mode) "`r`n"
        dump .= "--- Last " RingLogBuffer.Length " RingLog Events ---`r`n"
        for line in RingLogBuffer {
            dump .= line "`r`n"
        }
        dump .= "`r`n"

        f := FileOpen(ErrorLogPath, "a", "UTF-8")
        if IsObject(f) {
            f.Write(dump)
            f.Close()
        }
    }
    return 1
}

GetEffectiveDebugLogPath(overridePath := "") {
    global Debug_Log_Path, DefaultDebugLogPath
    raw := (overridePath != "") ? Trim(overridePath) : Trim(Debug_Log_Path)
    if (raw = "") {
        return DefaultDebugLogPath
    }
    if DirExist(raw) {
        return RTrim(raw, "\/") . "\OLEDEngine.debug.log"
    }
    return raw
}

OpenDebugLogFile(overridePath := "") {
    logPath := GetEffectiveDebugLogPath(overridePath)
    try {
        if !FileExist(logPath) {
            f := FileOpen(logPath, "w", "UTF-8")
            f.Write(FormatTime(, "yyyy-MM-dd hh:mm:ss tt") " | Debug log initialized`r`n")
            f.Close()
        }
        Run('"' logPath '"')
    } catch as err {
        MsgBox("Could not open log file:`n" logPath "`n`n" err.Message, "Debug Log", "Icon!")
    }
}

BrowseDebugLogPath(edtPathCtrl) {
    curPath := GetEffectiveDebugLogPath(edtPathCtrl.Value)
    selected := FileSelect("S24", curPath, "Select Debug Log File", "Log Files (*.log; *.txt)")
    if (selected != "") {
        edtPathCtrl.Value := selected
        MarkSettingsDirty()
    }
}

DebugLogEvent(msg, level := "INFO") {
    global Debug_Log_Enabled
    static lastMsg := "", lastTick := 0, repeatCount := 0
    PushRingLog(msg, level)
    if (!Debug_Log_Enabled || Debug_Log_Enabled != true) {
        return
    }
    now := A_TickCount
    ; Identical lines in quick succession are collapsed instead of flooding the log
    if (msg = lastMsg && (now - lastTick) < 2000) {
        repeatCount += 1
        lastTick := now
        return
    }
    try {
       logPath := GetEffectiveDebugLogPath()
        maxLogBytes := 1048576 ; 1 MB
        keepLines := 500
        if (FileExist(logPath) && FileGetSize(logPath) > maxLogBytes) {
            rawLines := StrSplit(StrReplace(FileRead(logPath, "UTF-8"), "`r`n", "`n"), "`n")
            if (rawLines.Length > 0 && rawLines[rawLines.Length] = "") {
                rawLines.Pop()
            }
            startIdx := Max(1, rawLines.Length - keepLines + 1)
            trimmed := FormatTime(, "yyyy-MM-dd hh:mm:ss tt") " | INFO  | Debug log trimmed to last " keepLines " lines`r`n"
            Loop (rawLines.Length - startIdx + 1) {
                trimmed .= rawLines[startIdx + A_Index - 1] "`r`n"
            }
            fTrim := FileOpen(logPath, "w", "UTF-8")
            fTrim.Write(trimmed)
            fTrim.Close()
        }
        stamp := FormatTime(, "yyyy-MM-dd hh:mm:ss tt")
        out := ""
        if (repeatCount > 0) {
            out .= stamp " | INFO  | (the line above repeated " repeatCount " more time(s))`r`n"
        }
        out .= stamp " | " SubStr(level "     ", 1, 5) " | " msg "`r`n"
        f := FileOpen(logPath, "a", "UTF-8")
        f.Write(out)
        f.Close()
    }
    lastMsg := msg
    lastTick := now
    repeatCount := 0
}

OnOff(v) {
    return v ? "on" : "off"
}

FriendlyCtx(ctx) {
    switch ctx {
        case "desktop":
            return "Desktop"
        case "normal_game":
            return "Game / fullscreen app"
        case "comp_game":
            return "Competitive game"
        case "movie_playing":
            return "Video playing"
        case "movie_paused":
            return "Video paused"
        default:
            return ctx
    }
}

MonListText(monMap) {
    parts := []
    for idx, _ in monMap {
        parts.Push("Monitor " idx)
    }
    return JoinArray(parts, ", ")
}

LogPrimaryDim(why, warnIfBounce := false) {
    global primaryLastWakeTick, primaryLastWakeWhy, primaryDimLogTick
    now := A_TickCount
    pct := Round(GetActivePrimaryDimAlpha() / 2.55)
    sinceWake := now - primaryLastWakeTick
    if (warnIfBounce && primaryLastWakeTick > 0 && sinceWake < 5000) {
        DebugLogEvent("Monitor 1 dimmed again only " Round(sinceWake / 1000, 1) "s after waking (" why "). The wake before it was caused by: " primaryLastWakeWhy ". Repeats of this line point to the cause of any flicker.", "WARN")
    } else {
        DebugLogEvent("Monitor 1 dimmed to " pct "% - " why)
    }
    primaryDimLogTick := now
}

LogPrimaryWake(why) {
    global primaryLastWakeTick, primaryLastWakeWhy, primaryDimLogTick
    now := A_TickCount
    dimmedText := (primaryDimLogTick > 0) ? (" (was dimmed for " FormatDuration(now - primaryDimLogTick) ")") : ""
    DebugLogEvent("Monitor 1 woke up - " why dimmedText)
    primaryLastWakeTick := now
    primaryLastWakeWhy  := why
}

RegisterSessionLockHook() {
    try DllCall("wtsapi32\WTSRegisterSessionNotification", "Ptr", A_ScriptHwnd, "UInt", 0)
}

UnregisterSessionLockHook() {
    try DllCall("wtsapi32\WTSUnRegisterSessionNotification", "Ptr", A_ScriptHwnd)
}

OnSessionChangeMsg(wParam, lParam, msg, hwnd) {
    global isSessionLocked, isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed
    global isManualExtraDimOn, isAutoExtraDimmed, manualExtraMonSet, lastOledCareTick

    if (wParam = 0x7) {
        ; WTS_SESSION_LOCK
        isSessionLocked := true
        DebugLogEvent("Windows locked - overlays removed, cursor and desktop icons restored")
        if isManualBlackoutOn {
            SetManualBlackout(false)
        }
        isManualPrimaryDimOn := false
        isAutoPrimaryDimmed  := false
        isManualExtraDimOn   := false
        isAutoExtraDimmed    := false
        manualExtraMonSet    := Map()
        SetCursorIdleHidden(false)
        RestoreDesktopIconsImmediate()
        UpdateCursorVisibility()
        StartPrimaryOverlayFade(0, 0)
        StartExtraFade(0, 0)
    } else if (wParam = 0x8) {
        ; WTS_SESSION_UNLOCK
        isSessionLocked := false
        lastOledCareTick := A_TickCount
        ResetAllIdleTimers()
        RestoreSystemCursors()
        DebugLogEvent("Windows unlocked - idle timers restarted")
    }
}

; ==============================================================================
; 3. STARTUP REGISTRY, MONITOR ICON, ACCENT COLOR, DETECTION & HOTKEYS
; ==============================================================================
HasStartupArg() {
    for arg in A_Args {
        clean := StrLower(Trim(arg, ' "`t'))
        if (clean = "/startup" || clean = "-startup") {
            return true
        }
    }
    return false
}

SyncStartupRegistry(enable) {
    global StartupRegKey, StartupRegValueName
    try {
        try RegDelete(StartupRegKey, "DisplayDimmerBlackout")
        if enable {
            cmd := A_IsCompiled
                ? ('"' A_ScriptFullPath '" /startup')
                : ('"' A_AhkPath '" "' A_ScriptFullPath '" /startup')
            RegWrite(cmd, "REG_SZ", StartupRegKey, StartupRegValueName)
        } else {
            try RegDelete(StartupRegKey, StartupRegValueName)
        }
    }
}
IsStartupRegistryEnabled() {
    global StartupRegKey, StartupRegValueName
    try {
        val := RegRead(StartupRegKey, StartupRegValueName)
        return (val != "")
    }
    return false
}

CreateMinimalistMonitorIcon(badgeState := 0) {
    w := 32
    h := 32
    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0)
    NumPut("Int", w, bi, 4)
    NumPut("Int", -h, bi, 8)
    NumPut("UShort", 1, bi, 12)
    NumPut("UShort", 32, bi, 14)
    NumPut("UInt", 0, bi, 16)

    pBits := 0
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    hbmColor := DllCall("CreateDIBSection", "Ptr", hdc, "Ptr", bi.Ptr, "UInt", 0, "Ptr*", &pBits, "Ptr", 0, "UInt", 0, "Ptr")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    if (!hbmColor || !pBits) {
        return 0
    }

    DllCall("RtlZeroMemory", "Ptr", pBits, "UPtr", w * h * 4)

    accentBgr := GetWindowsAccentColorBGR()
    accR := accentBgr & 0xFF
    accG := (accentBgr >> 8) & 0xFF
    accB := (accentBgr >> 16) & 0xFF

    bezelCol  := 0xFFF2F4F8
    screenCol := (0xFF << 24) | (Max(18, accR // 3) << 16) | (Max(22, accG // 3) << 8) | Max(28, accB // 3)
    glowCol   := (0xFF << 24) | (accR << 16) | (accG << 8) | accB
    standCol  := 0xFFD8DEE9
    badgeFill := (badgeState = 2) ? 0xFFFF3B30 : 0xFFFFD60A
    badgeRing := 0xFF141414

    Loop h {
        y := A_Index - 1
        Loop w {
            x := A_Index - 1
            col := 0

            if (x >= 2 && x <= 29 && y >= 4 && y <= 21) {
                isCorner := ((x = 2 || x = 29) && (y = 4 || y = 21))
                if !isCorner {
                    if (x >= 4 && x <= 27 && y >= 6 && y <= 19) {
                        col := screenCol
                        if (y = 18 && x >= 6 && x <= 14) {
                            col := glowCol
                        }
                    } else {
                        col := bezelCol
                    }
                }
            }
            else if (x >= 14 && x <= 17 && y >= 22 && y <= 25) {
                col := standCol
            }
            else if (x >= 9 && x <= 22 && y >= 26 && y <= 27) {
                col := bezelCol
            }

            if (badgeState > 0) {
                dx := x - 24
                dy := y - 24
                distSq := (dx * dx) + (dy * dy)
                if (distSq <= 36) {
                    col := (distSq >= 25) ? badgeRing : badgeFill
                }
            }

            if (col != 0) {
                NumPut("UInt", col, pBits + ((y * w + x) * 4), 0)
            }
        }
    }

    hbmMask := DllCall("CreateBitmap", "Int", w, "Int", h, "UInt", 1, "UInt", 1, "Ptr", 0, "Ptr")
    ii := Buffer(A_PtrSize = 8 ? 32 : 20, 0)
    NumPut("Int", 1, ii, 0)
    NumPut("Ptr", hbmMask, ii, A_PtrSize = 8 ? 16 : 12)
    NumPut("Ptr", hbmColor, ii, A_PtrSize = 8 ? 24 : 16)

    hIcon := DllCall("CreateIconIndirect", "Ptr", ii.Ptr, "Ptr")
    DllCall("DeleteObject", "Ptr", hbmColor)
    DllCall("DeleteObject", "Ptr", hbmMask)
    return hIcon
}

CreateStatusCircleIcon(badgeState := 1) {
    w := 16
    h := 16
    bi := Buffer(40, 0)
    NumPut("UInt", 40, bi, 0)
    NumPut("Int", w, bi, 4)
    NumPut("Int", -h, bi, 8)
    NumPut("UShort", 1, bi, 12)
    NumPut("UShort", 32, bi, 14)
    NumPut("UInt", 0, bi, 16)

    pBits := 0
    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    hbmColor := DllCall("CreateDIBSection", "Ptr", hdc, "Ptr", bi.Ptr, "UInt", 0, "Ptr*", &pBits, "Ptr", 0, "UInt", 0, "Ptr")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
    if (!hbmColor || !pBits) {
        return 0
    }
    DllCall("RtlZeroMemory", "Ptr", pBits, "UPtr", w * h * 4)

    fillCol := (badgeState = 2) ? 0xFFFF3B30 : 0xFFFFD60A
    ringCol := 0xFF1E1E1E
    Loop h {
        y := A_Index - 1
        Loop w {
            x := A_Index - 1
            dx := x - 7.5
            dy := y - 7.5
            distSq := (dx * dx) + (dy * dy)
            if (distSq <= 36) {
                col := (distSq >= 25) ? ringCol : fillCol
                NumPut("UInt", col, pBits + ((y * w + x) * 4), 0)
            }
        }
    }

    hbmMask := DllCall("CreateBitmap", "Int", w, "Int", h, "UInt", 1, "UInt", 1, "Ptr", 0, "Ptr")
    ii := Buffer(A_PtrSize = 8 ? 32 : 20, 0)
    NumPut("Int", 1, ii, 0)
    NumPut("Ptr", hbmMask, ii, A_PtrSize = 8 ? 16 : 12)
    NumPut("Ptr", hbmColor, ii, A_PtrSize = 8 ? 24 : 16)
    hIcon := DllCall("CreateIconIndirect", "Ptr", ii.Ptr, "Ptr")
    DllCall("DeleteObject", "Ptr", hbmColor)
    DllCall("DeleteObject", "Ptr", hbmMask)
    return hIcon
}

GetOledRefreshStatus() {
    global OLED_Refresh_Reminder_Enabled, oledActiveMsSinceRefresh
    thresholdMs := GetRefreshReminderThresholdMs()
    if (!OLED_Refresh_Reminder_Enabled || thresholdMs <= 0) {
        return { state: 0, pct: 0.0, thresholdMs: thresholdMs, remainingMs: 0, overdueMs: 0 }
    }
    pct := (oledActiveMsSinceRefresh / thresholdMs) * 100.0
    if (oledActiveMsSinceRefresh >= thresholdMs) {
        return { state: 2, pct: pct, thresholdMs: thresholdMs, remainingMs: 0, overdueMs: oledActiveMsSinceRefresh - thresholdMs }
    }
    if (pct >= 85.0) {
        return { state: 1, pct: pct, thresholdMs: thresholdMs, remainingMs: thresholdMs - oledActiveMsSinceRefresh, overdueMs: 0 }
    }
    return { state: 0, pct: pct, thresholdMs: thresholdMs, remainingMs: thresholdMs - oledActiveMsSinceRefresh, overdueMs: 0 }
}
UpdateTrayRefreshVisuals(force := false) {
    global currentTrayBadgeState, hActiveTrayIcon, hMinimalMonitorIcon, oledActiveMsSinceRefresh, isAutomationPaused
    st := GetOledRefreshStatus()
    stateChanged := (st.state != currentTrayBadgeState)

    if (force || stateChanged) {
        currentTrayBadgeState := st.state
        applied := false
        try {
            newIcon := (st.state = 0) ? hMinimalMonitorIcon : CreateMinimalistMonitorIcon(st.state)
            if newIcon {
                TraySetIcon("HICON:" newIcon)
                if (hActiveTrayIcon && hActiveTrayIcon != hMinimalMonitorIcon) {
                    try DllCall("DestroyIcon", "Ptr", hActiveTrayIcon)
                }
                hActiveTrayIcon := newIcon
                applied := true
            }
        }
        ; Backup plan if custom GDI icon fails
        if !applied {
            try {
                if (st.state = 2) {
                    TraySetIcon("imageres.dll", 94)
                } else if (st.state = 1) {
                    TraySetIcon("imageres.dll", 80)
                } else {
                    TraySetIcon("imageres.dll", 110)
                }
            }
        }
        SetupTrayMenu()
        UpdateOledCareAlertUi()
    }

    if isAutomationPaused {
        A_IconTip := "OLED Engine — AUTOMATION PAUSED"
    } else if (st.state = 2) {
        A_IconTip := "OLED Engine — PIXEL REFRESH DUE (Overdue by " FormatDuration(st.overdueMs, false) ")"
    } else if (st.state = 1) {
        A_IconTip := "OLED Engine — Pixel refresh due soon (" FormatDuration(st.remainingMs, false) " left)"
    } else {
        A_IconTip := "OLED Engine"
    }
}

ApplyWindowMonitorIcon(hwnd) {
    global hMinimalMonitorIcon
    if (hMinimalMonitorIcon && hwnd) {
        DllCall("SendMessage", "Ptr", hwnd, "UInt", 0x0080, "Ptr", 0, "Ptr", hMinimalMonitorIcon)
        DllCall("SendMessage", "Ptr", hwnd, "UInt", 0x0080, "Ptr", 1, "Ptr", hMinimalMonitorIcon)
    }
}

GetWindowsAccentColorBGR() {
    try {
        abgr := RegRead("HKCU\Software\Microsoft\Windows\DWM", "AccentColor")
        return abgr & 0x00FFFFFF
    }
    try {
        argb := RegRead("HKCU\Software\Microsoft\Windows\DWM", "ColorizationColor")
        r := (argb >> 16) & 0xFF
        g := (argb >> 8) & 0xFF
        b := argb & 0xFF
        return (b << 16) | (g << 8) | r
    }
    return 0xD47800
}

GetDetectedMonitorCount() {
    global MAX_MONITORS
    return Max(1, Min(MAX_MONITORS, MonitorGetCount()))
}

GetMonitorHotkeyVar(monIdx) {
    global Mon1_Hotkey, Mon2_Hotkey, Mon3_Hotkey, Mon4_Hotkey, Mon5_Hotkey
    switch monIdx {
        case 1: return Mon1_Hotkey
        case 2: return Mon2_Hotkey
        case 3: return Mon3_Hotkey
        case 4: return Mon4_Hotkey
        case 5: return Mon5_Hotkey
        default: return ""
    }
}

SetMonitorHotkeyVar(monIdx, hkStr) {
    global Mon1_Hotkey, Mon2_Hotkey, Mon3_Hotkey, Mon4_Hotkey, Mon5_Hotkey
    cleanHk := Trim(hkStr)
    switch monIdx {
        case 1: Mon1_Hotkey := cleanHk
        case 2: Mon2_Hotkey := cleanHk
        case 3: Mon3_Hotkey := cleanHk
        case 4: Mon4_Hotkey := cleanHk
        case 5: Mon5_Hotkey := cleanHk
    }
}

FormatHotkeyForDisplay(hkStr) {
    if (hkStr = "") {
        return ""
    }
    s := hkStr
    s := StrReplace(s, "^", "Ctrl+")
    s := StrReplace(s, "!", "Alt+")
    s := StrReplace(s, "+", "Shift+")
    s := StrReplace(s, "#", "Win+")
    return s
}

UnregisterAllMonitorHotkeys() {
    global RegisteredHotkeysList
    for item in RegisteredHotkeysList {
        try Hotkey(item.hk, item.fn, "Off")
    }
    RegisteredHotkeysList := []
}

RegisterAllMonitorHotkeys() {
    global RegisteredHotkeysList, MAX_MONITORS
    UnregisterAllMonitorHotkeys()

    monCount := GetDetectedMonitorCount()
    Loop Min(MAX_MONITORS, monCount) {
        idx := A_Index
        hkStr := Trim(GetMonitorHotkeyVar(idx))
        if (hkStr != "") {
            fn := MakeMonitorHotkeyCallback(idx)
            try {
                Hotkey(hkStr, fn, "On")
                RegisteredHotkeysList.Push({ hk: hkStr, fn: fn })
            }
        }
    }
}

MakeMonitorHotkeyCallback(monIdx) {
    return (*) => HandleMonitorHotkeyAction(monIdx)
}

HandleMonitorHotkeyAction(monIdx) {
    if (monIdx > GetDetectedMonitorCount()) {
        return
    }
    priIdx := MonitorGetPrimary()
    if (monIdx = priIdx) {
        TogglePrimaryDimOrBlackout()
    } else {
        ToggleSpecificExtraMonitor(monIdx)
    }
}

InvalidateDisplayTopoCache() {
    global cachedDisplayTopo, lastDisplayTopoTick, lastHdrCheckTick
    cachedDisplayTopo := ""
    lastDisplayTopoTick := 0
    lastHdrCheckTick := 0
}

GetDisplayTopoSnapshot() {
    global cachedDisplayTopo, lastDisplayTopoTick
    if (IsObject(cachedDisplayTopo) && (A_TickCount - lastDisplayTopoTick < 1500)) {
        return cachedDisplayTopo
    }

    friendlyByGdi := Map()
    pathByGdi     := Map()

    numPaths := 0
    numModes := 0
    if (DllCall("user32\GetDisplayConfigBufferSizes", "UInt", 2, "UInt*", &numPaths, "UInt*", &numModes, "Int") = 0 && numPaths > 0) {
        pathsBuf := Buffer(numPaths * 72, 0)
        modesBuf := Buffer(numModes * 64, 0)
        if (DllCall("user32\QueryDisplayConfig", "UInt", 2, "UInt*", &numPaths, "Ptr", pathsBuf.Ptr, "UInt*", &numModes, "Ptr", modesBuf.Ptr, "Ptr", 0, "Int") = 0) {
            srcNameBuf := Buffer(84, 0)
            tgtNameBuf := Buffer(420, 0)

            Loop numPaths {
                offset := (A_Index - 1) * 72
                pathFlags := NumGet(pathsBuf, offset + 68, "UInt")
                if !(pathFlags & 0x1) {
                    continue
                }
                srcAdapterLow  := NumGet(pathsBuf, offset + 0, "UInt")
                srcAdapterHigh := NumGet(pathsBuf, offset + 4, "Int")
                srcId          := NumGet(pathsBuf, offset + 8, "UInt")

                DllCall("RtlZeroMemory", "Ptr", srcNameBuf.Ptr, "UPtr", 84)
                NumPut("UInt", 1, srcNameBuf, 0)
                NumPut("UInt", 84, srcNameBuf, 4)
                NumPut("UInt", srcAdapterLow, srcNameBuf, 8)
                NumPut("Int", srcAdapterHigh, srcNameBuf, 12)
                NumPut("UInt", srcId, srcNameBuf, 16)

                if (DllCall("user32\DisplayConfigGetDeviceInfo", "Ptr", srcNameBuf.Ptr, "Int") = 0) {
                    gdiName := StrGet(srcNameBuf.Ptr + 20, 32, "UTF-16")
                    if (gdiName != "") {
                        tgtAdapterLow  := NumGet(pathsBuf, offset + 20, "UInt")
                        tgtAdapterHigh := NumGet(pathsBuf, offset + 24, "Int")
                        tgtId          := NumGet(pathsBuf, offset + 28, "UInt")

                        if !pathByGdi.Has(gdiName) {
                            pathByGdi[gdiName] := {
                                tgtLow: tgtAdapterLow,
                                tgtHigh: tgtAdapterHigh,
                                tgtId: tgtId
                            }
                        }

                        if !friendlyByGdi.Has(gdiName) {
                            DllCall("RtlZeroMemory", "Ptr", tgtNameBuf.Ptr, "UPtr", 420)
                            NumPut("UInt", 2, tgtNameBuf, 0)
                            NumPut("UInt", 420, tgtNameBuf, 4)
                            NumPut("UInt", tgtAdapterLow, tgtNameBuf, 8)
                            NumPut("Int", tgtAdapterHigh, tgtNameBuf, 12)
                            NumPut("UInt", tgtId, tgtNameBuf, 16)

                            if (DllCall("user32\DisplayConfigGetDeviceInfo", "Ptr", tgtNameBuf.Ptr, "Int") = 0) {
                                friendly := Trim(StrGet(tgtNameBuf.Ptr + 36, 64, "UTF-16"))
                                if (friendly != "") {
                                    friendlyByGdi[gdiName] := friendly
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    cachedDisplayTopo := { friendly: friendlyByGdi, paths: pathByGdi }
    lastDisplayTopoTick := A_TickCount
    return cachedDisplayTopo
}

GetFriendlyMonitorName(monIdx) {
    gdiName := ""
    try gdiName := MonitorGetName(monIdx)
    if (gdiName = "") {
        return "Display " monIdx
    }

    topo := GetDisplayTopoSnapshot()
    if topo.friendly.Has(gdiName) {
        return topo.friendly[gdiName]
    }

    try {
        monDev := Buffer(840, 0)
        NumPut("UInt", 840, monDev, 0)
        if DllCall("user32\EnumDisplayDevicesW", "Str", gdiName, "UInt", 0, "Ptr", monDev.Ptr, "UInt", 0, "Int") {
            monStr := Trim(StrGet(monDev.Ptr + 72, 128, "UTF-16"))
            if (monStr != "" && monStr != "Generic PnP Monitor" && monStr != "Generic Monitor") {
                return monStr
            }
        }
    }
    return StrReplace(gdiName, "\\.\", "")
}

GetMonitorRefreshRate(monIdx) {
    gdiName := ""
    try gdiName := MonitorGetName(monIdx)
    if (gdiName = "") {
        return 0
    }
    dm := Buffer(220, 0)
    NumPut("UShort", 220, dm, 68)
    if DllCall("user32\EnumDisplaySettingsW", "Str", gdiName, "Int", -1, "Ptr", dm.Ptr, "Int") {
        return NumGet(dm, 184, "UInt")
    }
    return 0
}

GetMonitorHoverInfo(monIdx) {
    priIdx := MonitorGetPrimary()
    name := GetFriendlyMonitorName(monIdx)
    MonitorGet(monIdx, &l, &t, &r, &b)
    w := Abs(r - l)
    h := Abs(b - t)
    hz := GetMonitorRefreshRate(monIdx)
    role := (monIdx = priIdx) ? "Primary" : "Secondary"
    hzStr := (hz > 0) ? (" @ " hz " Hz") : ""
    return "Monitor " monIdx " (" role "): " name " — " w "x" h hzStr
}

ApplyMenuTheme(darkMode) {
    try {
        hUx := DllCall("GetModuleHandle", "Str", "uxtheme.dll", "Ptr")
        if !hUx {
            hUx := DllCall("LoadLibrary", "Str", "uxtheme.dll", "Ptr")
        }
        if hUx {
            pSetMode := DllCall("GetProcAddress", "Ptr", hUx, "Ptr", 135, "Ptr")
            pFlush   := DllCall("GetProcAddress", "Ptr", hUx, "Ptr", 136, "Ptr")
            if pSetMode {
                DllCall(pSetMode, "Int", darkMode ? 2 : 3)
            }
            if pFlush {
                DllCall(pFlush)
            }
        }
    }
}

RegisterTip(ctrl, tipText) {
    global HoverTipMap
    if IsObject(ctrl) && (tipText != "") {
        HoverTipMap[ctrl.Hwnd] := tipText
    }
}

RegisterGroupTitleTip(grpCtrl, titleWidthPx, tipText) {
    global GroupTitleTips
    if IsObject(grpCtrl) && (tipText != "") {
        GroupTitleTips.Push({ ctrl: grpCtrl, titleW: titleWidthPx, tip: tipText })
    }
}

SetStatusBannerText(text) {
    global SettingsHintCtrl, SettingsLastBannerText
    if (text = SettingsLastBannerText) {
        return
    }
    SettingsLastBannerText := text
    if IsObject(SettingsHintCtrl) {
        try {
            SettingsHintCtrl.Visible := (text != "")
            SettingsHintCtrl.Text := text
        }
    }
}

GetDefaultBannerForTab(tabIdx) {
    global SettingsTabDefaultBanner
    if SettingsTabDefaultBanner.Has(tabIdx) {
        return SettingsTabDefaultBanner[tabIdx]
    }
    return ""
}

GetTabIndexAtClientPoint(hTab, cx, cy) {
    hti := Buffer(12, 0)
    NumPut("Int", cx, hti, 0)
    NumPut("Int", cy, hti, 4)
    idx := DllCall("SendMessage", "Ptr", hTab, "UInt", 0x130D, "Ptr", 0, "Ptr", hti.Ptr, "Int")
    return (idx >= 0) ? (idx + 1) : 0
}

PollHoverTooltip() {
    global HoverTipMap, GroupTitleTips, lastHoveredKey, SettingsGui, StatsPromptGui, RefreshPromptGui, SettingsTabsCtrl, SettingsTabTipMap
    activeGuiHwnd := 0
    if IsObject(SettingsGui) {
        try activeGuiHwnd := SettingsGui.Hwnd
    }
    if (!activeGuiHwnd && IsObject(StatsPromptGui)) {
        try activeGuiHwnd := StatsPromptGui.gui.Hwnd
    }
    if (!activeGuiHwnd && IsObject(RefreshPromptGui)) {
        try activeGuiHwnd := RefreshPromptGui.Hwnd
    }
    if !activeGuiHwnd {
        if (lastHoveredKey != "") {
            lastHoveredKey := ""
            ToolTip()
        }
        SetTimer(PollHoverTooltip, 0)
        return
    }

    pt := Buffer(8, 0)
    if !DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        return
    }
    cx := NumGet(pt, 0, "Int")
    cy := NumGet(pt, 4, "Int")
    packedPt := (cx & 0xFFFFFFFF) | (cy << 32)
    hUnder := DllCall("WindowFromPoint", "Int64", packedPt, "Ptr")
    if !hUnder {
        if (lastHoveredKey != "") {
            lastHoveredKey := ""
            ToolTip()
        }
        return
    }

    hRoot := DllCall("GetAncestor", "Ptr", hUnder, "UInt", 2, "Ptr")
    if (hRoot != activeGuiHwnd && hUnder != activeGuiHwnd) {
        if (lastHoveredKey != "") {
            lastHoveredKey := ""
            ToolTip()
        }
        return
    }

    for item in GroupTitleTips {
        try {
            if !DllCall("IsWindowVisible", "Ptr", item.ctrl.Hwnd) {
                continue
            }
            rc := Buffer(16, 0)
            if DllCall("GetWindowRect", "Ptr", item.ctrl.Hwnd, "Ptr", rc.Ptr) {
                gL := NumGet(rc, 0, "Int")
                gT := NumGet(rc, 4, "Int")
                if (cx >= gL + 6 && cx <= gL + item.titleW && cy >= gT - 2 && cy <= gT + 20) {
                    key := "grp_" item.ctrl.Hwnd
                    if (key != lastHoveredKey) {
                        lastHoveredKey := key
                        ToolTip(item.tip)
                    }
                    return
                }
            }
        }
    }

    if (IsObject(SettingsGui) && IsObject(SettingsTabsCtrl) && hUnder = SettingsTabsCtrl.Hwnd) {
        tabPt := Buffer(8, 0)
        NumPut("Int", cx, tabPt, 0)
        NumPut("Int", cy, tabPt, 4)
        DllCall("ScreenToClient", "Ptr", SettingsTabsCtrl.Hwnd, "Ptr", tabPt.Ptr)
        tabNum := GetTabIndexAtClientPoint(SettingsTabsCtrl.Hwnd, NumGet(tabPt, 0, "Int"), NumGet(tabPt, 4, "Int"))
        if (tabNum >= 1 && SettingsTabTipMap.Has(tabNum)) {
            key := "tab_" tabNum
            if (key != lastHoveredKey) {
                lastHoveredKey := key
                ToolTip(SettingsTabTipMap[tabNum])
            }
            return
        }
    }

    if HoverTipMap.Has(hUnder) {
        key := "hwnd_" hUnder
        if (key != lastHoveredKey) {
            lastHoveredKey := key
            ToolTip(HoverTipMap[hUnder])
        }
    } else if (lastHoveredKey != "") {
        lastHoveredKey := ""
        ToolTip()
    }
}

; ==============================================================================
; 4. LIVE COLORED SDR/HDR TEXT BOXES, CHECKBOXES & SMOOTH ACCENT SLIDERS
; ==============================================================================
EnsureHdrSwitchEntry(swCtrl, monIdx := 1, isSupported := false, isHdrOn := false, isMasterEnabled := true) {
    global HdrSwitchMap
    if !IsObject(swCtrl) {
        return ""
    }
    if !HdrSwitchMap.Has(swCtrl.Hwnd) {
        HdrSwitchMap[swCtrl.Hwnd] := {
            ctrl: swCtrl,
            monIdx: monIdx,
            supported: !!isSupported,
            enabled: !!isHdrOn,
            masterEnabled: !!isMasterEnabled,
            statusCtrl: "",
            masterChk: ""
        }
    }
    return HdrSwitchMap[swCtrl.Hwnd]
}

; Clean segmented SDR | HDR toggle. It is a normal button that we paint ourselves (see OnSdrHdrSwitchDraw),
; so every existing Click handler keeps working.
CreateSdrHdrSwitch(guiObj, x, y, w, h, monIdx, isSupported, isHdrOn, isMasterEnabled) {
    ctrl := guiObj.AddButton("x" x " y" y " w" w " h" h, "")
    EnsureHdrSwitchEntry(ctrl, monIdx, isSupported, isHdrOn, isMasterEnabled)
    ctrl.OnNotify(-12, OnSdrHdrSwitchDraw)
    return ctrl
}

BindSdrHdrStatusCtrl(swCtrl, statusCtrl) {
    entry := EnsureHdrSwitchEntry(swCtrl)
    if IsObject(entry) {
        entry.statusCtrl := statusCtrl
    }
}

UpdateSdrHdrSwitchVisual(swCtrl, isSupported, isHdrOn, isMasterEnabled) {
    entry := EnsureHdrSwitchEntry(swCtrl)
    if !IsObject(entry) {
        return
    }
    changed := (entry.supported != !!isSupported || entry.enabled != !!isHdrOn || entry.masterEnabled != !!isMasterEnabled)
    entry.supported := !!isSupported
    entry.enabled := !!isHdrOn
    entry.masterEnabled := !!isMasterEnabled
    if (IsObject(entry.statusCtrl) && entry.supported) {
        newStatus := "Monitor " entry.monIdx " output is " (entry.enabled ? "HDR" : "SDR")
        if (entry.statusCtrl.Text != newStatus) {
            entry.statusCtrl.Text := newStatus
        }
    }
    if changed {
        swCtrl.Redraw()
    }
}

SyncLiveHdrIndicators(*) {
    global HdrSwitchMap, SettingsGui, Active_HDR_Mode, cachedHdrState, lastHdrCheckTick
    if !IsObject(SettingsGui) || HdrSwitchMap.Count = 0 {
        return
    }
    InvalidateDisplayTopoCache()
    priIdx := MonitorGetPrimary()
    for hwnd, info in HdrSwitchMap {
        mInfo := GetMonitorHdrInfo(info.monIdx)
        masterEn := true
        if IsObject(info.masterChk) {
            masterEn := !!info.masterChk.Value
        }
        UpdateSdrHdrSwitchVisual(info.ctrl, mInfo.supported, mInfo.enabled, masterEn)
        if (info.monIdx = priIdx) {
            cachedHdrState := mInfo.enabled
            Active_HDR_Mode := mInfo.enabled
            lastHdrCheckTick := A_TickCount
        }
    }
}

; ---- Live Status box (Monitor tabs) -------------------------------------------
; Settings is the active window while it is open, so the foreground app is always "OLED Engine". In that
; case the first normal window behind it is used, which is the app the engine would see if Settings were closed.
GetLiveStatusSnapshot() {
    ownPid := DllCall("GetCurrentProcessId", "UInt")
    snap := GetForegroundWindowSnapshot()
    if (snap.pid != ownPid) {
        return snap
    }
    hwnd := DllCall("GetTopWindow", "Ptr", 0, "Ptr")
    Loop 300 {
        if !hwnd {
            break
        }
        try {
            if (DllCall("IsWindowVisible", "Ptr", hwnd) && !DllCall("IsIconic", "Ptr", hwnd)) {
                pid    := WinGetPID("ahk_id " hwnd)
                title  := WinGetTitle("ahk_id " hwnd)
                cls    := WinGetClass("ahk_id " hwnd)
                exStyle := WinGetExStyle("ahk_id " hwnd)
                cloaked := 0
                DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "UInt*", &cloaked, "UInt", 4)
                if (pid != ownPid && title != "" && !cloaked && !(exStyle & 0x80)
                    && cls != "Progman" && cls != "WorkerW" && cls != "Shell_TrayWnd" && cls != "Shell_SecondaryTrayWnd") {
                    return { hwnd: hwnd, class: cls, exe: WinGetProcessName("ahk_id " hwnd), pid: pid, title: title, valid: true }
                }
            }
        }
        hwnd := DllCall("GetWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
    }
    return { hwnd: 0, class: "", exe: "", pid: 0, title: "", valid: false }
}

; Returns [line 1, line 2] for one monitor: what is detected + the delay in effect, and the current state.
GetLiveStatusLines(monIdx, isPrimary) {
    global Primary_Auto_Enabled, isAutomationPaused, isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed, Debug_Log_Enabled
    global manualExtraMonSet, isManualExtraDimOn, extraMonDimmedSet, lastPrimaryActiveTick, lastExtraActiveTick, extraMonLastActiveTick

    ; Each monitor reports ITS OWN top window (never Monitor 1's / the foreground app's)
    info := GetMonitorContextInfo(monIdx)
    ctx  := info.ctx
    snap := info.snap
    movieMons := Map()
    try movieMons := GetMoviePlayingMonitorsCached()

    if isPrimary {
        autoOn := !!Primary_Auto_Enabled
        alpha  := GetActivePrimaryDimAlpha()
    } else {
        autoOn := !!GetExtraMonSetting(monIdx, "Auto")
        alpha  := GetEffectiveExtraMonAlpha(monIdx)
    }
    if (movieMons.Has(monIdx) && ctx != "movie_paused") {
        ctx := "movie_playing"
    }
    sec := isPrimary ? GetPrimaryTimeoutSeconds(ctx) : GetEffectiveExtraMonTimeoutSec(monIdx, ctx)

    if !autoOn {
        delayTxt := "never (Auto dim is off)"
    } else if (alpha <= 0) {
        delayTxt := "never (Dim Level is 0%)"
    } else if (ctx = "movie_playing") {
        delayTxt := "never while a video plays"
    } else if (sec <= 0) {
        delayTxt := "never (delay is set to 0)"
    } else {
        delayTxt := sec " s without activity"
    }

    appTxt := ""
    if (info.carried = -1) {
        appTxt := " (game running)"
    } else if (info.carried > 0) {
        appTxt := " (game on Monitor " info.carried ")"
    } else if (ctx != "desktop" && IsObject(snap) && snap.exe != "") {
        appTxt := " (" snap.exe ")"
    }
    line1 := "Now: " FriendlyCtx(ctx) appTxt "    |    Dims after: " delayTxt

    if isAutomationPaused {
        state := "Automation is paused"
    } else if IsExcludedProcessRunning() {
        state := "Paused - a Never Dim app is running"
    } else if isPrimary {
        state := isManualBlackoutOn ? "Blackout (manual)" : (isManualPrimaryDimOn ? "Dimmed (manual)" : (isAutoPrimaryDimmed ? "Dimmed (idle)" : "Active"))
    } else {
        state := (isManualExtraDimOn || manualExtraMonSet.Has(monIdx)) ? "Dimmed (manual)" : (extraMonDimmedSet.Has(monIdx) ? "Dimmed (idle)" : "Active")
    }
    ; Live countdown (only computed while Settings is open: this function is only called by the Live Status boxes)
    if (state = "Active" && autoOn && alpha > 0 && ctx != "movie_playing" && sec > 0) {
        lastTick := isPrimary ? lastPrimaryActiveTick : (extraMonLastActiveTick.Has(monIdx) ? extraMonLastActiveTick[monIdx] : lastExtraActiveTick)
        remaining := Max(0, Ceil(sec - (A_TickCount - lastTick) / 1000))
        state := "Active    |    Dims in " remaining " s"
    }
    if (Debug_Log_Enabled && info.why != "") {
        state .= "    |    seen: " info.why
    }
    return [line1, "State: " state]
}

AddLiveStatusBox(g, darkMode, monIdx, isPrimary, tabIdx) {
    global SettingsLayout, LiveStatusRefs
    lay := SettingsLayout
    box := AddSectionBox(g, lay.bx, 538, lay.bw, 78, "Live Status", darkMode)
    RegisterGroupTitleTip(box, 110, "What OLED Engine is doing for this monitor right now, refreshed every second.`n`n"
        . "Now: the activity it detects (Desktop, Video playing / paused, Game, Competitive game). While Settings is open it looks at the app behind this window.`n"
        . "Dims after: the idle delay that applies to that activity.`n"
        . "State: Active (with a live countdown to the next dim), Dimmed (idle or manual), Blackout, or why dimming is paused.")
    t1 := g.AddText("x" lay.ix " y562 w" lay.iw " +0x100", "")
    t2 := g.AddText("x" lay.ix " y586 w" lay.iw " +0x100", "")
    StyleControlTheme(t1, darkMode)
    StyleControlTheme(t2, darkMode)
    LiveStatusRefs.Push({ t1: t1, t2: t2, mon: monIdx, primary: isPrimary, tab: tabIdx })
    try {
        lines := GetLiveStatusLines(monIdx, isPrimary)
        t1.Text := lines[1]
        t2.Text := lines[2]
    }
}

SyncLiveStatusBoxes(*) {
    global SettingsGui, SettingsTabsCtrl, LiveStatusRefs
    if (!IsObject(SettingsGui) || LiveStatusRefs.Length = 0) {
        SetTimer(SyncLiveStatusBoxes, 0)
        return
    }
    ; Settings minimized or hidden: nothing is visible, so skip all work
    try {
        if (WinGetMinMax("ahk_id " SettingsGui.Hwnd) = -1 || !DllCall("IsWindowVisible", "Ptr", SettingsGui.Hwnd, "Int")) {
            return
        }
    }
    curTab := 0
    try curTab := SettingsTabsCtrl.Value
    for ref in LiveStatusRefs {
        if (ref.tab != curTab) {
            continue
        }
        try {
            lines := GetLiveStatusLines(ref.mon, ref.primary)
            if (ref.t1.Text != lines[1]) {
                ref.t1.Text := lines[1]
            }
            if (ref.t2.Text != lines[2]) {
                ref.t2.Text := lines[2]
            }
        }
    }
}

; ---- GDI+ helpers (anti-aliased toggle drawing) ------------------------------
GdipStart() {
    static token := 0
    if !token {
        si := Buffer(A_PtrSize = 8 ? 24 : 16, 0)
        NumPut("UInt", 1, si, 0)
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", si, "Ptr", 0)
    }
    return token
}

GdipFillPill(gfx, x, y, w, h, argb) {
    br := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
    DllCall("gdiplus\GdipFillEllipseI", "Ptr", gfx, "Ptr", br, "Int", x, "Int", y, "Int", h, "Int", h)
    DllCall("gdiplus\GdipFillEllipseI", "Ptr", gfx, "Ptr", br, "Int", x + w - h, "Int", y, "Int", h, "Int", h)
    DllCall("gdiplus\GdipFillRectangleI", "Ptr", gfx, "Ptr", br, "Int", x + h // 2, "Int", y, "Int", w - h, "Int", h)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

GdipFillCircle(gfx, x, y, d, argb) {
    br := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", argb, "Ptr*", &br)
    DllCall("gdiplus\GdipFillEllipseI", "Ptr", gfx, "Ptr", br, "Int", x, "Int", y, "Int", d, "Int", d)
    DllCall("gdiplus\GdipDeleteBrush", "Ptr", br)
}

BgrToArgb(bgr, alpha := 0xFF) {
    return (alpha << 24) | ((bgr & 0xFF) << 16) | (bgr & 0xFF00) | ((bgr >> 16) & 0xFF)
}

; Paints the NM_CUSTOMDRAW checkbox as a modern on/off switch followed by its label.
OnCheckboxCustomDraw(chkCtrl, lParam) {
    global UI_Dark_Mode
    static nmh := (A_PtrSize = 8) ? 24 : 12
    stage := NumGet(lParam + nmh, 0, "UInt")
    if (stage != 0x00000001) {
        return 0
    }
    hdcOff := nmh + A_PtrSize
    rcOff  := hdcOff + A_PtrSize
    hdc    := NumGet(lParam, hdcOff, "Ptr")
    l := NumGet(lParam, rcOff, "Int")
    t := NumGet(lParam, rcOff + 4, "Int")
    r := NumGet(lParam, rcOff + 8, "Int")
    b := NumGet(lParam, rcOff + 12, "Int")
    state := NumGet(lParam, rcOff + 16 + A_PtrSize, "UInt")

    enabled := DllCall("IsWindowEnabled", "Ptr", chkCtrl.Hwnd, "Int")
    checked := DllCall("SendMessage", "Ptr", chkCtrl.Hwnd, "UInt", 0x00F0, "Ptr", 0, "Ptr", 0, "Ptr") = 1

    ; background (same colour the page uses)
    bgBrush := DllCall("CreateSolidBrush", "UInt", RgbToBgr(ThemeBgRgb), "Ptr")
    DllCall("FillRect", "Ptr", hdc, "Ptr", lParam + rcOff, "Ptr", bgBrush)
    DllCall("DeleteObject", "Ptr", bgBrush)

    ; switch geometry
    tw := 32, th := 18
    tx := l + 1
    ty := ((t + b) // 2) - (th // 2)

    accent := BgrToArgb(GetWindowsAccentColorBGR())
    if enabled {
        trackCol := checked ? accent : (UI_Dark_Mode ? 0xFF4A4A52 : 0xFFC4C7CE)
        knobCol  := 0xFFFFFFFF
    } else {
        trackCol := checked ? BgrToArgb(GetWindowsAccentColorBGR(), 0x55) : (UI_Dark_Mode ? 0xFF2F2F34 : 0xFFE2E4E8)
        knobCol  := UI_Dark_Mode ? 0xFF6B6B74 : 0xFFF4F4F6
    }

    GdipStart()
    gfx := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &gfx)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", gfx, "Int", 4)
    if (state & 0x0010) && enabled {
        GdipFillPill(gfx, tx - 2, ty - 2, tw + 4, th + 4, BgrToArgb(GetWindowsAccentColorBGR(), 0x55))
    }
    GdipFillPill(gfx, tx, ty, tw, th, trackCol)
    knobD := th - 6
    knobX := checked ? (tx + tw - knobD - 3) : (tx + 3)
    GdipFillCircle(gfx, knobX, ty + 3, knobD, knobCol)
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", gfx)

    ; label
    hFont := DllCall("SendMessage", "Ptr", chkCtrl.Hwnd, "UInt", 0x0031, "Ptr", 0, "Ptr", 0, "Ptr")
    oldFont := hFont ? DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr") : 0
    txtCol := enabled ? (UI_Dark_Mode ? 0xFFFFFF : 0x000000) : (UI_Dark_Mode ? 0x776E6E : 0xA69E9A)
    DllCall("SetTextColor", "Ptr", hdc, "UInt", txtCol)
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
    textRc := Buffer(16, 0)
    NumPut("Int", l + tw + 10, "Int", t, "Int", r, "Int", b, textRc)
    DllCall("DrawTextW", "Ptr", hdc, "Str", chkCtrl.Text, "Int", -1, "Ptr", textRc.Ptr, "UInt", 0x8024)   ; LEFT|VCENTER|SINGLELINE|END_ELLIPSIS
    if oldFont {
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
    }
    return 0x00000004   ; CDRF_SKIPDEFAULT
}

; Paints the SDR | HDR button as a two-segment pill: the active side is highlighted.
OnSdrHdrSwitchDraw(swCtrl, lParam) {
    global UI_Dark_Mode, HdrSwitchMap
    static nmh := (A_PtrSize = 8) ? 24 : 12
    stage := NumGet(lParam + nmh, 0, "UInt")
    if (stage != 0x00000001) {
        return 0
    }
    hdcOff := nmh + A_PtrSize
    rcOff  := hdcOff + A_PtrSize
    hdc    := NumGet(lParam, hdcOff, "Ptr")
    l := NumGet(lParam, rcOff, "Int")
    t := NumGet(lParam, rcOff + 4, "Int")
    r := NumGet(lParam, rcOff + 8, "Int")
    b := NumGet(lParam, rcOff + 12, "Int")

    info := HdrSwitchMap.Has(swCtrl.Hwnd) ? HdrSwitchMap[swCtrl.Hwnd] : ""
    supported := IsObject(info) ? info.supported : false
    isHdr     := IsObject(info) ? (info.supported && info.enabled) : false
    active    := IsObject(info) ? (info.supported && info.masterEnabled) : false
    clickable := DllCall("IsWindowEnabled", "Ptr", swCtrl.Hwnd, "Int") && active

    bgBrush := DllCall("CreateSolidBrush", "UInt", RgbToBgr(ThemeBgRgb), "Ptr")
    DllCall("FillRect", "Ptr", hdc, "Ptr", lParam + rcOff, "Ptr", bgBrush)
    DllCall("DeleteObject", "Ptr", bgBrush)

    w := r - l
    h := b - t
    half := w // 2
    GdipStart()
    gfx := 0
    DllCall("gdiplus\GdipCreateFromHDC", "Ptr", hdc, "Ptr*", &gfx)
    DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", gfx, "Int", 4)
    GdipFillPill(gfx, l, t, w, h, UI_Dark_Mode ? 0xFF303036 : 0xFFE3E6EB)
    if clickable {
        segCol := isHdr ? (UI_Dark_Mode ? 0xFF3E9A62 : 0xFF2F8F57) : (UI_Dark_Mode ? 0xFF3F7FD9 : 0xFF2F6FE0)
        segX := isHdr ? (l + half) : (l + 2)
        GdipFillPill(gfx, segX, t + 2, half - 2, h - 4, segCol)
    } else if supported {
        segX := isHdr ? (l + half) : (l + 2)
        GdipFillPill(gfx, segX, t + 2, half - 2, h - 4, UI_Dark_Mode ? 0xFF4A4A52 : 0xFFC9CDD4)
    }
    DllCall("gdiplus\GdipDeleteGraphics", "Ptr", gfx)

    hFont := DllCall("SendMessage", "Ptr", swCtrl.Hwnd, "UInt", 0x0031, "Ptr", 0, "Ptr", 0, "Ptr")
    oldFont := hFont ? DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr") : 0
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
    mutedCol := UI_Dark_Mode ? 0x9A9A9A : 0x6B6B6B
    for idx, label in ["SDR", "HDR"] {
        segActive := supported && ((idx = 2) = isHdr)
        DllCall("SetTextColor", "Ptr", hdc, "UInt", (segActive && clickable) ? 0xFFFFFF : mutedCol)
        rc := Buffer(16, 0)
        NumPut("Int", l + (idx - 1) * half, "Int", t, "Int", l + idx * half, "Int", b, rc)
        DllCall("DrawTextW", "Ptr", hdc, "Str", label, "Int", -1, "Ptr", rc.Ptr, "UInt", 0x25)   ; CENTER|VCENTER|SINGLELINE
    }
    if oldFont {
        DllCall("SelectObject", "Ptr", hdc, "Ptr", oldFont)
    }
    return 0x00000004
}

OnSliderCustomDraw(sldCtrl, lParam) {
    global UI_Dark_Mode
    nmhdrSize := (A_PtrSize = 8) ? 24 : 12
    drawStage := NumGet(lParam + nmhdrSize, 0, "UInt")

    if (drawStage = 0x00000001) {
        return 0x00000020
    }
    if (drawStage = 0x00010001) {
        hdc      := NumGet(lParam + nmhdrSize + 8, 0, "Ptr")
        rcPtr    := lParam + nmhdrSize + 8 + A_PtrSize
        left     := NumGet(rcPtr, 0, "Int")
        top      := NumGet(rcPtr, 4, "Int")
        right    := NumGet(rcPtr, 8, "Int")
        bottom   := NumGet(rcPtr, 12, "Int")
        itemSpec := NumGet(lParam + nmhdrSize + 8 + A_PtrSize + 16, 0, "UPtr")

        isEnabled := DllCall("IsWindowEnabled", "Ptr", sldCtrl.Hwnd, "Int")
        accentCol := isEnabled ? GetWindowsAccentColorBGR() : (UI_Dark_Mode ? 0x52525B : 0xB4B8C0)

        if (itemSpec = 3) {
            cliRc := Buffer(16, 0)
            DllCall("GetClientRect", "Ptr", sldCtrl.Hwnd, "Ptr", cliRc.Ptr)
            bgBrush := DllCall("CreateSolidBrush", "UInt", RgbToBgr(ThemeBgRgb), "Ptr")
            DllCall("FillRect", "Ptr", hdc, "Ptr", cliRc.Ptr, "Ptr", bgBrush)
            DllCall("DeleteObject", "Ptr", bgBrush)

            chRc := Buffer(16, 0)
            DllCall("SendMessage", "Ptr", sldCtrl.Hwnd, "UInt", 0x041A, "Ptr", 0, "Ptr", chRc.Ptr)
            cL := NumGet(chRc, 0, "Int")
            cR := NumGet(chRc, 8, "Int")
            midY := (top + bottom) // 2

            thRc := Buffer(16, 0)
            DllCall("SendMessage", "Ptr", sldCtrl.Hwnd, "UInt", 0x0419, "Ptr", 0, "Ptr", thRc.Ptr)
            tMidX := (NumGet(thRc, 0, "Int") + NumGet(thRc, 8, "Int")) // 2
            tMidX := Max(cL, Min(cR, tMidX))

            trackBg := UI_Dark_Mode ? 0x3F3F46 : 0xD4D4D8
            DrawRoundedFillRect(hdc, cL, midY - 2, cR, midY + 2, 4, trackBg)
            if (tMidX > cL) {
                DrawRoundedFillRect(hdc, cL, midY - 2, tMidX, midY + 2, 4, accentCol)
            }
            return 0x00000004
        }
        if (itemSpec = 2) {
            cx := (left + right) // 2
            cy := (top + bottom) // 2
            outerBg := UI_Dark_Mode ? 0x2B2B30 : 0xFFFFFF
            outerBd := UI_Dark_Mode ? 0x52525B : 0xC4C7CE
            DrawRoundedRectWithBorder(hdc, cx - 7, cy - 7, cx + 7, cy + 7, 14, outerBg, outerBd)
            DrawRoundedFillRect(hdc, cx - 4, cy - 4, cx + 4, cy + 4, 8, accentCol)
            return 0x00000004
        }
    }
    return 0
}

DrawRoundedFillRect(hdc, l, t, r, b, radius, fillCol) {
    hPen   := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", fillCol, "Ptr")
    hBrush := DllCall("CreateSolidBrush", "UInt", fillCol, "Ptr")
    oldP   := DllCall("SelectObject", "Ptr", hdc, "Ptr", hPen, "Ptr")
    oldB   := DllCall("SelectObject", "Ptr", hdc, "Ptr", hBrush, "Ptr")
    DllCall("RoundRect", "Ptr", hdc, "Int", l, "Int", t, "Int", r, "Int", b, "Int", radius, "Int", radius)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldP)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldB)
    DllCall("DeleteObject", "Ptr", hPen)
    DllCall("DeleteObject", "Ptr", hBrush)
}

DrawRoundedRectWithBorder(hdc, l, t, r, b, radius, fillCol, borderCol) {
    hPen   := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", borderCol, "Ptr")
    hBrush := DllCall("CreateSolidBrush", "UInt", fillCol, "Ptr")
    oldP   := DllCall("SelectObject", "Ptr", hdc, "Ptr", hPen, "Ptr")
    oldB   := DllCall("SelectObject", "Ptr", hdc, "Ptr", hBrush, "Ptr")
    DllCall("RoundRect", "Ptr", hdc, "Int", l, "Int", t, "Int", r, "Int", b, "Int", radius, "Int", radius)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldP)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldB)
    DllCall("DeleteObject", "Ptr", hPen)
    DllCall("DeleteObject", "Ptr", hBrush)
}

OnTabDrawItem(wParam, lParam, msg, hwnd) {
    global SettingsTabsCtrl, SectionBoxTitles, UI_Dark_Mode, UI_Custom_Color, ThemeBgRgb, ThemeSurfaceRgb
    ctype := NumGet(lParam, 0, "UInt")               ; 101 = tab item, 5 = static
    if (ctype != 101 && ctype != 5) {
        return
    }
    o := (A_PtrSize = 8) ? 24 : 20
    hwndItem := NumGet(lParam, o, "Ptr")
    hdc := NumGet(lParam, o + A_PtrSize, "Ptr")
    rc  := lParam + o + 2 * A_PtrSize
    l := NumGet(rc, 0, "Int"), t := NumGet(rc, 4, "Int"), r := NumGet(rc, 8, "Int"), b := NumGet(rc, 12, "Int")

    ; ---------- rounded section box ----------
    if (ctype = 5) {
        if !SectionBoxTitles.Has(hwndItem) {
            return
        }
        title := StrReplace(SectionBoxTitles[hwndItem], "&&", "&")
        hFont := SendMessage(0x31, 0, 0, hwndItem)
        oldF := hFont ? DllCall("SelectObject", "Ptr", hdc, "Ptr", hFont, "Ptr") : 0
        trc := Buffer(16, 0)
        DllCall("DrawTextW", "Ptr", hdc, "Str", title, "Int", -1, "Ptr", trc.Ptr, "UInt", 0x800 | 0x400 | 0x20)
        tw := NumGet(trc, 8, "Int"), th := NumGet(trc, 12, "Int")
        borderCol := MixRgb(ThemeBgRgb, UI_Dark_Mode ? 0xFFFFFF : 0x000000, 0.22)
        saved := DllCall("SaveDC", "Ptr", hdc)
        DllCall("ExcludeClipRect", "Ptr", hdc, "Int", l + 10, "Int", t, "Int", l + 18 + tw, "Int", t + th + 2)
        hPen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", RgbToBgr(borderCol), "Ptr")
        DllCall("SelectObject", "Ptr", hdc, "Ptr", hPen)
        DllCall("SelectObject", "Ptr", hdc, "Ptr", DllCall("GetStockObject", "Int", 5, "Ptr"))   ; NULL_BRUSH
        DllCall("RoundRect", "Ptr", hdc, "Int", l, "Int", t + th // 2, "Int", r - 1, "Int", b - 1, "Int", 12, "Int", 12)
        DllCall("RestoreDC", "Ptr", hdc, "Int", saved)
        DllCall("DeleteObject", "Ptr", hPen)
        DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
        DllCall("SetTextColor", "Ptr", hdc, "UInt", UI_Dark_Mode ? 0xFFFFFF : 0x000000)
        NumPut("Int", l + 14, trc, 0), NumPut("Int", t, trc, 4), NumPut("Int", r, trc, 8), NumPut("Int", t + th, trc, 12)
        DllCall("DrawTextW", "Ptr", hdc, "Str", title, "Int", -1, "Ptr", trc.Ptr, "UInt", 0x800 | 0x20)
        if oldF {
            DllCall("SelectObject", "Ptr", hdc, "Ptr", oldF)
        }
        return 1
    }

    ; ---------- rounded pill tab ----------
    if !IsObject(SettingsTabsCtrl) {
        return
    }
    try {
        if (hwndItem != SettingsTabsCtrl.Hwnd) {
            return
        }
    } catch {
        return
    }
    itemId := NumGet(lParam, 8, "UInt")
    state  := NumGet(lParam, 16, "UInt")

    tciOff := (A_PtrSize = 8) ? 16 : 12
    tci := Buffer((A_PtrSize = 8) ? 40 : 28, 0)
    txt := Buffer(512, 0)
    NumPut("UInt", 1, tci, 0)
    NumPut("Ptr", txt.Ptr, tci, tciOff)
    NumPut("Int", 256, tci, tciOff + A_PtrSize)
    SendMessage(0x133C, itemId, tci.Ptr, hwndItem)
    label := StrGet(txt, "UTF-16")

    selected := (state & 1)
    bg := DllCall("CreateSolidBrush", "UInt", RgbToBgr(ThemeBgRgb), "Ptr")
    fillRc := Buffer(16, 0)
    NumPut("Int", l - 2, fillRc, 0), NumPut("Int", t - 2, fillRc, 4), NumPut("Int", r + 2, fillRc, 8), NumPut("Int", b + 2, fillRc, 12)
    DllCall("FillRect", "Ptr", hdc, "Ptr", fillRc.Ptr, "Ptr", bg)
    DllCall("DeleteObject", "Ptr", bg)

    if selected {
        if (UI_Custom_Color != "") {
            shadeTarget := UI_Dark_Mode ? 0xFFFFFF : 0x000000
            fillCol     := MixRgb(ThemeBgRgb, shadeTarget, UI_Dark_Mode ? 0.28 : 0.24)
            borderCol   := MixRgb(ThemeBgRgb, shadeTarget, UI_Dark_Mode ? 0.48 : 0.42)
        } else {
            accentRgb := RgbToBgr(GetWindowsAccentColorBGR())
            fillCol   := MixRgb(ThemeSurfaceRgb, accentRgb, UI_Dark_Mode ? 0.65 : 0.80)
            borderCol := MixRgb(ThemeSurfaceRgb, accentRgb, 0.92)
        }
    } else {
        fillCol   := ThemeSurfaceRgb
        borderCol := MixRgb(ThemeBgRgb, UI_Dark_Mode ? 0xFFFFFF : 0x000000, 0.16)
    }
    DrawRoundedRectWithBorder(hdc, l + 2, t + 2, r - 2, b - 1, 14, RgbToBgr(fillCol), RgbToBgr(borderCol))

    ; smaller font so long names fit
    hFont := SendMessage(0x31, 0, 0, hwndItem)
    small := 0
    if hFont {
        lf := Buffer(92, 0)
        if DllCall("GetObject", "Ptr", hFont, "Int", 92, "Ptr", lf.Ptr) {
            NumPut("Int", Round(NumGet(lf, 0, "Int") * 0.84), lf, 0)
            small := DllCall("CreateFontIndirectW", "Ptr", lf.Ptr, "Ptr")
        }
    }
    oldF := DllCall("SelectObject", "Ptr", hdc, "Ptr", small ? small : hFont, "Ptr")
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)

    if selected {
        fillLum := (((fillCol >> 16) & 0xFF) * 299 + ((fillCol >> 8) & 0xFF) * 587 + (fillCol & 0xFF) * 114) / 1000
        tabTxtCol := (fillLum < 145) ? 0xFFFFFF : 0x111111
    } else {
        tabTxtCol := UI_Dark_Mode ? 0xD8D8D8 : 0x202020
    }
    DllCall("SetTextColor", "Ptr", hdc, "UInt", RgbToBgr(tabTxtCol))

    txtRc := Buffer(16, 0)
    NumPut("Int", l + 2, txtRc, 0), NumPut("Int", t, txtRc, 4), NumPut("Int", r - 2, txtRc, 8), NumPut("Int", b, txtRc, 12)
    DllCall("DrawTextW", "Ptr", hdc, "Str", label, "Int", -1, "Ptr", txtRc.Ptr, "UInt", 0x8825)
    DllCall("SelectObject", "Ptr", hdc, "Ptr", oldF)
    if small {
        DllCall("DeleteObject", "Ptr", small)
    }
    return 1
}

OnLvCustomDraw(lvCtrl, lParam) {
    global trayDraftRef, UI_Dark_Mode
    nmhdrSize := (A_PtrSize = 8) ? 24 : 12
    drawStage := NumGet(lParam + nmhdrSize, 0, "UInt")

    if (drawStage = 0x00000001) {
        return 0x00000020
    }
    if (drawStage = 0x00010001) {
        rowIdx := NumGet(lParam + nmhdrSize + 8 + A_PtrSize, 0, "UPtr") + 1
        if (rowIdx >= 1 && rowIdx <= trayDraftRef.Length) {
            isEnabled := trayDraftRef[rowIdx].enabled
            if !isEnabled {
                NumPut("UInt", UI_Dark_Mode ? 0x7A7A80 : 0x8C8C94, lParam + nmhdrSize + 8 + (A_PtrSize * 3), 0)
            } else {
                NumPut("UInt", UI_Dark_Mode ? 0xFFFFFF : 0x000000, lParam + nmhdrSize + 8 + (A_PtrSize * 3), 0)
            }
        }
        return 0x00000002
    }
    return 0
}

OnCtlColor(wParam, lParam, msg, hwnd) {
    global UI_Dark_Mode, SettingsGui, StatsPromptGui, RefreshPromptGui, HdrSwitchMap, CareUiRefs
    global themeBgBrush, themeSurfaceBrush

    isOurWindow := false
    if (IsObject(SettingsGui) && hwnd = SettingsGui.Hwnd) {
        isOurWindow := true
    } else if (IsObject(StatsPromptGui) && hwnd = StatsPromptGui.gui.Hwnd) {
        isOurWindow := true
    } else if (IsObject(RefreshPromptGui) && hwnd = RefreshPromptGui.Hwnd) {
        isOurWindow := true
    }
    if !isOurWindow {
        return
    }

    hdc := wParam

    isRedAlertText := false
    if lParam {
        if (CareUiRefs.Has("secBang") && IsObject(CareUiRefs["secBang"]) && lParam = CareUiRefs["secBang"].Hwnd) {
            isRedAlertText := true
        } else if (CareUiRefs.Has("btnBang") && IsObject(CareUiRefs["btnBang"]) && lParam = CareUiRefs["btnBang"].Hwnd) {
            isRedAlertText := true
        }
    }

    isCtrlEnabled := lParam ? DllCall("IsWindowEnabled", "Ptr", lParam, "Int") : true

    textColor := isRedAlertText ? 0x303BFF : (isCtrlEnabled ? (UI_Dark_Mode ? 0xFFFFFF : 0x000000) : (UI_Dark_Mode ? 0x776E6E : 0xA69E9A))
    DllCall("SetTextColor", "Ptr", hdc, "UInt", textColor)
    if (msg = 0x0133 || msg = 0x0134) {
        DllCall("SetBkColor", "Ptr", hdc, "UInt", RgbToBgr(ThemeSurfaceRgb))
        DllCall("SetBkMode", "Ptr", hdc, "Int", 2)
        return themeSurfaceBrush
    }
    DllCall("SetBkColor", "Ptr", hdc, "UInt", RgbToBgr(ThemeBgRgb))
    DllCall("SetBkMode", "Ptr", hdc, "Int", 1)
    return themeBgBrush
}

; Fades a window in with the same smooth ease Windows uses for its own pop-ups
ShowWithFade(guiObj, opts := "", ms := 160) {
    hwnd := guiObj.Hwnd
    WinSetTransparent(0, hwnd)
    guiObj.Show(opts)
    ; A window shown at alpha 0 never gets its child controls painted -> blank until hovered. Force a full paint now.
    DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0585)
    start := A_TickCount
    Loop {
        p := Min(1.0, (A_TickCount - start) / ms)
        WinSetTransparent(Round(255 * p * p * (3 - 2 * p)), hwnd)
        if (p >= 1.0) {
            break
        }
        Sleep(8)
    }
    WinSetTransparent("Off", hwnd)
    ; Repaint everything once the fade is done, and again shortly after for controls that finish late
    DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0585)
    SetTimer(() => (WinExist(hwnd) ? DllCall("RedrawWindow", "Ptr", hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0585) : 0), -120)
}

ApplyGuiTheme(guiObj, darkMode) {
    global ThemeBgRgb
    ApplyWindowMonitorIcon(guiObj.Hwnd)
    guiObj.BackColor := Format("{:06X}", ThemeBgRgb)
    guiObj.SetFont("s9.5 " (darkMode ? "cFFFFFF" : "c000000"), "Segoe UI")
    try DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", guiObj.Hwnd, "UInt", 20, "Int*", darkMode ? 1 : 0, "UInt", 4)
}

StyleControlTheme(ctrl, darkMode, muted := false) {
    try {
        modeStr := darkMode ? "DarkMode_Explorer" : "Explorer"
        if (ctrl.Type = "CheckBox") {
            DllCall("uxtheme\SetWindowTheme", "Ptr", ctrl.Hwnd, "Str", modeStr, "Ptr", 0)
            ctrl.OnNotify(-12, OnCheckboxCustomDraw)
        } else if (ctrl.Type = "Slider") {
            DllCall("uxtheme\SetWindowTheme", "Ptr", ctrl.Hwnd, "Str", modeStr, "Ptr", 0)
            ctrl.OnNotify(-12, OnSliderCustomDraw)
        } else if (ctrl.Type = "Button") {
            DllCall("uxtheme\SetWindowTheme", "Ptr", ctrl.Hwnd, "Str", "Explorer", "Ptr", 0)
        } else if (ctrl.Type = "Edit" || ctrl.Type = "ListBox" || ctrl.Type = "ComboBox" || ctrl.Type = "DDL" || ctrl.Type = "Tab3" || ctrl.Type = "Hotkey") {
            DllCall("uxtheme\SetWindowTheme", "Ptr", ctrl.Hwnd, "Str", modeStr, "Ptr", 0)
        } else if (ctrl.Type = "ListView") {
            DllCall("uxtheme\SetWindowTheme", "Ptr", ctrl.Hwnd, "Str", "", "Str", "")
            ctrl.Opt((darkMode ? "cFFFFFF" : "c000000") " Background" Format("{:06X}", ThemeSurfaceRgb))
            return
        }
        colorHex := darkMode ? (muted ? "cD4D4D8" : "cFFFFFF") : (muted ? "c3F3F46" : "c000000")
        ctrl.SetFont("s9.5 " colorHex, "Segoe UI")
    }
}

AddSectionBox(guiObj, x, y, w, h, titleText, darkMode) {
        grp := guiObj.AddGroupBox("x" x " y" y " w" w " h" h, titleText)
    grp.SetFont("s9.5 bold " (darkMode ? "cFFFFFF" : "c000000"), "Segoe UI")
    try {
        if darkMode {
            DllCall("uxtheme\SetWindowTheme", "Ptr", grp.Hwnd, "Str", "", "Str", "")
        } else {
            DllCall("uxtheme\SetWindowTheme", "Ptr", grp.Hwnd, "Str", "Explorer", "Ptr", 0)
        }
    }
    return grp
}

; ==============================================================================
; SOUNDS: gentle synthesized tones (built in memory, no files needed) + Windows' own sounds
; ==============================================================================

GetSoundVolumePercent(step := "") {
    global Sound_Volume_Step
    if (step = "") {
        step := Sound_Volume_Step
    }
    step := Max(0, Min(3, Integer(step)))
    ; 4 discrete click steps (0..3): 0 = mute, 1 = quiet (15%), 2 = medium (45%), 3 = full (100%)
    static levels := [0, 15, 45, 100]
    return levels[step + 1]
}

GetSoundGainFactor(step := "") {
    return GetSoundVolumePercent(step) / 100.0
}

GetSoundChoices() {
    return ["None", "Soft Chime", "Gentle Bell", "Glass Drop", "Calm Rise", "Calm Fall", "Windows Default", "Windows Notify", "Windows Ding"]
}

NormalizeSoundName(name) {
    static legacy := Map("Chime", "Soft Chime", "Ding", "Gentle Bell", "Alert", "Windows Default", "Chord", "Calm Rise")
    if legacy.Has(name) {
        return legacy[name]
    }
    for choice in GetSoundChoices() {
        if (choice = name) {
            return name
        }
    }
    return "None"
}

; Builds a soft, bell-like tone sequence as an in-memory WAV: sine + quiet overtone, fast attack, smooth decay.
; notes = [[frequencyHz, startSec, lengthSec], ...]
BuildSoftTones(notes, volume := 0.30) {
    rate := 22050
    total := 0.0
    for n in notes {
        total := Max(total, n[2] + n[3])
    }
    sampleCount := Integer(total * rate)
    dataBytes := sampleCount * 2
    buf := Buffer(44 + dataBytes, 0)
    NumPut("UInt", 0x46464952, buf, 0)             ; "RIFF"
    NumPut("UInt", 36 + dataBytes, buf, 4)
    NumPut("UInt", 0x45564157, buf, 8)             ; "WAVE"
    NumPut("UInt", 0x20746D66, buf, 12)            ; "fmt "
    NumPut("UInt", 16, buf, 16)
    NumPut("UShort", 1, buf, 20)                   ; PCM
    NumPut("UShort", 1, buf, 22)                   ; mono
    NumPut("UInt", rate, buf, 24)
    NumPut("UInt", rate * 2, buf, 28)
    NumPut("UShort", 2, buf, 32)
    NumPut("UShort", 16, buf, 34)
    NumPut("UInt", 0x61746164, buf, 36)            ; "data"
    NumPut("UInt", dataBytes, buf, 40)
    twoPi := 6.283185307179586
    Loop sampleCount {
        t := (A_Index - 1) / rate
        s := 0.0
        for n in notes {
            dt := t - n[2]
            if (dt < 0 || dt > n[3]) {
                continue
            }
            envelope := Min(1.0, dt / 0.012) * Exp(-4.5 * dt / n[3]) * Min(1.0, (n[3] - dt) / 0.03)
            s += (Sin(twoPi * n[1] * dt) + 0.25 * Sin(twoPi * n[1] * 2 * dt)) * envelope
        }
        NumPut("Short", Round(Max(-1.0, Min(1.0, s * volume)) * 32767), buf, 44 + (A_Index - 1) * 2)
    }
    return buf
}

; Scales PCM sample amplitude in a copy of a WAV buffer by gain (0.0..1.0) without mutating the cached source
ScaleWavBufferGain(srcBuf, gain) {
    gain := Max(0.0, Min(1.0, gain))
    out := Buffer(srcBuf.Size, 0)
    DllCall("RtlMoveMemory", "Ptr", out.Ptr, "Ptr", srcBuf.Ptr, "UPtr", srcBuf.Size)
    if (srcBuf.Size > 44) {
        sampleCount := (srcBuf.Size - 44) // 2
        Loop sampleCount {
            off := 44 + (A_Index - 1) * 2
            sample := NumGet(out, off, "Short")
            scaled := Round(Max(-32768, Min(32767, sample * gain)))
            NumPut("Short", scaled, out, off)
        }
    }
    return out
}

PlaySoundByName(name) {
    static cache := Map(), lastScaledBuf := ""
    name := NormalizeSoundName(name)
    if (name = "None") {
        return
    }
    volPct := GetSoundVolumePercent()
    if (volPct <= 0) {
        return
    }
    gain := GetSoundGainFactor()

    switch name {
        case "Windows Default":
            DllCall("MessageBeep", "UInt", 0)
            return
        case "Windows Notify":
            wav := A_WinDir "\Media\Windows Notify System Generic.wav"
            if FileExist(wav) {
                SoundPlay(wav)
            } else {
                DllCall("MessageBeep", "UInt", 0x40)
            }
            return
        case "Windows Ding":
            wav := A_WinDir "\Media\Windows Ding.wav"
            if FileExist(wav) {
                SoundPlay(wav)
            } else {
                DllCall("MessageBeep", "UInt", 0x30)
            }
            return
    }
    if !cache.Has(name) {
        switch name {
            case "Soft Chime":
                cache[name] := BuildSoftTones([[880, 0, 0.7], [1318.5, 0.14, 0.9]])
            case "Gentle Bell":
                cache[name] := BuildSoftTones([[659.3, 0, 1.2]])
            case "Glass Drop":
                cache[name] := BuildSoftTones([[1396.9, 0, 0.5]])
            case "Calm Rise":
                cache[name] := BuildSoftTones([[523.3, 0, 0.6], [659.3, 0.15, 0.6], [784, 0.30, 0.9]])
            case "Calm Fall":
                cache[name] := BuildSoftTones([[784, 0, 0.6], [659.3, 0.15, 0.6], [523.3, 0.30, 0.9]])
            default:
                return
        }
    }
    lastScaledBuf := ScaleWavBufferGain(cache[name], gain)
    ; SND_MEMORY | SND_ASYNC | SND_NODEFAULT - keep lastScaledBuf alive while playing asynchronously
    DllCall("winmm\PlaySoundW", "Ptr", lastScaledBuf, "Ptr", 0, "UInt", 0x7)
}

NotifyDimEvent() {
    global Dim_Sound_Enabled, Dim_Sound_Name
    static lastTick := 0
    if (Dim_Sound_Enabled && (A_TickCount - lastTick) > 1000) {
        lastTick := A_TickCount
        PlaySoundByName(Dim_Sound_Name)
    }
}

NotifyWakeEvent() {
    global Wake_Sound_Enabled, Wake_Sound_Name
    static lastTick := 0
    if (Wake_Sound_Enabled && (A_TickCount - lastTick) > 1000) {
        lastTick := A_TickCount
        PlaySoundByName(Wake_Sound_Name)
    }
}

; One row of the Sound Alerts box: checkbox + sound picker (plays when you pick) + Play button
AddSoundRow(g, y, label, enabled, current) {
    global UI_Dark_Mode, SettingsLayout
    lay := SettingsLayout
    ddlX := lay.ix + 206
    btnX := lay.ir - 84
    chk := g.AddCheckbox("x42 y" (y + 4) " w" (ddlX - 42 - 6) " Checked" enabled, label)
    ddl := g.AddDropDownList("x" ddlX " y" y " w" (btnX - 6 - ddlX), GetSoundChoices())
    ddl.Text := NormalizeSoundName(current)
    btn := g.AddButton("x" btnX " y" y " w84 h24", "Play")
    for c in [chk, ddl, btn] {
        StyleControlTheme(c, UI_Dark_Mode)
    }
    ddl.OnEvent("Change", (*) => (
        PlaySoundByName(ddl.Text),
        chk.Value := (ddl.Text != "None"),
        chk.Redraw(),
        MarkSettingsDirty()
    ))
    btn.OnEvent("Click", (*) => PlaySoundByName(ddl.Text))
    chk.OnEvent("Click", MarkSettingsDirty)
    RegisterTip(ddl, "Pick a sound to hear it right away. 'Windows Default' uses your normal Windows sound scheme. 'None' turns this sound off.")
    RegisterTip(btn, "Plays the selected sound again.")
    return { chk: chk, ddl: ddl }
}

SetSoundSelections(dimName, wakeName) {
    global Dim_Sound_Name, Wake_Sound_Name
    Dim_Sound_Name  := NormalizeSoundName(dimName)
    Wake_Sound_Name := NormalizeSoundName(wakeName)
}

OnRunAdminToggle(ctrl, *) {
    global Run_As_Admin, SettingsGui
    Run_As_Admin := !!ctrl.Value
    MarkSettingsDirty()
    SetTimer(SavePresetsToIni, -500)
    if (!Run_As_Admin || A_IsAdmin) {
        return
    }
    ; Turned ON while not elevated: offer to restart right now so the UAC prompt appears immediately
    if IsObject(SettingsGui) {
        SettingsGui.Opt("+OwnDialogs")
    }
    ask := "Restart OLED Engine now to run as administrator?`n`nWindows will ask for permission. Changes on other tabs that you have not applied yet will be discarded, so click Apply first if you have any."
    if (MsgBox(ask, "Run as administrator", "YesNo Icon?") != "Yes") {
        return
    }
    SetTimer(SavePresetsToIni, 0)
    SavePresetsToIni()
    try {
        startupFlag := HasStartupArg() ? " /startup" : ""
        if A_IsCompiled {
            Run('*RunAs "' A_ScriptFullPath '"' startupFlag)
        } else {
            Run('*RunAs "' A_AhkPath '" "' A_ScriptFullPath '"' startupFlag)
        }
        ExitApp()
    } catch {
        ; UAC prompt was declined: keep running as before (the setting stays saved for the next start)
    }
}

MarkSettingsDirty(*) {
    global SettingsApplyBtn
    if IsObject(SettingsApplyBtn) {
        SettingsApplyBtn.Enabled := true
    }
}

SetSettingsClean() {
    global SettingsApplyBtn
    if IsObject(SettingsApplyBtn) {
        SettingsApplyBtn.Enabled := false
    }
}
; ==============================================================================
; 5. UNIFIED MULTI-MONITOR SETTINGS GUI
; ==============================================================================
; Single source of truth for the Settings window geometry (unscaled GUI units).
; The window is as wide as the tab strip, so every tab is laid out from these numbers
; instead of fixed pixel sizes. Add new controls with these values, not with literals.
SetSettingsLayout(tabW) {
    global SettingsLayout
    lay := {}
    lay.bx := 28                                  ; section box left
    lay.bw := Max(496, tabW - 24)                 ; section box width (12 px margin each side of the tab)
    lay.ix := lay.bx + 14                         ; inner left edge
    lay.iw := lay.bw - 28                         ; inner width
    lay.ir := lay.ix + lay.iw                     ; inner right edge
    lay.colGap := 16
    lay.colW := Floor((lay.iw - lay.colGap) / 2)  ; two-column grid
    lay.c2x := lay.ix + lay.colW + lay.colGap     ; second column left
    lay.edW := 52                                 ; number box width
    lay.edOff := lay.colW - lay.edW - 24          ; number box offset inside a column
    lay.lblW := lay.edOff - 6                     ; label width in front of a number box
    lay.e1 := lay.ix + lay.edOff                  ; number box x, column 1
    lay.e2 := lay.c2x + lay.edOff                 ; number box x, column 2
    lay.dLblW := 112                              ; "HDR Dim Level" label
    lay.dSldX := lay.ix + 114                     ; dim slider x
    lay.dChkW := 100                              ; "Blackout" checkbox
    lay.dChkX := lay.ir - lay.dChkW
    lay.dPctX := lay.dChkX - 50                   ; "100%" readout
    lay.dSldW := lay.dPctX - 6 - lay.dSldX        ; dim slider width
    lay.rstW := 104                               ; "Reset Defaults" button
    SettingsLayout := lay
}

; Controls that another script file (App Automation.ahk) adds to this window were laid out for the
; old 496 px section boxes. Stretch / move them with the same rules so that tab fills the window too.
; Read-only rich text box for the changelog: each "• Title:" is bold and accent-colored, the rest is normal text.
AddChangelogRichEdit(g, x, y, w, h, entries, dark) {
    global ThemeSurfaceRgb
    static hLib := DllCall("LoadLibrary", "Str", "Msftedit.dll", "Ptr")
    re := g.AddCustom("ClassRICHEDIT50W x" x " y" y " w" w " h" h " +0x4 +0x40 +0x800 +0x200000 +E0x200")
    hwnd := re.Hwnd
    try DllCall("uxtheme\SetWindowTheme", "Ptr", hwnd, "Str", dark ? "DarkMode_Explorer" : "Explorer", "Ptr", 0)

    ; Rich edit counts a line break as ONE character, so separate lines with `r only
    text := ""
    ranges := []
    for e in entries {
        head := "• " e[1] ":"
        ranges.Push([StrLen(text), StrLen(text) + StrLen(head)])
        text .= head " " e[2] ((A_Index < entries.Length) ? "`r" : "")
    }
    DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x0C, "Ptr", 0, "Str", text)            ; WM_SETTEXT
    DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x443, "Ptr", 0, "Int", RgbToBgr(ThemeSurfaceRgb))  ; EM_SETBKGNDCOLOR

    SetFmt(start, end, mask, effects, rgb) {
        cf := Buffer(92, 0)
        NumPut("UInt", 92, cf, 0)
        NumPut("UInt", mask, cf, 4)
        NumPut("UInt", effects, cf, 8)
        NumPut("Int", 190, cf, 12)                         ; 9.5 pt in twips
        NumPut("UInt", RgbToBgr(rgb), cf, 20)
        StrPut("Segoe UI", cf.Ptr + 26, 32, "UTF-16")
        cr := Buffer(8, 0)
        NumPut("Int", start, cr, 0)
        NumPut("Int", end, cr, 4)
        DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x0B1, "Ptr", start, "Ptr", end)  ; EM_SETSEL
        DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x444, "Ptr", 1, "Ptr", cf.Ptr)   ; EM_SETCHARFORMAT (selection)
    }
    ; CFM_SIZE|CFM_FACE|CFM_COLOR|CFM_BOLD  = 0x80000000|0x20000000|0x40000000|1
    SetFmt(0, -1, 0xE0000001, 0, dark ? 0xFFFFFF : 0x000000)
    for r in ranges {
        SetFmt(r[1], r[2], 0xE0000001, 1, dark ? 0x6EE7B7 : 0x1D4ED8)   ; CFE_BOLD
    }
    DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x0B1, "Ptr", 0, "Ptr", 0)   ; caret to top
    DllCall("SendMessageW", "Ptr", hwnd, "UInt", 0x0B7, "Ptr", 0, "Ptr", 0)   ; EM_SCROLLCARET
    return re
}

ReflowForeignTabControls(g, knownHwnds) {
    global SettingsLayout
    extra := SettingsLayout.bw - 496
    if (extra <= 0) {
        return
    }
    for ctrl in g {
        if knownHwnds.Has(ctrl.Hwnd) {
            continue
        }
        ; The Automation tab used to show a "Run as administrator - see Presets tab" note that belongs to the
        ; Presets tab (where that checkbox lives). Blank it so it no longer floats on the Automation tab.
        try {
            if (ctrl.Type = "Text") {
                noteTxt := ctrl.Text
                if (InStr(noteTxt, "admin") && InStr(noteTxt, "Presets")) {
                    ctrl.Text := ""
                    ctrl.Visible := false
                    continue
                }
            }
        }
        try {
            ctrl.GetPos(&cx, &cy, &cw, &ch)
            if (cx + cw >= 490) {
                if (cx <= 60 || cw >= 150) {
                    ctrl.Move(, , cw + extra)
                } else {
                    ctrl.Move(cx + extra)
                }
            } else if (cx >= 240) {
                ctrl.Move(cx + Round(extra / 2))
            }
        }
    }
}

OpenSettingsGui(initialTab := 0) {
    static isOpeningSettingsGui := false
    if isOpeningSettingsGui {
        return
    }
    isOpeningSettingsGui := true
    try {
        global APP_VERSION, ErrorLogPath
        global SettingsGui, SettingsTabsCtrl, SettingsTabDefaultBanner, SettingsTabTipMap, GroupTitleTips
        global SettingsApplyBtn, SettingsHintCtrl, SettingsLastBannerText, SettingsActiveTab, HdrSwitchMap, SettingsLayout
        global UI_Dark_Mode, Debug_Log_Enabled, Debug_Log_Path, Active_HDR_Mode, Comp_Game_Auto_SDR_Enabled, lastConnectedMonitorCount
        global Primary_Auto_Enabled, OLED_HDR_SDR_Mode_Enabled, Primary_Dim_Percent, Primary_HDR_Dim_Percent, Primary_Fade_Ms
        global OLED_Refresh_Reminder_Enabled, OLED_Refresh_Reminder_Days, OLED_Refresh_Reminder_Hours, OLED_Refresh_Reminder_Minutes
        global OLED_Refresh_Popup_Monitor, OLED_Refresh_Alert_Style, OLED_Refresh_Popup_Sound, CareUiRefs, CareTabIdx
        global Dim_Sound_Enabled, Wake_Sound_Enabled, Dim_Sound_Name, Wake_Sound_Name
        global oledActiveMsSinceRefresh, primaryDimmedMs, primaryUndimmedMs, secondaryDimmedMs, secondaryUndimmedMs
        global primaryWakeCount, secondaryWakeCount, primaryDimBlackoutTriggers, secondaryDimBlackoutTriggers, scriptStartTick
        global Primary_SDR_Desktop_Sec, Primary_SDR_Normal_Sec, Primary_SDR_Comp_Sec, Primary_SDR_Paused_Sec
        global Primary_HDR_Desktop_Sec, Primary_HDR_Normal_Sec, Primary_HDR_Comp_Sec, Primary_HDR_Paused_Sec
        global Extra_Auto_Enabled, Extra_HDR_SDR_Mode_Enabled, Extra_Comp_Game_Auto_SDR
        global Extra_Dim_Percent, Extra_HDR_Dim_Percent, Extra_Fade_Ms
        global Extra_SDR_Desktop_Sec, Extra_SDR_Normal_Sec, Extra_SDR_Comp_Sec, Extra_SDR_Paused_Sec
        global Extra_HDR_Desktop_Sec, Extra_HDR_Normal_Sec, Extra_HDR_Comp_Sec, Extra_HDR_Paused_Sec
        global Extra_Mon3_Dim_Percent, Extra_Mon3_HDR_Dim_Percent, Extra_Mon3_SDR_Sec, Extra_Mon3_HDR_Sec
        global Extra_Mon4_Dim_Percent, Extra_Mon4_HDR_Dim_Percent, Extra_Mon4_SDR_Sec, Extra_Mon4_HDR_Sec
        global Extra_Mon5_Dim_Percent, Extra_Mon5_HDR_Dim_Percent, Extra_Mon5_SDR_Sec, Extra_Mon5_HDR_Sec
        global Desktop_Hide_Enabled, Desktop_Idle_Sec, Icon_Fade_Ms, Start_With_Windows, Start_Minimized
        global Comp_Games_List, Excluded_Processes_List, TrayMenuItems, trayListViewCtrl, trayDraftRef, trayRefreshFn
        global LiveStatusRefs

        if IsObject(SettingsGui) {
            try {
                if (initialTab >= 1) {
                    SettingsTabsCtrl.Value := initialTab
                    SetStatusBannerText(GetDefaultBannerForTab(initialTab))
                }
                SettingsGui.Show()
                SyncLiveHdrIndicators()
                SetTimer(SyncLiveStatusBoxes, 500)
                SyncSettingsLiveRefreshTimer()
                SetTimer(SyncSettingsLiveRefreshTimer, 1000)
                return
            }
        }

        GroupTitleTips := []
        LiveStatusRefs := []
        HdrSwitchMap := Map()
        monCount := GetDetectedMonitorCount()
        priIdx := MonitorGetPrimary()
        lastConnectedMonitorCount := monCount
        priHdrInfo := GetMonitorHdrInfo(priIdx)
        liveHdr := priHdrInfo.enabled
        Active_HDR_Mode := liveHdr

        extraIndices := []
        Loop monCount {
            if (A_Index != priIdx) {
                extraIndices.Push(A_Index)
            }
        }

        tabH := 640

       g := Gui("+DPIScale -MaximizeBox -MinimizeBox", "OLED Engine")
        ApplyGuiTheme(g, UI_Dark_Mode)
        g.MarginX := 16
        g.MarginY := 14

        priInfo := GetMonitorHoverInfo(priIdx)
        tabNames := ["Monitor 1"]
        SettingsTabTipMap := Map()
        SettingsTabDefaultBanner := Map()
        SettingsTabTipMap[1] := priInfo
        SettingsTabDefaultBanner[1] := priInfo

        extraTabMap := Map()
        extraInfos := []
        for mIdx in extraIndices {
            mInfo := GetMonitorHoverInfo(mIdx)
            extraInfos.Push(mInfo)
            tabNames.Push("Monitor " mIdx)
            tIdx := tabNames.Length
            extraTabMap[mIdx] := tIdx
            SettingsTabTipMap[tIdx] := mInfo
            SettingsTabDefaultBanner[tIdx] := mInfo
        }
        extraSummary := (extraInfos.Length > 0) ? JoinArray(extraInfos, "  |  ") : ""

        iconsTabIdx := tabNames.Length + 1
        tabNames.Push("General")
        SettingsTabDefaultBanner[iconsTabIdx] := ""

        presetsTabIdx := tabNames.Length + 1
        tabNames.Push("Presets")
        SettingsTabDefaultBanner[presetsTabIdx] := ""

        autoTabIdx := tabNames.Length + 1
        tabNames.Push("Automation")
        SettingsTabDefaultBanner[autoTabIdx] := ""

        hotkeysTabIdx := tabNames.Length + 1
        tabNames.Push("Hotkeys")
        SettingsTabDefaultBanner[hotkeysTabIdx] := ""

        careTabIdx := tabNames.Length + 1
        CareTabIdx := careTabIdx
        refreshStInit := GetOledRefreshStatus()
        tabNames.Push((refreshStInit.state >= 1) ? "! OLED Care" : "OLED Care")
        SettingsTabDefaultBanner[careTabIdx] := ""

        statsTabIdx := tabNames.Length + 1
        tabNames.Push("Stats")
        SettingsTabDefaultBanner[statsTabIdx] := ""

        aboutTabIdx := tabNames.Length + 1
        tabNames.Push("Help / About")
        SettingsTabDefaultBanner[aboutTabIdx] := ""

        tabs := g.AddTab3("x16 y14 w660 h" tabH " -Wrap +0x2000", tabNames)
        tabItemW := Max(72, Min(110, Floor(652 / tabNames.Length)))
        SendMessage(0x1329, 0, tabItemW | (28 << 16), tabs)   ; TCM_SETITEMSIZE
        StyleControlTheme(tabs, UI_Dark_Mode)
        SettingsTabsCtrl := tabs

        ; Size the tab strip first: its width decides the width of everything inside the tabs.
        rcLastTab := Buffer(16, 0)
        SendMessage(0x130A, tabNames.Length - 1, rcLastTab, tabs.Hwnd)   ; TCM_GETITEMRECT
        dpiScale := A_ScreenDPI / 96
        exactTabW := Max(522, Round(NumGet(rcLastTab, 8, "Int") / dpiScale) + 4)
        tabs.Move(, , exactTabW)
        SetSettingsLayout(exactTabW)
        lay := SettingsLayout

        tipDesktopSec  := "Idle delay (in seconds) before dimming or blacking out when on the Windows Desktop, browsing, or using regular apps."
        tipNormGameSec := "Idle delay (in seconds) before dimming or blacking out while playing a standard fullscreen or borderless game."
        tipCompGameSec := "Idle delay (in seconds) before dimming or blacking out while a game in your Competitive Games list is running."
        tipPausedSec   := "Idle delay (in seconds) before dimming or blacking out when a video player (MPC-HC, Stremio, VLC, mpv, etc.) is paused. Fullscreen/maximized browser videos (such as YouTube) on Monitor 1 do not dim while playing."
        tipDimLevel    := "Controls screen darkness when idle: 0% turns dimming off, while 100% is pure black (#000000) pixel-off blackout."
        tipBlackoutChk := "Quick toggle that sets Dim Level to 100% pure black (#000000) blackout when checked."
        tipFadeSpeed   := "Controls how smoothly the screen fades in and out (in milliseconds). Set to 0 ms for an instant switch."

        ; --------------------------------------------------------------------------
        ; TAB 1: MONITOR 1
        ; --------------------------------------------------------------------------
        tabs.UseTab(1)

        chkPriAuto := g.AddCheckbox("x" lay.bx " y46 w" (lay.bw - 8) " Checked" Primary_Auto_Enabled, "Auto dim when idle   (turn off = manual dim only)")
        StyleControlTheme(chkPriAuto, UI_Dark_Mode)
        chkPriAuto.SetFont("s9.5 bold " (UI_Dark_Mode ? "cFFFFFF" : "c000000"), "Segoe UI")
        RegisterTip(chkPriAuto, "Master toggle for automatic idle dimming on Monitor 1. When OFF, only manual dim / blackout (hotkey or tray) works and the Dim Level below still applies to it.")

        boxHdrMode := AddSectionBox(g, lay.bx, 72, lay.bw, 84, "HDR && Display Mode", UI_Dark_Mode)
        chkHdrSdr := g.AddCheckbox("x" lay.ix " y94 w" lay.colW " Checked" (priHdrInfo.supported && OLED_HDR_SDR_Mode_Enabled), "Separate HDR/SDR profiles")
        StyleControlTheme(chkHdrSdr, UI_Dark_Mode)
        RegisterTip(chkHdrSdr, priHdrInfo.supported ? "Uses separate idle delays and dim levels depending on whether Windows HDR is currently ON or OFF." : "Monitor 1 does not support HDR.")

        chkCompSdr := g.AddCheckbox("x" lay.c2x " y94 w" lay.colW " Checked" (priHdrInfo.supported && Comp_Game_Auto_SDR_Enabled), "Auto-SDR in competitive games")
        StyleControlTheme(chkCompSdr, UI_Dark_Mode)
        RegisterTip(chkCompSdr, priHdrInfo.supported ? "Automatically switches Monitor 1 from HDR to SDR when a game from your Competitive Games list launches." : "Monitor 1 does not support HDR.")

        swPriHdr := CreateSdrHdrSwitch(g, lay.ix, 122, 98, 24, priIdx, priHdrInfo.supported, liveHdr, true)
        RegisterTip(swPriHdr, priHdrInfo.supported ? "Click to toggle between SDR and HDR for Monitor 1." : "Monitor 1 does not support HDR.")

        txtHdrStatus := g.AddText("x" (lay.ix + 106) " y126 w" (lay.iw - 106) " +0x100", priHdrInfo.supported ? ("Monitor 1 output is " (liveHdr ? "HDR" : "SDR")) : "Monitor 1 does not support HDR")
        StyleControlTheme(txtHdrStatus, UI_Dark_Mode, true)
        RegisterTip(txtHdrStatus, "Shows whether Monitor 1 supports HDR and is currently outputting an HDR or SDR signal.")

        BindSdrHdrStatusCtrl(swPriHdr, txtHdrStatus)

        if priHdrInfo.supported {
            swPriHdr.OnEvent("Click", (*) => ToggleMonitorHdrFromSwitch(priIdx, swPriHdr, txtHdrStatus))
        } else {
            chkHdrSdr.Enabled := false
            chkCompSdr.Enabled := false
            txtHdrStatus.Enabled := false
        }

        priSepInitial := priHdrInfo.supported && OLED_HDR_SDR_Mode_Enabled
        boxTimers := AddSectionBox(g, lay.bx, 164, lay.bw, 92, priSepInitial ? "SDR Idle Delay  (0 = Disabled)" : "Idle Delay  (0 = Disabled)", UI_Dark_Mode)
        t1 := g.AddText("x" lay.ix " y188 w" lay.lblW " +0x100", "Desktop (s)")
        edtSdrDesk := g.AddEdit("x" lay.e1 " y185 w" lay.edW " Number")
        udSdrDesk := g.AddUpDown("Range0-3600", Primary_SDR_Desktop_Sec)
        RegisterTip(t1, tipDesktopSec " Set to 0 to disable.")
        RegisterTip(edtSdrDesk, tipDesktopSec " Set to 0 to disable.")

        t2 := g.AddText("x" lay.c2x " y188 w" lay.lblW " +0x100", "Standard Game (s)")
        edtSdrNorm := g.AddEdit("x" lay.e2 " y185 w" lay.edW " Number")
        udSdrNorm := g.AddUpDown("Range0-3600", Primary_SDR_Normal_Sec)
        RegisterTip(t2, tipNormGameSec " Set to 0 to disable.")
        RegisterTip(edtSdrNorm, tipNormGameSec " Set to 0 to disable.")

        t3 := g.AddText("x" lay.ix " y218 w" lay.lblW " +0x100", "Competitive Game (s)")
        edtSdrComp := g.AddEdit("x" lay.e1 " y215 w" lay.edW " Number")
        udSdrComp := g.AddUpDown("Range0-3600", Primary_SDR_Comp_Sec)
        RegisterTip(t3, tipCompGameSec " Set to 0 to disable.")
        RegisterTip(edtSdrComp, tipCompGameSec " Set to 0 to disable.")

        t4 := g.AddText("x" lay.c2x " y218 w" lay.lblW " +0x100", "Paused Video (s)")
        edtSdrPause := g.AddEdit("x" lay.e2 " y215 w" lay.edW " Number")
        udSdrPause := g.AddUpDown("Range0-3600", Primary_SDR_Paused_Sec)
        RegisterTip(t4, tipPausedSec " Set to 0 to disable.")
        RegisterTip(edtSdrPause, tipPausedSec " Set to 0 to disable.")

        boxHdr := AddSectionBox(g, lay.bx, 264, lay.bw, 92, "HDR Idle Delay  (0 = Disabled)", UI_Dark_Mode)
        t5 := g.AddText("x" lay.ix " y288 w" lay.lblW " +0x100", "Desktop (s)")
        edtHdrDesk := g.AddEdit("x" lay.e1 " y285 w" lay.edW " Number")
        udHdrDesk := g.AddUpDown("Range0-3600", Primary_HDR_Desktop_Sec)
        RegisterTip(t5, tipDesktopSec " Set to 0 to disable.")
        RegisterTip(edtHdrDesk, tipDesktopSec " Set to 0 to disable.")

        t6 := g.AddText("x" lay.c2x " y288 w" lay.lblW " +0x100", "Standard Game (s)")
        edtHdrNorm := g.AddEdit("x" lay.e2 " y285 w" lay.edW " Number")
        udHdrNorm := g.AddUpDown("Range0-3600", Primary_HDR_Normal_Sec)
        RegisterTip(t6, tipNormGameSec " Set to 0 to disable.")
        RegisterTip(edtHdrNorm, tipNormGameSec " Set to 0 to disable.")

        t7 := g.AddText("x" lay.ix " y318 w" lay.lblW " +0x100", "Competitive Game (s)")
        edtHdrComp := g.AddEdit("x" lay.e1 " y315 w" lay.edW " Number")
        udHdrComp := g.AddUpDown("Range0-3600", Primary_HDR_Comp_Sec)
        RegisterTip(t7, tipCompGameSec " Set to 0 to disable.")
        RegisterTip(edtHdrComp, tipCompGameSec " Set to 0 to disable.")

        t8 := g.AddText("x" lay.c2x " y318 w" lay.lblW " +0x100", "Paused Video (s)")
        edtHdrPause := g.AddEdit("x" lay.e2 " y315 w" lay.edW " Number")
        udHdrPause := g.AddUpDown("Range0-3600", Primary_HDR_Paused_Sec)
        RegisterTip(t8, tipPausedSec " Set to 0 to disable.")
        RegisterTip(edtHdrPause, tipPausedSec " Set to 0 to disable.")

        boxDim := AddSectionBox(g, lay.bx, 364, lay.bw, 166, "Dim Level && Fade Speed  (0% = Disabled)", UI_Dark_Mode)
        priDiv1 := g.AddText("x" lay.ix " y446 w" lay.iw " h2 0x10")      ; divider: dim levels | fade speed
        priDiv2 := g.AddText("x" lay.ix " y480 w" lay.iw " h2 0x10")      ; divider: settings | action buttons
        t9 := g.AddText("x" lay.ix " y390 w" lay.dLblW " +0x100", priSepInitial ? "SDR Dim Level" : "Dim Level")
        sldPriDark := g.AddSlider("x" lay.dSldX " y388 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-100", Primary_Dim_Percent)
        txtPriDark := g.AddText("x" lay.dPctX " y390 w44 +0x100", Primary_Dim_Percent "%")
        chkPriSdrBlk := g.AddCheckbox("x" lay.dChkX " y389 w" lay.dChkW " Checked" (Primary_Dim_Percent = 100), "Blackout")
        RegisterTip(t9, tipDimLevel)
        RegisterTip(sldPriDark, tipDimLevel)
        RegisterTip(chkPriSdrBlk, tipBlackoutChk)

        t10 := g.AddText("x" lay.ix " y422 w" lay.dLblW " +0x100", "HDR Dim Level")
        sldPriHdrDark := g.AddSlider("x" lay.dSldX " y420 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-100", Primary_HDR_Dim_Percent)
        txtPriHdrDark := g.AddText("x" lay.dPctX " y422 w44 +0x100", Primary_HDR_Dim_Percent "%")
        chkPriHdrBlk := g.AddCheckbox("x" lay.dChkX " y421 w" lay.dChkW " Checked" (Primary_HDR_Dim_Percent = 100), "Blackout")
        RegisterTip(t10, tipDimLevel)
        RegisterTip(sldPriHdrDark, tipDimLevel)
        RegisterTip(chkPriHdrBlk, tipBlackoutChk)

        t11 := g.AddText("x" lay.ix " y454 w" lay.dLblW " +0x100", "Fade Speed")
        sldPriFade := g.AddSlider("x" lay.dSldX " y452 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-2000", Primary_Fade_Ms)
        txtPriFade := g.AddText("x" lay.dPctX " y454 w70 +0x100", Primary_Fade_Ms " ms")
        RegisterTip(t11, tipFadeSpeed)
        RegisterTip(sldPriFade, tipFadeSpeed)

        btnTestPri := g.AddButton("x" lay.ix " y490 w132 h26", "Test Dim (3s)")
        RegisterTip(btnTestPri, "Previews Monitor 1's current Dim Level and Fade Speed for 3 seconds.")
        btnTestPri.OnEvent("Click", (*) => PreviewPrimaryDim(sldPriDark.Value, sldPriHdrDark.Value, sldPriFade.Value, QueryWindowsPrimaryHdrState()))

        btnResetPri := g.AddButton("x" (lay.ir - lay.rstW) " y490 w" lay.rstW " h26", "Reset Defaults")
        RegisterTip(btnResetPri, "Restores Monitor 1 delays, dim levels, fade speed, and HDR options to their default values.")
        AddLiveStatusBox(g, UI_Dark_Mode, priIdx, true, 1)

        prevPriSdrVal := (Primary_Dim_Percent < 100) ? Primary_Dim_Percent : 75
        prevPriHdrVal := (Primary_HDR_Dim_Percent < 100) ? Primary_HDR_Dim_Percent : 75

        sldPriDark.OnEvent("Change", (*) => (
            txtPriDark.Text := sldPriDark.Value "%",
            chkPriSdrBlk.Value := (sldPriDark.Value = 100) ? 1 : 0,
            (sldPriDark.Value < 100) ? (prevPriSdrVal := sldPriDark.Value) : 0,
            sldPriDark.Redraw(),
            MarkSettingsDirty()
        ))
        chkPriSdrBlk.OnEvent("Click", (*) => (
            newVal := chkPriSdrBlk.Value ? 100 : prevPriSdrVal,
            sldPriDark.Value := newVal,
            txtPriDark.Text := newVal "%",
            sldPriDark.Redraw(),
            MarkSettingsDirty()
        ))

        sldPriHdrDark.OnEvent("Change", (*) => (
            txtPriHdrDark.Text := sldPriHdrDark.Value "%",
            chkPriHdrBlk.Value := (sldPriHdrDark.Value = 100) ? 1 : 0,
            (sldPriHdrDark.Value < 100) ? (prevPriHdrVal := sldPriHdrDark.Value) : 0,
            sldPriHdrDark.Redraw(),
            MarkSettingsDirty()
        ))
        chkPriHdrBlk.OnEvent("Click", (*) => (
            newVal := chkPriHdrBlk.Value ? 100 : prevPriHdrVal,
            sldPriHdrDark.Value := newVal,
            txtPriHdrDark.Text := newVal "%",
            sldPriHdrDark.Redraw(),
            MarkSettingsDirty()
        ))
        sldPriFade.OnEvent("Change", (*) => (txtPriFade.Text := sldPriFade.Value " ms", sldPriFade.Redraw(), MarkSettingsDirty()))

        hdrOnlyCtrls := [boxHdr, t5, edtHdrDesk, udHdrDesk, t6, edtHdrNorm, udHdrNorm, t7, edtHdrComp, udHdrComp, t8, edtHdrPause, udHdrPause, t10, sldPriHdrDark, txtPriHdrDark, chkPriHdrBlk, priDiv1]
        allMainCtrls := [
            boxHdrMode, btnResetPri, boxTimers,
            t1, edtSdrDesk, udSdrDesk, t2, edtSdrNorm, udSdrNorm,
            t3, edtSdrComp, udSdrComp, t4, edtSdrPause, udSdrPause,
            boxHdr, t5, edtHdrDesk, udHdrDesk, t6, edtHdrNorm, udHdrNorm,
            t7, edtHdrComp, udHdrComp, t8, edtHdrPause, udHdrPause, boxDim,
            t9, sldPriDark, txtPriDark, chkPriSdrBlk, t10, sldPriHdrDark, txtPriHdrDark, chkPriHdrBlk,
            t11, sldPriFade, txtPriFade, btnTestPri
        ]
        if priHdrInfo.supported {
            allMainCtrls.Push(chkHdrSdr)
            allMainCtrls.Push(chkCompSdr)
            allMainCtrls.Push(swPriHdr)
            allMainCtrls.Push(txtHdrStatus)
        }

        ; Controls that only matter for AUTOMATIC dimming. Dim level / fade / HDR options stay usable for manual dim.
        autoOnlyMain := [
            boxTimers, t1, edtSdrDesk, udSdrDesk, t2, edtSdrNorm, udSdrNorm,
            t3, edtSdrComp, udSdrComp, t4, edtSdrPause, udSdrPause,
            boxHdr, t5, edtHdrDesk, udHdrDesk, t6, edtHdrNorm, udHdrNorm,
            t7, edtHdrComp, udHdrComp, t8, edtHdrPause, udHdrPause
        ]

        for c in allMainCtrls {
            if !HdrSwitchMap.Has(c.Hwnd) {
                StyleControlTheme(c, UI_Dark_Mode, (c = txtHdrStatus))
            }
            if (c.Type = "Edit") {
                c.OnEvent("Change", MarkSettingsDirty)
            } else if (c.Type = "CheckBox") {
                c.OnEvent("Click", MarkSettingsDirty)
            }
        }

        ApplyProfileLayout(*) {
            ox := 0, oy := 0
            try {
                boxHdrMode.GetPos(&bx, &by)
                ox := bx - lay.bx
                oy := by - 72
            }
            DllCall("SendMessage", "Ptr", g.Hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
            sep := priHdrInfo.supported && !!chkHdrSdr.Value
            boxTimers.Text := sep ? "SDR Idle Delay  (0 = Disabled)" : "Idle Delay  (0 = Disabled)"
            t9.Text := sep ? "SDR Dim Level" : "Dim Level"
            for hc in hdrOnlyCtrls {
                hc.Visible := sep
            }
            rstX := lay.ir - lay.rstW
            if sep {
                boxDim.Move(lay.bx + ox, 364 + oy, lay.bw, 166)
                t9.Move(lay.ix + ox, 390 + oy)
                sldPriDark.Move(lay.dSldX + ox, 388 + oy, lay.dSldW, 24)
                txtPriDark.Move(lay.dPctX + ox, 390 + oy)
                chkPriSdrBlk.Move(lay.dChkX + ox, 389 + oy)
                t10.Move(lay.ix + ox, 422 + oy)
                sldPriHdrDark.Move(lay.dSldX + ox, 420 + oy, lay.dSldW, 24)
                txtPriHdrDark.Move(lay.dPctX + ox, 422 + oy)
                chkPriHdrBlk.Move(lay.dChkX + ox, 421 + oy)
                priDiv1.Move(lay.ix + ox, 446 + oy)
                t11.Move(lay.ix + ox, 454 + oy)
                sldPriFade.Move(lay.dSldX + ox, 452 + oy, lay.dSldW, 24)
                txtPriFade.Move(lay.dPctX + ox, 454 + oy)
                priDiv2.Move(lay.ix + ox, 480 + oy)
                btnTestPri.Move(lay.ix + ox, 490 + oy)
                btnResetPri.Move(rstX + ox, 490 + oy)
            } else {
                boxDim.Move(lay.bx + ox, 264 + oy, lay.bw, 134)
                t9.Move(lay.ix + ox, 290 + oy)
                sldPriDark.Move(lay.dSldX + ox, 288 + oy, lay.dSldW, 24)
                txtPriDark.Move(lay.dPctX + ox, 290 + oy)
                chkPriSdrBlk.Move(lay.dChkX + ox, 289 + oy)
                t11.Move(lay.ix + ox, 322 + oy)
                sldPriFade.Move(lay.dSldX + ox, 320 + oy, lay.dSldW, 24)
                txtPriFade.Move(lay.dPctX + ox, 322 + oy)
                priDiv2.Move(lay.ix + ox, 348 + oy)
                btnTestPri.Move(lay.ix + ox, 358 + oy)
                btnResetPri.Move(rstX + ox, 358 + oy)
            }
            DllCall("SendMessage", "Ptr", g.Hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
            DllCall("RedrawWindow", "Ptr", g.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0085)
            MarkSettingsDirty()
        }

        btnResetPri.OnEvent("Click", (*) => ( chkPriAuto.Value := 1,
            udSdrDesk.Value := 23,
            udSdrNorm.Value := 35,
            udSdrComp.Value := 45,
            udSdrPause.Value := 10,
            udHdrDesk.Value := 15,
            udHdrNorm.Value := 23,
            udHdrComp.Value := 23,
            udHdrPause.Value := 10,
            sldPriDark.Value := 100,
            txtPriDark.Text := "100%",
            chkPriSdrBlk.Value := 1,
            sldPriHdrDark.Value := 100,
            txtPriHdrDark.Text := "100%",
            chkPriHdrBlk.Value := 1,
            sldPriFade.Value := 350,
            txtPriFade.Text := "350 ms",
            SetControlsEnabled(allMainCtrls, true),
            swEntry := EnsureHdrSwitchEntry(swPriHdr, priIdx, priHdrInfo.supported, liveHdr, true),
            UpdateSdrHdrSwitchVisual(swPriHdr, priHdrInfo.supported, IsObject(swEntry) ? swEntry.enabled : liveHdr, true),
            SetControlsEnabled(autoOnlyMain, !!chkPriAuto.Value),
            MarkSettingsDirty()
        ))

        syncMainAutoState(*) {
            SetControlsEnabled(autoOnlyMain, !!chkPriAuto.Value)
            MarkSettingsDirty()
        }
        chkHdrSdr.OnEvent("Click", ApplyProfileLayout)
        chkPriAuto.OnEvent("Click", syncMainAutoState)

        ApplyProfileLayout()
        SetControlsEnabled(autoOnlyMain, !!Primary_Auto_Enabled)
        UpdateSdrHdrSwitchVisual(swPriHdr, priHdrInfo.supported, liveHdr, true)

        ; --------------------------------------------------------------------------
        ; OPTIONAL TABS: MONITOR 2, 3, 4, 5+ (IDENTICAL LAYOUT PER CONNECTED MONITOR)
        ; --------------------------------------------------------------------------
        extraMonTabCtrls := Map()
        for mIdx in extraIndices {
            extraMonTabCtrls[mIdx] := BuildExtraMonitorTab(g, tabs, extraTabMap[mIdx], mIdx, UI_Dark_Mode)
        }

        ; --------------------------------------------------------------------------
        ; TAB: OLED CARE
        ; --------------------------------------------------------------------------
        tabs.UseTab(careTabIdx)
        careSt := GetOledRefreshStatus()
        isCareAlert := (careSt.state >= 1)

        AddSectionBox(g, lay.bx, 46, lay.bw, 84, "Desktop Icons && Cursor  (0 = Disabled)", UI_Dark_Mode)
        chkDeskHide := g.AddCheckbox("x42 y68 w" lay.iw " Checked" Desktop_Hide_Enabled, "Hide cursor && fade desktop icons on idle")
        StyleControlTheme(chkDeskHide, UI_Dark_Mode)

        t21 := g.AddText("x42 y98 w110 +0x100", "Idle Delay (s)")
        StyleControlTheme(t21, UI_Dark_Mode)
        edtDeskIdle := g.AddEdit("x156 y95 w54 Number")
        StyleControlTheme(edtDeskIdle, UI_Dark_Mode)
        edtDeskIdle.OnEvent("Change", MarkSettingsDirty)
        udDesk := g.AddUpDown("Range0-3600", Desktop_Idle_Sec)
        RegisterTip(t21, "Idle delay (in seconds) before hiding the mouse cursor and fading out desktop icons.")
        RegisterTip(edtDeskIdle, "Idle delay (in seconds) before hiding the mouse cursor and fading out desktop icons.")

        deskHideDependentCtrls := [t21, edtDeskIdle, udDesk]
        syncDeskHideState := (markDirty := true) => (
            SetControlsEnabled(deskHideDependentCtrls, !!chkDeskHide.Value),
            (markDirty ? MarkSettingsDirty() : 0)
        )
        chkDeskHide.OnEvent("Click", (*) => syncDeskHideState(true))
        syncDeskHideState(false)

        boxCareRefresh := AddSectionBox(g, lay.bx, 138, lay.bw, 180, "Pixel Refresh", UI_Dark_Mode)
        tipPixelRefresh := "OLED screens slowly develop uneven wear. Most OLED monitors have a built-in 'Pixel Refresh' (or 'Panel Care') routine in their own on-screen menu that evens it out. This reminder tracks how long the screen has been on and NOT dimmed, and nudges you to run that routine once the interval below has passed."
        RegisterGroupTitleTip(boxCareRefresh, 110, tipPixelRefresh)
        txtCareSecBang := g.AddText("x" (lay.ir - 24) " y137 w24 +0x100", isCareAlert ? "!" : "")
        txtCareSecBang.SetFont("s11 bold cFF3B30", "Segoe UI")

        chkRefreshRem := g.AddCheckbox("x42 y160 w" (lay.iw - 158) " Checked" OLED_Refresh_Reminder_Enabled, "Remind me to run manual pixel refresh")
        StyleControlTheme(chkRefreshRem, UI_Dark_Mode)
        RegisterTip(chkRefreshRem, tipPixelRefresh)

        t14 := g.AddText("x42 y190 +0x100", "Interval")
        StyleControlTheme(t14, UI_Dark_Mode)
        RegisterTip(t14, "How much undimmed screen time (days / hours / minutes) must pass after a pixel refresh before you get reminded again.")

        edtRefreshDays := g.AddEdit("x96 y187 w46 Number")
        StyleControlTheme(edtRefreshDays, UI_Dark_Mode)
        edtRefreshDays.OnEvent("Change", MarkSettingsDirty)
        udRefD := g.AddUpDown("Range0-365", OLED_Refresh_Reminder_Days)
        tDayLbl := g.AddText("x146 y190 +0x100", "d")
        StyleControlTheme(tDayLbl, UI_Dark_Mode)

        edtRefreshHours := g.AddEdit("x164 y187 w46 Number")
        StyleControlTheme(edtRefreshHours, UI_Dark_Mode)
        edtRefreshHours.OnEvent("Change", MarkSettingsDirty)
        udRefH := g.AddUpDown("Range0-23", OLED_Refresh_Reminder_Hours)
        t15 := g.AddText("x214 y190 +0x100", "hr")
        StyleControlTheme(t15, UI_Dark_Mode)

        edtRefreshMins := g.AddEdit("x236 y187 w46 Number")
        StyleControlTheme(edtRefreshMins, UI_Dark_Mode)
        edtRefreshMins.OnEvent("Change", MarkSettingsDirty)
        udRefM := g.AddUpDown("Range0-59", OLED_Refresh_Reminder_Minutes)
        t16 := g.AddText("x286 y190 +0x100", "min")
        StyleControlTheme(t16, UI_Dark_Mode)

        tAlertStyle := g.AddText("x42 y220 +0x100", "Alert Style")
        StyleControlTheme(tAlertStyle, UI_Dark_Mode)
        RegisterTip(tAlertStyle, "Popup: a small window on the chosen monitor. Notification: a Windows tray notification. While you are in a game or fullscreen app the reminder waits until you leave it.")
        ddlAlertStyle := g.AddDropDownList("x126 y216 w" (lay.c2x - 16 - 126), ["Popup", "Notification"])
        ddlAlertStyle.Text := (OLED_Refresh_Alert_Style = "Notification") ? "Notification" : "Popup"
        StyleControlTheme(ddlAlertStyle, UI_Dark_Mode)

        tPopupSound := g.AddText("x" lay.c2x " y220 +0x100", "Popup Sound")
        StyleControlTheme(tPopupSound, UI_Dark_Mode)
        ddlPopupSound := g.AddDropDownList("x" (lay.c2x + 90) " y216 w" (lay.ir - lay.c2x - 90), GetSoundChoices())
        ddlPopupSound.Text := NormalizeSoundName(OLED_Refresh_Popup_Sound)
        StyleControlTheme(ddlPopupSound, UI_Dark_Mode)
        ddlPopupSound.OnEvent("Change", (*) => (PlaySoundByName(ddlPopupSound.Text), MarkSettingsDirty()))
        RegisterTip(ddlPopupSound, "Sound played when the Popup reminder appears. Pick one to hear it right away.")

    tPopupMon := g.AddText("x42 y250 +0x100", "Popup Monitor")
        StyleControlTheme(tPopupMon, UI_Dark_Mode)
        connectedCount := GetDetectedMonitorCount()
        monChoices := []
        Loop connectedCount {
            mIdx := A_Index
            mainTag := (mIdx = priIdx) ? " [Main]" : ""
            monChoices.Push("Monitor " mIdx mainTag " (" GetFriendlyMonitorName(mIdx) ")")
        }
        defaultPopupMon := (OLED_Refresh_Popup_Monitor >= 1 && OLED_Refresh_Popup_Monitor <= connectedCount)
            ? OLED_Refresh_Popup_Monitor
            : priIdx
        ddlPopupMon := g.AddDropDownList("x136 y246 w" (lay.ir - 136) " Choose" defaultPopupMon, monChoices)
        StyleControlTheme(ddlPopupMon, UI_Dark_Mode)
        RegisterTip(ddlPopupMon, "Select which connected monitor displays the Pixel Refresh popup (defaults to the main monitor).")
        ddlPopupMon.OnEvent("Change", MarkSettingsDirty)

        btnTestPopupSound := g.AddButton("x42 y280 w122 h24", "Test Popup")
        StyleControlTheme(btnTestPopupSound, UI_Dark_Mode)
        RegisterTip(btnTestPopupSound, "Shows the reminder popup right now so you can see how it looks and sounds.")
        btnTestPopupSound.OnEvent("Click", (*) => (
            OLED_Refresh_Popup_Monitor := ddlPopupMon.Value,
            OLED_Refresh_Popup_Sound := ddlPopupSound.Text,
            CloseRefreshPromptGui(),
            ShowRefreshReminderPopup()
        ))

        txtOledHours := g.AddText("x174 y284 w" (lay.ir - 174 - 8 - 190) " +0x100", "Active time since refresh: " FormatDuration(oledActiveMsSinceRefresh))
        StyleControlTheme(txtOledHours, UI_Dark_Mode, true)
        RegisterTip(txtOledHours, "Time Monitor 1 has been on and undimmed since the last pixel refresh. Dimmed or blacked-out time does not count.")

        btnLogRefresh := g.AddButton("x" (lay.ir - 190) " y278 w190 h28", isCareAlert ? "[!] Mark Pixel Refreshed" : "Mark Pixel Refreshed")
        StyleControlTheme(btnLogRefresh, UI_Dark_Mode)
        if isCareAlert {
            btnLogRefresh.SetFont("s9.5 bold cFF3B30", "Segoe UI")
        }
        RegisterTip(btnLogRefresh, "Click this AFTER you have run the pixel refresh from your monitor's own menu. It sets the active-time counter back to zero and clears the reminder. It does not start a refresh itself.")
        txtBtnCareBang := g.AddText("x" (lay.ir - 154) " y164 w150 +0x100 +0x2", isCareAlert ? "! Pixel refresh is due" : "")
        txtBtnCareBang.SetFont("s9.5 bold cFF3B30", "Segoe UI")

        CareUiRefs := Map(
            "box", boxCareRefresh,
            "secBang", txtCareSecBang,
            "btn", btnLogRefresh,
            "btnBang", txtBtnCareBang,
            "hoursTxt", txtOledHours
        )

        btnLogRefresh.OnEvent("Click", (*) => (
            MarkPixelRefreshed(),
            txtOledHours.Text := "Active time since refresh: 0m 0s"
        ))

        refreshDependentCtrls := [
            t14, edtRefreshDays, udRefD, tDayLbl, edtRefreshHours, udRefH, t15, edtRefreshMins, udRefM, t16,
            tAlertStyle, ddlAlertStyle, tPopupSound, ddlPopupSound, tPopupMon, ddlPopupMon,
            btnTestPopupSound, txtOledHours, btnLogRefresh
        ]
        popupOnlyCtrls := [tPopupSound, ddlPopupSound, tPopupMon, ddlPopupMon, btnTestPopupSound]

        syncRefreshRemState := (markDirty := true) => (
            remOn := !!chkRefreshRem.Value,
            SetControlsEnabled(refreshDependentCtrls, remOn),
            (remOn ? SetControlsEnabled(popupOnlyCtrls, ddlAlertStyle.Text = "Popup") : 0),
            (markDirty ? MarkSettingsDirty() : 0)
        )

        chkRefreshRem.OnEvent("Click", (*) => syncRefreshRemState(true))
        ddlAlertStyle.OnEvent("Change", (*) => syncRefreshRemState(true))
        syncRefreshRemState(false)

        ; Turn displays off after a long idle (all monitors, one, or several) - its own section under Pixel Refresh
        boxLongIdle := AddSectionBox(g, lay.bx, 326, lay.bw, 92, "Display Off After Long Idle", UI_Dark_Mode)
        RegisterGroupTitleTip(boxLongIdle, 210, "Turns your screens completely off after a long time without input, so an OLED can rest and run its own care cycle.")
        BuildLongIdleCareRows(g, UI_Dark_Mode, 350, 382)

        AddSectionBox(g, lay.bx, 426, lay.bw, 144, "Sound Alerts", UI_Dark_Mode)
        dimRow  := AddSoundRow(g, 448, "Sound on Dim / Blackout", Dim_Sound_Enabled, Dim_Sound_Name)
        wakeRow := AddSoundRow(g, 482, "Sound on Wake", Wake_Sound_Enabled, Wake_Sound_Name)
        chkDimSound  := dimRow.chk
        ddlDimSound  := dimRow.ddl
        chkWakeSound := wakeRow.chk
        ddlWakeSound := wakeRow.ddl

        sndSldX := lay.ix + 202
        sndBtnX := lay.ir - 84
        tSoundVol  := g.AddText("x42 y522 w" (sndSldX - 42 - 4) " +0x100", "Notification Volume")
        sldSoundVol := g.AddSlider("x" sndSldX " y519 w" (sndBtnX - 6 - sndSldX) " NoTicks +AltSubmit Range0-3 TickInterval1 Page1", Sound_Volume_Step)
        txtSoundVol := g.AddText("x" sndBtnX " y522 w84 +0x100", (Max(0, Min(3, Integer(Sound_Volume_Step))) + 1) " / 4")
        for c in [tSoundVol, sldSoundVol, txtSoundVol] {
            StyleControlTheme(c, UI_Dark_Mode)
        }
        RegisterTip(sldSoundVol, "4-click volume level (1 to 4) for popup, dim, and wake sounds.")
        sldSoundVol.OnEvent("Change", (*) => (
            txtSoundVol.Text := (Max(0, Min(3, Integer(sldSoundVol.Value))) + 1) " / 4",
            sldSoundVol.Redraw(),
            MarkSettingsDirty()
        ))

        AddSectionBox(g, lay.bx, 576, lay.bw, 56, "Taskbar Auto-Hide (OLED Burn-In Protection)", UI_Dark_Mode)
        chkCareTbar := g.AddCheckbox("x42 y600 w" lay.iw " Checked" Taskbar_AutoHide_Enabled, "Automatically hide the taskbar in Windows")
        StyleControlTheme(chkCareTbar, UI_Dark_Mode)
        RegisterTip(chkCareTbar, "Enables or disables Windows' built-in 'Automatically hide the taskbar' setting when you click Apply or Save & Close.")
        chkCareTbar.OnEvent("Click", MarkSettingsDirty)

        ; --------------------------------------------------------------------------
        ; TAB: ICONS, MENU & GAMES (WITH NEVER-DIM EXCLUDED PROCESSES)
        ; --------------------------------------------------------------------------
        tabs.UseTab(iconsTabIdx)

        AddSectionBox(g, lay.bx, 44, lay.bw, 62, "Theme", UI_Dark_Mode)
        chkDarkMode := g.AddCheckbox("x42 y68 w130 Checked" UI_Dark_Mode, "Dark Mode")
        StyleControlTheme(chkDarkMode, UI_Dark_Mode)
        chkDarkMode.OnEvent("Click", (*) => ToggleDarkModeLive(chkDarkMode.Value))
        btnCustomColor := g.AddButton("x178 y65 w104 h26", "Custom Color...")
        btnEyedropper  := g.AddButton("x286 y65 w88 h26", "Eyedropper")
        btnResetColor  := g.AddButton("x378 y65 w52 h26", "Reset")
        txtColorVal    := g.AddText("x438 y69 w" (lay.ir - 438) " +0x100", (UI_Custom_Color != "") ? ("#" UI_Custom_Color) : "Default theme")
        StyleControlTheme(btnCustomColor, UI_Dark_Mode)
        StyleControlTheme(btnEyedropper, UI_Dark_Mode)
        StyleControlTheme(btnResetColor, UI_Dark_Mode)
        StyleControlTheme(txtColorVal, UI_Dark_Mode, true)
        btnCustomColor.OnEvent("Click", (*) => PickCustomUiColor())
        btnEyedropper.OnEvent("Click", (*) => StartColorEyedropper())
        btnResetColor.OnEvent("Click", (*) => ApplyCustomUiColor(""))
        RegisterTip(btnCustomColor, "Opens the Windows color picker. Your color becomes the background of the Settings window and pop-ups.")
        RegisterTip(btnEyedropper, "Sample any pixel color anywhere on your screen. Left-click to pick, Right-click or Esc to cancel.")
        RegisterTip(btnResetColor, "Goes back to the plain Dark or Light theme.")
        RegisterTip(txtColorVal, "The color currently used for the menu and Settings UI.")

        AddSectionBox(g, lay.bx, 112, lay.bw, 56, "Startup", UI_Dark_Mode)
        stW1 := Round(lay.iw * 0.34)
        stW2 := Round(lay.iw * 0.30)
        stW3 := lay.iw - stW1 - stW2
        chkStartWin := g.AddCheckbox("x" lay.ix " y136 w" stW1 " Checked" (Start_With_Windows || IsStartupRegistryEnabled()), "Start with Windows")
        StyleControlTheme(chkStartWin, UI_Dark_Mode)
        RegisterTip(chkStartWin, "Automatically runs OLED Engine when you sign in to Windows.")
        chkStartWin.OnEvent("Click", MarkSettingsDirty)

        chkStartMin := g.AddCheckbox("x" (lay.ix + stW1) " y136 w" stW2 " Checked" Start_Minimized, "Start minimized")
        StyleControlTheme(chkStartMin, UI_Dark_Mode)
        RegisterTip(chkStartMin, "Starts silently in the system tray without opening the Settings window on launch.")
        chkStartMin.OnEvent("Click", MarkSettingsDirty)

        chkRunAdmin := g.AddCheckbox("x" (lay.ix + stW1 + stW2) " y136 w" stW3 " Checked" Run_As_Admin, "Run as administrator")
        StyleControlTheme(chkRunAdmin, UI_Dark_Mode)
        RegisterTip(chkRunAdmin, "Starts OLED Engine with administrator rights (Windows asks for permission at each start). Needed only if it must control windows of apps that run as administrator.")
        chkRunAdmin.OnEvent("Click", OnRunAdminToggle)

        AddSectionBox(g, lay.bx, 174, lay.bw, 144, "Tray Menu Items", UI_Dark_Mode)
        lvColors := (UI_Dark_Mode ? "cFFFFFF" : "c000000") " Background" Format("{:06X}", ThemeSurfaceRgb)
        trayBtnX := lay.ir - 110
        lvTray := g.AddListView("x42 y196 w" (trayBtnX - 10 - 42) " h112 -Multi NoSortHdr Grid " lvColors, ["State", "Tray Item"])
        StyleControlTheme(lvTray, UI_Dark_Mode)

        btnTrayUp     := g.AddButton("x" trayBtnX " y196 w110 h25", "Move Up")
        btnTrayDown   := g.AddButton("x" trayBtnX " y224 w110 h25", "Move Down")
        btnTrayToggle := g.AddButton("x" trayBtnX " y252 w110 h25", "Keep / Hide")
        btnTrayReset  := g.AddButton("x" trayBtnX " y282 w110 h25", "Reset Order")
        StyleControlTheme(btnTrayUp, UI_Dark_Mode)
        StyleControlTheme(btnTrayDown, UI_Dark_Mode)
        StyleControlTheme(btnTrayToggle, UI_Dark_Mode)
        StyleControlTheme(btnTrayReset, UI_Dark_Mode)

        draftTrayItems := CloneTrayItems(TrayMenuItems)
        refreshTrayListView := (selectRow := 1) => (
            lvTray.Delete(),
            PopulateTrayListView(lvTray, draftTrayItems),
            StyleControlTheme(lvTray, UI_Dark_Mode),
            lvTray.Modify(Max(1, Min(draftTrayItems.Length, selectRow)), "Select Focus")
        )
        refreshTrayListView(1)

        trayListViewCtrl := lvTray
        trayDraftRef     := draftTrayItems
        trayRefreshFn    := refreshTrayListView

        lvTray.OnNotify(-108, OnLvBeginDrag)
        lvTray.OnNotify(-12, OnLvCustomDraw)

        btnTrayUp.OnEvent("Click", (*) => (
            row := lvTray.GetNext(0, "Focused"),
            (row < 1) ? row := lvTray.GetNext(0) : 0,
            (row >= 2 && row <= draftTrayItems.Length) ? (
                moved := draftTrayItems.RemoveAt(row),
                draftTrayItems.InsertAt(row - 1, moved),
                refreshTrayListView(row - 1),
                MarkSettingsDirty()
            ) : 0
        ))
        btnTrayDown.OnEvent("Click", (*) => (
            row := lvTray.GetNext(0, "Focused"),
            (row < 1) ? row := lvTray.GetNext(0) : 0,
            (row >= 1 && row < draftTrayItems.Length) ? (
                moved := draftTrayItems.RemoveAt(row),
                draftTrayItems.InsertAt(row + 1, moved),
                refreshTrayListView(row + 1),
                MarkSettingsDirty()
            ) : 0
        ))
        btnTrayToggle.OnEvent("Click", (*) => (
            row := lvTray.GetNext(0, "Focused"),
            (row < 1) ? row := lvTray.GetNext(0) : 0,
            (row >= 1 && row <= draftTrayItems.Length) ? (
                draftTrayItems[row].enabled := !draftTrayItems[row].enabled,
                refreshTrayListView(row),
                MarkSettingsDirty()
            ) : 0
        ))
        btnTrayReset.OnEvent("Click", (*) => (
            draftTrayItems := GetDefaultTrayItems(),
            trayDraftRef := draftTrayItems,
            refreshTrayListView(1),
            MarkSettingsDirty()
        ))

        AddSectionBox(g, lay.bx, 324, lay.bw, 86, "Competitive Games (.exe)", UI_Dark_Mode)
        edtCompGames := g.AddEdit("x42 y346 w" lay.iw " h54 Multi", Comp_Games_List)
        StyleControlTheme(edtCompGames, UI_Dark_Mode)
        RegisterTip(edtCompGames, "Comma-separated executable names treated as Competitive Games for longer idle timers and automatic SDR switching.")
        edtCompGames.OnEvent("Change", MarkSettingsDirty)

        AddSectionBox(g, lay.bx, 540, lay.bw, 62, "Never Dim While Running (.exe)", UI_Dark_Mode)
        edtExcludedProcs := g.AddEdit("x42 y562 w" lay.iw " h32 Multi", Excluded_Processes_List)
        StyleControlTheme(edtExcludedProcs, UI_Dark_Mode)
        RegisterTip(edtExcludedProcs, "Comma-separated .exe names (e.g. obs64.exe, Zoom.exe). Automatic dimming/blackout pauses while any listed process is running.")
        edtExcludedProcs.OnEvent("Change", MarkSettingsDirty)

        boxMediaBrowsers := AddSectionBox(g, lay.bx, 416, lay.bw, 118, "Video Players && Browsers (.exe)", UI_Dark_Mode)
        tipMediaBrowsers := "Tells OLED Engine which apps count as 'watching a video', so the screen isn't dimmed while you watch.`n`n"
            . "Players: when one of these is the active window, OLED Engine checks whether it is playing. Playing = no dimming; paused = your 'Paused' idle delay is used.`n"
            . "Browsers: for streaming in a tab (YouTube, Netflix...). Playing media counts as a movie; paused while fullscreen or maximized uses the 'Paused' delay.`n`n"
            . "Add the .exe name of any player or browser that is missing. Leave a box blank to use the built-in list."
        RegisterGroupTitleTip(boxMediaBrowsers, 250, tipMediaBrowsers)
        tMediaLbl := g.AddText("x42 y442 w70 +0x100", "Players")
        edtMediaPlayers := g.AddEdit("x116 y438 w" (lay.iw - 74) " h56 Multi", GetMediaPlayersListText())
        tBrowserLbl := g.AddText("x42 y504 w70 +0x100", "Browsers")
        edtBrowsers := g.AddEdit("x116 y500 w" (lay.iw - 74) " h30 Multi", GetBrowsersListText())
        for c in [tMediaLbl, edtMediaPlayers, tBrowserLbl, edtBrowsers] {
            StyleControlTheme(c, UI_Dark_Mode)
        }
        RegisterTip(edtMediaPlayers, "Comma-separated .exe names recognized as video players (used for the paused-movie timer). Leave blank to use the built-in list.")
        RegisterTip(edtBrowsers, "Comma-separated .exe names recognized as browsers (used for fullscreen video detection). Leave blank to use the built-in list.")
        edtMediaPlayers.OnEvent("Change", MarkSettingsDirty)
        edtBrowsers.OnEvent("Change", MarkSettingsDirty)

        tBackupLbl := g.AddText("x42 y613 w120 +0x100", "Settings Backup")
        btnOpenCfg    := g.AddButton("x170 y608 w140 h26", "Open Config Folder")
        btnBackupNow  := g.AddButton("x316 y608 w110 h26", "Back Up Now")
        btnRestoreBak := g.AddButton("x432 y608 w130 h26", "Restore Backup...")
        StyleControlTheme(tBackupLbl, UI_Dark_Mode, true)
        StyleControlTheme(btnOpenCfg, UI_Dark_Mode)
        StyleControlTheme(btnBackupNow, UI_Dark_Mode)
        StyleControlTheme(btnRestoreBak, UI_Dark_Mode)
        RegisterTip(btnOpenCfg, "Opens the folder that holds your settings files.")
        RegisterTip(btnBackupNow, "Saves a dated copy of your last saved settings (and this script) into the 'backups' folder next to the script. Click Apply first to include pending changes.")
        RegisterTip(btnRestoreBak, "Pick a backup folder to restore. A safety copy of your current settings is made first, then OLED Engine reloads.")
        btnOpenCfg.OnEvent("Click", (*) => OpenSettingsFolder())
        btnBackupNow.OnEvent("Click", (*) => BackupSettingsNow())
        btnRestoreBak.OnEvent("Click", (*) => RestoreSettingsBackup())

        ; --------------------------------------------------------------------------
        ; TAB: STATS (WITH DEBUG TELEMETRY, LOG PATH & OPEN LOG BUTTON)
        ; --------------------------------------------------------------------------
        tabs.UseTab(statsTabIdx)
        boxStPri := AddSectionBox(g, lay.bx, 46, lay.bw, 150, "Monitor 1 Stats", UI_Dark_Mode)
        RegisterGroupTitleTip(boxStPri, 150, priInfo)
        txtStPri1 := g.AddText("x42 y68 w" lay.iw " +0x100", "Dimmed / Blackout: " FormatDuration(primaryDimmedMs) "  |  Active: " FormatDuration(primaryUndimmedMs))
        txtStPri2 := g.AddText("x42 y92 w" lay.iw " +0x100", "Dim / Blackout Triggers: " primaryDimBlackoutTriggers "  |  Wakes: " primaryWakeCount)
        txtStPri3 := g.AddText("x42 y116 w" lay.iw " +0x100", "Active time since refresh: " FormatDuration(oledActiveMsSinceRefresh))
        txtStPri4 := g.AddText("x42 y140 w" lay.iw " +0x100", "Session uptime: " FormatDuration(A_TickCount - scriptStartTick))
        btnResetStPri := g.AddButton("x" (lay.ir - 126) " y160 w126 h26", "Reset Monitor 1")
        StyleControlTheme(txtStPri1, UI_Dark_Mode)
        StyleControlTheme(txtStPri2, UI_Dark_Mode)
        StyleControlTheme(txtStPri3, UI_Dark_Mode, true)
        StyleControlTheme(txtStPri4, UI_Dark_Mode, true)
        StyleControlTheme(btnResetStPri, UI_Dark_Mode)
        RegisterTip(btnResetStPri, "Resets Monitor 1 dimmed/active time, triggers, wakes, and active time since pixel refresh.")

        extraStatTitle := (monCount <= 1) ? "Additional Monitors Stats" : ((monCount = 2) ? "Monitor 2 Stats" : "Monitors 2–" monCount " Stats")
        extraResetLabel := (monCount <= 2) ? "Reset Monitor 2" : "Reset Monitors 2–" monCount
        extraTipForStats := (extraSummary != "") ? extraSummary : "No additional monitors connected"
        boxStSec := AddSectionBox(g, lay.bx, 202, lay.bw, 118, extraStatTitle, UI_Dark_Mode)
        RegisterGroupTitleTip(boxStSec, 195, extraTipForStats)
        txtStSec1 := g.AddText("x42 y224 w" lay.iw " +0x100", (monCount <= 1) ? "No additional monitors connected" : ("Dimmed / Blackout: " FormatDuration(secondaryDimmedMs) "  |  Active: " FormatDuration(secondaryUndimmedMs)))
        txtStSec2 := g.AddText("x42 y248 w" lay.iw " +0x100", "Dim / Blackout Triggers: " secondaryDimBlackoutTriggers "  |  Wakes: " secondaryWakeCount)
        btnResetStSec := g.AddButton("x" (lay.ir - 126) " y284 w126 h26", extraResetLabel)
        StyleControlTheme(txtStSec1, UI_Dark_Mode)
        StyleControlTheme(txtStSec2, UI_Dark_Mode, true)
        StyleControlTheme(btnResetStSec, UI_Dark_Mode)
        RegisterTip(btnResetStSec, (monCount <= 2) ? "Resets Monitor 2 dimmed/active time, triggers, and wakes." : "Resets Monitors 2–" monCount " dimmed/active time, triggers, and wakes.")

        boxDbg := AddSectionBox(g, lay.bx, 326, lay.bw, 120, "Debug Telemetry Log", UI_Dark_Mode)
        chkDebugLog := g.AddCheckbox("x42 y348 w276 Checked" Debug_Log_Enabled, "Write debug telemetry log")
        StyleControlTheme(chkDebugLog, UI_Dark_Mode)
        RegisterTip(chkDebugLog, "Appends state, display mode, session lock, and dim/wake events to the configured log file.")
        chkDebugLog.OnEvent("Click", MarkSettingsDirty)

        btnOpenDbgLog := g.AddButton("x" (lay.ir - 114) " y345 w114 h26", "Open Log")
        StyleControlTheme(btnOpenDbgLog, UI_Dark_Mode)
        RegisterTip(btnOpenDbgLog, "Opens the debug log file in your default text editor.")
        btnOpenDbgLog.OnEvent("Click", (*) => OpenDebugLogFile(edtDbgLogPath.Value))

        lblDbgPath := g.AddText("x42 y386 w72 h20 +0x100", "Save To")
        edtDbgLogPath := g.AddEdit("x116 y382 w" (lay.ir - 72 - 6 - 116) " h26 -Multi", GetEffectiveDebugLogPath())
        btnBrowseDbgLog := g.AddButton("x" (lay.ir - 72) " y382 w72 h26", "Browse...")
        StyleControlTheme(lblDbgPath, UI_Dark_Mode)
        StyleControlTheme(edtDbgLogPath, UI_Dark_Mode)
        StyleControlTheme(btnBrowseDbgLog, UI_Dark_Mode)
        RegisterTip(edtDbgLogPath, "Path where debug telemetry entries are written (leave blank or use default to write next to the script).")
        RegisterTip(btnBrowseDbgLog, "Choose where to save the debug telemetry log file.")
        edtDbgLogPath.OnEvent("Change", MarkSettingsDirty)
        btnBrowseDbgLog.OnEvent("Click", (*) => BrowseDebugLogPath(edtDbgLogPath))

        txtDbgHint := g.AddText("x42 y414 w" lay.iw " h20 +0x100", "Default: logs\debug.log")
        StyleControlTheme(txtDbgHint, UI_Dark_Mode, true)

        btnStRefresh  := g.AddButton("x28 y454 w110 h28", "Refresh")
        btnStResetAll := g.AddButton("x+10 yp w126 h28", "Reset All Stats")
        StyleControlTheme(btnStRefresh, UI_Dark_Mode)
        StyleControlTheme(btnStResetAll, UI_Dark_Mode)
        RegisterTip(btnStResetAll, "Resets all saved statistics and pixel refresh timer for all monitors.")

        refreshStatsTabLabels := (*) => (
            txtStPri1.Text := "Dimmed / Blackout: " FormatDuration(primaryDimmedMs) "  |  Active: " FormatDuration(primaryUndimmedMs),
            txtStPri2.Text := "Dim / Blackout Triggers: " primaryDimBlackoutTriggers "  |  Wakes: " primaryWakeCount,
            txtStPri3.Text := "Active time since refresh: " FormatDuration(oledActiveMsSinceRefresh),
            txtStPri4.Text := "Session uptime: " FormatDuration(A_TickCount - scriptStartTick),
            txtStSec1.Text := (monCount <= 1) ? "No additional monitors connected" : ("Dimmed / Blackout: " FormatDuration(secondaryDimmedMs) "  |  Active: " FormatDuration(secondaryUndimmedMs)),
            txtStSec2.Text := "Dim / Blackout Triggers: " secondaryDimBlackoutTriggers "  |  Wakes: " secondaryWakeCount
        )

        btnStRefresh.OnEvent("Click", refreshStatsTabLabels)
        btnResetStPri.OnEvent("Click", (*) => (
            ResetMonitor1Stats(),
            refreshStatsTabLabels()
        ))
        btnResetStSec.OnEvent("Click", (*) => (
            ResetMonitor2PlusStats(),
            refreshStatsTabLabels()
        ))
        btnStResetAll.OnEvent("Click", (*) => (
            ResetAllCareAndStats(),
            refreshStatsTabLabels()
        ))

        ; --------------------------------------------------------------------------
        ; TAB: HOTKEYS
        ; --------------------------------------------------------------------------
        tabs.UseTab(hotkeysTabIdx)
        hkControlsMap := Map()
        hkY := 46
        hkW := Min(300, lay.ir - 66 - 8 - 192)     ; hotkey box; the Clear button sits right after it

        Loop monCount {
            mIdx := A_Index
            roleLabel := (mIdx = priIdx) ? "Monitor " mIdx " (Primary)" : "Monitor " mIdx
            monDimPct := (mIdx = priIdx) ? Primary_Dim_Percent : GetEffectiveExtraMonDimPercent(mIdx)
            modeDesc  := (monDimPct = 100) ? "Blackout (100%)" : ("Dim (" monDimPct "%)")

            boxHk := AddSectionBox(g, lay.bx, hkY, lay.bw, 62, roleLabel " — " modeDesc, UI_Dark_Mode)
            RegisterGroupTitleTip(boxHk, 260, GetMonitorHoverInfo(mIdx))

            lblHk := g.AddText("x42 y" (hkY + 28) " w144 +0x100", "Toggle Dim / Blackout")
            hkCtrl := g.AddHotkey("x192 y" (hkY + 25) " w" hkW, GetMonitorHotkeyVar(mIdx))
            btnClr := g.AddButton("x" (192 + hkW + 8) " y" (hkY + 24) " w66 h24", "Clear")

            StyleControlTheme(lblHk, UI_Dark_Mode)
            StyleControlTheme(hkCtrl, UI_Dark_Mode)
            StyleControlTheme(btnClr, UI_Dark_Mode)

            hkTip := "Press a key or shortcut to toggle Dim / Blackout on Monitor " mIdx " using its configured Dim Level slider."
            RegisterTip(lblHk, hkTip)
            RegisterTip(hkCtrl, hkTip)

            hkCtrl.OnEvent("Change", MarkSettingsDirty)
            btnClr.OnEvent("Click", MakeClearHotkeyCallback(hkCtrl))

            hkControlsMap[mIdx] := hkCtrl
            hkY += 70
        }

        btnResetHk := g.AddButton("x28 y" (hkY + 6) " w116 h26", "Reset Defaults")
        StyleControlTheme(btnResetHk, UI_Dark_Mode)
        btnResetHk.OnEvent("Click", (*) => (
            ResetHotkeyControlsToDefault(hkControlsMap),
            MarkSettingsDirty()
        ))

        tabs.UseTab(presetsTabIdx)
        BuildPresetsTab(g, UI_Dark_Mode, presetsTabIdx)

        preAutoHwnds := Map()
        for preAutoCtl in g {
            preAutoHwnds[preAutoCtl.Hwnd] := 1
        }
        InitGameAutomation(g, tabs, "Automation")
        ReflowForeignTabControls(g, preAutoHwnds)

        ; --------------------------------------------------------------------------
        ; TAB: HELP / ABOUT
        ; --------------------------------------------------------------------------
        ; Give every tab except Help / About a little more room under the tab strip.
        for padCtl in g {
            if (padCtl.Hwnd = tabs.Hwnd) {
                continue
            }
            try {
                padCtl.GetPos(, &padY)
                padCtl.Move(, padY + 10)
            }
        }

        tabs.UseTab(aboutTabIdx)

        ; Every height on this tab is measured from the real text (AddText without an h), so a line can
        ; never be cut off, whatever the DPI or font size. Sections stack from aboutY downward.
        aboutY := 54
        boxAbout := AddSectionBox(g, lay.bx, aboutY, lay.bw, 110, "About", UI_Dark_Mode)
        txtAboutTitle := g.AddText("x" lay.ix " y" (aboutY + 24) " w" (lay.iw - 340) " h26 +0x100", "Version " APP_VERSION)
        txtAboutTitle.SetFont("s10.5 bold " (UI_Dark_Mode ? "cFFFFFF" : "c000000"), "Segoe UI")
        btnCheckUpd := g.AddButton("x" (lay.ix + lay.iw - 160) " y" (aboutY + 22) " w160 h28", "Check for Updates")
        StyleControlTheme(btnCheckUpd, UI_Dark_Mode)
        RegisterTip(btnCheckUpd, "Looks for a newer OLED Engine on GitHub. Your settings are kept.")
        btnCheckUpd.OnEvent("Click", (*) => CheckForUpdates(false))
        chkAutoUpd := g.AddCheckbox("x" (lay.ix + lay.iw - 160 - 156) " y" (aboutY + 26) " w150 Checked" (IniRead(IniPath, "Updates", "AutoCheck", "0") = "1"), "Check at startup")
        StyleControlTheme(chkAutoUpd, UI_Dark_Mode)
        RegisterTip(chkAutoUpd, "Quietly checks GitHub for a newer version about 30 seconds after OLED Engine starts, and shows a tray notice if one exists. Saved instantly.")
        chkAutoUpd.OnEvent("Click", (ctl, *) => IniWrite(ctl.Value ? 1 : 0, IniPath, "Updates", "AutoCheck"))
        txtUpdStatus := g.AddText("x" (lay.ix + lay.iw - 330) " y" (aboutY + 54) " w330 h20 +Right", "")
        StyleControlTheme(txtUpdStatus, UI_Dark_Mode, true)
        SetUpdateStatusCtrl(txtUpdStatus)

        txtAboutAuthor := g.AddText("x" lay.ix " y" (aboutY + 50) " w" (lay.iw - 340) " h24 +0x100", "Created by dxrksin")
        StyleControlTheme(txtAboutAuthor, UI_Dark_Mode)
        txtAboutAuthor.SetFont("s9.5 bold " (UI_Dark_Mode ? "c6EE7B7" : "c1D4ED8"), "Segoe UI")

        txtAboutDesc := g.AddText("x" lay.ix " y" (aboutY + 78) " w" lay.iw " +0x100", "Multi-monitor OLED burn-in protection, per-category idle dimming and #000000 blackout, HDR/SDR profile switching, pixel refresh tracking, and game automation.")
        StyleControlTheme(txtAboutDesc, UI_Dark_Mode, true)
        txtAboutDesc.GetPos(, , , &aboutDescH)
        aboutBoxH := 78 + aboutDescH + 14
        boxAbout.Move(, , , aboutBoxH)
        aboutY += aboutBoxH + 8

        logEditH := 118
        boxLog := AddSectionBox(g, lay.bx, aboutY, lay.bw, 24 + logEditH + 14, "What's New (v" APP_VERSION ")", UI_Dark_Mode)
        changelogEntries := [
            ["Display Off After Long Idle, Per Monitor", "Now its own section in OLED Care, under Pixel Refresh. Set the minutes, then turn off all screens, one, or several. Picking only some uses the monitor's DDC/CI link and wakes them on your first key or mouse move. Hover any control for an explanation, and use Test to check it."],
            ["Mark Pixel Refreshed Placement", "The button now sits to the right of the running active-time counter, and the due notice moved up beside the reminder checkbox."],
            ["Presets Status Fix", "The Active right now line keeps updating and now explains why the selected preset is not active yet."],
            ["Help / About Version Label", "Removed the duplicate version label at the top; the version at the bottom stays on every tab."],
            ["Live Status per Monitor", "Each Monitor tab now has a Live Status box showing what OLED Engine detects right now (desktop, video, game), the idle delay that applies, and whether the monitor is active, dimmed or paused."],
            ["Version & Changelog Sync", "App version updated to v1.0.1 with full release notes."],
            ["Secondary Display Dim Fix", "Prevented false wake triggers so Monitor 2+ stays dimmed in both auto and manual modes."],
            ["Eyedropper Inside Color Picker", "Added a live screen Eyedropper button right inside the Custom Color dialog with an eyedropper cursor and cursor-following hex tooltip."],
            ["G-Sync Status Clarity", "Keeps live G-Sync status visible when automation is disabled, with a G-Sync control ON/OFF indicator underneath."],
            ["Layout & Reset Stability", "Fixed section shifting on Reset Defaults and eliminated Help/About text overlap and GUI flicker."]
        ]
        edtChangelog := AddChangelogRichEdit(g, lay.ix, aboutY + 24, lay.iw, logEditH, changelogEntries, UI_Dark_Mode)
        aboutY += 24 + logEditH + 14 + 8

        helpLines := [
            "• 0 = Disabled: Set any idle delay (s) or dim level (%) to 0 to turn off automatic dimming for that category.",
            "• Monitors 2–5 Support: Configure up to 5 displays independently; moving the cursor or clicking wakes only that display.",
            "• Hotkeys: No hotkeys are set by default. Record one per monitor in the Hotkeys tab to toggle its dim / blackout.",
            "• Instant Reload: Press Ctrl+Alt+R anytime to reload OLED Engine.ahk immediately."
        ]
        aboutLater := []
        boxHelp := AddSectionBox(g, lay.bx, aboutY, lay.bw, 100, "Quick Help && Controls", UI_Dark_Mode)
        aboutLater.Push(boxHelp)
        helpY := aboutY + 24
        for helpLine in helpLines {
            helpCtl := g.AddText("x" lay.ix " y" helpY " w" lay.iw " +0x100", helpLine)
            StyleControlTheme(helpCtl, UI_Dark_Mode)
            helpCtl.GetPos(, , , &helpLineH)
            aboutLater.Push(helpCtl)
            helpY += helpLineH + 8
        }
        helpBoxH := helpY - aboutY + 4
        boxHelp.Move(, , , helpBoxH)
        aboutY += helpBoxH + 8

        boxCrash := AddSectionBox(g, lay.bx, aboutY, lay.bw, 100, "Silent Crash && State Diagnostics", UI_Dark_Mode)
        aboutLater.Push(boxCrash)
        txtErrInfo := g.AddText("x" lay.ix " y" (aboutY + 24) " w" lay.iw " +0x100", "Unexpected errors are captured quietly in logs\errors.log alongside the last " RING_LOG_MAX " RAM RingLog events without interrupting popups.")
        StyleControlTheme(txtErrInfo, UI_Dark_Mode, true)
        txtErrInfo.GetPos(, , , &errInfoH)
        aboutLater.Push(txtErrInfo)

        crashBtnY := aboutY + 24 + errInfoH + 8
        btnOpenErrLog := g.AddButton("x" lay.ix " y" crashBtnY " w150 h26", "Open Error Log")
        btnOpenLogsDir := g.AddButton("x" (lay.ix + 158) " y" crashBtnY " w150 h26", "Open Logs Folder")
        StyleControlTheme(btnOpenErrLog, UI_Dark_Mode)
        StyleControlTheme(btnOpenLogsDir, UI_Dark_Mode)
        aboutLater.Push(btnOpenErrLog)
        aboutLater.Push(btnOpenLogsDir)
        btnOpenErrLog.OnEvent("Click", (*) => OpenErrorLogFile())
        btnOpenLogsDir.OnEvent("Click", (*) => (
            DirCreate(A_ScriptDir "\logs"),
            Run('"' A_ScriptDir '\logs"')
        ))
        crashBoxH := crashBtnY - aboutY + 26 + 14
        boxCrash.Move(, , , crashBoxH)
        aboutY += crashBoxH

        ; Safety net: if the text ever needs more room than the tab has, the scrolling changelog gives way.
        aboutOverflow := aboutY - (14 + tabH - 12)
        if (aboutOverflow > 0) {
            aboutShrink := Min(aboutOverflow, logEditH - 60)
            edtChangelog.Move(, , , logEditH - aboutShrink)
            boxLog.Move(, , , 24 + logEditH - aboutShrink + 14)
            for aboutCtl in aboutLater {
                aboutCtl.GetPos(, &aboutCy)
                aboutCtl.Move(, aboutCy - aboutShrink)
            }
        }

        tabs.UseTab()

        startTab := (initialTab >= 1 && initialTab <= tabNames.Length) ? initialTab : 1
        tabs.Value := startTab
        SettingsActiveTab := startTab

        bannerY := 14 + tabH + 6
        buttonsY := bannerY + 26

        SettingsLastBannerText := ""
        hintBar := g.AddText("x16 y" bannerY " w" exactTabW " +0x100", "")
        hintBar.SetFont("s9 " (UI_Dark_Mode ? "cFFFFFF" : "c000000"), "Segoe UI")
        SettingsHintCtrl := hintBar
        SetStatusBannerText(GetDefaultBannerForTab(startTab))

        tabs.OnEvent("Change", (*) => (
            SettingsActiveTab := tabs.Value,
            SetStatusBannerText(GetDefaultBannerForTab(tabs.Value))
        ))

        btnStartX := 16 + exactTabW - 306
        txtGuiVer := g.AddText("x16 y" (buttonsY + 7) " w" (btnStartX - 24) " +0x100", "v" APP_VERSION)
        StyleControlTheme(txtGuiVer, UI_Dark_Mode, true)

        btnApply := g.AddButton("x" btnStartX " y" buttonsY " w96 h30 Disabled", "Apply")
        btnSave  := g.AddButton("x+8 yp w108 h30 Default", "Save && Close")
        btnQuit  := g.AddButton("x+8 yp w86 h30", "Cancel")
        StyleControlTheme(btnApply, UI_Dark_Mode)
        StyleControlTheme(btnSave, UI_Dark_Mode)
        StyleControlTheme(btnQuit, UI_Dark_Mode)
        SettingsApplyBtn := btnApply

        collectAndApply := (closeAfter) => (
            SetSoundSelections(ddlDimSound.Text, ddlWakeSound.Text),
            CommitSettingsFromGui(
                closeAfter,
                chkDarkMode.Value, chkDebugLog.Value, edtDbgLogPath.Value,
                chkPriAuto.Value, chkHdrSdr.Value, chkCompSdr.Value, QueryWindowsPrimaryHdrState(), sldPriDark.Value, sldPriHdrDark.Value, sldPriFade.Value,
                chkRefreshRem.Value, edtRefreshDays.Value, edtRefreshHours.Value, edtRefreshMins.Value,
                ddlPopupMon.Value, ddlAlertStyle.Text, ddlPopupSound.Text,
                chkDimSound.Value, chkWakeSound.Value, sldSoundVol.Value,
                edtSdrDesk.Value, edtSdrNorm.Value, edtSdrComp.Value, edtSdrPause.Value,
                edtHdrDesk.Value, edtHdrNorm.Value, edtHdrComp.Value, edtHdrPause.Value,
                extraMonTabCtrls,
                chkDeskHide.Value, edtDeskIdle.Value, Icon_Fade_Ms,
                chkStartWin.Value, chkStartMin.Value, chkCareTbar.Value,
                edtCompGames.Value, edtExcludedProcs.Value, trayDraftRef, hkControlsMap,
                edtMediaPlayers.Value, edtBrowsers.Value
            )
        )

        btnApply.OnEvent("Click", (*) => collectAndApply(false))
        btnSave.OnEvent("Click", (*) => collectAndApply(true))
        btnQuit.OnEvent("Click", CloseSettingsGui)
        g.OnEvent("Close", CloseSettingsGui)
        g.OnEvent("Escape", CloseSettingsGui)

        SettingsGui := g
        SetTimer(SyncLiveHdrIndicators, 750)
        SetTimer(SyncLiveStatusBoxes, 500)
        SetTimer(PollHoverTooltip, 80)
        SyncSettingsLiveRefreshTimer()
        SetTimer(SyncSettingsLiveRefreshTimer, 1000)
        ShowWithFade(g, "AutoSize Center")
    } finally {
        isOpeningSettingsGui := false
    }
}

BuildExtraMonitorTab(g, tabs, tabIdx, mIdx, darkMode) {
    global SettingsLayout
    lay := SettingsLayout
    tabs.UseTab(tabIdx)
    mHdr := GetMonitorHdrInfo(mIdx)
    monLabel := "Monitor " mIdx

    tipDesktopSec  := "Idle delay (in seconds) before dimming or blacking out when on the Windows Desktop, browsing, or using regular apps."
    tipNormGameSec := "Idle delay (in seconds) before dimming or blacking out while playing a standard fullscreen or borderless game."
    tipCompGameSec := "Idle delay (in seconds) before dimming or blacking out while a game in your Competitive Games list is running."
    tipPausedSec   := "Idle delay (in seconds) before dimming or blacking out when a video player (MPC-HC, Stremio, VLC, mpv, etc.) is paused."
    tipDimLevel    := "Controls screen darkness when idle: 0% turns dimming off, while 100% is pure black (#000000) pixel-off blackout."
    tipBlackoutChk := "Quick toggle that sets Dim Level to 100% pure black (#000000) blackout when checked."
    tipFadeSpeed   := "Controls how smoothly the screen fades in and out (in milliseconds). Set to 0 ms for an instant switch."

    autoInit     := GetExtraMonSetting(mIdx, "Auto")
    hdrSdrInit   := mHdr.supported && GetExtraMonSetting(mIdx, "HdrSdrMode")
    compSdrInit  := mHdr.supported && GetExtraMonSetting(mIdx, "CompAutoSdr")
    sdrDeskInit  := GetExtraMonSetting(mIdx, "SdrDesk")
    sdrNormInit  := GetExtraMonSetting(mIdx, "SdrNorm")
    sdrCompInit  := GetExtraMonSetting(mIdx, "SdrComp")
    sdrPauseInit := GetExtraMonSetting(mIdx, "SdrPause")
    hdrDeskInit  := GetExtraMonSetting(mIdx, "HdrDesk")
    hdrNormInit  := GetExtraMonSetting(mIdx, "HdrNorm")
    hdrCompInit  := GetExtraMonSetting(mIdx, "HdrComp")
    hdrPauseInit := GetExtraMonSetting(mIdx, "HdrPause")
    dimPctInit   := GetExtraMonSetting(mIdx, "DimPercent")
    hdrDimInit   := GetExtraMonSetting(mIdx, "HdrDimPercent")
    fadeMsInit   := GetExtraMonSetting(mIdx, "FadeMs")

    chkAuto := g.AddCheckbox("x" lay.bx " y46 w" (lay.bw - 8) " Checked" autoInit, "Auto dim " monLabel " when idle   (turn off = manual dim only)")
    StyleControlTheme(chkAuto, darkMode)
    chkAuto.SetFont("s9.5 bold " (darkMode ? "cFFFFFF" : "c000000"), "Segoe UI")
    RegisterTip(chkAuto, "Master toggle for automatic idle dimming on " monLabel ". When OFF, only manual dim / blackout (hotkey or tray) works and the Dim Level below still applies to it.")

    boxHdrMode := AddSectionBox(g, lay.bx, 72, lay.bw, 84, "HDR && Display Mode", darkMode)
    chkHdrSdr := g.AddCheckbox("x" lay.ix " y94 w" lay.colW " Checked" hdrSdrInit, "Separate HDR/SDR profiles")
    StyleControlTheme(chkHdrSdr, darkMode)
    RegisterTip(chkHdrSdr, mHdr.supported ? ("Uses separate idle delays and dim levels on " monLabel " depending on whether HDR is ON or OFF.") : (monLabel " does not support HDR."))

    chkCompSdr := g.AddCheckbox("x" lay.c2x " y94 w" lay.colW " Checked" compSdrInit, "Auto-SDR in competitive games")
    StyleControlTheme(chkCompSdr, darkMode)
    RegisterTip(chkCompSdr, mHdr.supported ? ("Automatically switches " monLabel " from HDR to SDR when a competitive game launches.") : (monLabel " does not support HDR."))

    swMon := CreateSdrHdrSwitch(g, lay.ix, 122, 98, 24, mIdx, mHdr.supported, mHdr.enabled, true)
    RegisterTip(swMon, mHdr.supported ? ("Click to toggle between SDR and HDR for " monLabel ".") : (monLabel " does not support HDR."))

    statusStr := mHdr.supported ? (monLabel " output is " (mHdr.enabled ? "HDR" : "SDR")) : (monLabel " does not support HDR")
    txtMonHdr := g.AddText("x" (lay.ix + 106) " y126 w" (lay.iw - 106) " +0x100", statusStr)
    StyleControlTheme(txtMonHdr, darkMode, true)
    RegisterTip(txtMonHdr, GetMonitorHoverInfo(mIdx))
    BindSdrHdrStatusCtrl(swMon, txtMonHdr)

    if mHdr.supported {
        swMon.OnEvent("Click", MakeExtraMonitorHdrClickCallback(mIdx, swMon, txtMonHdr))
    } else {
        chkHdrSdr.Enabled := false
        chkCompSdr.Enabled := false
        txtMonHdr.Enabled := false
    }

    boxTimers := AddSectionBox(g, lay.bx, 164, lay.bw, 92, hdrSdrInit ? "SDR Idle Delay  (0 = Disabled)" : "Idle Delay  (0 = Disabled)", darkMode)
    t1 := g.AddText("x" lay.ix " y188 w" lay.lblW " +0x100", "Desktop (s)")
    edtSdrDesk := g.AddEdit("x" lay.e1 " y185 w" lay.edW " Number")
    udSdrDesk := g.AddUpDown("Range0-3600", sdrDeskInit)
    RegisterTip(t1, tipDesktopSec " Set to 0 to disable.")
    RegisterTip(edtSdrDesk, tipDesktopSec " Set to 0 to disable.")

    t2 := g.AddText("x" lay.c2x " y188 w" lay.lblW " +0x100", "Standard Game (s)")
    edtSdrNorm := g.AddEdit("x" lay.e2 " y185 w" lay.edW " Number")
    udSdrNorm := g.AddUpDown("Range0-3600", sdrNormInit)
    RegisterTip(t2, tipNormGameSec " Set to 0 to disable.")
    RegisterTip(edtSdrNorm, tipNormGameSec " Set to 0 to disable.")

    t3 := g.AddText("x" lay.ix " y218 w" lay.lblW " +0x100", "Competitive Game (s)")
    edtSdrComp := g.AddEdit("x" lay.e1 " y215 w" lay.edW " Number")
    udSdrComp := g.AddUpDown("Range0-3600", sdrCompInit)
    RegisterTip(t3, tipCompGameSec " Set to 0 to disable.")
    RegisterTip(edtSdrComp, tipCompGameSec " Set to 0 to disable.")

    t4 := g.AddText("x" lay.c2x " y218 w" lay.lblW " +0x100", "Paused Video (s)")
    edtSdrPause := g.AddEdit("x" lay.e2 " y215 w" lay.edW " Number")
    udSdrPause := g.AddUpDown("Range0-3600", sdrPauseInit)
    RegisterTip(t4, tipPausedSec " Set to 0 to disable.")
    RegisterTip(edtSdrPause, tipPausedSec " Set to 0 to disable.")

    boxHdr := AddSectionBox(g, lay.bx, 264, lay.bw, 92, "HDR Idle Delay  (0 = Disabled)", darkMode)
    t5 := g.AddText("x" lay.ix " y288 w" lay.lblW " +0x100", "Desktop (s)")
    edtHdrDesk := g.AddEdit("x" lay.e1 " y285 w" lay.edW " Number")
    udHdrDesk := g.AddUpDown("Range0-3600", hdrDeskInit)
    RegisterTip(t5, tipDesktopSec " Set to 0 to disable.")
    RegisterTip(edtHdrDesk, tipDesktopSec " Set to 0 to disable.")

    t6 := g.AddText("x" lay.c2x " y288 w" lay.lblW " +0x100", "Standard Game (s)")
    edtHdrNorm := g.AddEdit("x" lay.e2 " y285 w" lay.edW " Number")
    udHdrNorm := g.AddUpDown("Range0-3600", hdrNormInit)
    RegisterTip(t6, tipNormGameSec " Set to 0 to disable.")
    RegisterTip(edtHdrNorm, tipNormGameSec " Set to 0 to disable.")

    t7 := g.AddText("x" lay.ix " y318 w" lay.lblW " +0x100", "Competitive Game (s)")
    edtHdrComp := g.AddEdit("x" lay.e1 " y315 w" lay.edW " Number")
    udHdrComp := g.AddUpDown("Range0-3600", hdrCompInit)
    RegisterTip(t7, tipCompGameSec " Set to 0 to disable.")
    RegisterTip(edtHdrComp, tipCompGameSec " Set to 0 to disable.")

    t8 := g.AddText("x" lay.c2x " y318 w" lay.lblW " +0x100", "Paused Video (s)")
    edtHdrPause := g.AddEdit("x" lay.e2 " y315 w" lay.edW " Number")
    udHdrPause := g.AddUpDown("Range0-3600", hdrPauseInit)
    RegisterTip(t8, tipPausedSec " Set to 0 to disable.")
    RegisterTip(edtHdrPause, tipPausedSec " Set to 0 to disable.")

    boxDim := AddSectionBox(g, lay.bx, 364, lay.bw, 166, "Dim Level && Fade Speed  (0% = Disabled)", darkMode)
    div1 := g.AddText("x" lay.ix " y446 w" lay.iw " h2 0x10")
    div2 := g.AddText("x" lay.ix " y480 w" lay.iw " h2 0x10")
    t9 := g.AddText("x" lay.ix " y390 w" lay.dLblW " +0x100", hdrSdrInit ? "SDR Dim Level" : "Dim Level")
    sldDark := g.AddSlider("x" lay.dSldX " y388 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-100", dimPctInit)
    txtDark := g.AddText("x" lay.dPctX " y390 w44 +0x100", dimPctInit "%")
    chkBlk  := g.AddCheckbox("x" lay.dChkX " y389 w" lay.dChkW " Checked" (dimPctInit = 100), "Blackout")
    RegisterTip(t9, tipDimLevel)
    RegisterTip(sldDark, tipDimLevel)
    RegisterTip(chkBlk, tipBlackoutChk)

    t10 := g.AddText("x" lay.ix " y422 w" lay.dLblW " +0x100", "HDR Dim Level")
    sldHdrDark := g.AddSlider("x" lay.dSldX " y420 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-100", hdrDimInit)
    txtHdrDark := g.AddText("x" lay.dPctX " y422 w44 +0x100", hdrDimInit "%")
    chkHdrBlk  := g.AddCheckbox("x" lay.dChkX " y421 w" lay.dChkW " Checked" (hdrDimInit = 100), "Blackout")
    RegisterTip(t10, tipDimLevel)
    RegisterTip(sldHdrDark, tipDimLevel)
    RegisterTip(chkHdrBlk, tipBlackoutChk)

    t11 := g.AddText("x" lay.ix " y454 w" lay.dLblW " +0x100", "Fade Speed")
    sldFade := g.AddSlider("x" lay.dSldX " y452 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-2000", fadeMsInit)
    txtFade := g.AddText("x" lay.dPctX " y454 w70 +0x100", fadeMsInit " ms")
    RegisterTip(t11, tipFadeSpeed)
    RegisterTip(sldFade, tipFadeSpeed)

    btnTest := g.AddButton("x" lay.ix " y490 w132 h26", "Test Dim (3s)")
    RegisterTip(btnTest, "Previews " monLabel "'s current Dim Level and Fade Speed for 3 seconds.")
    btnTest.OnEvent("Click", (*) => PreviewSingleExtraMonitor(mIdx, sldDark.Value, sldHdrDark.Value, sldFade.Value, mHdr.supported && !!chkHdrSdr.Value))

    btnReset := g.AddButton("x" (lay.ir - lay.rstW) " y490 w" lay.rstW " h26", "Reset Defaults")
    RegisterTip(btnReset, "Restores " monLabel " delays, dim levels, fade speed, and HDR options to their default values.")
    AddLiveStatusBox(g, darkMode, mIdx, false, tabIdx)

    prevSdrVal := (dimPctInit < 100) ? dimPctInit : 73
    prevHdrVal := (hdrDimInit < 100) ? hdrDimInit : 73

    sldDark.OnEvent("Change", (*) => (
        txtDark.Text := sldDark.Value "%",
        chkBlk.Value := (sldDark.Value = 100) ? 1 : 0,
        (sldDark.Value < 100) ? (prevSdrVal := sldDark.Value) : 0,
        sldDark.Redraw(),
        MarkSettingsDirty()
    ))
    chkBlk.OnEvent("Click", (*) => (
        newVal := chkBlk.Value ? 100 : prevSdrVal,
        sldDark.Value := newVal,
        txtDark.Text := newVal "%",
        sldDark.Redraw(),
        MarkSettingsDirty()
    ))

    sldHdrDark.OnEvent("Change", (*) => (
        txtHdrDark.Text := sldHdrDark.Value "%",
        chkHdrBlk.Value := (sldHdrDark.Value = 100) ? 1 : 0,
        (sldHdrDark.Value < 100) ? (prevHdrVal := sldHdrDark.Value) : 0,
        sldHdrDark.Redraw(),
        MarkSettingsDirty()
    ))
    chkHdrBlk.OnEvent("Click", (*) => (
        newVal := chkHdrBlk.Value ? 100 : prevHdrVal,
        sldHdrDark.Value := newVal,
        txtHdrDark.Text := newVal "%",
        sldHdrDark.Redraw(),
        MarkSettingsDirty()
    ))
    sldFade.OnEvent("Change", (*) => (txtFade.Text := sldFade.Value " ms", sldFade.Redraw(), MarkSettingsDirty()))

    hdrOnlyCtrls := [boxHdr, t5, edtHdrDesk, udHdrDesk, t6, edtHdrNorm, udHdrNorm, t7, edtHdrComp, udHdrComp, t8, edtHdrPause, udHdrPause, t10, sldHdrDark, txtHdrDark, chkHdrBlk, div1]
    allCtrls := [
        boxHdrMode, btnReset, boxTimers,
        t1, edtSdrDesk, udSdrDesk, t2, edtSdrNorm, udSdrNorm,
        t3, edtSdrComp, udSdrComp, t4, edtSdrPause, udSdrPause,
        boxHdr, t5, edtHdrDesk, udHdrDesk, t6, edtHdrNorm, udHdrNorm,
        t7, edtHdrComp, udHdrComp, t8, edtHdrPause, udHdrPause, boxDim,
        t9, sldDark, txtDark, chkBlk, t10, sldHdrDark, txtHdrDark, chkHdrBlk,
        t11, sldFade, txtFade, btnTest
    ]
    if mHdr.supported {
        allCtrls.Push(chkHdrSdr)
        allCtrls.Push(chkCompSdr)
        allCtrls.Push(swMon)
        allCtrls.Push(txtMonHdr)
    }

    autoOnlyCtrls := [
        boxTimers, t1, edtSdrDesk, udSdrDesk, t2, edtSdrNorm, udSdrNorm,
        t3, edtSdrComp, udSdrComp, t4, edtSdrPause, udSdrPause,
        boxHdr, t5, edtHdrDesk, udHdrDesk, t6, edtHdrNorm, udHdrNorm,
        t7, edtHdrComp, udHdrComp, t8, edtHdrPause, udHdrPause
    ]

    for c in allCtrls {
        if !HdrSwitchMap.Has(c.Hwnd) {
            StyleControlTheme(c, darkMode, (c = txtMonHdr))
        }
        if (c.Type = "Edit") {
            c.OnEvent("Change", MarkSettingsDirty)
        } else if (c.Type = "CheckBox") {
            c.OnEvent("Click", MarkSettingsDirty)
        }
    }

    applyLayout(*) {
        ox := 0, oy := 0
        try {
            boxTimers.GetPos(&bx, &by)
            ox := bx - lay.bx
            oy := by - 164
        }
        DllCall("SendMessage", "Ptr", g.Hwnd, "UInt", 0x000B, "Ptr", 0, "Ptr", 0)
        sep := mHdr.supported && !!chkHdrSdr.Value
        boxTimers.Text := sep ? "SDR Idle Delay  (0 = Disabled)" : "Idle Delay  (0 = Disabled)"
        t9.Text := sep ? "SDR Dim Level" : "Dim Level"
        ForEachSetVisible(hdrOnlyCtrls, sep)
        rstX := lay.ir - lay.rstW
        if sep {
            boxDim.Move(lay.bx + ox, 364 + oy, lay.bw, 166)
            t9.Move(lay.ix + ox, 390 + oy), sldDark.Move(lay.dSldX + ox, 388 + oy, lay.dSldW, 24), txtDark.Move(lay.dPctX + ox, 390 + oy), chkBlk.Move(lay.dChkX + ox, 389 + oy)
            t10.Move(lay.ix + ox, 422 + oy), sldHdrDark.Move(lay.dSldX + ox, 420 + oy, lay.dSldW, 24), txtHdrDark.Move(lay.dPctX + ox, 422 + oy), chkHdrBlk.Move(lay.dChkX + ox, 421 + oy)
            div1.Move(lay.ix + ox, 446 + oy), t11.Move(lay.ix + ox, 454 + oy), sldFade.Move(lay.dSldX + ox, 452 + oy, lay.dSldW, 24), txtFade.Move(lay.dPctX + ox, 454 + oy)
            div2.Move(lay.ix + ox, 480 + oy), btnTest.Move(lay.ix + ox, 490 + oy), btnReset.Move(rstX + ox, 490 + oy)
        } else {
            boxDim.Move(lay.bx + ox, 264 + oy, lay.bw, 134)
            t9.Move(lay.ix + ox, 290 + oy), sldDark.Move(lay.dSldX + ox, 288 + oy, lay.dSldW, 24), txtDark.Move(lay.dPctX + ox, 290 + oy), chkBlk.Move(lay.dChkX + ox, 289 + oy)
            t11.Move(lay.ix + ox, 322 + oy), sldFade.Move(lay.dSldX + ox, 320 + oy, lay.dSldW, 24), txtFade.Move(lay.dPctX + ox, 322 + oy)
            div2.Move(lay.ix + ox, 348 + oy), btnTest.Move(lay.ix + ox, 358 + oy), btnReset.Move(rstX + ox, 358 + oy)
        }
        DllCall("SendMessage", "Ptr", g.Hwnd, "UInt", 0x000B, "Ptr", 1, "Ptr", 0)
        DllCall("RedrawWindow", "Ptr", g.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0181)
        MarkSettingsDirty()
    }

    btnReset.OnEvent("Click", (*) => (
        chkAuto.Value := 1,
        chkHdrSdr.Value := 0,
        chkCompSdr.Value := mHdr.supported ? 1 : 0,
        udSdrDesk.Value := 15, udSdrNorm.Value := 5, udSdrComp.Value := 5, udSdrPause.Value := 10,
        udHdrDesk.Value := 15, udHdrNorm.Value := 5, udHdrComp.Value := 5, udHdrPause.Value := 10,
        sldDark.Value := 73, txtDark.Text := "73%", chkBlk.Value := 0,
        sldHdrDark.Value := 73, txtHdrDark.Text := "73%", chkHdrBlk.Value := 0,
        sldFade.Value := 300, txtFade.Text := "300 ms",
        SetControlsEnabled(allCtrls, true),
       curInfo := GetMonitorHdrInfo(mIdx),
        UpdateSdrHdrSwitchVisual(swMon, curInfo.supported, curInfo.enabled, true),
        SetControlsEnabled(autoOnlyCtrls, !!chkAuto.Value),
        MarkSettingsDirty()
    ))

    chkHdrSdr.OnEvent("Click", applyLayout)
    chkAuto.OnEvent("Click", (*) => (SetControlsEnabled(autoOnlyCtrls, !!chkAuto.Value), MarkSettingsDirty()))

    applyLayout()
    SetControlsEnabled(autoOnlyCtrls, !!autoInit)
    UpdateSdrHdrSwitchVisual(swMon, mHdr.supported, mHdr.enabled, true)

    return {
        chkAuto: chkAuto, chkHdrSdr: chkHdrSdr, chkCompSdr: chkCompSdr,
        edtSdrDesk: edtSdrDesk, edtSdrNorm: edtSdrNorm, edtSdrComp: edtSdrComp, edtSdrPause: edtSdrPause,
        edtHdrDesk: edtHdrDesk, edtHdrNorm: edtHdrNorm, edtHdrComp: edtHdrComp, edtHdrPause: edtHdrPause,
        sldDark: sldDark, sldHdrDark: sldHdrDark, sldFade: sldFade
    }
}

ForEachSetVisible(ctrlList, vis) {
    for c in ctrlList {
        try c.Visible := vis
    }
}

GetExtraMonSetting(monIdx, key) {
    global Extra_Auto_Enabled, Extra_HDR_SDR_Mode_Enabled, Extra_Comp_Game_Auto_SDR
    global Extra_Dim_Percent, Extra_HDR_Dim_Percent, Extra_Fade_Ms
    global Extra_SDR_Desktop_Sec, Extra_SDR_Normal_Sec, Extra_SDR_Comp_Sec, Extra_SDR_Paused_Sec
    global Extra_HDR_Desktop_Sec, Extra_HDR_Normal_Sec, Extra_HDR_Comp_Sec, Extra_HDR_Paused_Sec
    global Mon3_Auto_Enabled, Mon3_HDR_SDR_Mode_Enabled, Mon3_Comp_Game_Auto_SDR
    global Mon3_Dim_Percent, Mon3_HDR_Dim_Percent, Mon3_Fade_Ms
    global Mon3_SDR_Desktop_Sec, Mon3_SDR_Normal_Sec, Mon3_SDR_Comp_Sec, Mon3_SDR_Paused_Sec
    global Mon3_HDR_Desktop_Sec, Mon3_HDR_Normal_Sec, Mon3_HDR_Comp_Sec, Mon3_HDR_Paused_Sec
    global Mon4_Auto_Enabled, Mon4_HDR_SDR_Mode_Enabled, Mon4_Comp_Game_Auto_SDR
    global Mon4_Dim_Percent, Mon4_HDR_Dim_Percent, Mon4_Fade_Ms
    global Mon4_SDR_Desktop_Sec, Mon4_SDR_Normal_Sec, Mon4_SDR_Comp_Sec, Mon4_SDR_Paused_Sec
    global Mon4_HDR_Desktop_Sec, Mon4_HDR_Normal_Sec, Mon4_HDR_Comp_Sec, Mon4_HDR_Paused_Sec
    global Mon5_Auto_Enabled, Mon5_HDR_SDR_Mode_Enabled, Mon5_Comp_Game_Auto_SDR
    global Mon5_Dim_Percent, Mon5_HDR_Dim_Percent, Mon5_Fade_Ms
    global Mon5_SDR_Desktop_Sec, Mon5_SDR_Normal_Sec, Mon5_SDR_Comp_Sec, Mon5_SDR_Paused_Sec
    global Mon5_HDR_Desktop_Sec, Mon5_HDR_Normal_Sec, Mon5_HDR_Comp_Sec, Mon5_HDR_Paused_Sec
    global ExtraDynamicMonCfg

    if (monIdx = 3) {
        switch key {
            case "Auto": return Mon3_Auto_Enabled
            case "HdrSdrMode": return Mon3_HDR_SDR_Mode_Enabled
            case "CompAutoSdr": return Mon3_Comp_Game_Auto_SDR
            case "DimPercent": return Mon3_Dim_Percent
            case "HdrDimPercent": return Mon3_HDR_Dim_Percent
            case "FadeMs": return Mon3_Fade_Ms
            case "SdrDesk": return Mon3_SDR_Desktop_Sec
            case "SdrNorm": return Mon3_SDR_Normal_Sec
            case "SdrComp": return Mon3_SDR_Comp_Sec
            case "SdrPause": return Mon3_SDR_Paused_Sec
            case "HdrDesk": return Mon3_HDR_Desktop_Sec
            case "HdrNorm": return Mon3_HDR_Normal_Sec
            case "HdrComp": return Mon3_HDR_Comp_Sec
            case "HdrPause": return Mon3_HDR_Paused_Sec
        }
    } else if (monIdx = 4) {
        switch key {
            case "Auto": return Mon4_Auto_Enabled
            case "HdrSdrMode": return Mon4_HDR_SDR_Mode_Enabled
            case "CompAutoSdr": return Mon4_Comp_Game_Auto_SDR
            case "DimPercent": return Mon4_Dim_Percent
            case "HdrDimPercent": return Mon4_HDR_Dim_Percent
            case "FadeMs": return Mon4_Fade_Ms
            case "SdrDesk": return Mon4_SDR_Desktop_Sec
            case "SdrNorm": return Mon4_SDR_Normal_Sec
            case "SdrComp": return Mon4_SDR_Comp_Sec
            case "SdrPause": return Mon4_SDR_Paused_Sec
            case "HdrDesk": return Mon4_HDR_Desktop_Sec
            case "HdrNorm": return Mon4_HDR_Normal_Sec
            case "HdrComp": return Mon4_HDR_Comp_Sec
            case "HdrPause": return Mon4_HDR_Paused_Sec
        }
    } else if (monIdx = 5) {
        switch key {
            case "Auto": return Mon5_Auto_Enabled
            case "HdrSdrMode": return Mon5_HDR_SDR_Mode_Enabled
            case "CompAutoSdr": return Mon5_Comp_Game_Auto_SDR
            case "DimPercent": return Mon5_Dim_Percent
            case "HdrDimPercent": return Mon5_HDR_Dim_Percent
            case "FadeMs": return Mon5_Fade_Ms
            case "SdrDesk": return Mon5_SDR_Desktop_Sec
            case "SdrNorm": return Mon5_SDR_Normal_Sec
            case "SdrComp": return Mon5_SDR_Comp_Sec
            case "SdrPause": return Mon5_SDR_Paused_Sec
            case "HdrDesk": return Mon5_HDR_Desktop_Sec
            case "HdrNorm": return Mon5_HDR_Normal_Sec
            case "HdrComp": return Mon5_HDR_Comp_Sec
            case "HdrPause": return Mon5_HDR_Paused_Sec
        }
    } else if (monIdx >= 6) {
        if !ExtraDynamicMonCfg.Has(monIdx) {
            ExtraDynamicMonCfg[monIdx] := Map(
                "Auto", true, "HdrSdrMode", false, "CompAutoSdr", false,
                "DimPercent", 73, "HdrDimPercent", 73, "FadeMs", 300,
                "SdrDesk", 15, "SdrNorm", 5, "SdrComp", 5, "SdrPause", 10,
                "HdrDesk", 15, "HdrNorm", 5, "HdrComp", 5, "HdrPause", 10
            )
        }
        return ExtraDynamicMonCfg[monIdx][key]
    }

    switch key {
        case "Auto": return Extra_Auto_Enabled
        case "HdrSdrMode": return Extra_HDR_SDR_Mode_Enabled
        case "CompAutoSdr": return Extra_Comp_Game_Auto_SDR
        case "DimPercent": return Extra_Dim_Percent
        case "HdrDimPercent": return Extra_HDR_Dim_Percent
        case "FadeMs": return Extra_Fade_Ms
        case "SdrDesk": return Extra_SDR_Desktop_Sec
        case "SdrNorm": return Extra_SDR_Normal_Sec
        case "SdrComp": return Extra_SDR_Comp_Sec
        case "SdrPause": return Extra_SDR_Paused_Sec
        case "HdrDesk": return Extra_HDR_Desktop_Sec
        case "HdrNorm": return Extra_HDR_Normal_Sec
        case "HdrComp": return Extra_HDR_Comp_Sec
        case "HdrPause": return Extra_HDR_Paused_Sec
    }
    return 0
}

SetExtraMonSetting(monIdx, key, val) {
    global Extra_Auto_Enabled, Extra_HDR_SDR_Mode_Enabled, Extra_Comp_Game_Auto_SDR
    global Extra_Dim_Percent, Extra_HDR_Dim_Percent, Extra_Dim_Alpha, Extra_HDR_Dim_Alpha, Extra_Fade_Ms
    global Extra_SDR_Desktop_Sec, Extra_SDR_Normal_Sec, Extra_SDR_Comp_Sec, Extra_SDR_Paused_Sec
    global Extra_HDR_Desktop_Sec, Extra_HDR_Normal_Sec, Extra_HDR_Comp_Sec, Extra_HDR_Paused_Sec
    global Mon3_Auto_Enabled, Mon3_HDR_SDR_Mode_Enabled, Mon3_Comp_Game_Auto_SDR
    global Mon3_Dim_Percent, Mon3_HDR_Dim_Percent, Mon3_Fade_Ms
    global Mon3_SDR_Desktop_Sec, Mon3_SDR_Normal_Sec, Mon3_SDR_Comp_Sec, Mon3_SDR_Paused_Sec
    global Mon3_HDR_Desktop_Sec, Mon3_HDR_Normal_Sec, Mon3_HDR_Comp_Sec, Mon3_HDR_Paused_Sec
    global Mon4_Auto_Enabled, Mon4_HDR_SDR_Mode_Enabled, Mon4_Comp_Game_Auto_SDR
    global Mon4_Dim_Percent, Mon4_HDR_Dim_Percent, Mon4_Fade_Ms
    global Mon4_SDR_Desktop_Sec, Mon4_SDR_Normal_Sec, Mon4_SDR_Comp_Sec, Mon4_SDR_Paused_Sec
    global Mon4_HDR_Desktop_Sec, Mon4_HDR_Normal_Sec, Mon4_HDR_Comp_Sec, Mon4_HDR_Paused_Sec
    global Mon5_Auto_Enabled, Mon5_HDR_SDR_Mode_Enabled, Mon5_Comp_Game_Auto_SDR
    global Mon5_Dim_Percent, Mon5_HDR_Dim_Percent, Mon5_Fade_Ms
    global Mon5_SDR_Desktop_Sec, Mon5_SDR_Normal_Sec, Mon5_SDR_Comp_Sec, Mon5_SDR_Paused_Sec
    global Mon5_HDR_Desktop_Sec, Mon5_HDR_Normal_Sec, Mon5_HDR_Comp_Sec, Mon5_HDR_Paused_Sec
    global ExtraDynamicMonCfg

    if (monIdx = 3) {
        switch key {
            case "Auto": Mon3_Auto_Enabled := !!val
            case "HdrSdrMode": Mon3_HDR_SDR_Mode_Enabled := !!val
            case "CompAutoSdr": Mon3_Comp_Game_Auto_SDR := !!val
            case "DimPercent": Mon3_Dim_Percent := Max(0, Min(100, Integer(val)))
            case "HdrDimPercent": Mon3_HDR_Dim_Percent := Max(0, Min(100, Integer(val)))
            case "FadeMs": Mon3_Fade_Ms := Max(0, Min(2000, Integer(val)))
            case "SdrDesk": Mon3_SDR_Desktop_Sec := Max(0, Integer(val))
            case "SdrNorm": Mon3_SDR_Normal_Sec := Max(0, Integer(val))
            case "SdrComp": Mon3_SDR_Comp_Sec := Max(0, Integer(val))
            case "SdrPause": Mon3_SDR_Paused_Sec := Max(0, Integer(val))
            case "HdrDesk": Mon3_HDR_Desktop_Sec := Max(0, Integer(val))
            case "HdrNorm": Mon3_HDR_Normal_Sec := Max(0, Integer(val))
            case "HdrComp": Mon3_HDR_Comp_Sec := Max(0, Integer(val))
            case "HdrPause": Mon3_HDR_Paused_Sec := Max(0, Integer(val))
        }
        return
    }
    if (monIdx = 4) {
        switch key {
            case "Auto": Mon4_Auto_Enabled := !!val
            case "HdrSdrMode": Mon4_HDR_SDR_Mode_Enabled := !!val
            case "CompAutoSdr": Mon4_Comp_Game_Auto_SDR := !!val
            case "DimPercent": Mon4_Dim_Percent := Max(0, Min(100, Integer(val)))
            case "HdrDimPercent": Mon4_HDR_Dim_Percent := Max(0, Min(100, Integer(val)))
            case "FadeMs": Mon4_Fade_Ms := Max(0, Min(2000, Integer(val)))
            case "SdrDesk": Mon4_SDR_Desktop_Sec := Max(0, Integer(val))
            case "SdrNorm": Mon4_SDR_Normal_Sec := Max(0, Integer(val))
            case "SdrComp": Mon4_SDR_Comp_Sec := Max(0, Integer(val))
            case "SdrPause": Mon4_SDR_Paused_Sec := Max(0, Integer(val))
            case "HdrDesk": Mon4_HDR_Desktop_Sec := Max(0, Integer(val))
            case "HdrNorm": Mon4_HDR_Normal_Sec := Max(0, Integer(val))
            case "HdrComp": Mon4_HDR_Comp_Sec := Max(0, Integer(val))
            case "HdrPause": Mon4_HDR_Paused_Sec := Max(0, Integer(val))
        }
        return
    }
    if (monIdx = 5) {
        switch key {
            case "Auto": Mon5_Auto_Enabled := !!val
            case "HdrSdrMode": Mon5_HDR_SDR_Mode_Enabled := !!val
            case "CompAutoSdr": Mon5_Comp_Game_Auto_SDR := !!val
            case "DimPercent": Mon5_Dim_Percent := Max(0, Min(100, Integer(val)))
            case "HdrDimPercent": Mon5_HDR_Dim_Percent := Max(0, Min(100, Integer(val)))
            case "FadeMs": Mon5_Fade_Ms := Max(0, Min(2000, Integer(val)))
            case "SdrDesk": Mon5_SDR_Desktop_Sec := Max(0, Integer(val))
            case "SdrNorm": Mon5_SDR_Normal_Sec := Max(0, Integer(val))
            case "SdrComp": Mon5_SDR_Comp_Sec := Max(0, Integer(val))
            case "SdrPause": Mon5_SDR_Paused_Sec := Max(0, Integer(val))
            case "HdrDesk": Mon5_HDR_Desktop_Sec := Max(0, Integer(val))
            case "HdrNorm": Mon5_HDR_Normal_Sec := Max(0, Integer(val))
            case "HdrComp": Mon5_HDR_Comp_Sec := Max(0, Integer(val))
            case "HdrPause": Mon5_HDR_Paused_Sec := Max(0, Integer(val))
        }
        return
    }
    if (monIdx >= 6) {
        GetExtraMonSetting(monIdx, key)
        ExtraDynamicMonCfg[monIdx][key] := val
        return
    }

    switch key {
        case "Auto": Extra_Auto_Enabled := !!val
        case "HdrSdrMode": Extra_HDR_SDR_Mode_Enabled := !!val
        case "CompAutoSdr": Extra_Comp_Game_Auto_SDR := !!val
        case "DimPercent":
            Extra_Dim_Percent := Max(0, Min(100, Integer(val)))
            Extra_Dim_Alpha := Round(Extra_Dim_Percent * 2.55)
        case "HdrDimPercent":
            Extra_HDR_Dim_Percent := Max(0, Min(100, Integer(val)))
            Extra_HDR_Dim_Alpha := Round(Extra_HDR_Dim_Percent * 2.55)
        case "FadeMs": Extra_Fade_Ms := Max(0, Min(2000, Integer(val)))
        case "SdrDesk": Extra_SDR_Desktop_Sec := Max(0, Integer(val))
        case "SdrNorm": Extra_SDR_Normal_Sec := Max(0, Integer(val))
        case "SdrComp": Extra_SDR_Comp_Sec := Max(0, Integer(val))
        case "SdrPause": Extra_SDR_Paused_Sec := Max(0, Integer(val))
        case "HdrDesk": Extra_HDR_Desktop_Sec := Max(0, Integer(val))
        case "HdrNorm": Extra_HDR_Normal_Sec := Max(0, Integer(val))
        case "HdrComp": Extra_HDR_Comp_Sec := Max(0, Integer(val))
        case "HdrPause": Extra_HDR_Paused_Sec := Max(0, Integer(val))
    }
}

IsAnyExtraMonAutoEnabled() {
    priIdx := MonitorGetPrimary()
    Loop GetDetectedMonitorCount() {
        if (A_Index != priIdx && GetExtraMonSetting(A_Index, "Auto")) {
            return true
        }
    }
    return false
}

ReadIniInt(sec, key, def) {
    global IniPath
    val := IniRead(IniPath, sec, key, String(def))
    return IsNumber(val) ? Integer(val) : def
}

ReadIniBool(sec, key, def) {
    return !!ReadIniInt(sec, key, def ? 1 : 0)
}

LoadSettingsFromIni() {
    global IniPath, MAX_MONITORS
    global Primary_Auto_Enabled, HDR_SDR_Mode_Enabled, Comp_Game_Auto_SDR
    global Dim_Percent, HDR_Dim_Percent, Dim_Alpha, HDR_Dim_Alpha, Fade_Ms
    global SDR_Desktop_Sec, SDR_Normal_Sec, SDR_Comp_Sec, SDR_Paused_Sec
    global HDR_Desktop_Sec, HDR_Normal_Sec, HDR_Comp_Sec, HDR_Paused_Sec
    global UI_Dark_Mode, Debug_Log_Enabled, Debug_Log_Path
    global OLED_Refresh_Reminder_Enabled, OLED_Refresh_Days, OLED_Refresh_Hours, OLED_Refresh_Mins
    global Popup_Monitor, Alert_Style, Popup_Sound
    global Dim_Sound_Enabled, Wake_Sound_Enabled, Sound_Volume_Step
    global Desktop_Hide_Enabled, Desktop_Idle_Sec, Icon_Fade_Ms
    global Start_With_Windows, Start_Minimized, Care_Taskbar_AutoHide

    if !FileExist(IniPath) {
        SaveSettingsToIni()
        return
    }

    Primary_Auto_Enabled := ReadIniBool("Monitor1", "Auto", IsSet(Primary_Auto_Enabled) ? Primary_Auto_Enabled : true)
    HDR_SDR_Mode_Enabled := ReadIniBool("Monitor1", "HdrSdrMode", IsSet(HDR_SDR_Mode_Enabled) ? HDR_SDR_Mode_Enabled : false)
    Comp_Game_Auto_SDR   := ReadIniBool("Monitor1", "CompAutoSdr", IsSet(Comp_Game_Auto_SDR) ? Comp_Game_Auto_SDR : false)
    Dim_Percent          := ReadIniInt("Monitor1", "DimPercent", IsSet(Dim_Percent) ? Dim_Percent : 73)
    HDR_Dim_Percent      := ReadIniInt("Monitor1", "HdrDimPercent", IsSet(HDR_Dim_Percent) ? HDR_Dim_Percent : 73)
    Dim_Alpha            := Round(Dim_Percent * 2.55)
    HDR_Dim_Alpha        := Round(HDR_Dim_Percent * 2.55)
    Fade_Ms              := ReadIniInt("Monitor1", "FadeMs", IsSet(Fade_Ms) ? Fade_Ms : 300)
    SDR_Desktop_Sec      := ReadIniInt("Monitor1", "SdrDesk", IsSet(SDR_Desktop_Sec) ? SDR_Desktop_Sec : 15)
    SDR_Normal_Sec       := ReadIniInt("Monitor1", "SdrNorm", IsSet(SDR_Normal_Sec) ? SDR_Normal_Sec : 5)
    SDR_Comp_Sec         := ReadIniInt("Monitor1", "SdrComp", IsSet(SDR_Comp_Sec) ? SDR_Comp_Sec : 5)
    SDR_Paused_Sec       := ReadIniInt("Monitor1", "SdrPause", IsSet(SDR_Paused_Sec) ? SDR_Paused_Sec : 10)
    HDR_Desktop_Sec      := ReadIniInt("Monitor1", "HdrDesk", IsSet(HDR_Desktop_Sec) ? HDR_Desktop_Sec : 15)
    HDR_Normal_Sec       := ReadIniInt("Monitor1", "HdrNorm", IsSet(HDR_Normal_Sec) ? HDR_Normal_Sec : 5)
    HDR_Comp_Sec         := ReadIniInt("Monitor1", "HdrComp", IsSet(HDR_Comp_Sec) ? HDR_Comp_Sec : 5)
    HDR_Paused_Sec       := ReadIniInt("Monitor1", "HdrPause", IsSet(HDR_Paused_Sec) ? HDR_Paused_Sec : 10)

    keys := ["Auto", "HdrSdrMode", "CompAutoSdr", "DimPercent", "HdrDimPercent", "FadeMs",
             "SdrDesk", "SdrNorm", "SdrComp", "SdrPause", "HdrDesk", "HdrNorm", "HdrComp", "HdrPause"]
    Loop (MAX_MONITORS - 1) {
        mIdx := A_Index + 1
        sec := "Monitor" mIdx
        for k in keys {
            cur := GetExtraMonSetting(mIdx, k)
            val := (k = "Auto" || k = "HdrSdrMode" || k = "CompAutoSdr")
                ? ReadIniBool(sec, k, cur)
                : ReadIniInt(sec, k, cur)
            SetExtraMonSetting(mIdx, k, val)
        }
    }

    UI_Dark_Mode                  := ReadIniBool("General", "DarkMode", IsSet(UI_Dark_Mode) ? UI_Dark_Mode : true)
    Debug_Log_Enabled             := ReadIniBool("General", "DebugLog", IsSet(Debug_Log_Enabled) ? Debug_Log_Enabled : false)
    Debug_Log_Path                := IniRead(IniPath, "General", "DebugLogPath", "")
    OLED_Refresh_Reminder_Enabled := ReadIniBool("General", "RefreshReminder", IsSet(OLED_Refresh_Reminder_Enabled) ? OLED_Refresh_Reminder_Enabled : true)
    OLED_Refresh_Days             := ReadIniInt("General", "RefreshDays", IsSet(OLED_Refresh_Days) ? OLED_Refresh_Days : 0)
    OLED_Refresh_Hours            := ReadIniInt("General", "RefreshHours", IsSet(OLED_Refresh_Hours) ? OLED_Refresh_Hours : 4)
    OLED_Refresh_Mins             := ReadIniInt("General", "RefreshMins", IsSet(OLED_Refresh_Mins) ? OLED_Refresh_Mins : 0)
    Popup_Monitor                 := ReadIniInt("General", "PopupMonitor", IsSet(Popup_Monitor) ? Popup_Monitor : 1)
    Alert_Style                   := IniRead(IniPath, "General", "AlertStyle", IsSet(Alert_Style) ? Alert_Style : "Toast")
    Popup_Sound                   := IniRead(IniPath, "General", "PopupSound", IsSet(Popup_Sound) ? Popup_Sound : "Default")
    Dim_Sound_Enabled             := ReadIniBool("General", "DimSound", IsSet(Dim_Sound_Enabled) ? Dim_Sound_Enabled : false)
    Wake_Sound_Enabled            := ReadIniBool("General", "WakeSound", IsSet(Wake_Sound_Enabled) ? Wake_Sound_Enabled : false)
    Sound_Volume_Step             := ReadIniInt("General", "SoundVol", IsSet(Sound_Volume_Step) ? Sound_Volume_Step : 50)
    Desktop_Hide_Enabled          := ReadIniBool("General", "DeskHide", IsSet(Desktop_Hide_Enabled) ? Desktop_Hide_Enabled : false)
    Desktop_Idle_Sec              := ReadIniInt("General", "DeskIdle", IsSet(Desktop_Idle_Sec) ? Desktop_Idle_Sec : 15)
    Icon_Fade_Ms                  := ReadIniInt("General", "IconFade", IsSet(Icon_Fade_Ms) ? Icon_Fade_Ms : 300)
    Start_With_Windows            := ReadIniBool("General", "StartWin", IsSet(Start_With_Windows) ? Start_With_Windows : false)
    Start_Minimized               := ReadIniBool("General", "StartMin", IsSet(Start_Minimized) ? Start_Minimized : false)
    Care_Taskbar_AutoHide         := ReadIniBool("General", "CareTaskbar", IsSet(Care_Taskbar_AutoHide) ? Care_Taskbar_AutoHide : false)
    LoadAppSettingsFromIni()
}

SaveSettingsToIni() {
    global IniPath, ConfigDir, MAX_MONITORS
    global Primary_Auto_Enabled, HDR_SDR_Mode_Enabled, Comp_Game_Auto_SDR
    global Dim_Percent, HDR_Dim_Percent, Fade_Ms
    global SDR_Desktop_Sec, SDR_Normal_Sec, SDR_Comp_Sec, SDR_Paused_Sec
    global HDR_Desktop_Sec, HDR_Normal_Sec, HDR_Comp_Sec, HDR_Paused_Sec
    global UI_Dark_Mode, Debug_Log_Enabled, Debug_Log_Path
    global OLED_Refresh_Reminder_Enabled, OLED_Refresh_Days, OLED_Refresh_Hours, OLED_Refresh_Mins
    global Popup_Monitor, Alert_Style, Popup_Sound
    global Dim_Sound_Enabled, Wake_Sound_Enabled, Sound_Volume_Step
    global Desktop_Hide_Enabled, Desktop_Idle_Sec, Icon_Fade_Ms
    global Start_With_Windows, Start_Minimized, Care_Taskbar_AutoHide

    DirCreate(ConfigDir)

    IniWrite((IsSet(Primary_Auto_Enabled) && Primary_Auto_Enabled) ? 1 : 0, IniPath, "Monitor1", "Auto")
    IniWrite((IsSet(HDR_SDR_Mode_Enabled) && HDR_SDR_Mode_Enabled) ? 1 : 0, IniPath, "Monitor1", "HdrSdrMode")
    IniWrite((IsSet(Comp_Game_Auto_SDR) && Comp_Game_Auto_SDR) ? 1 : 0,     IniPath, "Monitor1", "CompAutoSdr")
    IniWrite(IsSet(Dim_Percent) ? Dim_Percent : 73,                         IniPath, "Monitor1", "DimPercent")
    IniWrite(IsSet(HDR_Dim_Percent) ? HDR_Dim_Percent : 73,                 IniPath, "Monitor1", "HdrDimPercent")
    IniWrite(IsSet(Fade_Ms) ? Fade_Ms : 300,                                IniPath, "Monitor1", "FadeMs")
    IniWrite(IsSet(SDR_Desktop_Sec) ? SDR_Desktop_Sec : 15,                 IniPath, "Monitor1", "SdrDesk")
    IniWrite(IsSet(SDR_Normal_Sec) ? SDR_Normal_Sec : 5,                    IniPath, "Monitor1", "SdrNorm")
    IniWrite(IsSet(SDR_Comp_Sec) ? SDR_Comp_Sec : 5,                        IniPath, "Monitor1", "SdrComp")
    IniWrite(IsSet(SDR_Paused_Sec) ? SDR_Paused_Sec : 10,                   IniPath, "Monitor1", "SdrPause")
    IniWrite(IsSet(HDR_Desktop_Sec) ? HDR_Desktop_Sec : 15,                 IniPath, "Monitor1", "HdrDesk")
    IniWrite(IsSet(HDR_Normal_Sec) ? HDR_Normal_Sec : 5,                    IniPath, "Monitor1", "HdrNorm")
    IniWrite(IsSet(HDR_Comp_Sec) ? HDR_Comp_Sec : 5,                        IniPath, "Monitor1", "HdrComp")
    IniWrite(IsSet(HDR_Paused_Sec) ? HDR_Paused_Sec : 10,                   IniPath, "Monitor1", "HdrPause")

    keys := ["Auto", "HdrSdrMode", "CompAutoSdr", "DimPercent", "HdrDimPercent", "FadeMs",
             "SdrDesk", "SdrNorm", "SdrComp", "SdrPause", "HdrDesk", "HdrNorm", "HdrComp", "HdrPause"]
    Loop (MAX_MONITORS - 1) {
        mIdx := A_Index + 1
        sec := "Monitor" mIdx
        for k in keys {
            v := GetExtraMonSetting(mIdx, k)
            if (k = "Auto" || k = "HdrSdrMode" || k = "CompAutoSdr") {
                v := v ? 1 : 0
            }
            IniWrite(v, IniPath, sec, k)
        }
    }

    IniWrite((IsSet(UI_Dark_Mode) && UI_Dark_Mode) ? 1 : 0,                                   IniPath, "General", "DarkMode")
    IniWrite((IsSet(Debug_Log_Enabled) && Debug_Log_Enabled) ? 1 : 0,                         IniPath, "General", "DebugLog")
    IniWrite(IsSet(Debug_Log_Path) ? Debug_Log_Path : "",                                     IniPath, "General", "DebugLogPath")
    IniWrite((IsSet(OLED_Refresh_Reminder_Enabled) && OLED_Refresh_Reminder_Enabled) ? 1 : 0, IniPath, "General", "RefreshReminder")
    IniWrite(IsSet(OLED_Refresh_Days) ? OLED_Refresh_Days : 0,                                IniPath, "General", "RefreshDays")
    IniWrite(IsSet(OLED_Refresh_Hours) ? OLED_Refresh_Hours : 4,                              IniPath, "General", "RefreshHours")
    IniWrite(IsSet(OLED_Refresh_Mins) ? OLED_Refresh_Mins : 0,                                IniPath, "General", "RefreshMins")
    IniWrite(IsSet(Popup_Monitor) ? Popup_Monitor : 1,                                        IniPath, "General", "PopupMonitor")
    IniWrite(IsSet(Alert_Style) ? Alert_Style : "Toast",                                      IniPath, "General", "AlertStyle")
    IniWrite(IsSet(Popup_Sound) ? Popup_Sound : "Default",                                    IniPath, "General", "PopupSound")
    IniWrite((IsSet(Dim_Sound_Enabled) && Dim_Sound_Enabled) ? 1 : 0,                         IniPath, "General", "DimSound")
    IniWrite((IsSet(Wake_Sound_Enabled) && Wake_Sound_Enabled) ? 1 : 0,                       IniPath, "General", "WakeSound")
    IniWrite(IsSet(Sound_Volume_Step) ? Sound_Volume_Step : 50,                               IniPath, "General", "SoundVol")
    IniWrite((IsSet(Desktop_Hide_Enabled) && Desktop_Hide_Enabled) ? 1 : 0,                   IniPath, "General", "DeskHide")
    IniWrite(IsSet(Desktop_Idle_Sec) ? Desktop_Idle_Sec : 15,                                 IniPath, "General", "DeskIdle")
    IniWrite(IsSet(Icon_Fade_Ms) ? Icon_Fade_Ms : 300,                                        IniPath, "General", "IconFade")
    IniWrite((IsSet(Start_With_Windows) && Start_With_Windows) ? 1 : 0,                       IniPath, "General", "StartWin")
    IniWrite((IsSet(Start_Minimized) && Start_Minimized) ? 1 : 0,                             IniPath, "General", "StartMin")
    IniWrite((IsSet(Care_Taskbar_AutoHide) && Care_Taskbar_AutoHide) ? 1 : 0,                 IniPath, "General", "CareTaskbar")
    SaveAppSettingsToIni()
}

; ------------------------------------------------------------------------------
; The settings below are stored inside the script text when you run the .ahk, which a compiled .exe
; cannot do (and the older INI code above used different variable names for most of Monitor 1).
; They are kept in settings.ini under [App]. The .exe reads them back at startup; the .ahk keeps
; using the values written into the script, so editing PART 1 by hand still works there.
; ------------------------------------------------------------------------------
LoadAppSettingsFromIni() {
    global IniPath
    global OLED_HDR_SDR_Mode_Enabled, Comp_Game_Auto_SDR_Enabled
    global Primary_Dim_Percent, Primary_HDR_Dim_Percent, Primary_Fade_Ms
    global Primary_SDR_Desktop_Sec, Primary_SDR_Normal_Sec, Primary_SDR_Comp_Sec, Primary_SDR_Paused_Sec
    global Primary_HDR_Desktop_Sec, Primary_HDR_Normal_Sec, Primary_HDR_Comp_Sec, Primary_HDR_Paused_Sec
    global OLED_Refresh_Reminder_Days, OLED_Refresh_Reminder_Hours, OLED_Refresh_Reminder_Minutes
    global OLED_Refresh_Popup_Monitor, OLED_Refresh_Alert_Style, OLED_Refresh_Popup_Sound
    global Dim_Sound_Name, Wake_Sound_Name, UI_Custom_Color
    global Comp_Games_List, Excluded_Processes_List, Media_Players_List, Browsers_List, Tray_Menu_Config
    global Mon1_Hotkey, Mon2_Hotkey, Mon3_Hotkey, Mon4_Hotkey, Mon5_Hotkey

    if (!A_IsCompiled || !FileExist(IniPath)) {
        return
    }

    OLED_HDR_SDR_Mode_Enabled   := ReadIniBool("App", "HdrSdrMode", OLED_HDR_SDR_Mode_Enabled)
    Comp_Game_Auto_SDR_Enabled  := ReadIniBool("App", "CompAutoSdr", Comp_Game_Auto_SDR_Enabled)
    Primary_Dim_Percent         := Max(0, Min(100, ReadIniInt("App", "DimPercent", Primary_Dim_Percent)))
    Primary_HDR_Dim_Percent     := Max(0, Min(100, ReadIniInt("App", "HdrDimPercent", Primary_HDR_Dim_Percent)))
    Primary_Fade_Ms             := Max(0, Min(2000, ReadIniInt("App", "FadeMs", Primary_Fade_Ms)))
    Primary_SDR_Desktop_Sec     := Max(0, ReadIniInt("App", "SdrDesk", Primary_SDR_Desktop_Sec))
    Primary_SDR_Normal_Sec      := Max(0, ReadIniInt("App", "SdrNorm", Primary_SDR_Normal_Sec))
    Primary_SDR_Comp_Sec        := Max(0, ReadIniInt("App", "SdrComp", Primary_SDR_Comp_Sec))
    Primary_SDR_Paused_Sec      := Max(0, ReadIniInt("App", "SdrPause", Primary_SDR_Paused_Sec))
    Primary_HDR_Desktop_Sec     := Max(0, ReadIniInt("App", "HdrDesk", Primary_HDR_Desktop_Sec))
    Primary_HDR_Normal_Sec      := Max(0, ReadIniInt("App", "HdrNorm", Primary_HDR_Normal_Sec))
    Primary_HDR_Comp_Sec        := Max(0, ReadIniInt("App", "HdrComp", Primary_HDR_Comp_Sec))
    Primary_HDR_Paused_Sec      := Max(0, ReadIniInt("App", "HdrPause", Primary_HDR_Paused_Sec))

    OLED_Refresh_Reminder_Days    := Max(0, Min(365, ReadIniInt("App", "RefreshDays", OLED_Refresh_Reminder_Days)))
    OLED_Refresh_Reminder_Hours   := Max(0, Min(23, ReadIniInt("App", "RefreshHours", OLED_Refresh_Reminder_Hours)))
    OLED_Refresh_Reminder_Minutes := Max(0, Min(59, ReadIniInt("App", "RefreshMins", OLED_Refresh_Reminder_Minutes)))
    OLED_Refresh_Popup_Monitor    := Max(1, Min(5, ReadIniInt("App", "PopupMonitor", OLED_Refresh_Popup_Monitor)))
    OLED_Refresh_Alert_Style      := IniRead(IniPath, "App", "AlertStyle", OLED_Refresh_Alert_Style)
    OLED_Refresh_Popup_Sound      := IniRead(IniPath, "App", "PopupSound", OLED_Refresh_Popup_Sound)

    Dim_Sound_Name              := IniRead(IniPath, "App", "DimSoundName", Dim_Sound_Name)
    Wake_Sound_Name             := IniRead(IniPath, "App", "WakeSoundName", Wake_Sound_Name)
    UI_Custom_Color             := IniRead(IniPath, "App", "CustomColor", UI_Custom_Color)

    Comp_Games_List             := IniRead(IniPath, "App", "CompGamesList", Comp_Games_List)
    Excluded_Processes_List     := IniRead(IniPath, "App", "ExcludedList", Excluded_Processes_List)
    Media_Players_List          := IniRead(IniPath, "App", "MediaPlayersList", Media_Players_List)
    Browsers_List               := IniRead(IniPath, "App", "BrowsersList", Browsers_List)
    Tray_Menu_Config            := IniRead(IniPath, "App", "TrayMenuConfig", Tray_Menu_Config)

    Mon1_Hotkey                 := IniRead(IniPath, "App", "Mon1Hotkey", Mon1_Hotkey)
    Mon2_Hotkey                 := IniRead(IniPath, "App", "Mon2Hotkey", Mon2_Hotkey)
    Mon3_Hotkey                 := IniRead(IniPath, "App", "Mon3Hotkey", Mon3_Hotkey)
    Mon4_Hotkey                 := IniRead(IniPath, "App", "Mon4Hotkey", Mon4_Hotkey)
    Mon5_Hotkey                 := IniRead(IniPath, "App", "Mon5Hotkey", Mon5_Hotkey)
}

SaveAppSettingsToIni() {
    global IniPath
    global OLED_HDR_SDR_Mode_Enabled, Comp_Game_Auto_SDR_Enabled
    global Primary_Dim_Percent, Primary_HDR_Dim_Percent, Primary_Fade_Ms
    global Primary_SDR_Desktop_Sec, Primary_SDR_Normal_Sec, Primary_SDR_Comp_Sec, Primary_SDR_Paused_Sec
    global Primary_HDR_Desktop_Sec, Primary_HDR_Normal_Sec, Primary_HDR_Comp_Sec, Primary_HDR_Paused_Sec
    global OLED_Refresh_Reminder_Days, OLED_Refresh_Reminder_Hours, OLED_Refresh_Reminder_Minutes
    global OLED_Refresh_Popup_Monitor, OLED_Refresh_Alert_Style, OLED_Refresh_Popup_Sound
    global Dim_Sound_Name, Wake_Sound_Name, UI_Custom_Color
    global Comp_Games_List, Excluded_Processes_List, Media_Players_List, Browsers_List, Tray_Menu_Config
    global Mon1_Hotkey, Mon2_Hotkey, Mon3_Hotkey, Mon4_Hotkey, Mon5_Hotkey

    IniWrite(OLED_HDR_SDR_Mode_Enabled ? 1 : 0,  IniPath, "App", "HdrSdrMode")
    IniWrite(Comp_Game_Auto_SDR_Enabled ? 1 : 0, IniPath, "App", "CompAutoSdr")
    IniWrite(Primary_Dim_Percent,      IniPath, "App", "DimPercent")
    IniWrite(Primary_HDR_Dim_Percent,  IniPath, "App", "HdrDimPercent")
    IniWrite(Primary_Fade_Ms,          IniPath, "App", "FadeMs")
    IniWrite(Primary_SDR_Desktop_Sec,  IniPath, "App", "SdrDesk")
    IniWrite(Primary_SDR_Normal_Sec,   IniPath, "App", "SdrNorm")
    IniWrite(Primary_SDR_Comp_Sec,     IniPath, "App", "SdrComp")
    IniWrite(Primary_SDR_Paused_Sec,   IniPath, "App", "SdrPause")
    IniWrite(Primary_HDR_Desktop_Sec,  IniPath, "App", "HdrDesk")
    IniWrite(Primary_HDR_Normal_Sec,   IniPath, "App", "HdrNorm")
    IniWrite(Primary_HDR_Comp_Sec,     IniPath, "App", "HdrComp")
    IniWrite(Primary_HDR_Paused_Sec,   IniPath, "App", "HdrPause")

    IniWrite(OLED_Refresh_Reminder_Days,    IniPath, "App", "RefreshDays")
    IniWrite(OLED_Refresh_Reminder_Hours,   IniPath, "App", "RefreshHours")
    IniWrite(OLED_Refresh_Reminder_Minutes, IniPath, "App", "RefreshMins")
    IniWrite(OLED_Refresh_Popup_Monitor,    IniPath, "App", "PopupMonitor")
    IniWrite(OLED_Refresh_Alert_Style,      IniPath, "App", "AlertStyle")
    IniWrite(OLED_Refresh_Popup_Sound,      IniPath, "App", "PopupSound")

    IniWrite(Dim_Sound_Name,   IniPath, "App", "DimSoundName")
    IniWrite(Wake_Sound_Name,  IniPath, "App", "WakeSoundName")
    IniWrite(UI_Custom_Color,  IniPath, "App", "CustomColor")

    IniWrite(Comp_Games_List,         IniPath, "App", "CompGamesList")
    IniWrite(Excluded_Processes_List, IniPath, "App", "ExcludedList")
    IniWrite(Media_Players_List,      IniPath, "App", "MediaPlayersList")
    IniWrite(Browsers_List,           IniPath, "App", "BrowsersList")
    IniWrite(Tray_Menu_Config,        IniPath, "App", "TrayMenuConfig")

    IniWrite(Mon1_Hotkey, IniPath, "App", "Mon1Hotkey")
    IniWrite(Mon2_Hotkey, IniPath, "App", "Mon2Hotkey")
    IniWrite(Mon3_Hotkey, IniPath, "App", "Mon3Hotkey")
    IniWrite(Mon4_Hotkey, IniPath, "App", "Mon4Hotkey")
    IniWrite(Mon5_Hotkey, IniPath, "App", "Mon5Hotkey")
}

GetEffectiveExtraMonDimPercent(monIdx) {
    presetDim := GetPresetValue("m2Dim")
    if (presetDim > 0) {
        return Min(100, presetDim)
    }
    useHdr := GetExtraMonSetting(monIdx, "HdrSdrMode") && GetMonitorHdrInfo(monIdx).enabled
    return useHdr ? GetExtraMonSetting(monIdx, "HdrDimPercent") : GetExtraMonSetting(monIdx, "DimPercent")
}

GetEffectiveExtraMonAlpha(monIdx) {
    return Round(Max(0, Min(100, GetEffectiveExtraMonDimPercent(monIdx))) * 2.55)
}

GetEffectiveExtraMonTimeoutSec(monIdx, ctx := "") {
    if (ctx = "") {
        ctx := GetMonitorContext(monIdx)
    }
    presetSec := GetPresetValue("m2Sec")
    if (presetSec > 0) {
        return presetSec
    }
    useHdr := GetExtraMonSetting(monIdx, "HdrSdrMode") && GetMonitorHdrInfo(monIdx).enabled
    switch ctx {
        case "comp_game":
            return GetExtraMonSetting(monIdx, useHdr ? "HdrComp" : "SdrComp")
        case "normal_game":
            return GetExtraMonSetting(monIdx, useHdr ? "HdrNorm" : "SdrNorm")
        case "movie_paused":
            return GetExtraMonSetting(monIdx, useHdr ? "HdrPause" : "SdrPause")
        default:
            return GetExtraMonSetting(monIdx, useHdr ? "HdrDesk" : "SdrDesk")
    }
}

RefreshExtraHdrSwitchVisuals(swList, isMasterEnabled) {
    for swCtrl in swList {
        entry := EnsureHdrSwitchEntry(swCtrl)
        if IsObject(entry) {
            UpdateSdrHdrSwitchVisual(swCtrl, entry.supported, entry.enabled, isMasterEnabled)
        }
    }
}

MakeClearHotkeyCallback(hkCtrl) {
    return (*) => (
        hkCtrl.Value := "",
        MarkSettingsDirty()
    )
}

ResetHotkeyControlsToDefault(hkControlsMap) {
    for mIdx, hkCtrl in hkControlsMap {
        hkCtrl.Value := ""
    }
}

MakeExtraMonitorHdrClickCallback(monIdx, swCtrl, statusCtrl) {
    return (*) => ToggleMonitorHdrFromSwitch(monIdx, swCtrl, statusCtrl)
}

ToggleMonitorHdrFromSwitch(monIdx, swCtrl, statusCtrl) {
    global isTogglingHdr
    if isTogglingHdr {
        return
    }
    entry := EnsureHdrSwitchEntry(swCtrl)
    if (!IsObject(entry) || !entry.supported) {
        return
    }
    isTogglingHdr := true
    try {
        priIdx := MonitorGetPrimary()
        curInfo := GetMonitorHdrInfo(monIdx)
        nowHdr := SetMonitorHdrState(monIdx, !curInfo.enabled)
        statusCtrl.Text := "Monitor " monIdx " output is " (nowHdr ? "HDR" : "SDR")
        if (monIdx = priIdx) {
            SetupTrayMenu()
        }
        SyncLiveHdrIndicators()
    } finally {
        isTogglingHdr := false
    }
}

PopulateTrayListView(lv, items) {
    for item in items {
        lv.Add("", item.enabled ? "Keep" : "Hidden", GetTrayItemDisplayName(item.id))
    }
    lv.ModifyCol(1, 74)
    lv.ModifyCol(2, 266)
}

HitTestTrayListViewRow() {
    global trayListViewCtrl, trayDraftRef
    if !IsObject(trayListViewCtrl) || trayDraftRef.Length = 0 {
        return 0
    }
    pt := Buffer(8, 0)
    if !DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        return 0
    }
    DllCall("ScreenToClient", "Ptr", trayListViewCtrl.Hwnd, "Ptr", pt.Ptr)
    px := NumGet(pt, 0, "Int")
    py := NumGet(pt, 4, "Int")

    hitBuf := Buffer(24, 0)
    NumPut("Int", px, hitBuf, 0)
    NumPut("Int", py, hitBuf, 4)
    row := DllCall("SendMessage", "Ptr", trayListViewCtrl.Hwnd, "UInt", 0x1012, "Ptr", 0, "Ptr", hitBuf.Ptr, "Int") + 1
    if (row < 1) {
        return 1
    }
    if (row > trayDraftRef.Length) {
        return trayDraftRef.Length
    }
    return row
}

SetTrayDropHighlight(row) {
    global dragTrayHighlightRow, trayListViewCtrl
    if !IsObject(trayListViewCtrl) {
        return
    }
    if (dragTrayHighlightRow >= 1) {
        lvItemClear := Buffer(A_PtrSize * 9 + 16, 0)
        NumPut("UInt", 0x0008, lvItemClear, 12)
        NumPut("UInt", 0x0008, lvItemClear, 16)
        DllCall("SendMessage", "Ptr", trayListViewCtrl.Hwnd, "UInt", 0x102B, "Ptr", dragTrayHighlightRow - 1, "Ptr", lvItemClear.Ptr)
    }
    dragTrayHighlightRow := row
    if (row >= 1) {
        lvItemSet := Buffer(A_PtrSize * 9 + 16, 0)
        NumPut("UInt", 0x0008, lvItemSet, 12)
        NumPut("UInt", 0x0008, lvItemSet, 16)
        DllCall("SendMessage", "Ptr", trayListViewCtrl.Hwnd, "UInt", 0x102B, "Ptr", row - 1, "Ptr", lvItemSet.Ptr)
    }
}

OnLvBeginDrag(lvCtrl, lParam) {
    global dragTraySourceRow, isDraggingTrayRow, trayListViewCtrl
    if !IsObject(trayListViewCtrl) || (lvCtrl.Hwnd != trayListViewCtrl.Hwnd) {
        return
    }
    nmhdrSize := (A_PtrSize = 8) ? 24 : 12
    row := NumGet(lParam + nmhdrSize, 0, "Int") + 1
    if (row < 1) {
        row := lvCtrl.GetNext(0, "Focused")
    }
    if (row >= 1) {
        dragTraySourceRow := row
        isDraggingTrayRow := true
        DllCall("SetCapture", "Ptr", trayListViewCtrl.Hwnd)
        SetTrayDropHighlight(row)
    }
}

OnMouseMoveMsg(wParam, lParam, msg, hwnd) {
    global isDraggingTrayRow
    if !isDraggingTrayRow {
        return
    }
    targetRow := HitTestTrayListViewRow()
    if (targetRow >= 1) {
        SetTrayDropHighlight(targetRow)
    }
}

OnLeftButtonUp(wParam, lParam, msg, hwnd) {
    global isDraggingTrayRow, dragTraySourceRow, trayListViewCtrl, trayDraftRef, trayRefreshFn
    if !isDraggingTrayRow {
        return
    }
    DllCall("ReleaseCapture")
    targetRow := HitTestTrayListViewRow()
    SetTrayDropHighlight(0)

    isDraggingTrayRow := false
    srcRow := dragTraySourceRow
    dragTraySourceRow := 0

    if !IsObject(trayListViewCtrl) || trayDraftRef.Length = 0 {
        return
    }
    if (srcRow >= 1 && srcRow <= trayDraftRef.Length && targetRow >= 1 && targetRow <= trayDraftRef.Length && srcRow != targetRow) {
        movedItem := trayDraftRef.RemoveAt(srcRow)
        trayDraftRef.InsertAt(targetRow, movedItem)
        if IsObject(trayRefreshFn) {
            trayRefreshFn.Call(targetRow)
        }
        MarkSettingsDirty()
    }
}

SetControlsEnabled(ctrlList, enabled) {
    target := !!enabled
    for c in ctrlList {
        try {
            if (c.Enabled != target) {
                c.Enabled := target
                c.Redraw()
            }
        }
    }
}

; Dark / Light checkbox: goes back to the plain preset colors
ToggleDarkModeLive(newDarkState) {
    global UI_Dark_Mode, UI_Custom_Color
    UI_Custom_Color := ""
    UI_Dark_Mode := !!newDarkState
    ReapplyUiTheme()
}

; Applies (or clears, with "") a custom RRGGBB background color for the menu / Settings UI
ApplyCustomUiColor(hex) {
    global UI_Custom_Color
    UI_Custom_Color := hex
    ReapplyUiTheme()
    DebugLogEvent(hex = "" ? "Menu / Settings color reset to the plain Dark / Light theme" : ("Menu / Settings color set to #" hex))
}

; Rebuilds the palette and refreshes every open window, the tray menu and the saved settings
ReapplyUiTheme() {
    global UI_Dark_Mode, SettingsGui, SettingsTabsCtrl, StatsPromptGui, RefreshPromptGui
    savedTab := 1
    if IsObject(SettingsTabsCtrl) {
        try savedTab := SettingsTabsCtrl.Value
    }
    RefreshThemeColors()
    ApplyMenuTheme(UI_Dark_Mode)
    ApplyTrayMenuColor()
    SetupTrayMenu()
    SaveSettingsToScript()
    if IsObject(SettingsGui) {
        CloseSettingsGui()
        OpenSettingsGui(savedTab)
    }
    if IsObject(StatsPromptGui) {
        CloseStatsPromptGui()
        ShowOledCareStatus()
    }
    if IsObject(RefreshPromptGui) {
        CloseRefreshPromptGui()
        ShowRefreshReminderPopup()
    }
}

CreateEyedropperCursor() {
    w := 32, h := 32
    andMask := Buffer(128, 0xFF)
    xorMask := Buffer(128, 0x00)
    setPx := (x, y, isWhite) => (
        (x >= 0 && x < 32 && y >= 0 && y < 32) ? (
            byteIdx := (y * 4) + (x // 8),
            bitMask := 1 << (7 - Mod(x, 8)),
            NumPut("UChar", NumGet(andMask, byteIdx, "UChar") & ~bitMask, andMask, byteIdx),
            isWhite ? NumPut("UChar", NumGet(xorMask, byteIdx, "UChar") | bitMask, xorMask, byteIdx) : 0
        ) : 0
    )
    ; Diagonal eyedropper: tip at (1, 30), barrel up-right, bulb at top-right
    Loop 14 {
        i := A_Index - 1
        x := 2 + i
        y := 29 - i
        setPx(x, y, true)
        setPx(x + 1, y, false)
        setPx(x, y - 1, false)
        setPx(x + 1, y - 1, true)
    }
    ; Collar
    for pt in [[15,14],[16,13],[17,12],[18,15],[19,14],[20,13]] {
        setPx(pt[1], pt[2], false)
    }
    ; Bulb
    Loop 6 {
        dy := A_Index - 1
        Loop 6 {
            dx := A_Index - 1
            if (dx + dy >= 2 && dx + dy <= 8) {
                isEdge := (dx = 0 || dy = 0 || dx = 5 || dy = 5)
                setPx(18 + dx, 6 + dy, !isEdge)
            }
        }
    }
    ; Precision tip hotspot at (1, 30)
    setPx(1, 30, false)
    return DllCall("CreateCursor", "Ptr", 0, "Int", 1, "Int", 30, "Int", w, "Int", h, "Ptr", andMask.Ptr, "Ptr", xorMask.Ptr, "Ptr")
}

SetEyedropperSystemCursor(enable) {
    static active := false
    if (enable = active) {
        return
    }
    active := enable
    if enable {
        cursorIds := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]
        for id in cursorIds {
            hCur := CreateEyedropperCursor()
            if hCur {
                DllCall("SetSystemCursor", "Ptr", hCur, "UInt", id)
            }
        }
    } else {
        DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
    }
}

; Screen Eyedropper: sample any pixel anywhere on screen (left-click to pick, right-click or Esc to cancel)
StartColorEyedropper(onPickedCallback := "") {
    static active := false, waitRelease := true, lastHex := "", pickedCb := ""
    if active {
        return
    }
    active := true
    waitRelease := GetKeyState("LButton", "P")
    lastHex := ""
    pickedCb := onPickedCallback
    SetEyedropperSystemCursor(true)

    tickFn := (*) => (
        (!active) ? 0 : EyedropperStep(&active, &waitRelease, &lastHex, &pickedCb, tickFn)
    )
    SetTimer(tickFn, 16)
}

EyedropperStep(&active, &waitRelease, &lastHex, &pickedCb, tickFn) {
    lDown := GetKeyState("LButton", "P")
    rDown := GetKeyState("RButton", "P")
    escDown := GetKeyState("Escape", "P")

    if (rDown || escDown) {
        active := false
        SetTimer(tickFn, 0)
        SetEyedropperSystemCursor(false)
        ToolTip()
        return
    }

    pt := Buffer(8, 0)
    if !DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        return
    }
    cx := NumGet(pt, 0, "Int")
    cy := NumGet(pt, 4, "Int")

    hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
    bgr := DllCall("GetPixel", "Ptr", hdc, "Int", cx, "Int", cy, "UInt")
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)

    if (bgr != 0xFFFFFFFF) {
        lastHex := Format("{:06X}", RgbToBgr(bgr & 0x00FFFFFF))
    }

    ; Keep tooltip pinned directly beside the cursor
    ToolTip("Eyedropper: #" (lastHex != "" ? lastHex : "------") "`nLeft-click to pick  •  Right-click / Esc to cancel", cx + 18, cy + 16)

    if waitRelease {
        if !lDown {
            waitRelease := false
        }
        return
    }

    if lDown {
        active := false
        SetTimer(tickFn, 0)
        SetEyedropperSystemCursor(false)
        ToolTip()
        KeyWait("LButton", "T1")
        if (lastHex != "") {
            if IsObject(pickedCb) {
                pickedCb.Call(lastHex)
            } else {
                ApplyCustomUiColor(lastHex)
            }
        }
    }
}

; Windows color picker (ChooseColor)
PickCustomUiColor() {
    global UI_Custom_Color, SettingsGui, ThemeBgRgb
    static custColors := Buffer(64, 0)
    startRgb := RegExMatch(UI_Custom_Color, "i)^[0-9a-f]{6}$") ? Integer("0x" UI_Custom_Color) : ThemeBgRgb
    cc := Buffer(A_PtrSize = 8 ? 72 : 36, 0)
    rgbOff := A_PtrSize * 3
    NumPut("UInt", cc.Size, cc, 0)
    NumPut("Ptr", IsObject(SettingsGui) ? SettingsGui.Hwnd : 0, cc, A_PtrSize)
    NumPut("UInt", RgbToBgr(startRgb), cc, rgbOff)
    NumPut("Ptr", custColors.Ptr, cc, rgbOff + A_PtrSize)
    NumPut("UInt", 0x3, cc, rgbOff + A_PtrSize * 2)          ; CC_RGBINIT | CC_FULLOPEN
    if !DllCall("comdlg32\ChooseColorW", "Ptr", cc, "Int") {
        return
    }
    ApplyCustomUiColor(Format("{:06X}", RgbToBgr(NumGet(cc, rgbOff, "UInt"))))
}

RgbToBgr(rgb) {
    return ((rgb & 0xFF) << 16) | (rgb & 0xFF00) | ((rgb >> 16) & 0xFF)
}

MixRgb(a, b, t) {
    r  := Round(((a >> 16) & 0xFF) * (1 - t) + ((b >> 16) & 0xFF) * t)
    gr := Round(((a >> 8) & 0xFF) * (1 - t) + ((b >> 8) & 0xFF) * t)
    bl := Round((a & 0xFF) * (1 - t) + (b & 0xFF) * t)
    return (r << 16) | (gr << 8) | bl
}

; Palette for every window: plain Dark / Light preset, or the user's custom color.
; With a custom color, text contrast (UI_Dark_Mode) follows the color's brightness automatically.
RefreshThemeColors() {
    global UI_Dark_Mode, UI_Custom_Color, ThemeBgRgb, ThemeSurfaceRgb, themeBgBrush, themeSurfaceBrush
    if RegExMatch(UI_Custom_Color, "i)^[0-9a-f]{6}$") {
        bg := Integer("0x" UI_Custom_Color)
        brightness := (((bg >> 16) & 0xFF) * 299 + ((bg >> 8) & 0xFF) * 587 + (bg & 0xFF) * 114) / 1000
        UI_Dark_Mode := (brightness < 140)
        ThemeBgRgb := bg
        ThemeSurfaceRgb := MixRgb(bg, 0xFFFFFF, UI_Dark_Mode ? 0.10 : 0.55)    ; input boxes / lists sit a little lighter
    } else {
        UI_Custom_Color := ""
        ThemeBgRgb := UI_Dark_Mode ? 0x1E1E1E : 0xF4F5F7
        ThemeSurfaceRgb := UI_Dark_Mode ? 0x282828 : 0xFFFFFF
    }
    oldBg := themeBgBrush
    oldSurface := themeSurfaceBrush
    themeBgBrush := DllCall("CreateSolidBrush", "UInt", RgbToBgr(ThemeBgRgb), "Ptr")
    themeSurfaceBrush := DllCall("CreateSolidBrush", "UInt", RgbToBgr(ThemeSurfaceRgb), "Ptr")
    for br in [oldBg, oldSurface] {
        if br {
            try DllCall("DeleteObject", "Ptr", br)
        }
    }
}

; Best effort: paints the tray menu background with the custom color (Windows may ignore this when its own dark menu style is active)
ApplyTrayMenuColor() {
    global UI_Custom_Color, ThemeBgRgb
    static trayBrush := 0
    try {
        newBrush := (UI_Custom_Color != "") ? DllCall("CreateSolidBrush", "UInt", RgbToBgr(ThemeBgRgb), "Ptr") : 0
        mi := Buffer(A_PtrSize = 8 ? 40 : 28, 0)
        NumPut("UInt", mi.Size, mi, 0)
        NumPut("UInt", 0x80000002, mi, 4)                    ; MIM_BACKGROUND | MIM_APPLYTOSUBMENUS
        NumPut("Ptr", newBrush, mi, 16)
        DllCall("SetMenuInfo", "Ptr", A_TrayMenu.Handle, "Ptr", mi)
        if trayBrush {
            DllCall("DeleteObject", "Ptr", trayBrush)
        }
        trayBrush := newBrush
    }
}

ToggleActiveHdrSdrSwitch(*) {
    nowHdr := SetWindowsPrimaryHdrState(!QueryWindowsPrimaryHdrState())
    SaveSettingsToScript()
    SetupTrayMenu()
    SyncLiveHdrIndicators()
    RefreshStatsGuiFields()
    return nowHdr
}

ToggleHdrSdrMode(*) {
    global OLED_HDR_SDR_Mode_Enabled, lastHdrCheckTick
    OLED_HDR_SDR_Mode_Enabled := !OLED_HDR_SDR_Mode_Enabled
    lastHdrCheckTick := 0
    SaveSettingsToScript()
    SetupTrayMenu()
    RefreshStatsGuiFields()
}
SyncSettingsLiveRefreshTimer(*) {
    global SettingsGui, CareUiRefs, oledActiveMsSinceRefresh
    if (!IsObject(SettingsGui) || !CareUiRefs.Has("hoursTxt") || !IsObject(CareUiRefs["hoursTxt"])) {
        SetTimer(SyncSettingsLiveRefreshTimer, 0)
        return
    }
    try {
        CareUiRefs["hoursTxt"].Text := "Active time since refresh: " FormatDuration(oledActiveMsSinceRefresh)
    }
}

CloseSettingsGui(*) {
    global SettingsGui, SettingsTabsCtrl, SettingsTabDefaultBanner, SettingsTabTipMap, GroupTitleTips, HdrSwitchMap, CareUiRefs
    global SettingsApplyBtn, SettingsHintCtrl, SettingsLastBannerText, isDraggingTrayRow, dragTraySourceRow, lastHoveredKey
    global LiveStatusRefs
    SetTimer(SyncLiveStatusBoxes, 0)
    SetTimer(SyncLiveHdrIndicators, 0)
    SetTimer(SyncSettingsLiveRefreshTimer, 0)
    if isDraggingTrayRow {
        DllCall("ReleaseCapture")
    }
    SetTrayDropHighlight(0)
    isDraggingTrayRow := false
    dragTraySourceRow := 0
    lastHoveredKey := ""
    GroupTitleTips := []
    LiveStatusRefs := []
    HdrSwitchMap := Map()
    CareUiRefs := Map()
    SettingsTabsCtrl := ""
    SettingsTabDefaultBanner := Map()
    SettingsTabTipMap := Map()
    SettingsApplyBtn := ""
    SettingsHintCtrl := ""
    SettingsLastBannerText := ""
    ToolTip()
    if IsObject(SettingsGui) {
        try SettingsGui.Destroy()
    }
    SettingsGui := ""
}

CommitSettingsFromGui(
    closeAfter,
    darkMode, debugLog, debugLogPath,
    priAuto, hdrSdrMode, compAutoSdr, activeHdr, priDark, priHdrDark, priFade,
    refreshRem, refreshDays, refreshHours, refreshMins,
    popupMon, alertStyle, popupSound,
    dimSound, wakeSound, soundVolStep,
    sdrDesk, sdrNorm, sdrComp, sdrPause,
    hdrDesk, hdrNorm, hdrComp, hdrPause,
    extraMonTabCtrls,
    deskHide, deskIdle, iconFade,
    startWin, startMin, tbarAutoHide,
    compList, exclList, trayItemsDraft, hkControlsMap,
    mediaList?, browserList?
) {
    global Desktop_Hide_Enabled, Desktop_Idle_Sec, Icon_Fade_Ms, Start_With_Windows, Start_Minimized
    global Taskbar_AutoHide_Enabled
    global UI_Dark_Mode, Debug_Log_Enabled, Debug_Log_Path, DefaultDebugLogPath, SettingsTabsCtrl
    global Primary_Auto_Enabled, OLED_HDR_SDR_Mode_Enabled, Comp_Game_Auto_SDR_Enabled, Active_HDR_Mode, cachedHdrState, lastHdrCheckTick
    global Primary_Dim_Percent, Primary_HDR_Dim_Percent, Primary_Dim_Alpha, Primary_HDR_Dim_Alpha, Primary_Fade_Ms
    global OLED_Refresh_Reminder_Enabled, OLED_Refresh_Reminder_Days, OLED_Refresh_Reminder_Hours, OLED_Refresh_Reminder_Minutes
    global OLED_Refresh_Popup_Monitor, OLED_Refresh_Alert_Style, OLED_Refresh_Popup_Sound
    global Dim_Sound_Enabled, Wake_Sound_Enabled, Dim_Sound_Name, Wake_Sound_Name, Sound_Volume_Step
    global Primary_SDR_Desktop_Sec, Primary_SDR_Normal_Sec, Primary_SDR_Comp_Sec, Primary_SDR_Paused_Sec
    global Primary_HDR_Desktop_Sec, Primary_HDR_Normal_Sec, Primary_HDR_Comp_Sec, Primary_HDR_Paused_Sec
    global Extra_Auto_Enabled, Extra_HDR_SDR_Mode_Enabled, Extra_Comp_Game_Auto_SDR
    global Extra_Dim_Percent, Extra_HDR_Dim_Percent, Extra_Dim_Alpha, Extra_HDR_Dim_Alpha, Extra_Fade_Ms
    global Extra_SDR_Desktop_Sec, Extra_SDR_Normal_Sec, Extra_SDR_Comp_Sec, Extra_SDR_Paused_Sec
    global Extra_HDR_Desktop_Sec, Extra_HDR_Normal_Sec, Extra_HDR_Comp_Sec, Extra_HDR_Paused_Sec
    global Comp_Games_List, Excluded_Processes_List, TrayMenuItems, Tray_Menu_Config, lastCompCheckTick, lastExcludedCheckTick
    global Media_Players_List, Browsers_List
    global isAutoPrimaryDimmed, isManualBlackoutOn, isManualPrimaryDimOn, isAutoExtraDimmed, isManualExtraDimOn, manualExtraMonSet

    savedTab := 1
    if IsObject(SettingsTabsCtrl) {
        try savedTab := SettingsTabsCtrl.Value
    }

    prevDark := UI_Dark_Mode
    UI_Dark_Mode := !!darkMode    
    Debug_Log_Enabled := !!debugLog
    cleanLogPath := Trim(debugLogPath)
    Debug_Log_Path := (cleanLogPath = "" || StrLower(cleanLogPath) = StrLower(DefaultDebugLogPath)) ? "" : cleanLogPath
    ApplyMenuTheme(UI_Dark_Mode)

    Primary_Auto_Enabled          := !!priAuto
    OLED_HDR_SDR_Mode_Enabled     := !!hdrSdrMode
    Comp_Game_Auto_SDR_Enabled    := !!compAutoSdr
    Active_HDR_Mode               := !!activeHdr
    cachedHdrState                := Active_HDR_Mode
    lastHdrCheckTick              := A_TickCount

    Primary_Dim_Percent           := Max(0, Min(100, Integer(priDark)))
    Primary_HDR_Dim_Percent       := Max(0, Min(100, Integer(priHdrDark)))
    Primary_Dim_Alpha             := Round(Primary_Dim_Percent * 2.55)
    Primary_HDR_Dim_Alpha         := Round(Primary_HDR_Dim_Percent * 2.55)
    Primary_Fade_Ms               := Max(0, Min(2000, Integer(priFade)))

    OLED_Refresh_Reminder_Enabled := !!refreshRem
    OLED_Refresh_Reminder_Days    := IsNumber(refreshDays)   ? Max(0, Min(365, Integer(refreshDays))) : 0
    OLED_Refresh_Reminder_Hours   := IsNumber(refreshHours)  ? Max(0, Min(23, Integer(refreshHours))) : 1
    OLED_Refresh_Reminder_Minutes := IsNumber(refreshMins)   ? Max(0, Min(59, Integer(refreshMins))) : 30
    OLED_Refresh_Popup_Monitor    := IsNumber(popupMon)      ? Max(1, Min(5, Integer(popupMon)))      : 1
    OLED_Refresh_Alert_Style      := (alertStyle = "Notification") ? "Notification" : "Popup"
    OLED_Refresh_Popup_Sound      := (popupSound != "") ? popupSound : "None"

    Dim_Sound_Enabled             := !!dimSound
    Wake_Sound_Enabled            := !!wakeSound
    Sound_Volume_Step             := IsNumber(soundVolStep) ? Max(0, Min(3, Integer(soundVolStep))) : 2

    Primary_SDR_Desktop_Sec       := IsNumber(sdrDesk)     ? Max(0, Integer(sdrDesk))     : 23
    Primary_SDR_Normal_Sec        := IsNumber(sdrNorm)     ? Max(0, Integer(sdrNorm))     : 35
    Primary_SDR_Comp_Sec          := IsNumber(sdrComp)     ? Max(0, Integer(sdrComp))     : 45
    Primary_SDR_Paused_Sec        := IsNumber(sdrPause)    ? Max(0, Integer(sdrPause))    : 10
    Primary_HDR_Desktop_Sec       := IsNumber(hdrDesk)     ? Max(0, Integer(hdrDesk))     : 15
    Primary_HDR_Normal_Sec        := IsNumber(hdrNorm)     ? Max(0, Integer(hdrNorm))     : 23
    Primary_HDR_Comp_Sec          := IsNumber(hdrComp)     ? Max(0, Integer(hdrComp))     : 23
    Primary_HDR_Paused_Sec        := IsNumber(hdrPause)    ? Max(0, Integer(hdrPause))    : 10

    for mIdx, mc in extraMonTabCtrls {
        SetExtraMonSetting(mIdx, "Auto",          mc.chkAuto.Value)
        SetExtraMonSetting(mIdx, "HdrSdrMode",    mc.chkHdrSdr.Value)
        SetExtraMonSetting(mIdx, "CompAutoSdr",   mc.chkCompSdr.Value)
        SetExtraMonSetting(mIdx, "DimPercent",    mc.sldDark.Value)
        SetExtraMonSetting(mIdx, "HdrDimPercent", mc.sldHdrDark.Value)
        SetExtraMonSetting(mIdx, "FadeMs",        mc.sldFade.Value)
        SetExtraMonSetting(mIdx, "SdrDesk",       IsNumber(mc.edtSdrDesk.Value)  ? mc.edtSdrDesk.Value  : 15)
        SetExtraMonSetting(mIdx, "SdrNorm",       IsNumber(mc.edtSdrNorm.Value)  ? mc.edtSdrNorm.Value  : 5)
        SetExtraMonSetting(mIdx, "SdrComp",       IsNumber(mc.edtSdrComp.Value)  ? mc.edtSdrComp.Value  : 5)
        SetExtraMonSetting(mIdx, "SdrPause",      IsNumber(mc.edtSdrPause.Value) ? mc.edtSdrPause.Value : 10)
        SetExtraMonSetting(mIdx, "HdrDesk",       IsNumber(mc.edtHdrDesk.Value)  ? mc.edtHdrDesk.Value  : 15)
        SetExtraMonSetting(mIdx, "HdrNorm",       IsNumber(mc.edtHdrNorm.Value)  ? mc.edtHdrNorm.Value  : 5)
        SetExtraMonSetting(mIdx, "HdrComp",       IsNumber(mc.edtHdrComp.Value)  ? mc.edtHdrComp.Value  : 5)
        SetExtraMonSetting(mIdx, "HdrPause",      IsNumber(mc.edtHdrPause.Value) ? mc.edtHdrPause.Value : 10)
    }

    Desktop_Hide_Enabled          := !!deskHide
    Desktop_Idle_Sec              := IsNumber(deskIdle)    ? Max(0, Integer(deskIdle))    : 5
    Icon_Fade_Ms                  := Max(0, Min(2000, Integer(iconFade)))
    Start_With_Windows            := !!startWin
    Start_Minimized               := !!startMin
    Taskbar_AutoHide_Enabled      := !!tbarAutoHide
    SyncStartupRegistry(Start_With_Windows)
    SyncWindowsTaskbarAutoHide(PresetTaskbarTarget())

    Comp_Games_List               := Trim(StrReplace(StrReplace(compList, "`r", ""), "`n", " "))
    lastCompCheckTick             := 0
    ParseCompGamesList()

    Excluded_Processes_List       := Trim(StrReplace(StrReplace(exclList, "`r", ""), "`n", " "))
    lastExcludedCheckTick         := 0
    ParseExcludedProcessesList()

    if (IsSet(mediaList) && IsSet(browserList)) {
        Media_Players_List        := CleanExeList(mediaList)
        Browsers_List             := CleanExeList(browserList)
        ParseMediaBrowserLists()
    }

    for mIdx, hkCtrl in hkControlsMap {
        SetMonitorHotkeyVar(mIdx, hkCtrl.Value)
    }
    RegisterAllMonitorHotkeys()

    TrayMenuItems := CloneTrayItems(trayItemsDraft)
    Tray_Menu_Config := SerializeTrayItems(TrayMenuItems)

    SaveSettingsToScript()
    SavePresetsToIni()
    try ApplyAutomationChanges()
    SaveOledCareState()
    UpdateTrayRefreshVisuals(true)
    SetupTrayMenu()
    ResetAllIdleTimers()
    DebugLogEvent("Settings saved - Monitor 1 auto-dim " OnOff(Primary_Auto_Enabled) ", other monitors auto-dim " OnOff(IsAnyExtraMonAutoEnabled()) ", theme " (UI_Custom_Color != "" ? ("custom #" UI_Custom_Color) : (UI_Dark_Mode ? "dark" : "light")))

    activePrimaryAlphaCap := GetActivePrimaryDimAlpha()
    if (!isManualBlackoutOn) {
        if (isAutoPrimaryDimmed || isManualPrimaryDimOn) {
            StartPrimaryOverlayFade(activePrimaryAlphaCap)
        }
    }
    if (!Desktop_Hide_Enabled) {
        SetCursorIdleHidden(false)
        SetDesktopIconsTarget(true)
    }
    activeExtraAlphaCap := GetActiveExtraDimAlpha()
    if ((!IsAnyExtraMonAutoEnabled() || activeExtraAlphaCap = 0) && isAutoExtraDimmed && manualExtraMonSet.Count = 0) {
        isAutoExtraDimmed := false
        StartExtraFade(0)
    } else if (isAutoExtraDimmed || isManualExtraDimOn || manualExtraMonSet.Count > 0) {
        StartExtraFade(activeExtraAlphaCap)
    }
    UpdateCursorVisibility()

    if closeAfter {
        CloseSettingsGui()
    } else if (prevDark != UI_Dark_Mode) {
        CloseSettingsGui()
        OpenSettingsGui(savedTab)
    } else {
        SetSettingsClean()
        RepaintSettingsGui()
    }
}

RepaintSettingsGui() {
    global SettingsGui
    if !IsObject(SettingsGui) {
        return
    }
    try {
        DllCall("RedrawWindow", "Ptr", SettingsGui.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0181)          ; INVALIDATE|ALLCHILDREN|UPDATENOW (no erase flicker)
    }
}

SaveSettingsToScript() {
    global UI_Dark_Mode, UI_Custom_Color, Debug_Log_Enabled, Debug_Log_Path
    global Primary_Auto_Enabled, OLED_HDR_SDR_Mode_Enabled, Comp_Game_Auto_SDR_Enabled, Active_HDR_Mode, Primary_Dim_Percent, Primary_HDR_Dim_Percent, Primary_Fade_Ms
    global OLED_Refresh_Reminder_Enabled, OLED_Refresh_Reminder_Days, OLED_Refresh_Reminder_Hours, OLED_Refresh_Reminder_Minutes
    global OLED_Refresh_Popup_Monitor, OLED_Refresh_Alert_Style, OLED_Refresh_Popup_Sound
    global Dim_Sound_Enabled, Wake_Sound_Enabled, Dim_Sound_Name, Wake_Sound_Name, Sound_Volume_Step
    global Primary_SDR_Desktop_Sec, Primary_SDR_Normal_Sec, Primary_SDR_Comp_Sec, Primary_SDR_Paused_Sec
    global Primary_HDR_Desktop_Sec, Primary_HDR_Normal_Sec, Primary_HDR_Comp_Sec, Primary_HDR_Paused_Sec
    global Extra_Auto_Enabled, Extra_HDR_SDR_Mode_Enabled, Extra_Comp_Game_Auto_SDR
    global Extra_Dim_Percent, Extra_HDR_Dim_Percent, Extra_Fade_Ms
    global Extra_SDR_Desktop_Sec, Extra_SDR_Normal_Sec, Extra_SDR_Comp_Sec, Extra_SDR_Paused_Sec
    global Extra_HDR_Desktop_Sec, Extra_HDR_Normal_Sec, Extra_HDR_Comp_Sec, Extra_HDR_Paused_Sec
    global Mon3_Auto_Enabled, Mon3_HDR_SDR_Mode_Enabled, Mon3_Comp_Game_Auto_SDR, Mon3_Dim_Percent, Mon3_HDR_Dim_Percent, Mon3_Fade_Ms
    global Mon3_SDR_Desktop_Sec, Mon3_SDR_Normal_Sec, Mon3_SDR_Comp_Sec, Mon3_SDR_Paused_Sec, Mon3_HDR_Desktop_Sec, Mon3_HDR_Normal_Sec, Mon3_HDR_Comp_Sec, Mon3_HDR_Paused_Sec
    global Mon4_Auto_Enabled, Mon4_HDR_SDR_Mode_Enabled, Mon4_Comp_Game_Auto_SDR, Mon4_Dim_Percent, Mon4_HDR_Dim_Percent, Mon4_Fade_Ms
    global Mon4_SDR_Desktop_Sec, Mon4_SDR_Normal_Sec, Mon4_SDR_Comp_Sec, Mon4_SDR_Paused_Sec, Mon4_HDR_Desktop_Sec, Mon4_HDR_Normal_Sec, Mon4_HDR_Comp_Sec, Mon4_HDR_Paused_Sec
    global Mon5_Auto_Enabled, Mon5_HDR_SDR_Mode_Enabled, Mon5_Comp_Game_Auto_SDR, Mon5_Dim_Percent, Mon5_HDR_Dim_Percent, Mon5_Fade_Ms
    global Mon5_SDR_Desktop_Sec, Mon5_SDR_Normal_Sec, Mon5_SDR_Comp_Sec, Mon5_SDR_Paused_Sec, Mon5_HDR_Desktop_Sec, Mon5_HDR_Normal_Sec, Mon5_HDR_Comp_Sec, Mon5_HDR_Paused_Sec

    SaveSettingsToIni()
    if (A_IsCompiled)
        return
    global Desktop_Hide_Enabled, Desktop_Idle_Sec, Icon_Fade_Ms, Start_With_Windows, Start_Minimized
    global Comp_Games_List, Excluded_Processes_List, Tray_Menu_Config
    global Media_Players_List, Browsers_List
    global Mon1_Hotkey, Mon2_Hotkey, Mon3_Hotkey, Mon4_Hotkey, Mon5_Hotkey

    try {
        code := FileRead(A_ScriptFullPath, "UTF-8")
        ; Backups: last good copy, plus one per day (kept 14 days)
        if InStr(code, "INTERNAL SCRIPT ENGINE") {
            autoDir := A_ScriptDir "\backups\auto"
            try DirCreate(autoDir)
            try FileCopy(A_ScriptFullPath, autoDir "\" A_ScriptName ".bak", 1)
            dayBak := autoDir "\" A_ScriptName "." A_YYYY A_MM A_DD ".bak"
            if !FileExist(dayBak) {
                try FileCopy(A_ScriptFullPath, dayBak)
            }
            Loop Files, autoDir "\*.bak" {
                if (A_LoopFileName != A_ScriptName ".bak" && DateDiff(A_Now, A_LoopFileTimeModified, "Days") > 14) {
                    try FileDelete(A_LoopFilePath)
                }
            }
        }

        SetScriptVar(&code, "Primary_Auto_Enabled",          Primary_Auto_Enabled ? "true" : "false")
        SetScriptVar(&code, "OLED_HDR_SDR_Mode_Enabled",     OLED_HDR_SDR_Mode_Enabled ? "true" : "false")
        SetScriptVar(&code, "Comp_Game_Auto_SDR_Enabled",    Comp_Game_Auto_SDR_Enabled ? "true" : "false")
        SetScriptVar(&code, "Active_HDR_Mode",               Active_HDR_Mode ? "true" : "false")
        SetScriptVar(&code, "Primary_Dim_Percent",           Primary_Dim_Percent)
        SetScriptVar(&code, "Primary_HDR_Dim_Percent",       Primary_HDR_Dim_Percent)
        SetScriptVar(&code, "Primary_Fade_Ms",               Primary_Fade_Ms)

        SetScriptVar(&code, "UI_Dark_Mode",                  UI_Dark_Mode ? "true" : "false")
        SetScriptVar(&code, "UI_Custom_Color",               UI_Custom_Color, true)
        SetScriptVar(&code, "Debug_Log_Enabled",             Debug_Log_Enabled ? "true" : "false")
        SetScriptVar(&code, "Debug_Log_Path",                Debug_Log_Path, true)
        SetScriptVar(&code, "OLED_Refresh_Reminder_Enabled", OLED_Refresh_Reminder_Enabled ? "true" : "false")
        SetScriptVar(&code, "OLED_Refresh_Reminder_Days",    OLED_Refresh_Reminder_Days)
        SetScriptVar(&code, "OLED_Refresh_Reminder_Hours",   OLED_Refresh_Reminder_Hours)
        SetScriptVar(&code, "OLED_Refresh_Reminder_Minutes", OLED_Refresh_Reminder_Minutes)
        SetScriptVar(&code, "OLED_Refresh_Popup_Monitor",    OLED_Refresh_Popup_Monitor)
        SetScriptVar(&code, "OLED_Refresh_Alert_Style",      OLED_Refresh_Alert_Style, true)
        SetScriptVar(&code, "OLED_Refresh_Popup_Sound",      OLED_Refresh_Popup_Sound, true)

        SetScriptVar(&code, "Dim_Sound_Enabled",             Dim_Sound_Enabled ? "true" : "false")
        SetScriptVar(&code, "Wake_Sound_Enabled",            Wake_Sound_Enabled ? "true" : "false")
        SetScriptVar(&code, "Dim_Sound_Name",                Dim_Sound_Name, true)
        SetScriptVar(&code, "Wake_Sound_Name",               Wake_Sound_Name, true)
        SetScriptVar(&code, "Sound_Volume_Step",             Sound_Volume_Step)

        SetScriptVar(&code, "Primary_SDR_Desktop_Sec",       Primary_SDR_Desktop_Sec)
        SetScriptVar(&code, "Primary_SDR_Normal_Sec",        Primary_SDR_Normal_Sec)
        SetScriptVar(&code, "Primary_SDR_Comp_Sec",          Primary_SDR_Comp_Sec)
        SetScriptVar(&code, "Primary_SDR_Paused_Sec",        Primary_SDR_Paused_Sec)
        SetScriptVar(&code, "Primary_HDR_Desktop_Sec",       Primary_HDR_Desktop_Sec)
        SetScriptVar(&code, "Primary_HDR_Normal_Sec",        Primary_HDR_Normal_Sec)
        SetScriptVar(&code, "Primary_HDR_Comp_Sec",          Primary_HDR_Comp_Sec)
        SetScriptVar(&code, "Primary_HDR_Paused_Sec",        Primary_HDR_Paused_Sec)

        SetScriptVar(&code, "Extra_Auto_Enabled",            Extra_Auto_Enabled ? "true" : "false")
        SetScriptVar(&code, "Extra_HDR_SDR_Mode_Enabled",    Extra_HDR_SDR_Mode_Enabled ? "true" : "false")
        SetScriptVar(&code, "Extra_Comp_Game_Auto_SDR",      Extra_Comp_Game_Auto_SDR ? "true" : "false")
        SetScriptVar(&code, "Extra_Dim_Percent",             Extra_Dim_Percent)
        SetScriptVar(&code, "Extra_HDR_Dim_Percent",         Extra_HDR_Dim_Percent)
        SetScriptVar(&code, "Extra_Fade_Ms",                 Extra_Fade_Ms)

        SetScriptVar(&code, "Extra_SDR_Desktop_Sec",         Extra_SDR_Desktop_Sec)
        SetScriptVar(&code, "Extra_SDR_Normal_Sec",          Extra_SDR_Normal_Sec)
        SetScriptVar(&code, "Extra_SDR_Comp_Sec",            Extra_SDR_Comp_Sec)
        SetScriptVar(&code, "Extra_SDR_Paused_Sec",          Extra_SDR_Paused_Sec)
        SetScriptVar(&code, "Extra_HDR_Desktop_Sec",         Extra_HDR_Desktop_Sec)
        SetScriptVar(&code, "Extra_HDR_Normal_Sec",          Extra_HDR_Normal_Sec)
        SetScriptVar(&code, "Extra_HDR_Comp_Sec",            Extra_HDR_Comp_Sec)
        SetScriptVar(&code, "Extra_HDR_Paused_Sec",          Extra_HDR_Paused_Sec)

       for mNum in [3, 4, 5] {
            SetScriptVar(&code, "Mon" mNum "_Auto_Enabled",         GetExtraMonSetting(mNum, "Auto") ? "true" : "false")
            SetScriptVar(&code, "Mon" mNum "_HDR_SDR_Mode_Enabled", GetExtraMonSetting(mNum, "HdrSdrMode") ? "true" : "false")
            SetScriptVar(&code, "Mon" mNum "_Comp_Game_Auto_SDR",   GetExtraMonSetting(mNum, "CompAutoSdr") ? "true" : "false")
            SetScriptVar(&code, "Mon" mNum "_Dim_Percent",          GetExtraMonSetting(mNum, "DimPercent"))
            SetScriptVar(&code, "Mon" mNum "_HDR_Dim_Percent",      GetExtraMonSetting(mNum, "HdrDimPercent"))
            SetScriptVar(&code, "Mon" mNum "_Fade_Ms",              GetExtraMonSetting(mNum, "FadeMs"))
            SetScriptVar(&code, "Mon" mNum "_SDR_Desktop_Sec",      GetExtraMonSetting(mNum, "SdrDesk"))
            SetScriptVar(&code, "Mon" mNum "_SDR_Normal_Sec",       GetExtraMonSetting(mNum, "SdrNorm"))
            SetScriptVar(&code, "Mon" mNum "_SDR_Comp_Sec",         GetExtraMonSetting(mNum, "SdrComp"))
            SetScriptVar(&code, "Mon" mNum "_SDR_Paused_Sec",       GetExtraMonSetting(mNum, "SdrPause"))
            SetScriptVar(&code, "Mon" mNum "_HDR_Desktop_Sec",      GetExtraMonSetting(mNum, "HdrDesk"))
            SetScriptVar(&code, "Mon" mNum "_HDR_Normal_Sec",       GetExtraMonSetting(mNum, "HdrNorm"))
            SetScriptVar(&code, "Mon" mNum "_HDR_Comp_Sec",         GetExtraMonSetting(mNum, "HdrComp"))
            SetScriptVar(&code, "Mon" mNum "_HDR_Paused_Sec",       GetExtraMonSetting(mNum, "HdrPause"))
        }

        SetScriptVar(&code, "Desktop_Hide_Enabled",          Desktop_Hide_Enabled ? "true" : "false")
        SetScriptVar(&code, "Desktop_Idle_Sec",              Desktop_Idle_Sec)
        SetScriptVar(&code, "Icon_Fade_Ms",                  Icon_Fade_Ms)
        SetScriptVar(&code, "Start_With_Windows",            Start_With_Windows ? "true" : "false")
        SetScriptVar(&code, "Start_Minimized",               Start_Minimized ? "true" : "false")

        SetScriptVar(&code, "Comp_Games_List",               Comp_Games_List, true)
        SetScriptVar(&code, "Excluded_Processes_List",       Excluded_Processes_List, true)
        SetScriptVar(&code, "Media_Players_List",            Media_Players_List, true)
        SetScriptVar(&code, "Browsers_List",                 Browsers_List, true)
        SetScriptVar(&code, "Tray_Menu_Config",              Tray_Menu_Config, true)

        SetScriptVar(&code, "Mon1_Hotkey",                   Mon1_Hotkey, true)
        SetScriptVar(&code, "Mon2_Hotkey",                   Mon2_Hotkey, true)
        SetScriptVar(&code, "Mon3_Hotkey",                   Mon3_Hotkey, true)
        SetScriptVar(&code, "Mon4_Hotkey",                   Mon4_Hotkey, true)
        SetScriptVar(&code, "Mon5_Hotkey",                   Mon5_Hotkey, true)

                ; Safe save: write a temp copy, check it, then swap it in
        tmpPath := A_ScriptFullPath ".tmp"
        f := FileOpen(tmpPath, "w", "UTF-8")
        f.Write(code)
        f.Close()
        if (InStr(code, "INTERNAL SCRIPT ENGINE") && FileGetSize(tmpPath) > 1000) {
            FileMove(tmpPath, A_ScriptFullPath, 1)
        } else {
            try FileDelete(tmpPath)
            DebugLogEvent("Settings were NOT written to the script (the new copy looked incomplete)", "WARN")
        }
    }
}

SetScriptVar(&code, varName, val, isString := false) {
    formatted := isString ? '"' StrReplace(val, '"', '`"') '"' : String(val)
    safeVal   := StrReplace(formatted, "$", "$$")
    code      := RegExReplace(code, "m)^(\s*" varName "\s*:=\s*)[^;\r\n]+(.*)$", "${1}" safeVal "        ${2}", , 1)
}

ParseCompGamesList() {
    global Comp_Games_List, Comp_Game_Processes
    Comp_Game_Processes := []
    for item in StrSplit(Comp_Games_List, ",") {
        exe := Trim(item)
        if (exe != "") {
            Comp_Game_Processes.Push(exe)
        }
    }
}

ParseExcludedProcessesList() {
    global Excluded_Processes_List, Excluded_Processes
    Excluded_Processes := []
    for item in StrSplit(Excluded_Processes_List, ",") {
        exe := Trim(item)
        if (exe != "") {
            Excluded_Processes.Push(exe)
        }
    }
}

; Builds the live video-player / browser lists from the General tab text (blank = built-in lists)
ParseMediaBrowserLists() {
    global Media_Players_List, Browsers_List, Media_Player_Processes, Browser_Processes
    global Default_Media_Player_Processes, Default_Browser_Processes
    mp := []
    for item in StrSplit(Media_Players_List, ",") {
        exe := Trim(item)
        if (exe != "") {
            mp.Push(exe)
        }
    }
    br := []
    for item in StrSplit(Browsers_List, ",") {
        exe := Trim(item)
        if (exe != "") {
            br.Push(exe)
        }
    }
    Media_Player_Processes := (mp.Length > 0) ? mp : Default_Media_Player_Processes.Clone()
    Browser_Processes      := (br.Length > 0) ? br : Default_Browser_Processes.Clone()
}

GetMediaPlayersListText() {
    global Media_Player_Processes
    return JoinArray(Media_Player_Processes, ", ")
}

GetBrowsersListText() {
    global Browser_Processes
    return JoinArray(Browser_Processes, ", ")
}

; Tidies a typed list: commas / new lines / semicolons separate names, duplicates dropped, quotes removed
CleanExeList(txt) {
    txt := StrReplace(txt, '"', "")
    txt := StrReplace(txt, "``", "")
    for ch in ["`r`n", "`n", "`r", "`t", ";"] {
        txt := StrReplace(txt, ch, ",")
    }
    seen := Map()
    out := ""
    for item in StrSplit(txt, ",") {
        exe := Trim(item)
        key := StrLower(exe)
        if (exe = "" || seen.Has(key)) {
            continue
        }
        seen[key] := true
        out .= (out = "" ? "" : ", ") exe
    }
    return out
}

; ==============================================================================
; SETTINGS BACKUP (General tab): open the config folder, back up, restore
; ==============================================================================
GetSettingsBackupDirs() {
    global ConfigDir
    return [["config", ConfigDir]]
}

OpenSettingsFolder() {
    global IniPath
    SplitPath(IniPath, , &iniDir)
    if !DirExist(iniDir) {
        try DirCreate(iniDir)
    }
    try Run('explorer.exe "' iniDir '"')
}

; Copies the script (it stores most settings inside itself) and every .ini into backups\Backup <date time>.
; Returns the new backup folder, or "" if it failed.
BackupSettingsNow(quiet := false, tag := "") {
    root := A_ScriptDir "\backups"
    dest := root "\Backup " FormatTime(, "yyyy-MM-dd HHmmss") tag
    count := 0
    try {
        DirCreate(dest)
        if (!A_IsCompiled && FileExist(A_ScriptFullPath)) {
            FileCopy(A_ScriptFullPath, dest "\" A_ScriptName, 1)
            count += 1
        }
        for spec in GetSettingsBackupDirs() {
            if !DirExist(spec[2]) {
                continue
            }
            DirCreate(dest "\" spec[1])
            Loop Files, spec[2] "\*.ini" {
                FileCopy(A_LoopFilePath, dest "\" spec[1] "\" A_LoopFileName, 1)
                count += 1
            }
        }
    } catch as err {
        MsgBox("Backup failed:`n" err.Message, "Settings Backup", "Icon!")
        return ""
    }
    if !quiet {
        MsgBox("Backed up " count " file(s) to:`n" dest, "Settings Backup", "Iconi")
    }
    return dest
}

RestoreSettingsBackup() {
    global ConfigDir
    root := A_ScriptDir "\backups"
    try DirCreate(root)
    picked := DirSelect("*" root, 0, "Pick a backup folder to restore")
    if (picked = "") {
        return
    }
    picked := RTrim(picked, "\")
    scriptSrc := picked "\" A_ScriptName
    hasScript := (!A_IsCompiled && FileExist(scriptSrc))
    hasIni := false
    specs := GetSettingsBackupDirs()
    specs.Push(["data-config", ConfigDir])   ; backups made by older versions used this folder name
    for spec in specs {
        if DirExist(picked "\" spec[1]) {
            hasIni := true
        }
    }
    if (!hasScript && !hasIni) {
        MsgBox("That folder doesn't look like an OLED Engine backup.", "Restore Backup", "Icon!")
        return
    }
    ask := "Restore settings from:`n" picked "`n`nThis replaces your current settings files"
        . (hasScript ? " and the script file" : "") ", then reloads OLED Engine."
        . "`nA safety copy of your current settings is made first."
    if (MsgBox(ask, "Restore Backup", "YesNo Icon?") != "Yes") {
        return
    }
    if (BackupSettingsNow(true, " (before restore)") = "") {
        return
    }
    try {
        for spec in specs {
            srcDir := picked "\" spec[1]
            if !DirExist(srcDir) {
                continue
            }
            DirCreate(spec[2])
            Loop Files, srcDir "\*.ini" {
                FileCopy(A_LoopFilePath, spec[2] "\" A_LoopFileName, 1)
            }
        }
        if hasScript {
            FileCopy(scriptSrc, A_ScriptFullPath, 1)
        }
    } catch as err {
        MsgBox("Restore failed part-way:`n" err.Message "`n`nYour previous settings were saved in the 'backups' folder (marked 'before restore').", "Restore Backup", "Icon!")
        return
    }
    Reload()
}

IsExcludedProcessRunning() {
    global cachedExcludedRunning, lastExcludedCheckTick, Excluded_Processes
    if PresetNeverDimActive() {
        return true
    }
    if (Excluded_Processes.Length = 0) {
        return false
    }
   
    if (A_TickCount - lastExcludedCheckTick < 1000) {
        return cachedExcludedRunning
    }
    lastExcludedCheckTick := A_TickCount

    for proc in Excluded_Processes {
        if ProcessExist(proc) {
            cachedExcludedRunning := true
            return true
        }
    }
    cachedExcludedRunning := false
    return false
}

GetDefaultTrayItems() {
    return [
        { id: "pause",      enabled: true },
        { id: "auto_dim",   enabled: true },
        { id: "hdr_toggle", enabled: true },
        { id: "hdr_sdr",    enabled: false },
        { id: "refresh",    enabled: true },
        { id: "blackout",   enabled: true },
        { id: "sec_dim",    enabled: true },
        { id: "desk_hide",  enabled: true },
        { id: "edit",       enabled: false },
        { id: "reload",     enabled: false }
    ]
}

CloneTrayItems(src) {
    out := []
    for item in src {
        out.Push({ id: item.id, enabled: !!item.enabled })
    }
    return out
}

SerializeTrayItems(items) {
    parts := []
    for item in items {
        parts.Push(item.id ":" (item.enabled ? "1" : "0"))
    }
    return JoinArray(parts, ",")
}

JoinArray(arr, sep) {
    res := ""
    for idx, val in arr {
        res .= (idx > 1 ? sep : "") . val
    }
    return res
}

ParseTrayMenuConfig() {
    global Tray_Menu_Config, TrayMenuItems
    defaults := GetDefaultTrayItems()
    byId := Map()
    for d in defaults {
        byId[d.id] := d
    }

    parsed := []
    seen := Map()
    for part in StrSplit(Tray_Menu_Config, ",") {
        raw := Trim(part)
        if (raw = "") {
            continue
        }
        tokens := StrSplit(raw, ":")
        id := Trim(tokens[1])
        if !byId.Has(id) || seen.Has(id) {
            continue
        }
        en := (tokens.Length >= 2) ? (Trim(tokens[2]) != "0") : true
        parsed.Push({ id: id, enabled: en })
        seen[id] := true
    }

    for d in defaults {
        if !seen.Has(d.id) {
            parsed.Push({ id: d.id, enabled: d.enabled })
        }
    }
    TrayMenuItems := parsed
}

GetTrayItemMenuLabel(id) {
    global OLED_HDR_SDR_Mode_Enabled, Active_HDR_Mode, Mon1_Hotkey, Mon2_Hotkey
    switch id {
        case "hdr_toggle":
            return Active_HDR_Mode ? "Switch to SDR Mode" : "Switch to HDR Mode"
        case "hdr_sdr":
            return OLED_HDR_SDR_Mode_Enabled ? "Use Unified Profile" : "Use Separate HDR / SDR Profiles"
        case "refresh":
            return "Mark Pixel Refreshed"
        case "pause":
            return "Pause Automation"
        case "auto_dim":
            return "Auto Dim (manual dim only when off)"
        case "blackout":
            hkDisp := FormatHotkeyForDisplay(Mon1_Hotkey)
            return (hkDisp != "") ? ("Dim / Blackout Monitor 1 (" hkDisp ")") : "Dim / Blackout Monitor 1"
        case "sec_dim":
            hkDisp := FormatHotkeyForDisplay(Mon2_Hotkey)
            return (hkDisp != "") ? ("Dim / Blackout Monitors 2+ (" hkDisp ")") : "Dim / Blackout Monitors 2+"
        case "desk_hide":
            return "Hide Cursor && Desktop Icons"
        case "edit":
            return "Edit Script"
        case "reload":
            return "Reload Script"
        default:
            return id
    }
}

GetTrayItemDisplayName(id) {
    return StrReplace(GetTrayItemMenuLabel(id), "&&", "&")
}

GetActivePrimaryDimAlpha() {
    global Primary_Dim_Alpha, Primary_HDR_Dim_Alpha, OLED_HDR_SDR_Mode_Enabled
    presetDim := GetPresetValue("m1Dim")
    if (presetDim > 0) {
        return Round(Min(100, presetDim) * 2.55)
    }
    return (!OLED_HDR_SDR_Mode_Enabled || !IsPrimaryDisplayHdrEnabled())
        ? Primary_Dim_Alpha
        : Primary_HDR_Dim_Alpha
}

IsAnyExtraDisplayHdrEnabled() {
    priIdx := MonitorGetPrimary()
    Loop GetDetectedMonitorCount() {
        if (A_Index != priIdx && GetMonitorHdrInfo(A_Index).enabled) {
            return true
        }
    }
    return false
}

GetActiveExtraDimAlpha() {
    priIdx := MonitorGetPrimary()
    maxAlpha := 0
    Loop GetDetectedMonitorCount() {
        if (A_Index != priIdx) {
            maxAlpha := Max(maxAlpha, GetEffectiveExtraMonAlpha(A_Index))
        }
    }
    return maxAlpha
}

GetRefreshReminderThresholdMs() {
    global OLED_Refresh_Reminder_Days, OLED_Refresh_Reminder_Hours, OLED_Refresh_Reminder_Minutes
    totalMins := (Max(0, OLED_Refresh_Reminder_Days) * 1440)
        + (Max(0, OLED_Refresh_Reminder_Hours) * 60)
        + Max(0, Min(59, OLED_Refresh_Reminder_Minutes))
    return totalMins * 60000
}

FormatRefreshIntervalLabel() {
    global OLED_Refresh_Reminder_Days, OLED_Refresh_Reminder_Hours, OLED_Refresh_Reminder_Minutes
    days := Max(0, OLED_Refresh_Reminder_Days)
    hrs  := Max(0, OLED_Refresh_Reminder_Hours)
    mins := Max(0, Min(59, OLED_Refresh_Reminder_Minutes))
    return days "d " hrs "h " mins "m"
}

GetSafePopupMonitorWorkArea(targetMonIdx) {
    monCount := GetDetectedMonitorCount()
    priIdx := MonitorGetPrimary()

    ; Primary: requested monitor (1-5)
    if (targetMonIdx >= 1 && targetMonIdx <= monCount) {
        try {
            MonitorGetWorkArea(targetMonIdx, &wL, &wT, &wR, &wB)
            if (wR > wL && wB > wT) {
                return { ok: true, monIdx: targetMonIdx, fallback: false, l: wL, t: wT, r: wR, b: wB }
            }
        }
    }

    ; Backup 1: revert to main/primary monitor if selected monitor disconnected
    try {
        MonitorGetWorkArea(priIdx, &wL, &wT, &wR, &wB)
        if (wR > wL && wB > wT) {
            return { ok: true, monIdx: priIdx, fallback: true, l: wL, t: wT, r: wR, b: wB }
        }
    }

    ; Backup 2: virtual screen bounds fallback
    return { ok: false, monIdx: priIdx, fallback: true, l: 0, t: 0, r: A_ScreenWidth, b: A_ScreenHeight }
}

IsInGameOrFullscreenSession() {
    ctx := GetPrimaryContext()
    if (ctx = "comp_game" || ctx = "normal_game" || IsCompGameRunning()) {
        return true
    }
    fgHwnd := DllCall("GetForegroundWindow", "Ptr")
    if (fgHwnd && fgHwnd != A_ScriptHwnd) {
        Loop GetDetectedMonitorCount() {
            if IsWindowFullscreenOnMonitor(fgHwnd, A_Index) {
                return true
            }
        }
    }
    return false
}

CloseRefreshPromptGui(*) {
    global RefreshPromptGui, lastHoveredKey
    lastHoveredKey := ""
    ToolTip()
    if IsObject(RefreshPromptGui) {
        try RefreshPromptGui.Destroy()
    }
    RefreshPromptGui := ""
}

ShowRefreshReminderPopup() {
    global RefreshPromptGui, UI_Dark_Mode, oledActiveMsSinceRefresh, OLED_Refresh_Popup_Sound, OLED_Refresh_Popup_Monitor

    if IsObject(RefreshPromptGui) {
        try {
            area := GetSafePopupMonitorWorkArea(OLED_Refresh_Popup_Monitor)
            WinGetPos(, , &gw, &gh, RefreshPromptGui.Hwnd)
            if (area.ok && gw > 0 && gh > 0) {
                px := Max(area.l, Min(area.r - gw, area.l + ((area.r - area.l - gw) // 2)))
                py := Max(area.t, Min(area.b - gh, area.t + ((area.b - area.t - gh) // 2)))
                RefreshPromptGui.Show("x" px " y" py " NoActivate")
            } else {
                RefreshPromptGui.Show("AutoSize Center NoActivate")
            }
            PlaySoundByName(OLED_Refresh_Popup_Sound)
            return
        }
    }

    area := GetSafePopupMonitorWorkArea(OLED_Refresh_Popup_Monitor)
    g := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox -DPIScale", "! Pixel Refresh Reminder")
    ApplyGuiTheme(g, UI_Dark_Mode)
    g.MarginX := 16
    g.MarginY := 14

    AddSectionBox(g, 16, 14, 360, 84, "!  Manual OSD Pixel Refresh Due", UI_Dark_Mode)
    fbNote := area.fallback ? "`n(Monitor " OLED_Refresh_Popup_Monitor " disconnected — shown on Monitor " area.monIdx ")" : ""
    txtMsg := g.AddText("x28 y36 w336", "Active time: " FormatDuration(oledActiveMsSinceRefresh) " (target: " FormatRefreshIntervalLabel() ").`nRun a manual pixel refresh in your monitor OSD." fbNote)
    StyleControlTheme(txtMsg, UI_Dark_Mode)

    btnReset := g.AddButton("x16 y110 w164 h28", "Mark Pixel Refreshed")
    btnLater := g.AddButton("x+10 yp w96 h28 Default", "Dismiss")
    StyleControlTheme(btnReset, UI_Dark_Mode)
    StyleControlTheme(btnLater, UI_Dark_Mode)

    RegisterTip(btnReset, "Click this AFTER you have run the pixel refresh from your monitor's own menu. It sets the active-time counter back to zero and clears the reminder.")
    RegisterTip(btnLater, "Hides this reminder for now. If a refresh is still due you will be reminded again in about 15 minutes.")
    btnReset.OnEvent("Click", (*) => (MarkPixelRefreshed(), CloseRefreshPromptGui()))
    btnLater.OnEvent("Click", CloseRefreshPromptGui)
    g.OnEvent("Close", CloseRefreshPromptGui)
    g.OnEvent("Escape", CloseRefreshPromptGui)

    RefreshPromptGui := g
    SetTimer(PollHoverTooltip, 80)
    g.Show("AutoSize Hide")
    WinGetPos(, , &gw, &gh, g.Hwnd)
    if (area.ok && gw > 0 && gh > 0) {
        px := Max(area.l, Min(area.r - gw, area.l + ((area.r - area.l - gw) // 2)))
        py := Max(area.t, Min(area.b - gh, area.t + ((area.b - area.t - gh) // 2)))
        ShowWithFade(g, "x" px " y" py " NoActivate")
    } else {
        ShowWithFade(g, "AutoSize Center NoActivate")
    }
    PlaySoundByName(OLED_Refresh_Popup_Sound)
}

CheckStartupOledRefreshReminder() {
    global OLED_Refresh_Reminder_Enabled, OLED_Refresh_Alert_Style, oledActiveMsSinceRefresh
    global lastRefreshPromptTick, pendingRefreshReminder, isSessionLocked

    UpdateTrayRefreshVisuals(true)
    if !OLED_Refresh_Reminder_Enabled {
        return
    }
    thresholdMs := GetRefreshReminderThresholdMs()
    if (thresholdMs > 0 && oledActiveMsSinceRefresh >= thresholdMs) {
        if isSessionLocked {
            pendingRefreshReminder := true
            return
        }
        lastRefreshPromptTick := A_TickCount
        pendingRefreshReminder := false
        DebugLogEvent("Pixel refresh is already overdue at startup (active time " FormatDuration(oledActiveMsSinceRefresh) ") - showing the reminder")
        if (OLED_Refresh_Alert_Style = "Notification") {
            try TrayTip("Active time: " FormatDuration(oledActiveMsSinceRefresh) " — run manual OSD pixel refresh.", "Pixel Refresh Reminder", 1)
        } else {
            ShowRefreshReminderPopup()
        }
    }
}

DispatchRefreshReminderAlert() {
    global OLED_Refresh_Alert_Style, oledActiveMsSinceRefresh, pendingRefreshReminder

    if (OLED_Refresh_Alert_Style = "Notification") {
        pendingRefreshReminder := false
        try TrayTip("Active time: " FormatDuration(oledActiveMsSinceRefresh) " — run manual OSD pixel refresh.", "Pixel Refresh Reminder", 1)
        return
    }

    if IsInGameOrFullscreenSession() {
        pendingRefreshReminder := true
        return
    }

    pendingRefreshReminder := false
    ShowRefreshReminderPopup()
}

; ==============================================================================
; 6. WINDOWS HDR STATE / TOGGLE (STRICT CAPABILITY CHECK) & CONTEXT DETECTION
; ==============================================================================
GetMonitorHdrInfo(monIdx) {
    monName := ""
    try monName := MonitorGetName(monIdx)
    if (monName = "") {
        return { supported: false, enabled: false }
    }

    topo := GetDisplayTopoSnapshot()
    if !topo.paths.Has(monName) {
        return { supported: false, enabled: false }
    }
    tgt := topo.paths[monName]

    colorBuf    := Buffer(32, 0)
    sdrWhiteBuf := Buffer(24, 0)

    DllCall("RtlZeroMemory", "Ptr", colorBuf.Ptr, "UPtr", 32)
    NumPut("UInt", 9, colorBuf, 0)
    NumPut("UInt", 32, colorBuf, 4)
    NumPut("UInt", tgt.tgtLow, colorBuf, 8)
    NumPut("Int", tgt.tgtHigh, colorBuf, 12)
    NumPut("UInt", tgt.tgtId, colorBuf, 16)

    if (DllCall("user32\DisplayConfigGetDeviceInfo", "Ptr", colorBuf.Ptr, "Int") = 0) {
        flags         := NumGet(colorBuf, 20, "UInt")
        encoding      := NumGet(colorBuf, 24, "UInt")
        bpc           := NumGet(colorBuf, 28, "UInt")
        advSupported  := (flags & 0x1) != 0
        advEnabled    := (flags & 0x2) != 0
        forceDisabled := (flags & 0x4) != 0

        DllCall("RtlZeroMemory", "Ptr", sdrWhiteBuf.Ptr, "UPtr", 24)
        NumPut("UInt", 11, sdrWhiteBuf, 0)
        NumPut("UInt", 24, sdrWhiteBuf, 4)
        NumPut("UInt", tgt.tgtLow, sdrWhiteBuf, 8)
        NumPut("Int", tgt.tgtHigh, sdrWhiteBuf, 12)
        NumPut("UInt", tgt.tgtId, sdrWhiteBuf, 16)
        hasSdrWhiteLevel := (DllCall("user32\DisplayConfigGetDeviceInfo", "Ptr", sdrWhiteBuf.Ptr, "Int") = 0)
            && (NumGet(sdrWhiteBuf, 20, "UInt") >= 1000)

        supported := advSupported && !forceDisabled && (bpc >= 10 || encoding = 3) && hasSdrWhiteLevel
        enabled   := supported && (advEnabled || encoding = 3)
        return { supported: supported, enabled: enabled }
    }
    return { supported: false, enabled: false }
}

QueryWindowsPrimaryHdrState() {
    return GetMonitorHdrInfo(MonitorGetPrimary()).enabled
}

SetMonitorHdrState(monIdx, enableHdr) {
    global cachedHdrState, Active_HDR_Mode, lastHdrCheckTick, lastDisplayChangeTick
    priIdx := MonitorGetPrimary()
    curInfo := GetMonitorHdrInfo(monIdx)
    if !curInfo.supported {
        return false
    }
    lastDisplayChangeTick := A_TickCount

    targetHdr := !!enableHdr
    applied := false

    monName := ""
    try monName := MonitorGetName(monIdx)
    topo := GetDisplayTopoSnapshot()

    if (monName != "" && topo.paths.Has(monName)) {
        tgt := topo.paths[monName]
        setColorBuf := Buffer(24, 0)
        NumPut("UInt", 10, setColorBuf, 0)
        NumPut("UInt", 24, setColorBuf, 4)
        NumPut("UInt", tgt.tgtLow, setColorBuf, 8)
        NumPut("Int", tgt.tgtHigh, setColorBuf, 12)
        NumPut("UInt", tgt.tgtId, setColorBuf, 16)
        NumPut("UInt", targetHdr ? 0x1 : 0x0, setColorBuf, 20)

        if (DllCall("user32\DisplayConfigSetDeviceInfo", "Ptr", setColorBuf.Ptr, "Int") = 0) {
            applied := true
        }
    }

    if (!applied && monIdx = priIdx) {
        Send("{LWin down}{LAlt down}b{LAlt up}{LWin up}")
        Sleep(450)
    }

    InvalidateDisplayTopoCache()
    lastDisplayChangeTick := A_TickCount
    actualHdr := GetMonitorHdrInfo(monIdx).enabled
    if (monIdx = priIdx) {
        cachedHdrState := actualHdr
        Active_HDR_Mode := actualHdr
        lastHdrCheckTick := A_TickCount
    }
    DebugLogEvent("HDR on Monitor " monIdx ": asked for " (targetHdr ? "ON" : "OFF") ", result is " (actualHdr ? "ON" : "OFF") ((actualHdr = targetHdr) ? "" : " - Windows did not apply the change"), (actualHdr = targetHdr) ? "INFO" : "WARN")
    return actualHdr
}

SetWindowsPrimaryHdrState(enableHdr) {
    return SetMonitorHdrState(MonitorGetPrimary(), enableHdr)
}

IsPrimaryDisplayHdrEnabled() {
    global cachedHdrState, lastHdrCheckTick
    if (A_TickCount - lastHdrCheckTick < 5000) {
        return cachedHdrState
    }
    lastHdrCheckTick := A_TickCount
    cachedHdrState := QueryWindowsPrimaryHdrState()
    return cachedHdrState
}

GetForegroundWindowSnapshot() {
    fgHwnd := DllCall("GetForegroundWindow", "Ptr")
    if !fgHwnd {
        return { hwnd: 0, class: "", exe: "", pid: 0, title: "", valid: false }
    }
    fgClass := ""
    fgExe   := ""
    fgPid   := 0
    fgTitle := ""
    try fgClass := WinGetClass("ahk_id " fgHwnd)
    try fgExe   := WinGetProcessName("ahk_id " fgHwnd)
    try fgPid   := WinGetPID("ahk_id " fgHwnd)
    try fgTitle := WinGetTitle("ahk_id " fgHwnd)

    if (fgClass = "" || fgClass = "Progman" || fgClass = "WorkerW" || fgClass = "Shell_TrayWnd" || fgClass = "Shell_SecondaryTrayWnd") {
        return { hwnd: fgHwnd, class: fgClass, exe: fgExe, pid: fgPid, title: fgTitle, valid: false }
    }
    return { hwnd: fgHwnd, class: fgClass, exe: fgExe, pid: fgPid, title: fgTitle, valid: true }
}

; ------------------------------------------------------------------------------
; PER-MONITOR ACTIVITY DETECTION
; Every monitor now looks at ITS OWN top window instead of sharing the foreground window.
; ------------------------------------------------------------------------------
IsShellWindowClass(cls) {
    return (cls = "" || cls = "Progman" || cls = "WorkerW" || cls = "Shell_TrayWnd" || cls = "Shell_SecondaryTrayWnd")
}

IsWindowBigOnMonitor(hwnd, monIdx) {
    try {
        MonitorGet(monIdx, &ml, &mt, &mr, &mb)
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hwnd)
        return (ww * wh) >= ((mr - ml) * (mb - mt) * 0.10)
    }
    return false
}

; Returns Map(monIdx -> [window snapshots]) with the visible stack on each monitor, from the top down to (and including)
; the first maximized / fullscreen window. Looking at the whole visible stack (not only the single top window) means an
; overlay, a helper window or a player's separate video window can no longer hide a paused video.
GetMonitorOwnerWindows(fgSnap, monCount) {
    stacks := Map()
    done   := Map()
    seen   := Map()
    ownPid := DllCall("GetCurrentProcessId", "UInt")

    AddWin(mi, w) {
        if !stacks.Has(mi) {
            stacks[mi] := []
        }
        stacks[mi].Push(w)
        seen[w.hwnd] := true
        try {
            if (WinGetMinMax("ahk_id " w.hwnd) = 1 || IsWindowFullscreenOnMonitor(w.hwnd, mi)) {
                done[mi] := true
            }
        }
    }

    if (IsObject(fgSnap) && fgSnap.valid && fgSnap.pid != ownPid) {
        fm := GetWindowMonitorIndex(fgSnap.hwnd)
        if (fm > 0) {
            AddWin(fm, { hwnd: fgSnap.hwnd, class: fgSnap.class, exe: fgSnap.exe, pid: fgSnap.pid, title: fgSnap.title, valid: true, isFg: true })
        }
    }

    hwnd  := DllCall("GetTopWindow", "Ptr", 0, "Ptr")
    steps := 0
    while (hwnd && done.Count < monCount && steps < 300) {
        steps += 1
        try {
            if (!seen.Has(hwnd) && DllCall("IsWindowVisible", "Ptr", hwnd, "Int") && !DllCall("IsIconic", "Ptr", hwnd, "Int")) {
                cloaked := 0
                DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "UInt*", &cloaked, "UInt", 4)
                exStyle := DllCall("GetWindowLongPtr", "Ptr", hwnd, "Int", -20, "Ptr")
                if (!cloaked && !(exStyle & 0x80) && !(exStyle & 0x20) && !(exStyle & 0x08000000)) {
                    mi := GetWindowMonitorIndex(hwnd)
                    if (mi > 0 && !done.Has(mi) && (!stacks.Has(mi) || stacks[mi].Length < 6)) {
                        pid := WinGetPID("ahk_id " hwnd)
                        cls := WinGetClass("ahk_id " hwnd)
                        if (pid != ownPid && !IsShellWindowClass(cls) && IsWindowBigOnMonitor(hwnd, mi)) {
                            AddWin(mi, { hwnd: hwnd, class: cls, exe: WinGetProcessName("ahk_id " hwnd), pid: pid, title: WinGetTitle("ahk_id " hwnd), valid: true, isFg: false })
                        }
                    }
                }
            }
        }
        hwnd := DllCall("GetWindow", "Ptr", hwnd, "UInt", 2, "Ptr")
    }
    return stacks
}

CtxPriority(ctx) {
    switch ctx {
        case "comp_game":     return 5
        case "movie_playing": return 4
        case "normal_game":   return 3
        case "movie_paused":  return 2
        default:              return 1
    }
}

; Browser video on this monitor. Returns "movie_playing", "movie_paused" or "" (not a video situation).
; A paused fullscreen video used to fall through to "Standard game" because browsers drop / stop reporting their
; media session after a pause. Now: paused (5) or stopped (3) counts, and a session that vanishes after having
; been seen playing / paused is remembered for 30 minutes.
ClassifyBrowserContext(snap, monIdx, isFs, isMax) {
    static lastMediaSeen := Map()
    key  := snap.hwnd
    now  := A_TickCount
    pb   := QueryGsmtcPlaybackState(snap.exe)
    full := (isFs || isMax)

    ; Playing: GSMTC says so (4), or - for browsers whose media session Windows can't match (Firefox, some Chromium
    ; builds) - the browser has an audible audio session while fullscreen / maximized.
    playing := (pb = 4)
    if (!playing && full && pb != 5 && pb != 3) {
        try playing := HasActiveAudioSession(snap.pid, snap.exe)
    }
    if playing {
        lastMediaSeen[key] := now
        if (full && IsWindowCoveredOnMonitor(snap.hwnd, monIdx)) {
            return "desktop"
        }
        return "movie_playing"
    }

    if !full {
        return ""
    }

    if (pb = 5 || pb = 3) {
        lastMediaSeen[key] := now
        return "movie_paused"
    }

    ; No media session and no sound. A fullscreen browser here is a paused / idle video, never a "game".
    if isFs {
        return "movie_paused"
    }
    ; Maximized only: use it as paused when a video was seen on this window in the last 30 minutes or the tab is a video site
    if (lastMediaSeen.Has(key) && (now - lastMediaSeen[key]) < 1800000) {
        return "movie_paused"
    }
    if IsKnownVideoTabTitle(snap.title) {
        return "movie_paused"
    }
    return ""
}

; Classifies ONE window as seen on ONE monitor.
ClassifyWindowContext(snap, monIdx) {
    global Comp_Game_Processes, Media_Player_Processes, Browser_Processes

    exeLow := StrLower(snap.exe)
    isFg   := (snap.HasProp("isFg") && snap.isFg)

    for proc in Comp_Game_Processes {
        if (exeLow = StrLower(proc)) {
            return "comp_game"
        }
    }

    isMediaApp := false
    for proc in Media_Player_Processes {
        if (exeLow = StrLower(proc)) {
            isMediaApp := true
            break
        }
    }
    isBrowser := false
    for proc in Browser_Processes {
        if (exeLow = StrLower(proc)) {
            isBrowser := true
            break
        }
    }

    isFs  := IsWindowFullscreenOnMonitor(snap.hwnd, monIdx)
    isMax := IsWindowMaximizedOnMonitor(snap.hwnd, monIdx)

    if isBrowser {
        r := ClassifyBrowserContext(snap, monIdx, isFs, isMax)
        if (r != "") {
            return r
        }
    }

    if isMediaApp {
        if (!isFs && (snap.title = "Media Player Classic Home Cinema" || snap.title = "MPC-BE")) {
            return "desktop"
        }
        if (exeLow != "applicationframehost.exe" && isFs && !IsWindowExplicitlyPaused(snap.hwnd, snap.exe, snap.title)) {
            return "movie_playing"
        }
        return IsMediaActivelyPlaying(snap.hwnd, snap.pid, snap.exe, snap.title) ? "movie_playing" : "movie_paused"
    }

    if (isFg && !isBrowser) {
        qState := 0
        if (DllCall("shell32\SHQueryUserNotificationState", "Int*", &qState, "Int") = 0) {
            if (qState = 3 || qState = 2) {
                return "normal_game"
            }
        }
    }
    if (isFs && !isBrowser) {
        return "normal_game"
    }
    return "desktop"
}

; Map(monIdx -> { ctx, snap, carried }) for every monitor. Cached for 150 ms so the 120 ms timer and the Live Status
; boxes can call it freely.  carried: 0 = the monitor's own window decided, -1 = a competitive game process is running,
; N = a game is running on Monitor N (only used when Extra_Game_Carryover_Enabled is on; Monitor 1 never carries).
GetAllMonitorContexts(fgSnap := "") {
    global Extra_Game_Carryover_Enabled
    static cache := Map(), cacheTick := 0
    if (cache.Count > 0 && (A_TickCount - cacheTick) < 150) {
        return cache
    }

    monCount := GetDetectedMonitorCount()
    priIdx   := MonitorGetPrimary()
    if !IsObject(fgSnap) {
        fgSnap := GetForegroundWindowSnapshot()
    }
    stacks := GetMonitorOwnerWindows(fgSnap, monCount)

    result := Map()
    Loop monCount {
        m := A_Index
        ctx  := "desktop"
        snap := ""
        why  := ""
        if stacks.Has(m) {
            for w in stacks[m] {
                wCtx := "desktop"
                try wCtx := ClassifyWindowContext(w, m)
                catch as err {
                    wCtx := "desktop"
                    why .= "ERR(" w.exe ": " err.Message ") "
                }
                why .= w.exe "=" wCtx " "
                if (CtxPriority(wCtx) > CtxPriority(ctx) || (!IsObject(snap) && wCtx = ctx)) {
                    ctx  := wCtx
                    snap := w
                }
            }
        }
        result[m] := { ctx: ctx, snap: snap, carried: 0, why: Trim(why) }
    }

    if Extra_Game_Carryover_Enabled {
        Loop monCount {
            m := A_Index
            if (m = priIdx || result[m].ctx != "desktop") {
                continue
            }
            src := 0
            for om, info in result {
                if (om != m && info.ctx = "comp_game") {
                    src := om
                    break
                }
            }
            if (src > 0) {
                result[m].ctx := "comp_game"
                result[m].carried := src
                continue
            }
            if IsCompGameRunning() {
                result[m].ctx := "comp_game"
                result[m].carried := -1
                continue
            }
            for om, info in result {
                if (om != m && info.ctx = "normal_game") {
                    src := om
                    break
                }
            }
            if (src > 0) {
                result[m].ctx := "normal_game"
                result[m].carried := src
            }
        }
    }

    cache := result
    cacheTick := A_TickCount
    return cache
}

GetMonitorContextInfo(monIdx, fgSnap := "") {
    all := GetAllMonitorContexts(fgSnap)
    if all.Has(monIdx) {
        return all[monIdx]
    }
    return { ctx: "desktop", snap: "", carried: 0, why: "" }
}

GetMonitorContext(monIdx, fgSnap := "") {
    return GetMonitorContextInfo(monIdx, fgSnap).ctx
}

GetPrimaryContext(snap := "") {
    return GetMonitorContext(MonitorGetPrimary(), snap)
}

; Legacy helper: context of the first non-primary monitor (per-monitor code should use GetMonitorContext)
GetExtraContext(snap := "") {
    priIdx := MonitorGetPrimary()
    Loop GetDetectedMonitorCount() {
        if (A_Index != priIdx) {
            return GetMonitorContext(A_Index, snap)
        }
    }
    return "desktop"
}

MonCtxSummary() {
    priIdx := MonitorGetPrimary()
    parts := []
    for m, info in GetAllMonitorContexts() {
        if (m != priIdx) {
            parts.Push("M" m ": " FriendlyCtx(info.ctx) (info.why != "" ? " [" info.why "]" : ""))
        }
    }
    out := ""
    for t in parts {
        out .= (out = "" ? "" : ", ") t
    }
    return out = "" ? "none" : out
}

; Keeps "playing" true for 3 s after the last positive reading, so a quiet scene or a short audio hiccup can't flip the screen
; between "video playing" and "video paused" (that flip used to make Monitor 1 dim and wake over and over).
IsMediaActivelyPlaying(hwnd, pid, exeName, cachedTitle := "") {
    static lastPlayingTick := Map()
    key := StrLower(exeName) "_" hwnd
    if IsMediaActivelyPlayingRaw(hwnd, pid, exeName, cachedTitle) {
        lastPlayingTick[key] := A_TickCount
        return true
    }
    ; A clear "Paused" reading ends the hold immediately - the hold only bridges readings that are merely quiet / missing
    if IsWindowExplicitlyPaused(hwnd, exeName, cachedTitle) {
        if lastPlayingTick.Has(key) {
            lastPlayingTick.Delete(key)
        }
        return false
    }
    return lastPlayingTick.Has(key) && (A_TickCount - lastPlayingTick[key]) < 2000
}

GetMoviePlayingMonitorsCached() {
    static cachedMons := Map(), lastScanTick := 0
    if (A_TickCount - lastScanTick < 700) {
        return cachedMons
    }
    lastScanTick := A_TickCount
    cachedMons := GetMoviePlayingMonitors()
    return cachedMons
}
IsMediaActivelyPlayingRaw(hwnd, pid, exeName, cachedTitle := "") {
    title := ""
    try {
        title := (cachedTitle != "") ? cachedTitle : WinGetTitle("ahk_id " hwnd)
        if (InStr(title, "Paused") || InStr(title, "Stopped")) {
            return false
        }
    }
    st := GetPlayerStatusText(hwnd)
    if (st = "paused" || st = "stopped") {
        return false
    }
    if (st = "playing") {
        return true
    }

    ; Primary: WinRT Global System Media Transport Controls (works when muted or zero volume)
    gsmtcState := QueryGsmtcPlaybackState(exeName)
    if (gsmtcState = 4) {
        return true
    }
    if (gsmtcState = 5 || gsmtcState = 3) {
        return false
    }

    ; Backup 1: Media player window/control heuristics for silent or no-audio-track files
    if IsSilentMediaPlayerActive(hwnd, exeName, title) {
        return true
    }

    ; Backup 2: WASAPI audio session / peak meter
    return HasActiveAudioSession(pid, exeName)
}

QueryGsmtcPlaybackState(targetExe) {
    static cache := Map()
    key := StrLower(targetExe)
    now := A_TickCount
    if (cache.Has(key) && (now - cache[key].tick) < 700) {
        return cache[key].state
    }
    st := QueryGsmtcPlaybackStateRaw(targetExe)
    cache[key] := { tick: now, state: st }
    return st
}

QueryGsmtcPlaybackStateRaw(targetExe) {
    ; Returns 4 if Playing, 5 if Paused, 3 if Stopped, 0 if unknown/unavailable
    static hCombase := DllCall("LoadLibrary", "Str", "combase.dll", "Ptr")
    if !hCombase {
        return 0
    }

    targetLow := StrLower(targetExe)
    targetBase := RegExReplace(targetLow, "\.exe$", "")
    foundState := 0
    hStr := 0
    pFactory := 0
    pAsyncOp := 0
    pAsyncInfo := 0
    pMgr := 0
    pSessions := 0

    try {
        className := "Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager"
        if (DllCall("combase\WindowsCreateString", "WStr", className, "UInt", StrLen(className), "Ptr*", &hStr, "Int") != 0 || !hStr) {
            return 0
        }

        iidStatics := Buffer(16, 0)
        DllCall("ole32\CLSIDFromString", "Str", "{2050c4ee-11a0-57de-aed7-c97c70338245}", "Ptr", iidStatics.Ptr)
        if (DllCall("combase\RoGetActivationFactory", "Ptr", hStr, "Ptr", iidStatics.Ptr, "Ptr*", &pFactory, "Int") != 0 || !pFactory) {
            return 0
        }

        ; RequestAsync() -> vtable index 6
        if (ComCall(6, pFactory, "Ptr*", &pAsyncOp, "Int") != 0 || !pAsyncOp) {
            return 0
        }

        iidAsyncInfo := Buffer(16, 0)
        DllCall("ole32\CLSIDFromString", "Str", "{00000036-0000-0000-C000-000000000046}", "Ptr", iidAsyncInfo.Ptr)
        if (ComCall(0, pAsyncOp, "Ptr", iidAsyncInfo.Ptr, "Ptr*", &pAsyncInfo, "Int") != 0 || !pAsyncInfo) {
            return 0
        }

        status := 0
        Loop 5 {
            ComCall(7, pAsyncInfo, "Int*", &status)
            if (status != 0) {
                break
            }
            Sleep(2)
        }
        if (status != 1) {
            return 0
        }

        ; GetResults() -> vtable index 8
        if (ComCall(8, pAsyncOp, "Ptr*", &pMgr, "Int") != 0 || !pMgr) {
            return 0
        }

        ; GetSessions() -> vtable index 7
        if (ComCall(7, pMgr, "Ptr*", &pSessions, "Int") = 0 && pSessions) {
            count := 0
            ComCall(7, pSessions, "UInt*", &count)
            Loop count {
                pSess := 0
                if (ComCall(6, pSessions, "UInt", A_Index - 1, "Ptr*", &pSess, "Int") = 0 && pSess) {
                    hAppId := 0
                    appIdStr := ""
                    if (ComCall(6, pSess, "Ptr*", &hAppId, "Int") = 0 && hAppId) {
                        len := 0
                        pRaw := DllCall("combase\WindowsGetStringRawBuffer", "Ptr", hAppId, "UInt*", &len, "Ptr")
                        if pRaw {
                            appIdStr := StrLower(StrGet(pRaw, len, "UTF-16"))
                        }
                        DllCall("combase\WindowsDeleteString", "Ptr", hAppId)
                    }

                    isMatch := (appIdStr != "") && (
                        InStr(appIdStr, targetLow)
                        || InStr(appIdStr, targetBase)
                        || (targetBase = "msedge" && InStr(appIdStr, "edge"))
                        || (targetBase = "stremio" && InStr(appIdStr, "stremio"))
                    )

                    if isMatch {
                        pInfo := 0
                        if (ComCall(9, pSess, "Ptr*", &pInfo, "Int") = 0 && pInfo) {
                            pbStatus := 0
                            ComCall(7, pInfo, "Int*", &pbStatus)
                            if (pbStatus = 4) {
                                foundState := 4
                            } else if (foundState != 4 && (pbStatus = 5 || pbStatus = 3)) {
                                foundState := pbStatus
                            }
                            ObjRelease(pInfo)
                        }
                    }
                    ObjRelease(pSess)
                    if (foundState = 4) {
                        break
                    }
                }
            }
        }
    } finally {
        if pSessions
            try ObjRelease(pSessions)
        if pMgr
            try ObjRelease(pMgr)
        if pAsyncInfo
            try ObjRelease(pAsyncInfo)
        if pAsyncOp
            try ObjRelease(pAsyncOp)
        if pFactory
            try ObjRelease(pFactory)
        if hStr
            try DllCall("combase\WindowsDeleteString", "Ptr", hStr)
    }
    return foundState
}

IsSilentMediaPlayerActive(hwnd, exeName, title) {
    exeLow := StrLower(exeName)
    ; MPC-HC / MPC-BE: shows "Playing" in status bar or active media filename in title
    if (InStr(exeLow, "mpc-hc") || InStr(exeLow, "mpc-be")) {
        try {
            for ctrl in WinGetControls("ahk_id " hwnd) {
                if InStr(ctrl, "Static") {
                    txt := ControlGetText(ctrl, "ahk_id " hwnd)
                    if (txt = "Playing" || InStr(txt, "Playing")) {
                        return true
                    }
                }
            }
        }
        return (title != "" && title != "Media Player Classic Home Cinema" && title != "MPC-BE")
    }
    ; VLC: active file loaded when title has a media name prefix
    if (exeLow = "vlc.exe") {
        return (InStr(title, " - VLC media player") && title != "VLC media player")
    }
    ; mpv: active file loaded when title has a media name prefix
    if (exeLow = "mpv.exe") {
        return (InStr(title, " - mpv") && title != "mpv")
    }
    return false
}

HasActiveAudioSession(targetPid, targetExe) {
    static audioCache := Map()
    cacheKey := targetPid "_" StrLower(targetExe)
    now := A_TickCount
    if (audioCache.Has(cacheKey) && (now - audioCache[cacheKey].tick) < 800) {
        return audioCache[cacheKey].active
    }
    isActive := false
    targetExeLow := StrLower(targetExe)

    try {
        enumerator := ComObject("{BCDE0395-E52F-467C-8E3D-C4579291692E}", "{A95664D2-9614-4F35-A746-DE8DB63617E6}")
        pDevice := 0
        ComCall(4, enumerator, "UInt", 0, "UInt", 1, "Ptr*", &pDevice)
        if pDevice {
            iidMgr2 := Buffer(16, 0)
            DllCall("ole32\CLSIDFromString", "Str", "{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}", "Ptr", iidMgr2.Ptr)
            pMgr := 0
            ComCall(3, pDevice, "Ptr", iidMgr2.Ptr, "UInt", 23, "Ptr", 0, "Ptr*", &pMgr)
            if pMgr {
                pEnum := 0
                ComCall(5, pMgr, "Ptr*", &pEnum)
                if pEnum {
                    count := 0
                    ComCall(3, pEnum, "Int*", &count)
                    iidCtrl2 := Buffer(16, 0)
                    DllCall("ole32\CLSIDFromString", "Str", "{BFB7FF88-7239-4FC9-8FA2-07C950BE9C6D}", "Ptr", iidCtrl2.Ptr)
                    iidMeter := Buffer(16, 0)
                    DllCall("ole32\CLSIDFromString", "Str", "{C02216F6-8C67-4B5B-9D00-D008E73E0064}", "Ptr", iidMeter.Ptr)

                    Loop count {
                        pCtrl := 0
                        ComCall(4, pEnum, "Int", A_Index - 1, "Ptr*", &pCtrl)
                        if pCtrl {
                            state := 0
                            ComCall(3, pCtrl, "Int*", &state)
                            if (state = 1) {
                                pCtrl2 := 0
                                if (ComCall(0, pCtrl, "Ptr", iidCtrl2.Ptr, "Ptr*", &pCtrl2, "Int") = 0 && pCtrl2) {
                                    sPid := 0
                                    ComCall(14, pCtrl2, "UInt*", &sPid)
                                    matched := (sPid = targetPid)
                                    if (!matched && sPid > 0) {
                                        sExe := ""
                                        try sExe := StrLower(ProcessGetName(sPid))
                                        if (sExe = targetExeLow || (targetExeLow = "stremio.exe" && sExe = "stremio-runtime.exe")) {
                                            matched := true
                                        }
                                    }
                                    if matched {
                                        pMeter := 0
                                        if (ComCall(0, pCtrl, "Ptr", iidMeter.Ptr, "Ptr*", &pMeter, "Int") = 0 && pMeter) {
                                            peak := 0.0
                                            ComCall(3, pMeter, "Float*", &peak)
                                            if (peak > 0.0001) {
                                                isActive := true
                                            }
                                            ObjRelease(pMeter)
                                        } else {
                                            isActive := true
                                        }
                                    }
                                    ObjRelease(pCtrl2)
                                }
                            }
                            ObjRelease(pCtrl)
                            if isActive {
                                break
                            }
                        }
                    }
                    ObjRelease(pEnum)
                }
                ObjRelease(pMgr)
            }
            ObjRelease(pDevice)
        }
    }
    audioCache[cacheKey] := { tick: now, active: isActive }
    return isActive
}

IsWindowFullscreenOnMonitor(hwnd, monIndex) {
    if !hwnd || !WinExist("ahk_id " hwnd)
        return false

    if (WinGetMinMax(hwnd) = -1)
        return false

    MonitorGet(monIndex, &mLeft, &mTop, &mRight, &mBottom)
    monW := mRight - mLeft
    monH := mBottom - mTop

    WinGetPos(&wX, &wY, &wW, &wH, hwnd)

    cX := wX + (wW // 2)
    cY := wY + (wH // 2)
    if (cX < mLeft || cX >= mRight || cY < mTop || cY >= mBottom)
        return false

    return (Abs(wW - monW) <= 2 && Abs(wH - monH) <= 2)
}

IsWindowMaximizedOnMonitor(hwnd, monIdx) {
    try {
        if (WinGetMinMax("ahk_id " hwnd) != 1) {
            return false
        }
        MonitorGetWorkArea(monIdx, &mLeft, &mTop, &mRight, &mBottom)
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hwnd)
        cx := wx + (ww // 2)
        cy := wy + (wh // 2)
        return (cx >= mLeft && cx < mRight && cy >= mTop && cy < mBottom)
    }
    return false
}

; Reads the player's own status label ("Playing" / "Paused" / "Stopped", e.g. MPC-HC / MPC-BE). Returns "playing", "paused", "stopped" or "".
; This is the most direct and instant signal, so it is checked before any cached system-wide media state.
GetPlayerStatusText(hwnd) {
    try {
        for ctrl in WinGetControls("ahk_id " hwnd) {
            if InStr(ctrl, "Static") {
                txt := ControlGetText(ctrl, "ahk_id " hwnd)
                if (txt = "Paused" || InStr(txt, "Paused")) {
                    return "paused"
                }
                if (txt = "Stopped") {
                    return "stopped"
                }
                if (txt = "Playing" || InStr(txt, "Playing")) {
                    return "playing"
                }
            }
        }
    }
    return ""
}

IsWindowExplicitlyPaused(hwnd, exeName, cachedTitle := "") {
    title := ""
    try title := (cachedTitle != "") ? cachedTitle : WinGetTitle("ahk_id " hwnd)
    if (InStr(title, "Paused") || InStr(title, "Stopped")) {
        return true
    }
    st := GetPlayerStatusText(hwnd)
    if (st = "paused" || st = "stopped") {
        return true
    }
    if (st = "playing") {
        return false
    }
    gsmtc := QueryGsmtcPlaybackState(exeName)
    return (gsmtc = 5 || gsmtc = 3)
}

GetWindowMonitorIndex(hwnd) {
    try {
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hwnd)
        if (ww <= 0 || wh <= 0) {
            return 0
        }
        cx := wx + (ww // 2)
        cy := wy + (wh // 2)
        monCount := GetDetectedMonitorCount()
        Loop monCount {
            MonitorGet(A_Index, &mL, &mT, &mR, &mB)
            if (cx >= mL && cx < mR && cy >= mT && cy < mB) {
                return A_Index
            }
        }
        bestMon := 0
        bestArea := 0
        Loop monCount {
            MonitorGet(A_Index, &mL, &mT, &mR, &mB)
            ix1 := Max(wx, mL)
            iy1 := Max(wy, mT)
            ix2 := Min(wx + ww, mR)
            iy2 := Min(wy + wh, mB)
            if (ix2 > ix1 && iy2 > iy1) {
                area := (ix2 - ix1) * (iy2 - iy1)
                if (area > bestArea) {
                    bestArea := area
                    bestMon := A_Index
                }
            }
        }
        return bestMon
    }
    return 0
}

IsKnownVideoTabTitle(title) {
    static keywords := ["YouTube", "Twitch", "Netflix", "Prime Video", "Disney+", "Crunchyroll", "Plex", "Jellyfin", "Emby", "Vimeo", "Kick", "Bilibili", "Dailymotion", "Hulu", "Max"]
    for kw in keywords {
        if InStr(title, kw) {
            return true
        }
    }
    return false
}

IsWindowCoveredOnMonitor(targetHwnd, monIdx) {
    if (!targetHwnd || !WinExist("ahk_id " targetHwnd)) {
        return false
    }

    tX := 0, tY := 0, tW := 0, tH := 0
    try {
        WinGetPos(&tX, &tY, &tW, &tH, "ahk_id " targetHwnd)
    } catch {
        return false
    }
    if (tW <= 0 || tH <= 0) {
        return false
    }

    tRight  := tX + tW
    tBottom := tY + tH

    hCur := DllCall("GetTopWindow", "Ptr", 0, "Ptr")
    while (hCur && hCur != targetHwnd) {
        if (hCur != A_ScriptHwnd && DllCall("IsWindowVisible", "Ptr", hCur, "Int")) {
            cloaked := 0
            DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hCur, "UInt", 14, "Int*", &cloaked, "UInt", 4)
            if (cloaked = 0 && WinGetMinMax("ahk_id " hCur) != -1) {
                exStyle := DllCall("GetWindowLongPtr", "Ptr", hCur, "Int", -20, "Ptr")
                if !(exStyle & 0x20) {
                    oX := 0, oY := 0, oW := 0, oH := 0
                    try {
                        WinGetPos(&oX, &oY, &oW, &oH, "ahk_id " hCur)
                    } catch {
                        oW := 0
                        oH := 0
                    }
                    if (oW > 0 && oH > 0) {
                        oRight  := oX + oW
                        oBottom := oY + oH
                        ovLeft   := Max(tX, oX)
                        ovTop    := Max(tY, oY)
                        ovRight  := Min(tRight, oRight)
                        ovBottom := Min(tBottom, oBottom)
                        if (ovRight > ovLeft && ovBottom > ovTop && GetWindowMonitorIndex(hCur) = monIdx) {
                            return true
                        }
                    }
                }
            }
        }
        hCur := DllCall("GetWindow", "Ptr", hCur, "UInt", 2, "Ptr")
    }
    return false
}

GetMoviePlayingMonitors() {
    global Media_Player_Processes, Browser_Processes
    activeMons := Map()
    monCount := GetDetectedMonitorCount()
    gsmtcCache := Map()
    browserWindows := Map()

    checkGsmtc := (exe) => (
        gsmtcCache.Has(exe)
            ? gsmtcCache[exe]
            : (gsmtcCache[exe] := QueryGsmtcPlaybackState(exe))
    )

    for hwnd in WinGetList() {
        try {
            if !DllCall("IsWindowVisible", "Ptr", hwnd, "Int") {
                continue
            }
            cloaked := 0
            DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "Int*", &cloaked, "UInt", 4)
            if (cloaked != 0) {
                continue
            }
            if (WinGetMinMax("ahk_id " hwnd) = -1) {
                continue
            }
            exe := WinGetProcessName("ahk_id " hwnd)
            if (exe = "") {
                continue
            }
            exeLow := StrLower(exe)

            isMedia := false
            for proc in Media_Player_Processes {
                if (exeLow = StrLower(proc)) {
                    isMedia := true
                    break
                }
            }

            if isMedia {
                if (exeLow = "applicationframehost.exe") {
                    pid := WinGetPID("ahk_id " hwnd)
                    if (checkGsmtc(exe) = 4 || HasActiveAudioSession(pid, exe)) {
                        monIdx := GetWindowMonitorIndex(hwnd)
                        if (monIdx > 0) {
                            activeMons[monIdx] := true
                        }
                    }
                    continue
                }
                title := WinGetTitle("ahk_id " hwnd)
                if (title = "" || title = "Media Player Classic Home Cinema" || title = "MPC-BE" || title = "VLC media player" || title = "mpv") {
                    continue
                }
                if IsWindowExplicitlyPaused(hwnd, exe, title) {
                    continue
                }
                fsMon := 0
                Loop monCount {
                    if IsWindowFullscreenOnMonitor(hwnd, A_Index) {
                        fsMon := A_Index
                        break
                    }
                }
                if (fsMon > 0) {
                    activeMons[fsMon] := true
                    continue
                }
                pid := WinGetPID("ahk_id " hwnd)
                if IsMediaActivelyPlaying(hwnd, pid, exe, title) {
                    monIdx := GetWindowMonitorIndex(hwnd)
                    if (monIdx > 0) {
                        activeMons[monIdx] := true
                    }
                }
                continue
            }

            isBrowser := false
            for proc in Browser_Processes {
                if (exeLow = StrLower(proc)) {
                    isBrowser := true
                    break
                }
            }

            if isBrowser {
                if !browserWindows.Has(exeLow) {
                    browserWindows[exeLow] := []
                }
                fsMon := 0
                Loop monCount {
                    if IsWindowFullscreenOnMonitor(hwnd, A_Index) {
                        fsMon := A_Index
                        break
                    }
                }
                browserWindows[exeLow].Push({
                    hwnd: hwnd,
                    exe: exe,
                    title: WinGetTitle("ahk_id " hwnd),
                    fsMon: fsMon,
                    monIdx: (fsMon > 0) ? fsMon : GetWindowMonitorIndex(hwnd)
                })
            }
        }
    }

    for exeLow, winList in browserWindows {
        if (winList.Length = 0) {
            continue
        }
        repExe := winList[1].exe
        pb := checkGsmtc(repExe)

        hasFs := false
        for w in winList {
            if (w.fsMon > 0) {
                hasFs := true
                break
            }
        }

        isMediaExe := false
        for mProc in Media_Player_Processes {
            if (StrLower(repExe) = StrLower(mProc)) {
                isMediaExe := true
                break
            }
        }

        if isMediaExe {
            for w in winList {
                if (w.monIdx > 0 && WinGetMinMax("ahk_id " w.hwnd) = 0 && !IsWindowFullscreenOnMonitor(w.hwnd, w.monIdx)) {
                    wPid := 0
                    try wPid := WinGetPID("ahk_id " w.hwnd)
                    if (pb = 4 || (wPid > 0 && HasActiveAudioSession(wPid, w.exe))) {
                        activeMons[w.monIdx] := true
                    }
                }
            }
            continue
        }

        for w in winList {
            if (w.monIdx > 0 && WinExist("ahk_id " w.hwnd)) {
                try {
                    isMaxOrFs := (WinGetMinMax("ahk_id " w.hwnd) = 1 || IsWindowFullscreenOnMonitor(w.hwnd, w.monIdx))
                    if isMaxOrFs {
                        wPid := 0
                        try wPid := WinGetPID("ahk_id " w.hwnd)
                        if (pb = 4 || (pb != 5 && pb != 3 && wPid > 0 && HasActiveAudioSession(wPid, w.exe))) {
                            activeMons[w.monIdx] := true
                        }
                    }
                }
            }
        }

        if (pb = 4) {
            matchedVideoTab := false
            for w in winList {
                if (w.monIdx > 0 && IsKnownVideoTabTitle(w.title) && WinExist("ahk_id " w.hwnd)) {
                    try {
                        isMaxOrFs := (WinGetMinMax("ahk_id " w.hwnd) = 1 || IsWindowFullscreenOnMonitor(w.hwnd, w.monIdx))
                        if (!isMaxOrFs || !IsWindowCoveredOnMonitor(w.hwnd, w.monIdx)) {
                            activeMons[w.monIdx] := true
                            matchedVideoTab := true
                        }
                    }
                }
            }
            w1 := winList[1]
            if (!matchedVideoTab && w1.monIdx > 0 && WinExist("ahk_id " w1.hwnd)) {
                try {
                    isMaxOrFs1 := (WinGetMinMax("ahk_id " w1.hwnd) = 1 || IsWindowFullscreenOnMonitor(w1.hwnd, w1.monIdx))
                    if (!isMaxOrFs1 || !IsWindowCoveredOnMonitor(w1.hwnd, w1.monIdx)) {
                        activeMons[w1.monIdx] := true
                    }
                }
            }
        }
    }

    return activeMons
}

IsCompGameRunning() {
    global cachedCompRunning, lastCompCheckTick, Comp_Game_Processes
    if (A_TickCount - lastCompCheckTick < 1000) {
        return cachedCompRunning
    }
    lastCompCheckTick := A_TickCount

    for proc in Comp_Game_Processes {
        if ProcessExist(proc) {
            cachedCompRunning := true
            return true
        }
    }
    cachedCompRunning := false
    return false
}

GetPrimaryTimeoutSeconds(ctx := "") {
    global Primary_SDR_Desktop_Sec, Primary_SDR_Normal_Sec, Primary_SDR_Comp_Sec, Primary_SDR_Paused_Sec
    global Primary_HDR_Desktop_Sec, Primary_HDR_Normal_Sec, Primary_HDR_Comp_Sec, Primary_HDR_Paused_Sec
    global OLED_HDR_SDR_Mode_Enabled

    if (ctx = "") {
        ctx := GetPrimaryContext()
    }
    presetSec := GetPresetValue("m1Sec")
    if (presetSec > 0 && ctx != "movie_paused") {
        return presetSec
    }
    useHdr := OLED_HDR_SDR_Mode_Enabled && IsPrimaryDisplayHdrEnabled()

    switch ctx {
        case "comp_game":
            return useHdr ? Primary_HDR_Comp_Sec : Primary_SDR_Comp_Sec
        case "normal_game":
            return useHdr ? Primary_HDR_Normal_Sec : Primary_SDR_Normal_Sec
        case "movie_paused":
            return useHdr ? Primary_HDR_Paused_Sec : Primary_SDR_Paused_Sec
        default:
            return useHdr ? Primary_HDR_Desktop_Sec : Primary_SDR_Desktop_Sec
    }
}

GetExtraTimeoutSeconds(ctx := "") {
    global Extra_SDR_Desktop_Sec, Extra_SDR_Normal_Sec, Extra_SDR_Comp_Sec, Extra_SDR_Paused_Sec
    global Extra_HDR_Desktop_Sec, Extra_HDR_Normal_Sec, Extra_HDR_Comp_Sec, Extra_HDR_Paused_Sec
    global Extra_HDR_SDR_Mode_Enabled

    if (ctx = "") {
        ctx := GetExtraContext()
    }
    useHdr := Extra_HDR_SDR_Mode_Enabled && IsAnyExtraDisplayHdrEnabled()

    switch ctx {
        case "comp_game":
            return useHdr ? Extra_HDR_Comp_Sec : Extra_SDR_Comp_Sec
        case "normal_game":
            return useHdr ? Extra_HDR_Normal_Sec : Extra_SDR_Normal_Sec
        case "movie_paused":
            return useHdr ? Extra_HDR_Paused_Sec : Extra_SDR_Paused_Sec
        default:
            return useHdr ? Extra_HDR_Desktop_Sec : Extra_SDR_Desktop_Sec
    }
}

; ==============================================================================
; 7. OLED CARE STATE & STATS PERSISTENCE / POPUP
; ==============================================================================
LoadOledCareState() {
    global CareStateIniPath, oledActiveMsSinceRefresh, primaryDimmedMs, primaryUndimmedMs, secondaryDimmedMs, secondaryUndimmedMs
    global primaryWakeCount, secondaryWakeCount, primaryDimBlackoutTriggers, secondaryDimBlackoutTriggers
    try {
        oledActiveMsSinceRefresh     := Integer(IniRead(CareStateIniPath, "Care", "ActiveMsSinceRefresh", "0"))
        primaryDimmedMs              := Integer(IniRead(CareStateIniPath, "Stats", "PrimaryDimmedMs", "0"))
        primaryUndimmedMs            := Integer(IniRead(CareStateIniPath, "Stats", "PrimaryUndimmedMs", "0"))
        secondaryDimmedMs            := Integer(IniRead(CareStateIniPath, "Stats", "SecondaryDimmedMs", "0"))
        secondaryUndimmedMs          := Integer(IniRead(CareStateIniPath, "Stats", "SecondaryUndimmedMs", "0"))
        primaryWakeCount             := Integer(IniRead(CareStateIniPath, "Stats", "PrimaryWakeCount", "0"))
        secondaryWakeCount           := Integer(IniRead(CareStateIniPath, "Stats", "SecondaryWakeCount", "0"))
        primaryDimBlackoutTriggers   := Integer(IniRead(CareStateIniPath, "Stats", "PrimaryDimBlackoutTriggers", "0"))
        secondaryDimBlackoutTriggers := Integer(IniRead(CareStateIniPath, "Stats", "SecondaryDimBlackoutTriggers", "0"))
    }
}

SaveOledCareState() {
    global CareStateIniPath, oledActiveMsSinceRefresh, primaryDimmedMs, primaryUndimmedMs, secondaryDimmedMs, secondaryUndimmedMs
    global primaryWakeCount, secondaryWakeCount, primaryDimBlackoutTriggers, secondaryDimBlackoutTriggers
    try {
        IniWrite(oledActiveMsSinceRefresh,     CareStateIniPath, "Care", "ActiveMsSinceRefresh")
        IniWrite(primaryDimmedMs,              CareStateIniPath, "Stats", "PrimaryDimmedMs")
        IniWrite(primaryUndimmedMs,            CareStateIniPath, "Stats", "PrimaryUndimmedMs")
        IniWrite(secondaryDimmedMs,            CareStateIniPath, "Stats", "SecondaryDimmedMs")
        IniWrite(secondaryUndimmedMs,          CareStateIniPath, "Stats", "SecondaryUndimmedMs")
        IniWrite(primaryWakeCount,             CareStateIniPath, "Stats", "PrimaryWakeCount")
        IniWrite(secondaryWakeCount,           CareStateIniPath, "Stats", "SecondaryWakeCount")
        IniWrite(primaryDimBlackoutTriggers,   CareStateIniPath, "Stats", "PrimaryDimBlackoutTriggers")
        IniWrite(secondaryDimBlackoutTriggers, CareStateIniPath, "Stats", "SecondaryDimBlackoutTriggers")
    }
}

FormatDuration(ms, includeSec := true) {
    totalSec := Max(0, Integer(ms // 1000))
    days := totalSec // 86400
    hrs  := Mod(totalSec // 3600, 24)
    mins := Mod(totalSec // 60, 60)
    secs := Mod(totalSec, 60)
    if (days > 0) {
        return includeSec ? (days "d " hrs "h " mins "m " secs "s") : (days "d " hrs "h " mins "m")
    }
    if (hrs > 0) {
        return includeSec ? (hrs "h " mins "m " secs "s") : (hrs "h " mins "m")
    }
    return includeSec ? (mins "m " secs "s") : (mins "m")
}

MarkPixelRefreshed(*) {
    global oledActiveMsSinceRefresh, lastRefreshPromptTick, pendingRefreshReminder
    DebugLogEvent("Pixel refresh marked as done - active-time counter reset (was " FormatDuration(oledActiveMsSinceRefresh) ")")
    oledActiveMsSinceRefresh := 0
    lastRefreshPromptTick    := 0
    pendingRefreshReminder   := false
    CloseRefreshPromptGui()
    SaveOledCareState()
    RefreshStatsGuiFields()
    UpdateTrayRefreshVisuals(true)    ; refreshes tray icon + tray menu (and the Settings alert UI)
    UpdateOledCareAlertUi()           ; clears the ! marker on tab / header / button immediately
    A_IconTip := "OLED Engine — Pixel refresh logged (0m 0s)"
}

UpdateOledCareAlertUi() {
    global CareUiRefs, CareTabIdx, SettingsGui, SettingsTabsCtrl, UI_Dark_Mode, oledActiveMsSinceRefresh
    st := GetOledRefreshStatus()
    isAlert := (st.state >= 1)

    ; Tab caption: "! OLED Care" when due / overdue
    try {
        if (IsObject(SettingsGui) && IsObject(SettingsTabsCtrl) && CareTabIdx > 0) {
            SetTabItemText(SettingsTabsCtrl.Hwnd, CareTabIdx - 1, isAlert ? "! OLED Care" : "OLED Care")
        }
    }

    ; Section header
    try {
        if (CareUiRefs.Has("box") && IsObject(CareUiRefs["box"])) {
            ; group-box title is intentionally static: rewriting it wipes the controls drawn inside it
        }
    }
    try {
        if (CareUiRefs.Has("secBang") && IsObject(CareUiRefs["secBang"])) {
            CareUiRefs["secBang"].Text := isAlert ? "!" : ""
        }
    }

    ; Mark Pixel Refreshed button + side note
    try {
        if (CareUiRefs.Has("btn") && IsObject(CareUiRefs["btn"])) {
            newBtnTxt := isAlert ? "[!] Mark Pixel Refreshed" : "Mark Pixel Refreshed"
            if (CareUiRefs["btn"].Text != newBtnTxt) {
                CareUiRefs["btn"].Text := newBtnTxt
            }
            if isAlert {
                CareUiRefs["btn"].SetFont("s9.5 bold cFF3B30", "Segoe UI")
            } else {
                CareUiRefs["btn"].SetFont("s9.5 norm " (UI_Dark_Mode ? "cFFFFFF" : "c000000"), "Segoe UI")
            }
        }
    }
    try {
        if (CareUiRefs.Has("btnBang") && IsObject(CareUiRefs["btnBang"])) {
            CareUiRefs["btnBang"].Text := isAlert ? "! Pixel refresh is due" : ""
        }
    }
   try {
        if (CareUiRefs.Has("hoursTxt") && IsObject(CareUiRefs["hoursTxt"])) {
            CareUiRefs["hoursTxt"].Text := "Active time since refresh: " FormatDuration(oledActiveMsSinceRefresh)
        }
    }
}

SetTabItemText(hTab, idx0, text) {
    static lastText := Map()
    key := hTab "_" idx0
    if (lastText.Has(key) && lastText[key] = text) {
        return
    }
    lastText[key] := text
    ; TCM_SETITEMW with TCIF_TEXT
    tci := Buffer(A_PtrSize = 8 ? 40 : 28, 0)
    NumPut("UInt", 0x0001, tci, 0)
    NumPut("Ptr", StrPtr(text), tci, A_PtrSize = 8 ? 16 : 12)
    DllCall("SendMessageW", "Ptr", hTab, "UInt", 0x133D, "Ptr", idx0, "Ptr", tci.Ptr, "Ptr")
    DllCall("InvalidateRect", "Ptr", hTab, "Ptr", 0, "Int", 0)
}

ResetMonitor1Stats() {
    global primaryDimmedMs, primaryUndimmedMs, primaryWakeCount, primaryDimBlackoutTriggers
    global oledActiveMsSinceRefresh, lastRefreshPromptTick, pendingRefreshReminder
    primaryDimmedMs            := 0
    primaryUndimmedMs          := 0
    primaryWakeCount           := 0
    primaryDimBlackoutTriggers := 0
    oledActiveMsSinceRefresh   := 0
    lastRefreshPromptTick      := 0
    pendingRefreshReminder     := false
    CloseRefreshPromptGui()
    SaveOledCareState()
    RefreshStatsGuiFields()
    UpdateTrayRefreshVisuals(true)
}

ResetMonitor2PlusStats() {
    global secondaryDimmedMs, secondaryUndimmedMs, secondaryWakeCount, secondaryDimBlackoutTriggers
    secondaryDimmedMs            := 0
    secondaryUndimmedMs          := 0
    secondaryWakeCount           := 0
    secondaryDimBlackoutTriggers := 0
    SaveOledCareState()
    RefreshStatsGuiFields()
}

ResetAllCareAndStats() {
    ResetMonitor1Stats()
    ResetMonitor2PlusStats()
}

ShowOledCareStatus(*) {
    global StatsPromptGui, StatsTimerActive, UI_Dark_Mode, oledActiveMsSinceRefresh, scriptStartTick
    global primaryDimmedMs, primaryUndimmedMs, secondaryDimmedMs, secondaryUndimmedMs
    global primaryWakeCount, secondaryWakeCount, primaryDimBlackoutTriggers, secondaryDimBlackoutTriggers

    if IsObject(StatsPromptGui) {
        try {
            RefreshStatsGuiFields()
            StatsPromptGui.gui.Show()
            return
        }
    }

    monCount := GetDetectedMonitorCount()
    priIdx := MonitorGetPrimary()
    priInfo := GetMonitorHoverInfo(priIdx)

    g := Gui("+AlwaysOnTop +ToolWindow -MinimizeBox -DPIScale", "Stats")
    ApplyGuiTheme(g, UI_Dark_Mode)
    g.MarginX := 16
    g.MarginY := 14

    boxPri := AddSectionBox(g, 16, 14, 412, 134, "Monitor 1 Stats", UI_Dark_Mode)
    RegisterGroupTitleTip(boxPri, 150, priInfo)
    txtPriLine1 := g.AddText("x28 y36 w388 +0x100", "Dimmed / Blackout: " FormatDuration(primaryDimmedMs) "  |  Active: " FormatDuration(primaryUndimmedMs))
    txtPriLine2 := g.AddText("x28 y58 w388 +0x100", "Dim / Blackout Triggers: " primaryDimBlackoutTriggers "  |  Wakes: " primaryWakeCount)
    txtPriLine3 := g.AddText("x28 y80 w388 +0x100", "Active time since refresh: " FormatDuration(oledActiveMsSinceRefresh))
    txtPriLine4 := g.AddText("x28 y102 w260 +0x100", "Session uptime: " FormatDuration(A_TickCount - scriptStartTick))
    btnResetPri := g.AddButton("x304 y114 w112 h24", "Reset Monitor 1")

    extraTitle := (monCount <= 1) ? "Additional Monitors Stats" : ((monCount = 2) ? "Monitor 2 Stats" : "Monitors 2–" monCount " Stats")
    extraReset := (monCount <= 2) ? "Reset Monitor 2" : "Reset Monitors 2–" monCount
    extraInfos := []
    Loop monCount {
        if (A_Index != priIdx) {
            extraInfos.Push(GetMonitorHoverInfo(A_Index))
        }
    }
    extraTip := (extraInfos.Length > 0) ? JoinArray(extraInfos, "  |  ") : "No additional monitors connected"

    boxSec := AddSectionBox(g, 16, 156, 412, 108, extraTitle, UI_Dark_Mode)
    RegisterGroupTitleTip(boxSec, 195, extraTip)
    txtSecLine1 := g.AddText("x28 y178 w388 +0x100", (monCount <= 1) ? "No additional monitors connected" : ("Dimmed / Blackout: " FormatDuration(secondaryDimmedMs) "  |  Active: " FormatDuration(secondaryUndimmedMs)))
    txtSecLine2 := g.AddText("x28 y200 w388 +0x100", "Dim / Blackout Triggers: " secondaryDimBlackoutTriggers "  |  Wakes: " secondaryWakeCount)
    btnResetSec := g.AddButton("x304 y230 w112 h24", extraReset)

    btnSettings := g.AddButton("x16 y276 w118 h28", "Open Settings")
    btnResetAll := g.AddButton("x+8 yp w124 h28", "Reset All Stats")
    btnClose    := g.AddButton("x+8 yp w84 h28 Default", "Close")

    for ctrl in [txtPriLine1, txtPriLine2, btnResetPri, txtSecLine1, btnResetSec, btnSettings, btnResetAll, btnClose] {
        StyleControlTheme(ctrl, UI_Dark_Mode)
    }
    StyleControlTheme(txtPriLine3, UI_Dark_Mode, true)
    StyleControlTheme(txtPriLine4, UI_Dark_Mode, true)
    StyleControlTheme(txtSecLine2, UI_Dark_Mode, true)

    btnResetPri.OnEvent("Click", (*) => ResetMonitor1Stats())
    btnResetSec.OnEvent("Click", (*) => ResetMonitor2PlusStats())
    btnSettings.OnEvent("Click", (*) => (CloseStatsPromptGui(), OpenSettingsGui(1)))
    btnResetAll.OnEvent("Click", (*) => ResetAllCareAndStats())
    btnClose.OnEvent("Click", CloseStatsPromptGui)
    g.OnEvent("Close", CloseStatsPromptGui)
    g.OnEvent("Escape", CloseStatsPromptGui)

    StatsPromptGui := {
        gui: g,
        pri1: txtPriLine1,
        pri2: txtPriLine2,
        pri3: txtPriLine3,
        pri4: txtPriLine4,
        sec1: txtSecLine1,
        sec2: txtSecLine2
    }
    StatsTimerActive := true
    SetTimer(RefreshStatsGuiFields, 1000)
    SetTimer(PollHoverTooltip, 80)
    ShowWithFade(g, "AutoSize Center")
}

RefreshStatsGuiFields(*) {
    global StatsPromptGui, StatsTimerActive, oledActiveMsSinceRefresh, scriptStartTick
    global primaryDimmedMs, primaryUndimmedMs, secondaryDimmedMs, secondaryUndimmedMs
    global primaryWakeCount, secondaryWakeCount, primaryDimBlackoutTriggers, secondaryDimBlackoutTriggers

    if !IsObject(StatsPromptGui) {
        if StatsTimerActive {
            StatsTimerActive := false
            SetTimer(RefreshStatsGuiFields, 0)
        }
        return
    }
    monCount := GetDetectedMonitorCount()
    try {
        StatsPromptGui.pri1.Text := "Dimmed / Blackout: " FormatDuration(primaryDimmedMs) "  |  Active: " FormatDuration(primaryUndimmedMs)
        StatsPromptGui.pri2.Text := "Dim / Blackout Triggers: " primaryDimBlackoutTriggers "  |  Wakes: " primaryWakeCount
        StatsPromptGui.pri3.Text := "Active time since refresh: " FormatDuration(oledActiveMsSinceRefresh)
        StatsPromptGui.pri4.Text := "Session uptime: " FormatDuration(A_TickCount - scriptStartTick)
        StatsPromptGui.sec1.Text := (monCount <= 1) ? "No additional monitors connected" : ("Dimmed / Blackout: " FormatDuration(secondaryDimmedMs) "  |  Active: " FormatDuration(secondaryUndimmedMs))
        StatsPromptGui.sec2.Text := "Dim / Blackout Triggers: " secondaryDimBlackoutTriggers "  |  Wakes: " secondaryWakeCount
    }
}

CloseStatsPromptGui(*) {
    global StatsPromptGui, StatsTimerActive, lastHoveredKey
    if StatsTimerActive {
        StatsTimerActive := false
        SetTimer(RefreshStatsGuiFields, 0)
    }
    lastHoveredKey := ""
    ToolTip()
    if IsObject(StatsPromptGui) {
        try StatsPromptGui.gui.Destroy()
    }
    StatsPromptGui := ""
}

TickOledCare() {
    global lastOledCareTick, oledActiveMsSinceRefresh, primaryDimmedMs, primaryUndimmedMs, secondaryDimmedMs, secondaryUndimmedMs
    global primaryWakeCount, secondaryWakeCount, primaryDimBlackoutTriggers, secondaryDimBlackoutTriggers
    global wasPrimaryDimOrBlackoutStat, wasSecondaryDimStat
    global isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed, currentPrimaryAlpha
    global isAutoExtraDimmed, isManualExtraDimOn, currentExtraAlpha, manualExtraMonSet
    global OLED_Refresh_Reminder_Enabled, lastRefreshPromptTick, pendingRefreshReminder, isSessionLocked
    static saveTickCounter := 0

    now := A_TickCount
    delta := now - lastOledCareTick
    lastOledCareTick := now

    if (isSessionLocked || delta <= 0 || delta > 10000) {
        return
    }

    isPrimaryDimOrBlackoutNow := isManualBlackoutOn || isManualPrimaryDimOn || isAutoPrimaryDimmed || (currentPrimaryAlpha >= 200)
    if (isPrimaryDimOrBlackoutNow && !wasPrimaryDimOrBlackoutStat) {
        primaryDimBlackoutTriggers += 1
    } else if (!isPrimaryDimOrBlackoutNow && wasPrimaryDimOrBlackoutStat) {
        primaryWakeCount += 1
    }
    wasPrimaryDimOrBlackoutStat := isPrimaryDimOrBlackoutNow

    if isPrimaryDimOrBlackoutNow {
        primaryDimmedMs += delta
    } else {
        primaryUndimmedMs += delta
        oledActiveMsSinceRefresh += delta
    }

    if (GetDetectedMonitorCount() > 1) {
        isSecondaryDimNow := isAutoExtraDimmed || isManualExtraDimOn || (manualExtraMonSet.Count > 0) || (currentExtraAlpha >= 100)
        if (isSecondaryDimNow && !wasSecondaryDimStat) {
            secondaryDimBlackoutTriggers += 1
        } else if (!isSecondaryDimNow && wasSecondaryDimStat) {
            secondaryWakeCount += 1
        }
        wasSecondaryDimStat := isSecondaryDimNow

        if isSecondaryDimNow {
            secondaryDimmedMs += delta
        } else {
            secondaryUndimmedMs += delta
        }
    } else {
        wasSecondaryDimStat := false
    }

    saveTickCounter += 1
    if (saveTickCounter >= 30) {
        saveTickCounter := 0
        SaveOledCareState()
    }

    UpdateTrayRefreshVisuals(false)

    if OLED_Refresh_Reminder_Enabled {
        thresholdMs := GetRefreshReminderThresholdMs()
        if (thresholdMs > 0 && oledActiveMsSinceRefresh >= thresholdMs && (lastRefreshPromptTick = 0 || now - lastRefreshPromptTick >= 900000)) {
            lastRefreshPromptTick := now
            pendingRefreshReminder := true
            DebugLogEvent("Pixel refresh reminder is due - active time " FormatDuration(oledActiveMsSinceRefresh) " (target " FormatRefreshIntervalLabel() ")")
            SaveOledCareState()
            DispatchRefreshReminderAlert()
        } else if (pendingRefreshReminder && !IsInGameOrFullscreenSession()) {
            DispatchRefreshReminderAlert()
        }
    } else {
        pendingRefreshReminder := false
    }
}

; ==============================================================================
; 8. TRAY MENU & LIVE PREVIEWS
; ==============================================================================
SetupTrayMenu() {
    global TrayMenuItems, isAutomationPaused, isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed
    global isManualExtraDimOn, isAutoExtraDimmed, manualExtraMonSet, Desktop_Hide_Enabled, isCursorIdleHidden, areDesktopIconsHidden
    global hMenuAlertIcon, Primary_Auto_Enabled, Extra_Auto_Enabled

    tray := A_TrayMenu
    tray.Delete()

    refreshSt := GetOledRefreshStatus()
    hasRefreshItem := false

    tray.Add("Settings", (*) => OpenSettingsGui())
    tray.Add("Stats", (*) => ShowOledCareStatus())
    tray.Add()

    for item in TrayMenuItems {
        if (!item.enabled && !(item.id = "refresh" && refreshSt.state >= 1)) {
            continue
        }
        label := GetTrayItemMenuLabel(item.id)
        switch item.id {
            case "hdr_toggle":
                tray.Add(label, ToggleActiveHdrSdrSwitch)
            case "hdr_sdr":
                tray.Add(label, ToggleHdrSdrMode)
            case "refresh":
                hasRefreshItem := true
                if (refreshSt.state >= 1) {
                    tagText := (refreshSt.state = 2) ? ("OVERDUE by " FormatDuration(refreshSt.overdueMs, false)) : ("DUE in " FormatDuration(refreshSt.remainingMs, false))
                    label := "[!] Mark Pixel Refreshed (" tagText ")"
                }
                tray.Add(label, MarkPixelRefreshed)
                if (refreshSt.state >= 1) {
                    try {
                        if hMenuAlertIcon {
                            try DllCall("DestroyIcon", "Ptr", hMenuAlertIcon)
                        }
                        hMenuAlertIcon := CreateStatusCircleIcon(refreshSt.state)
                        if hMenuAlertIcon {
                            tray.SetIcon(label, "HICON:" hMenuAlertIcon)
                        }
                    }
                }
            case "pause":
                tray.Add(label, ToggleAutomationPause)
                if isAutomationPaused {
                    tray.Check(label)
                }
            case "auto_dim":
                tray.Add(label, ToggleAutoDimMaster)
                if (Primary_Auto_Enabled || IsAnyExtraMonAutoEnabled()) {
                    tray.Check(label)
                }
            case "blackout":
                tray.Add(label, TogglePrimaryDimOrBlackout)
                if (isManualBlackoutOn || isManualPrimaryDimOn || isAutoPrimaryDimmed) {
                    tray.Check(label)
                }
            case "sec_dim":
                tray.Add(label, ToggleExtraDimNow)
                if (GetDetectedMonitorCount() <= 1) {
                    tray.Disable(label)
                } else if (isManualExtraDimOn || isAutoExtraDimmed || manualExtraMonSet.Count > 0) {
                    tray.Check(label)
                }
            case "desk_hide":
                tray.Add(label, ToggleDesktopIconsAndCursorNow)
                if Desktop_Hide_Enabled {
                    tray.Check(label)
                } else {
                    tray.Uncheck(label)
                }
            case "edit":
                tray.Add(label, (*) => EditScript())
            case "reload":
                tray.Add(label, (*) => Reload())
        }
    }

    if (!hasRefreshItem && refreshSt.state >= 1) {
        tagText := (refreshSt.state = 2) ? ("OVERDUE by " FormatDuration(refreshSt.overdueMs, false)) : ("DUE in " FormatDuration(refreshSt.remainingMs, false))
        alertLbl := "[!] Mark Pixel Refreshed (" tagText ")"
        tray.Add()
        tray.Add(alertLbl, MarkPixelRefreshed)
        try {
            if hMenuAlertIcon {
                try DllCall("DestroyIcon", "Ptr", hMenuAlertIcon)
            }
            hMenuAlertIcon := CreateStatusCircleIcon(refreshSt.state)
            if hMenuAlertIcon {
                tray.SetIcon(alertLbl, "HICON:" hMenuAlertIcon)
            }
        }
    }

    tray.Add()
    tray.Add("Exit", (*) => ExitApp())
    tray.Default := "Settings"
}

ToggleAutomationPause(*) {
    global isAutomationPaused, isAutoPrimaryDimmed, isManualBlackoutOn, isManualPrimaryDimOn, isAutoExtraDimmed, manualExtraMonSet
    isAutomationPaused := !isAutomationPaused

    if isAutomationPaused {
        isAutoPrimaryDimmed := false
        if (!isManualBlackoutOn && !isManualPrimaryDimOn) {
            StartPrimaryOverlayFade(0)
        }
        if isAutoExtraDimmed {
            isAutoExtraDimmed := false
            if (manualExtraMonSet.Count = 0) {
                StartExtraFade(0)
            }
        }
        SetCursorIdleHidden(false)
        SetDesktopIconsTarget(true)
        UpdateCursorVisibility()
    } else {
        ResetAllIdleTimers()
    }
    SetupTrayMenu()
    UpdateTrayRefreshVisuals()
}

ToggleAutoDimMaster(*) {
    global Primary_Auto_Enabled, SettingsGui, SettingsActiveTab
    turnOn := !(Primary_Auto_Enabled || IsAnyExtraMonAutoEnabled())
    Primary_Auto_Enabled := turnOn
    priIdx := MonitorGetPrimary()
    Loop GetDetectedMonitorCount() {
        if (A_Index != priIdx) {
            SetExtraMonSetting(A_Index, "Auto", turnOn)
        }
    }
    ResetAllIdleTimers()
    SaveSettingsToScript()
    SetupTrayMenu()
    if IsObject(SettingsGui) {
        savedTab := SettingsActiveTab
        CloseSettingsGui()
        OpenSettingsGui(savedTab)
    }
}

TogglePrimaryDimOrBlackout(*) {
    global isManualPrimaryDimOn, isManualBlackoutOn, isAutoPrimaryDimmed
    if (isManualBlackoutOn || isManualPrimaryDimOn || isAutoPrimaryDimmed) {
        if isManualBlackoutOn {
            SetManualBlackout(false)
        }
        isManualPrimaryDimOn := false
        isAutoPrimaryDimmed  := false
        StartPrimaryOverlayFade(0)
        UpdateCursorVisibility()
        NotifyWakeEvent()
        LogPrimaryWake("switched off manually (hotkey / tray)")
        ResetPrimaryIdleTimers()
        SetupTrayMenu()
        return
    }

    targetAlpha := GetActivePrimaryDimAlpha()
    if (targetAlpha >= 255) {
        SetManualBlackout(true)
    } else if (targetAlpha > 0) {
        isManualPrimaryDimOn := true
        ArmManualPrimaryWake()
        StartPrimaryOverlayFade(targetAlpha)
        UpdateCursorVisibility()
        NotifyDimEvent()
        LogPrimaryDim("manual dim (hotkey / tray)")
        SetupTrayMenu()
    }
}

ToggleSpecificExtraMonitor(monIdx) {
    global manualExtraMonSet, isManualExtraDimOn, isAutoExtraDimmed, extraMonDimmedSet, manualExtraStartTick
    if (GetDetectedMonitorCount() <= 1 || monIdx = MonitorGetPrimary()) {
        return
    }
    if (GetEffectiveExtraMonAlpha(monIdx) <= 0) {
        return
    }

    ; This monitor is manually dimmed -> wake only this monitor
    if (isManualExtraDimOn || manualExtraMonSet.Has(monIdx)) {
        WakeManualExtraMon(monIdx)
        return
    }

    ; Auto-dimmed extras -> wake them all and restart their idle timers (Monitor 1 untouched)
    if isAutoExtraDimmed {
        isAutoExtraDimmed := false
        extraMonDimmedSet := Map()
        StartExtraFade(0)
        NotifyWakeEvent()
        DebugLogEvent("Other monitors woke up - toggled with hotkey")
        ResetExtraIdleTimers()
        SetupTrayMenu()
        return
    }

    manualExtraMonSet[monIdx] := true
    DebugLogEvent("Monitor " monIdx " dimmed manually (hotkey)")
    manualExtraStartTick := A_TickCount
    ArmManualExtraMonWake(monIdx)
    StartExtraFade(GetActiveExtraDimAlpha())
    NotifyDimEvent()
    SetupTrayMenu()
}

ToggleExtraDimNow(*) {
    global isManualExtraDimOn, isAutoExtraDimmed, manualExtraMonSet, extraMonDimmedSet, manualExtraStartTick
    if (GetDetectedMonitorCount() <= 1) {
        return
    }

    if (isManualExtraDimOn || isAutoExtraDimmed || manualExtraMonSet.Count > 0) {
        isManualExtraDimOn := false
        isAutoExtraDimmed  := false
        manualExtraMonSet  := Map()
        extraMonDimmedSet  := Map()
        StartExtraFade(0)
        NotifyWakeEvent()
        ResetExtraIdleTimers()
    } else {
        targetAlpha := GetActiveExtraDimAlpha()
        if (targetAlpha > 0) {
            isManualExtraDimOn := true
            DebugLogEvent("Other monitors dimmed manually (tray)")
            manualExtraStartTick := A_TickCount
            priIdx := MonitorGetPrimary()
            Loop GetDetectedMonitorCount() {
                m := A_Index
                if (m != priIdx) {
                    ArmManualExtraMonWake(m)
                }
            }
            StartExtraFade(targetAlpha)
            NotifyDimEvent()
        }
    }
    SetupTrayMenu()
}

ToggleDesktopIconsAndCursorNow(*) {
    global Desktop_Hide_Enabled, SettingsGui, SettingsActiveTab
    Desktop_Hide_Enabled := !Desktop_Hide_Enabled
    if !Desktop_Hide_Enabled {
        SetCursorIdleHidden(false)
        SetDesktopIconsTarget(true)
        UpdateCursorVisibility()
    } else {
        ResetAllIdleTimers()
    }
    SaveSettingsToScript()
    SetupTrayMenu()
    if IsObject(SettingsGui) {
        savedTab := SettingsActiveTab
        CloseSettingsGui()
        OpenSettingsGui(savedTab)
    }
}

PreviewPrimaryDim(sdrPercent, hdrPercent, fadeMs, isHdrNow) {
    global isTestingPrimaryDim, isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed, OLED_HDR_SDR_Mode_Enabled
    pct := (!OLED_HDR_SDR_Mode_Enabled || !isHdrNow) ? sdrPercent : hdrPercent
    alpha := Round(Max(0, Min(100, pct)) * 2.55)
    isTestingPrimaryDim := true
    StartPrimaryOverlayFade(alpha, fadeMs)
    UpdateCursorVisibility()
    SetTimer(() => EndPrimaryPreview(fadeMs), -3000)
}

EndPrimaryPreview(fadeMs) {
    global isTestingPrimaryDim, isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed
    isTestingPrimaryDim := false
    if isManualBlackoutOn {
        StartPrimaryOverlayFade(255, fadeMs)
    } else if (isManualPrimaryDimOn || isAutoPrimaryDimmed) {
        StartPrimaryOverlayFade(GetActivePrimaryDimAlpha(), fadeMs)
    } else {
        StartPrimaryOverlayFade(0, fadeMs)
    }
    UpdateCursorVisibility()
    ResetAllIdleTimers()
}

PreviewSingleExtraMonitor(monIdx, sdrPercent, hdrPercent, fadeMs, sepHdrSdr) {
    global isTestingExtraDim
    if (monIdx > GetDetectedMonitorCount() || monIdx = MonitorGetPrimary()) {
        return
    }
    pct := (!sepHdrSdr || !GetMonitorHdrInfo(monIdx).enabled) ? sdrPercent : hdrPercent
    alpha := Round(Max(0, Min(100, pct)) * 2.55)
    isTestingExtraDim := true
    StartExtraFade(alpha, fadeMs, monIdx)
    SetTimer(() => EndExtraPreview(fadeMs), -3000)
}

EndExtraPreview(fadeMs) {
    global isTestingExtraDim, isManualExtraDimOn, isAutoExtraDimmed, manualExtraMonSet
    isTestingExtraDim := false
    if (isManualExtraDimOn || isAutoExtraDimmed || manualExtraMonSet.Count > 0) {
        StartExtraFade(GetActiveExtraDimAlpha(), fadeMs)
    } else {
        StartExtraFade(0, fadeMs)
    }
    ResetAllIdleTimers()
}

EditScript(*) {
    try {
        Run('notepad.exe "' A_ScriptFullPath '"')
    } catch {
        Edit()
    }
}

; ==============================================================================
; 9. MAIN IDLE ENGINE (PER-MONITOR 3–5 OVERRIDES & EXCLUSION LIST SUPPORT)
; ==============================================================================

IsAnyDimOrHideActive() {
    global isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed, currentPrimaryAlpha, targetPrimaryAlpha
    global isManualExtraDimOn, isAutoExtraDimmed, manualExtraMonSet, currentExtraAlpha, targetExtraAlpha
    global isCursorIdleHidden, areDesktopIconsHidden
    return isManualBlackoutOn || isManualPrimaryDimOn || isAutoPrimaryDimmed
        || (currentPrimaryAlpha > 0) || (targetPrimaryAlpha > 0)
        || isManualExtraDimOn || isAutoExtraDimmed || (manualExtraMonSet.Count > 0)
        || (currentExtraAlpha > 0) || (targetExtraAlpha > 0)
        || isCursorIdleHidden || areDesktopIconsHidden
}

SyncWakeHooks() {
    if IsAnyDimOrHideActive() {
        StartWakeMouseHook()
    } else {
        StopWakeMouseHook()
    }
}

StartWakeMouseHook() {
    global wakeHookInitX, wakeHookInitY
    pt := Buffer(8, 0)
    if DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        wakeHookInitX := NumGet(pt, 0, "Int")
        wakeHookInitY := NumGet(pt, 4, "Int")
    }
    SetWakePoll(true)
}

StopWakeMouseHook() {
    SetWakePoll(false)
}

SetWakePoll(enable) {
    static running := false
    if (enable = running) {
        return
    }
    running := enable
    if enable {
        FastWakePoll(true)
    }
    SetTimer(FastWakePoll, enable ? 40 : 0)
}

; Hook-free wake detection. Runs only while something is dimmed or hidden.
FastWakePoll(resetBaseline := false) {
    global isSessionLocked, areDesktopIconsHidden, lastDesktopIconActiveTick, wakeHookInitX, wakeHookInitY, MANUAL_WAKE_MOVE_PX
    static prevIdle := 0, prevL := false, prevR := false, prevX := -99999, prevY := -99999
    static rcL := 0, rcT := 0, rcR := 0, rcB := 0, rectTick := 0

    if resetBaseline {
        prevIdle := A_TimeIdle
        prevL := GetKeyState("LButton", "P")
        prevR := GetKeyState("RButton", "P")
        pt0 := Buffer(8, 0)
        if DllCall("GetCursorPos", "Ptr", pt0.Ptr) {
            prevX := NumGet(pt0, 0, "Int")
            prevY := NumGet(pt0, 4, "Int")
            wakeHookInitX := prevX
            wakeHookInitY := prevY
        }
        return
    }

    if isSessionLocked {
        return
    }
    pt := Buffer(8, 0)
    if !DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        return
    }
    curX := NumGet(pt, 0, "Int")
    curY := NumGet(pt, 4, "Int")
    now := A_TickCount

    ; Monitor 1 rectangle, refreshed every 2 seconds
    if (now - rectTick > 2000) {
        rectTick := now
        try MonitorGet(MonitorGetPrimary(), &rcL, &rcT, &rcR, &rcB)
    }
    onPrimary := (curX >= rcL && curX < rcR && curY >= rcT && curY < rcB)

    ; Competitive game running and cursor on Monitor 1: do nothing at all
    if (onPrimary && IsCompGameRunning()) {
        wakeHookInitX := curX
        wakeHookInitY := curY
        prevX := curX
        prevY := curY
        return
    }

    lDown := GetKeyState("LButton", "P")
    rDown := GetKeyState("RButton", "P")
    lPress := lDown && !prevL
    rPress := rDown && !prevR
    prevL := lDown
    prevR := rDown

    ; Left or right click on empty desktop space brings the icons back
    if ((lPress || rPress) && areDesktopIconsHidden && IsPointInDesktopShell(curX, curY)) {
        lastDesktopIconActiveTick := now
        RestoreDesktopIconsImmediate()
    }

    idleNow := A_TimeIdle
    idleDropped := (idleNow < prevIdle)
    prevIdle := idleNow
    samePos := (curX = prevX && curY = prevY)
    prevX := curX
    prevY := curY

    moveThresh := Max(4, MANUAL_WAKE_MOVE_PX)
    if (Abs(curX - wakeHookInitX) > moveThresh || Abs(curY - wakeHookInitY) > moveThresh) {
        ; real mouse movement
        wakeHookInitX := curX
        wakeHookInitY := curY
        if !onPrimary {
            ; Cursor is on a secondary monitor: only treat an actual click as an instant wake trigger
            if (lPress || rPress) {
                TriggerInstantWake(curX, curY, true, false)
            }
        } else {
            TriggerInstantWake(curX, curY, false, false)
        }
    } else if ((idleDropped && samePos) || lPress || rPress) {
        ; key press, click or wheel without the cursor moving
        TriggerInstantWake(curX, curY, true, !(lPress || rPress))
    }
}
TriggerInstantWake(evX := -99999, evY := -99999, isInput := false, isKeyboard := false) {
    global isSessionLocked, isTestingPrimaryDim, isTestingExtraDim
    global isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed
    global isManualExtraDimOn, isAutoExtraDimmed, manualExtraMonSet, extraMonDimmedSet
    global manualPrimaryStartTick, manualExtraStartTick, manualExtraMonStartTick, MANUAL_WAKE_GRACE_MS
    global lastPrimaryActiveTick, lastExtraActiveTick, lastCursorInputTick, lastDesktopIconActiveTick
    global lastPrimaryRealInputTick, extraMonLastActiveTick, lastMouseX, lastMouseY, wasOnExtraMonitor
    global isCursorIdleHidden, areDesktopIconsHidden

    if (isSessionLocked || isTestingPrimaryDim || isTestingExtraDim) {
        return
    }

    now := A_TickCount
    curX := evX
    curY := evY
    if (curX = -99999 || curY = -99999) {
        pt := Buffer(8, 0)
        if DllCall("GetCursorPos", "Ptr", pt.Ptr) {
            curX := NumGet(pt, 0, "Int")
            curY := NumGet(pt, 4, "Int")
        } else {
            curX := lastMouseX
            curY := lastMouseY
        }
    }

    onExtraNow := IsPointOnExtraMonitor(curX, curY)
    activeExtraMon := onExtraNow ? GetExtraMonitorAtPoint(curX, curY) : 0

    lastMouseX           := curX
    lastMouseY           := curY
    wasOnExtraMonitor    := onExtraNow
    lastCursorInputTick  := now

    if isCursorIdleHidden {
        SetCursorIdleHidden(false)
    }

   if onExtraNow {
        ; Keyboard events (such as releasing PgUp after pressing the hotkey) must not wake a dimmed secondary monitor
        if isKeyboard {
            return
        }
        ; Ignore idle-drop triggers when cursor is stationary on secondary monitor unless a mouse button was actually clicked
        if (isInput && !GetKeyState("LButton", "P") && !GetKeyState("RButton", "P") && !GetKeyState("MButton", "P")) {
            return
        }
        lastExtraActiveTick := now
        if (activeExtraMon >= 2) {
            extraMonLastActiveTick[activeExtraMon] := now
            if (isManualExtraDimOn || manualExtraMonSet.Has(activeExtraMon)) {
                startTick := manualExtraMonStartTick.Has(activeExtraMon) ? manualExtraMonStartTick[activeExtraMon] : manualExtraStartTick
                if (now - startTick > MANUAL_WAKE_GRACE_MS) {
                    WakeManualExtraMon(activeExtraMon, now)
                }
            } else if (isAutoExtraDimmed && extraMonDimmedSet.Has(activeExtraMon)) {
                extraMonDimmedSet.Delete(activeExtraMon)
                if (extraMonDimmedSet.Count = 0) {
                    isAutoExtraDimmed := false
                    StartExtraFade(0)
                    NotifyWakeEvent()
                    DebugLogEvent("Activity - other monitors woke up")
                } else {
                    StartExtraFade(GetActiveExtraDimAlpha())
                }
                SetupTrayMenu()
            }
        }
    } else {
        lastPrimaryActiveTick    := now
        lastPrimaryRealInputTick := now
        if (isManualBlackoutOn || isManualPrimaryDimOn) {
            if (now - manualPrimaryStartTick > MANUAL_WAKE_GRACE_MS) {
                if isManualBlackoutOn {
                    SetManualBlackout(false)
                }
                isManualPrimaryDimOn := false
                isAutoPrimaryDimmed  := false
                StartPrimaryOverlayFade(0)
                UpdateCursorVisibility()
                NotifyWakeEvent()
                LogPrimaryWake(isKeyboard ? "keyboard input" : (isInput ? "mouse click / scroll" : "mouse moved on Monitor 1"))
                ResetPrimaryIdleTimers(now)
                SetupTrayMenu()
            }
        } else if isAutoPrimaryDimmed {
            isAutoPrimaryDimmed := false
            StartPrimaryOverlayFade(0)
            UpdateCursorVisibility()
            NotifyWakeEvent()
            LogPrimaryWake(isKeyboard ? "keyboard input" : (isInput ? "mouse click / scroll" : "mouse moved on Monitor 1"))
            SetupTrayMenu()
        }
    }

    SyncWakeHooks()
}

; Returns true when renaming a desktop icon (LVM_GETEDITCONTROL) or typing in an Explorer/Desktop Edit box
; True if the window's thread is stuck. Calling into a stuck Explorer window would freeze this script too.
IsWindowHung(hwnd) {
    return !!DllCall("IsHungAppWindow", "Ptr", hwnd, "Int")
}

IsEditingFileName() {
    if (lvHwnd := GetDesktopListViewHwnd()) {
        try {
            if !IsWindowHung(lvHwnd) {
                editHwnd := 0
                ; LVM_GETEDITCONTROL with a 150 ms timeout instead of waiting up to 5 s
                if (DllCall("SendMessageTimeoutW", "Ptr", lvHwnd, "UInt", 0x1018, "Ptr", 0, "Ptr", 0, "UInt", 0x2, "UInt", 150, "Ptr*", &editHwnd, "Ptr") && editHwnd != 0) {
                    return true
                }
            }
        }
    }

    fgHwnd := DllCall("GetForegroundWindow", "Ptr")
    if !fgHwnd {
        return false
    }
    fgClass := ""
    try fgClass := WinGetClass("ahk_id " fgHwnd)
    if (fgClass != "Progman" && fgClass != "WorkerW" && fgClass != "CabinetWClass" && fgClass != "ExploreWClass") {
        return false
    }
    try {
        if (hFocus := ControlGetFocus("A")) {
            focusClass := WinGetClass("ahk_id " hFocus)
            return (focusClass = "Edit" || InStr(focusClass, "Edit"))
        }
    }
    return false
}

; True while a classic (#32768) or visible uncloaked Windows 11 XAML context menu is open
IsContextMenuOpen() {
    if WinExist("ahk_class #32768") {
        return true
    }
    for hwnd in WinGetList("ahk_class XamlExplorerHostPopupWindow") {
        if !DllCall("IsWindowVisible", "Ptr", hwnd, "Int") {
            continue
        }
        cloaked := 0
        DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "Int*", &cloaked, "UInt", 4)
        if (cloaked = 0) {
            try {
                WinGetPos(, , &w, &h, "ahk_id " hwnd)
                if (w > 0 && h > 0) {
                    return true
                }
            }
        }
    }
    return false
}
; Returns true when (curX, curY) is over empty desktop space or desktop icons
IsPointInDesktopShell(curX, curY) {
    pt := Buffer(8, 0)
    NumPut("Int", curX, "Int", curY, pt)
    hwnd := DllCall("WindowFromPoint", "Int64", NumGet(pt, 0, "Int64"), "Ptr")
    if !hwnd {
        return false
    }
    hRoot := DllCall("GetAncestor", "Ptr", hwnd, "UInt", 2, "Ptr")
    for h in [hwnd, hRoot] {
        if !h {
            continue
        }
        cls := ""
        try cls := WinGetClass("ahk_id " h)
        if (cls = "Progman" || cls = "WorkerW" || cls = "SHELLDLL_DefView" || cls = "SysListView32") {
            return true
        }
    }
    return false
}

RestoreDesktopIconsImmediate() {
    global areDesktopIconsHidden, targetIconAlpha, currentIconAlpha, lastDesktopIconActiveTick
    lastDesktopIconActiveTick := A_TickCount
    areDesktopIconsHidden := false
    targetIconAlpha := 255
    currentIconAlpha := 255
    SetTimer(StepDesktopIconFade, 0)
    SetDesktopIconsTarget(true)
}
; Returns true on a left or right mouse button press while the cursor is on the desktop
IsDesktopClick(lBtnDown, prevLButtonDown, rBtnDown, prevRButtonDown, curX, curY) {
    lPressed := lBtnDown && !prevLButtonDown
    rPressed := rBtnDown && !prevRButtonDown
    if (!lPressed && !rPressed) {
        return false
    }
    return IsPointInDesktopShell(curX, curY)
}

CheckIdleActivity() {
    global isAutomationPaused, isSessionLocked, isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed
    global isCursorIdleHidden, areDesktopIconsHidden, isAutoExtraDimmed, isManualExtraDimOn, manualExtraMonSet
    global extraMonDimmedSet, extraMonLastActiveTick, manualExtraStartTick
    global manualPrimaryStartTick, manualPrimaryAnchorX, manualPrimaryAnchorY
    static isCompTimerThrottled := false

    if (IsCompGameRunning()) {
        if (!isCompTimerThrottled) {
            isCompTimerThrottled := true
            SetTimer(CheckIdleActivity, 1000)
        }
    } else if (isCompTimerThrottled) {
        isCompTimerThrottled := false
        SetTimer(CheckIdleActivity, 120)
    }
    global lastPrimaryActiveTick, lastDesktopIconActiveTick, lastExtraActiveTick
    global wasOnExtraMonitor, prevTimeIdle, prevLButtonDown, prevRButtonDown
    global lastMouseX, lastMouseY, lastGamepadPackets
    global Primary_Auto_Enabled, Comp_Game_Auto_SDR_Enabled, Extra_Auto_Enabled, Extra_Comp_Game_Auto_SDR, Desktop_Hide_Enabled, Desktop_Idle_Sec
    global wasCompGameRunning, switchedToSdrForCompGame, lastDebugStateSig
    global lastCursorInputTick, lastPrimaryRealInputTick, primaryAutoDimTick, lastDisplayChangeTick
    global PRIMARY_POSTDIM_MS, DISPLAY_SETTLE_MS, PRIMARY_REDIM_MS, primaryLastWakeTick

    if isSessionLocked {
        return
    }

    now := A_TickCount

    ; Keep desktop icons hidden even if Explorer / WorkerW refreshes and resets their layered alpha
    EnforceDesktopIconAlpha(now)

    compRunningNow := IsCompGameRunning()
    if (compRunningNow && !wasCompGameRunning) {
        DebugLogEvent("Competitive game detected" (Comp_Game_Auto_SDR_Enabled ? " - switching to SDR if Monitor 1 is in HDR" : ""))
        switchedToSdrForCompGame := false
        if (Comp_Game_Auto_SDR_Enabled && IsPrimaryDisplayHdrEnabled()) {
            SetWindowsPrimaryHdrState(false)
            switchedToSdrForCompGame := true
            SetupTrayMenu()
            SyncLiveHdrIndicators()
        }
        priIdx := MonitorGetPrimary()
        Loop GetDetectedMonitorCount() {
            if (A_Index != priIdx && GetExtraMonSetting(A_Index, "CompAutoSdr") && GetMonitorHdrInfo(A_Index).enabled) {
                SetMonitorHdrState(A_Index, false)
            }
        }
        SyncLiveHdrIndicators()
    } else if (!compRunningNow && wasCompGameRunning) {
        DebugLogEvent("Competitive game closed")
        if switchedToSdrForCompGame {
            switchedToSdrForCompGame := false
        }
    }
    wasCompGameRunning := compRunningNow

    curX := lastMouseX
    curY := lastMouseY
    hasCursorPos := false
    pt := Buffer(8, 0)
    if DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        curX := NumGet(pt, 0, "Int")
        curY := NumGet(pt, 4, "Int")
        hasCursorPos := true
    }

 static prevExtraBtnsDown := false
    lBtnDown := GetKeyState("LButton", "P")
    rBtnDown := GetKeyState("RButton", "P")
    extraBtnsDown := GetKeyState("MButton", "P") || GetKeyState("XButton1", "P") || GetKeyState("XButton2", "P")
    lJustPressed := lBtnDown && !prevLButtonDown
    rJustPressed := rBtnDown && !prevRButtonDown
    mouseClicked := lJustPressed || rJustPressed || (extraBtnsDown && !prevExtraBtnsDown)
    prevLButtonDown := lBtnDown
    prevRButtonDown := rBtnDown
    prevExtraBtnsDown := extraBtnsDown

    curTimeIdle := A_TimeIdle
    inputHappened := (curTimeIdle < prevTimeIdle) || mouseClicked
    prevTimeIdle := curTimeIdle

    if (!inputHappened && IsGamepadActive(&lastGamepadPackets)) {
        inputHappened := true
    }

    mouseMoved := hasCursorPos && (curX != lastMouseX || curY != lastMouseY)
    onExtraNow := hasCursorPos ? IsPointOnExtraMonitor(curX, curY) : false
    activeExtraMon := hasCursorPos ? GetExtraMonitorAtPoint(curX, curY) : 0

    ; Display / HDR topology changes can nudge the cursor without any user input -> ignore those moves
    displaySettling := (now - lastDisplayChangeTick) < DISPLAY_SETTLE_MS
    spuriousMove    := mouseMoved && !inputHappened && displaySettling
    activity        := inputHappened || (mouseMoved && !spuriousMove)

    if isManualBlackoutOn {
        ; Activity on Monitors 2-5 is tracked per monitor and never wakes the Monitor 1 blackout
        if (activity && onExtraNow) {
            lastCursorInputTick := now
            lastExtraActiveTick := now
            if (activeExtraMon >= 2) {
                extraMonLastActiveTick[activeExtraMon] := now
            }
        }
       ProcessManualExtraWake(now, hasCursorPos, curX, curY, activeExtraMon, mouseClicked, mouseMoved && !spuriousMove)
        ProcessManualPrimaryWake(now, hasCursorPos, curX, curY, onExtraNow, inputHappened)
        if hasCursorPos {
            lastMouseX := curX
            lastMouseY := curY
        }
        wasOnExtraMonitor := onExtraNow
        UpdateCursorVisibility()
        return
    }

    desktopClickedNow := hasCursorPos && IsDesktopClick(lJustPressed, false, rJustPressed, false, curX, curY)
    if (desktopClickedNow && areDesktopIconsHidden) {
        lastDesktopIconActiveTick := now
        RestoreDesktopIconsImmediate()
    }

    if activity {
        lastCursorInputTick  := now

        if (onExtraNow || wasOnExtraMonitor) {
            lastExtraActiveTick := now
            if (activeExtraMon >= 2) {
                extraMonLastActiveTick[activeExtraMon] := now
            }
            if (!onExtraNow && wasOnExtraMonitor && !inputHappened) {
                lastPrimaryActiveTick    := now
                lastPrimaryRealInputTick := now
            }
        } else {
            lastPrimaryActiveTick    := now
            lastPrimaryRealInputTick := now
        }
    }

    if hasCursorPos {
        lastMouseX := curX
        lastMouseY := curY
    }
    wasOnExtraMonitor := onExtraNow
    UpdateCursorVisibility()

  ; Per-monitor manual wake: each dimmed monitor only wakes from mouse move/click on that monitor
    ProcessManualExtraWake(now, hasCursorPos, curX, curY, activeExtraMon, mouseClicked, mouseMoved && !spuriousMove)
    if ProcessManualPrimaryWake(now, hasCursorPos, curX, curY, onExtraNow, inputHappened) {
        return
    }

    if isAutomationPaused {
        return
    }

    if IsExcludedProcessRunning() {
        ResetAllIdleTimers(now)
        if isAutoPrimaryDimmed {
            isAutoPrimaryDimmed := false
            if (!isManualBlackoutOn && !isManualPrimaryDimOn) {
                StartPrimaryOverlayFade(0)
            }
            UpdateCursorVisibility()
        }
        if (isAutoExtraDimmed || extraMonDimmedSet.Count > 0) {
            isAutoExtraDimmed := false
            extraMonDimmedSet := Map()
            if (!isManualExtraDimOn && manualExtraMonSet.Count = 0) {
                StartExtraFade(0)
            }
        }
        return
    }

    snap := GetForegroundWindowSnapshot()
    monCtxMap := GetAllMonitorContexts(snap)
    priCtx := GetPrimaryContext(snap)
    extSummary := MonCtxSummary()

    hdrNow := IsPrimaryDisplayHdrEnabled()
    stateSig := priCtx "/" extSummary "/" (hdrNow ? "1" : "0")
    if (stateSig != lastDebugStateSig) {
        lastDebugStateSig := stateSig
        DebugLogEvent("Activity changed - Monitor 1: " FriendlyCtx(priCtx) " | other monitors: " extSummary " | HDR: " OnOff(hdrNow) " | foreground app: " (snap.exe != "" ? snap.exe : "none"))
    }

    movieMons := GetMoviePlayingMonitorsCached()
    priIdx := MonitorGetPrimary()

    if (priCtx = "movie_playing" || (movieMons.Has(priIdx) && priCtx != "movie_paused")) {
        lastPrimaryActiveTick     := now
        lastDesktopIconActiveTick := now
    }
    for monIdx, _ in movieMons {
        ; A monitor whose own window is a PAUSED video must not be kept awake by a stale "playing" reading
        if (monCtxMap.Has(monIdx) && monCtxMap[monIdx].ctx = "movie_paused") {
            continue
        }
        if (monIdx = priIdx) {
            lastPrimaryActiveTick     := now
            lastDesktopIconActiveTick := now
        } else {
            lastExtraActiveTick := now
            extraMonLastActiveTick[monIdx] := now
        }
    }

    deskIdleSec := GetDesktopIdleSec()
    if (!Desktop_Hide_Enabled || isManualPrimaryDimOn || deskIdleSec <= 0) {
        if isCursorIdleHidden {
            SetCursorIdleHidden(false)
        }
        if areDesktopIconsHidden {
            SetDesktopIconsTarget(true)
        }
    } else {
        desktopIdleLimitMs := deskIdleSec * 1000
        cursorIdleElapsed := now - Max(lastCursorInputTick, lastDesktopIconActiveTick)
        iconIdleElapsed   := now - lastDesktopIconActiveTick

        if (cursorIdleElapsed >= desktopIdleLimitMs) {
            if !isCursorIdleHidden {
                SetCursorIdleHidden(true)
            }
        } else if isCursorIdleHidden {
            SetCursorIdleHidden(false)
        }

        if (IsEditingFileName() || IsContextMenuOpen()) {
            lastDesktopIconActiveTick := now
            if areDesktopIconsHidden {
                SetDesktopIconsTarget(true)
            }
        } else if (iconIdleElapsed >= desktopIdleLimitMs) {
            if !areDesktopIconsHidden {
                SetDesktopIconsTarget(false)
            }
        }
    }

    ; Windows native taskbar auto-hide is controlled via SyncWindowsTaskbarAutoHide()
    activePrimaryAlphaCap := GetActivePrimaryDimAlpha()
    priTimeoutSec := GetPrimaryTimeoutSeconds(priCtx)
    if (!Primary_Auto_Enabled || activePrimaryAlphaCap = 0 || priTimeoutSec <= 0) {
        if isAutoPrimaryDimmed {
            isAutoPrimaryDimmed := false
            if (!isManualBlackoutOn && !isManualPrimaryDimOn) {
                StartPrimaryOverlayFade(0)
            }
            UpdateCursorVisibility()
            SetupTrayMenu()
        }
    } else if !isManualPrimaryDimOn {
        primaryIdleLimitMs := priTimeoutSec * 1000
        primaryIdleElapsed := now - lastPrimaryActiveTick
        displaySettling    := (now - lastDisplayChangeTick) < DISPLAY_SETTLE_MS

        if (primaryIdleElapsed >= primaryIdleLimitMs) {
            ; Do not start a dim in the middle of a display / HDR transition
            if (!isAutoPrimaryDimmed && !displaySettling && (now - primaryLastWakeTick) > PRIMARY_REDIM_MS) {
                isAutoPrimaryDimmed := true
                primaryAutoDimTick  := now
                StartPrimaryOverlayFade(activePrimaryAlphaCap)
                UpdateCursorVisibility()
                NotifyDimEvent()
                LogPrimaryDim("no activity for " Round(primaryIdleElapsed / 1000) "s (" FriendlyCtx(priCtx) ")", true)
                SetupTrayMenu()
            }
        } else if isAutoPrimaryDimmed {
            ; Wake only on activity that happened AFTER the dim. A longer timeout after a context change,
            ; a stale timer, or a display / HDR transition alone must not wake (or bounce) Monitor 1.
            postDimSettling := (now - primaryAutoDimTick) < PRIMARY_POSTDIM_MS
            realWake        := (lastPrimaryRealInputTick > primaryAutoDimTick)
            mediaWake       := (priCtx = "movie_playing")
            timerWake       := (lastPrimaryActiveTick > primaryAutoDimTick) && !displaySettling
            if (!postDimSettling && (realWake || mediaWake || timerWake)) {
                isAutoPrimaryDimmed := false
                StartPrimaryOverlayFade(0)
                UpdateCursorVisibility()
                NotifyWakeEvent()
                LogPrimaryWake(realWake ? "keyboard / mouse / controller input" : (mediaWake ? "a video started playing" : "activity on Monitor 1"))
                SetupTrayMenu()
            }
        }
    }

    monCount := GetDetectedMonitorCount()
    priIdx := MonitorGetPrimary()
    if (monCount > 1 && IsAnyExtraMonAutoEnabled() && !isManualExtraDimOn && manualExtraMonSet.Count = 0) {
        desiredDimSet := Map()
        Loop monCount {
            mIdx := A_Index
            if (mIdx = priIdx || !GetExtraMonSetting(mIdx, "Auto")) {
                continue
            }
            if (GetEffectiveExtraMonAlpha(mIdx) <= 0) {
                continue
            }
            mTimeoutSec := GetEffectiveExtraMonTimeoutSec(mIdx, GetMonitorContext(mIdx, snap))
            if (mTimeoutSec <= 0) {
                continue
            }
            if !extraMonLastActiveTick.Has(mIdx) {
                extraMonLastActiveTick[mIdx] := lastExtraActiveTick
            }
            mTimeoutMs := mTimeoutSec * 1000
            if ((now - extraMonLastActiveTick[mIdx]) >= mTimeoutMs) {
                desiredDimSet[mIdx] := true
            }
        }

        changedSet := (desiredDimSet.Count != extraMonDimmedSet.Count)
        if !changedSet {
            for k, _ in desiredDimSet {
                if !extraMonDimmedSet.Has(k) {
                    changedSet := true
                    break
                }
            }
        }

        if changedSet {
            wasAnyDim := isAutoExtraDimmed
            DebugLogEvent(desiredDimSet.Count > 0 ? ("Idle - dimming " MonListText(desiredDimSet)) : "Activity - other monitors woke up")
            extraMonDimmedSet := desiredDimSet
            isAutoExtraDimmed := (desiredDimSet.Count > 0)
            if isAutoExtraDimmed {
                StartExtraFade(GetActiveExtraDimAlpha())
                if !wasAnyDim {
                    NotifyDimEvent()
                }
            } else {
                StartExtraFade(0)
                if wasAnyDim {
                    NotifyWakeEvent()
                }
            }
            SetupTrayMenu()
        }
    } else if (isAutoExtraDimmed && (monCount <= 1 || !IsAnyExtraMonAutoEnabled())) {
        isAutoExtraDimmed := false
        extraMonDimmedSet := Map()
        if (!isManualExtraDimOn && manualExtraMonSet.Count = 0) {
            StartExtraFade(0)
        }
        SetupTrayMenu()
    }
}

ResetAllIdleTimers(now := 0) {
    global lastPrimaryActiveTick, lastDesktopIconActiveTick, lastExtraActiveTick, prevTimeIdle, extraMonLastActiveTick, lastCursorInputTick
    if (now = 0) {
        now := A_TickCount
    }
    lastPrimaryActiveTick     := now
    lastCursorInputTick       := now
    lastDesktopIconActiveTick := now
    lastExtraActiveTick       := now
    prevTimeIdle              := A_TimeIdle
    Loop GetDetectedMonitorCount() {
        extraMonLastActiveTick[A_Index] := now
    }
}

; Resets only Monitor 1 / cursor / desktop-icon idle timers (Monitors 2-5 untouched)
ResetPrimaryIdleTimers(now := 0) {
    global lastPrimaryActiveTick, lastDesktopIconActiveTick, prevTimeIdle, lastCursorInputTick
    if (now = 0) {
        now := A_TickCount
    }
    lastPrimaryActiveTick     := now
    lastCursorInputTick       := now
    lastDesktopIconActiveTick := now
    prevTimeIdle              := A_TimeIdle
}

; Resets only Monitors 2-5 idle timers (Monitor 1 / icons untouched)
ResetExtraIdleTimers(now := 0) {
    global lastExtraActiveTick, extraMonLastActiveTick
    if (now = 0) {
        now := A_TickCount
    }
    lastExtraActiveTick := now
    Loop GetDetectedMonitorCount() {
        extraMonLastActiveTick[A_Index] := now
    }
}

; Records the toggle timestamp + cursor anchor for a manual Monitor 1 dim / blackout
ArmManualPrimaryWake() {
    global manualPrimaryStartTick, manualPrimaryAnchorX, manualPrimaryAnchorY
    manualPrimaryStartTick := A_TickCount
    pt := Buffer(8, 0)
    if DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        manualPrimaryAnchorX := NumGet(pt, 0, "Int")
        manualPrimaryAnchorY := NumGet(pt, 4, "Int")
    } else {
        manualPrimaryAnchorX := -99999
        manualPrimaryAnchorY := -99999
    }
}

; Records the toggle timestamp + cursor anchor for one manually dimmed Monitor 2-5
ArmManualExtraMonWake(monIdx) {
    global manualExtraMonStartTick, manualExtraMonAnchorPt
    manualExtraMonStartTick[monIdx] := A_TickCount
    pt := Buffer(8, 0)
    if DllCall("GetCursorPos", "Ptr", pt.Ptr) {
        manualExtraMonAnchorPt[monIdx] := { x: NumGet(pt, 0, "Int"), y: NumGet(pt, 4, "Int") }
    } else {
        manualExtraMonAnchorPt[monIdx] := { x: -99999, y: -99999 }
    }
}

; Re-arms the grace window + anchors after display topology changes (cursor may have been repositioned)
RearmManualWakeAnchors() {
    global isManualBlackoutOn, isManualPrimaryDimOn, isManualExtraDimOn, manualExtraMonSet, manualExtraStartTick
    if (isManualBlackoutOn || isManualPrimaryDimOn) {
        ArmManualPrimaryWake()
    }
    if (isManualExtraDimOn || manualExtraMonSet.Count > 0) {
        manualExtraStartTick := A_TickCount
        priIdx := MonitorGetPrimary()
        Loop GetDetectedMonitorCount() {
            m := A_Index
            if (m != priIdx && (isManualExtraDimOn || manualExtraMonSet.Has(m))) {
                ArmManualExtraMonWake(m)
            }
        }
    }
}

; Wakes a single manually dimmed extra monitor. The "all extras" flag is expanded into per-monitor
; entries so the remaining monitors stay dimmed until they see their own activity.
WakeManualExtraMon(monIdx, now := 0) {
    global isManualExtraDimOn, manualExtraMonSet, extraMonDimmedSet, manualExtraStartTick
    global manualExtraMonStartTick, manualExtraMonAnchorPt, extraMonLastActiveTick, lastExtraActiveTick
    if (now = 0) {
        now := A_TickCount
    }

    if isManualExtraDimOn {
        isManualExtraDimOn := false
        newSet := Map()
        priIdx := MonitorGetPrimary()
        Loop GetDetectedMonitorCount() {
            m := A_Index
            if (m = priIdx || m = monIdx || GetEffectiveExtraMonAlpha(m) <= 0) {
                continue
            }
            newSet[m] := true
            if !manualExtraMonStartTick.Has(m) {
                manualExtraMonStartTick[m] := manualExtraStartTick
            }
        }
        manualExtraMonSet := newSet
        extraMonDimmedSet := Map()
    } else if manualExtraMonSet.Has(monIdx) {
        manualExtraMonSet.Delete(monIdx)
    } else {
        return false
    }

    if manualExtraMonStartTick.Has(monIdx) {
        manualExtraMonStartTick.Delete(monIdx)
    }
    if manualExtraMonAnchorPt.Has(monIdx) {
        manualExtraMonAnchorPt.Delete(monIdx)
    }
    extraMonLastActiveTick[monIdx] := now
    lastExtraActiveTick := now
    DebugLogEvent("Monitor " monIdx " woke up - activity on it")

    if (manualExtraMonSet.Count = 0) {
        StartExtraFade(0)
        NotifyWakeEvent()
        ResetExtraIdleTimers(now)
    } else {
        StartExtraFade(GetActiveExtraDimAlpha())
    }
    SetupTrayMenu()
    return true
}

; Activity on a dimmed extra monitor wakes only that monitor (after the post-toggle grace window)
ProcessManualExtraWake(now, hasCursorPos, curX, curY, activeExtraMon, inputHappened, mouseMoved) {
    global isManualExtraDimOn, manualExtraMonSet, manualExtraStartTick, manualExtraMonStartTick, manualExtraMonAnchorPt
    global MANUAL_WAKE_GRACE_MS, MANUAL_WAKE_MOVE_PX

    if (!isManualExtraDimOn && manualExtraMonSet.Count = 0) {
        return false
    }
    if (activeExtraMon < 2) {
        return false
    }
    if (!isManualExtraDimOn && !manualExtraMonSet.Has(activeExtraMon)) {
        return false
    }

    startTick := manualExtraMonStartTick.Has(activeExtraMon) ? manualExtraMonStartTick[activeExtraMon] : manualExtraStartTick
    if (now - startTick <= MANUAL_WAKE_GRACE_MS) {
        return false
    }

    if !inputHappened {
        return false
    }

    return WakeManualExtraMon(activeExtraMon, now)
}

; Manual Monitor 1 dim / blackout wakes only from interaction with Monitor 1 (after the grace window)
ProcessManualPrimaryWake(now, hasCursorPos, curX, curY, onExtraNow, inputHappened) {
    global isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed
    global manualPrimaryStartTick, manualPrimaryAnchorX, manualPrimaryAnchorY
    global MANUAL_WAKE_GRACE_MS, MANUAL_WAKE_MOVE_PX, lastDisplayChangeTick, DISPLAY_SETTLE_MS

    if !(isManualBlackoutOn || isManualPrimaryDimOn) {
        return false
    }
    if (now - manualPrimaryStartTick <= MANUAL_WAKE_GRACE_MS) {
        return false
    }
    if onExtraNow {
        return false
    }

    movedDist := hasCursorPos ? Max(Abs(curX - manualPrimaryAnchorX), Abs(curY - manualPrimaryAnchorY)) : 0
    moved := (movedDist > MANUAL_WAKE_MOVE_PX)
    if ((now - lastDisplayChangeTick) < DISPLAY_SETTLE_MS) {
        moved := false    ; topology change may have repositioned the cursor
    }
    if !(inputHappened || moved) {
        return false
    }

    if isManualBlackoutOn {
        SetManualBlackout(false)
    }
    isManualPrimaryDimOn := false
    isAutoPrimaryDimmed  := false
    StartPrimaryOverlayFade(0)
    UpdateCursorVisibility()
    NotifyWakeEvent()
    LogPrimaryWake(inputHappened ? "keyboard / mouse / controller input" : "mouse moved on Monitor 1")
    ResetPrimaryIdleTimers(now)
    SetupTrayMenu()
    return true
}

GetExtraMonitorAtPoint(x, y) {
    priIdx := MonitorGetPrimary()
    Loop GetDetectedMonitorCount() {
        if (A_Index = priIdx) {
            continue
        }
        try {
            MonitorGet(A_Index, &mLeft, &mTop, &mRight, &mBottom)
            if (x >= mLeft && x < mRight && y >= mTop && y < mBottom) {
                return A_Index
            }
        }
    }
    return 0
}

; ==============================================================================
; 10. MONITOR 1 DIM / BLACKOUT OVERLAY
; ==============================================================================
SetManualBlackout(enable) {
    global isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed

    if enable {
        isManualBlackoutOn   := true
        isManualPrimaryDimOn := false
        isAutoPrimaryDimmed  := false
        ArmManualPrimaryWake()

        StartPrimaryOverlayFade(255)
        UpdateCursorVisibility()
        NotifyDimEvent()
        LogPrimaryDim("manual blackout (hotkey / tray)")
    } else {
        isManualBlackoutOn   := false
        isManualPrimaryDimOn := false
        isAutoPrimaryDimmed  := false
        StartPrimaryOverlayFade(0)
        UpdateCursorVisibility()
    }
    SetupTrayMenu()
}

StartPrimaryOverlayFade(alphaTarget, customFadeMs := -1) {
    global targetPrimaryAlpha, currentPrimaryAlpha, PrimaryOverlayGui, Primary_Fade_Ms
    global primaryFadeActive, primaryFadeFrom, primaryFadeStartTick, primaryFadeMs

    newTarget := Max(0, Min(255, Integer(alphaTarget)))
    fadeDuration := (customFadeMs >= 0) ? customFadeMs : Primary_Fade_Ms

    if (fadeDuration > 0 && newTarget = targetPrimaryAlpha && (primaryFadeActive || currentPrimaryAlpha = newTarget)) {
        return
    }
    if (fadeDuration <= 0 && newTarget = currentPrimaryAlpha && !primaryFadeActive) {
        targetPrimaryAlpha := newTarget
        return
    }

   targetPrimaryAlpha := newTarget
    if (targetPrimaryAlpha > 0) {
        if (currentPrimaryAlpha = 0) {
            WinSetTransparent(0, PrimaryOverlayGui.Hwnd)
        }
        PositionPrimaryOverlay()
        SyncWakeHooks()
    }

    if (fadeDuration <= 0) {
        SetTimer(primaryFadeTimerFn, 0)
        primaryFadeActive := false
        currentPrimaryAlpha := targetPrimaryAlpha
        ApplyPrimaryOverlayAlpha()
        return
    }

    primaryFadeFrom      := currentPrimaryAlpha
    primaryFadeStartTick := A_TickCount
    primaryFadeMs        := fadeDuration
    primaryFadeActive    := true
    SetTimer(primaryFadeTimerFn, 15)
}

; Fade progress comes from the clock, not from counting timer ticks, so it stays smooth even if a tick is late
StepPrimaryOverlayFade() {
    global currentPrimaryAlpha, targetPrimaryAlpha, primaryFadeActive, primaryFadeFrom, primaryFadeStartTick, primaryFadeMs

    progress := Min(1.0, (A_TickCount - primaryFadeStartTick) / primaryFadeMs)
    eased := progress * progress * (3 - 2 * progress)
    currentPrimaryAlpha := Round(primaryFadeFrom + (targetPrimaryAlpha - primaryFadeFrom) * eased)
    if (progress >= 1.0) {
        SetTimer(primaryFadeTimerFn, 0)
        primaryFadeActive := false
        currentPrimaryAlpha := targetPrimaryAlpha
    }
    ApplyPrimaryOverlayAlpha()
}

ApplyPrimaryOverlayAlpha() {
    global currentPrimaryAlpha, targetPrimaryAlpha, PrimaryOverlayGui
    if (currentPrimaryAlpha = 0 && targetPrimaryAlpha = 0) {
        PrimaryOverlayGui.Hide()
        SyncWakeHooks()
    } else {
        WinSetTransparent(currentPrimaryAlpha, PrimaryOverlayGui.Hwnd)
    }
}

PositionPrimaryOverlay() {
    global PrimaryOverlayGui
    MonitorGet(MonitorGetPrimary(), &mLeft, &mTop, &mRight, &mBottom)
    w := mRight - mLeft
    h := mBottom - mTop
    if (w > 0 && h > 0) {
        PrimaryOverlayGui.Show("x" mLeft " y" mTop " w" w " h" h " NA")
    }
}

; ==============================================================================
; 11. DESKTOP ICONS SMOOTH FADE (SYS-LISTVIEW32 LAYERED ALPHA)
; ==============================================================================
SetDesktopIconsTarget(visible) {
    global areDesktopIconsHidden, targetIconAlpha, currentIconAlpha, activeIconFadeStep, Icon_Fade_Ms, lastDesktopIconActiveTick

    if (!visible && (IsEditingFileName() || IsContextMenuOpen())) {
        lastDesktopIconActiveTick := A_TickCount
        return
    }

    areDesktopIconsHidden := !visible
    SyncWakeHooks()
    targetIconAlpha := visible ? 255 : 0
    lvHwnd := GetDesktopListViewHwnd()
    if !lvHwnd {
        currentIconAlpha := targetIconAlpha    ; keep state consistent; EnforceDesktopIconAlpha applies it once the list view exists
        return
    }

    if (Icon_Fade_Ms <= 0) {
        SetTimer(iconFadeTimerFn, 0)
        currentIconAlpha := targetIconAlpha
        ApplyDesktopListViewAlpha(lvHwnd, currentIconAlpha)
        return
    }

    diff := Abs(targetIconAlpha - currentIconAlpha)
    if (diff = 0) {
        ApplyDesktopListViewAlpha(lvHwnd, currentIconAlpha)
        return
    }

    ticks := Max(1, Icon_Fade_Ms // 16)
    activeIconFadeStep := Max(1, Ceil(diff / ticks))
    SetTimer(iconFadeTimerFn, 16)
}

StepDesktopIconFade() {
    global currentIconAlpha, targetIconAlpha, activeIconFadeStep
    lvHwnd := GetDesktopListViewHwnd()
    if !lvHwnd {
        SetTimer(iconFadeTimerFn, 0)
        return
    }

    if (currentIconAlpha < targetIconAlpha) {
        currentIconAlpha := Min(targetIconAlpha, currentIconAlpha + activeIconFadeStep)
    } else if (currentIconAlpha > targetIconAlpha) {
        currentIconAlpha := Max(targetIconAlpha, currentIconAlpha - activeIconFadeStep)
    }

    ApplyDesktopListViewAlpha(lvHwnd, currentIconAlpha)
    if (currentIconAlpha = targetIconAlpha) {
        SetTimer(iconFadeTimerFn, 0)
    }
}

ApplyDesktopListViewAlpha(lvHwnd, alpha) {
    global targetIconAlpha
    if IsWindowHung(lvHwnd) {
        return    ; Explorer is busy: try again on the next tick instead of freezing with it
    }

    ; Never leave the list view layered: that is what causes the black background
    exStyle := DllCall("GetWindowLongPtr", "Ptr", lvHwnd, "Int", -20, "Ptr")
    if (exStyle & 0x80000) {
        DllCall("SetLayeredWindowAttributes", "Ptr", lvHwnd, "UInt", 0, "UChar", 255, "UInt", 0x2)
        DllCall("SetWindowLongPtr", "Ptr", lvHwnd, "Int", -20, "Ptr", exStyle & ~0x80000)
    }

    ; Direction comes from the target, so restoring shows the icons immediately
    wantVisible := (targetIconAlpha > 0)
    isVisible   := DllCall("IsWindowVisible", "Ptr", lvHwnd, "Int")
    if (wantVisible && !isVisible) {
        DllCall("ShowWindow", "Ptr", lvHwnd, "Int", 8)                                   ; SW_SHOWNA
        DllCall("RedrawWindow", "Ptr", lvHwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0585)
    } else if (!wantVisible && isVisible) {
        DllCall("ShowWindow", "Ptr", lvHwnd, "Int", 0)                                   ; SW_HIDE
    }
}

; Re-applies the layered alpha while icons are hidden so Explorer / WorkerW refreshes can't reset visibility
EnforceDesktopIconAlpha(now := 0) {
    global areDesktopIconsHidden, currentIconAlpha, targetIconAlpha, lastIconEnforceTick, ICON_ENFORCE_MS
    if (now = 0) {
        now := A_TickCount
    }
    if (!areDesktopIconsHidden || (now - lastIconEnforceTick) < ICON_ENFORCE_MS) {
        return
    }
    lastIconEnforceTick := now
    if (currentIconAlpha != targetIconAlpha) {
        return    ; fade still running
    }
    lvHwnd := GetDesktopListViewHwnd()
    if lvHwnd {
        ApplyDesktopListViewAlpha(lvHwnd, currentIconAlpha)
    }
}

GetDesktopListViewHwnd() {
    hProgman := DllCall("FindWindow", "Str", "Progman", "Ptr", 0, "Ptr")
    hShell   := DllCall("FindWindowEx", "Ptr", hProgman, "Ptr", 0, "Str", "SHELLDLL_DefView", "Ptr", 0, "Ptr")
    if !hShell {
        hWorker := 0
        Loop {
            hWorker := DllCall("FindWindowEx", "Ptr", 0, "Ptr", hWorker, "Str", "WorkerW", "Ptr", 0, "Ptr")
            if !hWorker {
                break
            }
            hShell := DllCall("FindWindowEx", "Ptr", hWorker, "Ptr", 0, "Str", "SHELLDLL_DefView", "Ptr", 0, "Ptr")
            if hShell {
                break
            }
        }
    }
    return hShell ? DllCall("FindWindowEx", "Ptr", hShell, "Ptr", 0, "Str", "SysListView32", "Ptr", 0, "Ptr") : 0
}

; ==============================================================================
; 12. MONITORS 2 TO 5 SMOOTH DIM / BLACKOUT OVERLAYS (PER-MONITOR ALPHA SUPPORT)
; ==============================================================================
StartExtraFade(alphaTarget, customFadeMs := -1, previewMonIdx := 0) {
    global targetExtraAlpha, currentExtraAlpha, ExtraDimmerGuis
    global extraFadeTimerFn, extraFadeProgress

    if IsObject(extraFadeTimerFn) {
        SetTimer(extraFadeTimerFn, 0)
        extraFadeTimerFn := ""
    }

    targetExtraAlpha := Max(0, Min(255, Integer(alphaTarget)))

    if (targetExtraAlpha > 0) {
        EnsureExtraDimmerGuis(previewMonIdx)
        SyncWakeHooks()
    }

    needsFade := (currentExtraAlpha != targetExtraAlpha)
    maxFadeMs := 0
    for entry in ExtraDimmerGuis {
        if !IsObject(entry) {
            continue
        }
        curWinAlpha := ""
        try curWinAlpha := WinGetTransparent(entry.gui.Hwnd)
        if !IsInteger(curWinAlpha) {
            curWinAlpha := 0
        }
        targetAlphaForMon := (targetExtraAlpha > 0) ? GetEffectiveExtraMonAlpha(entry.monIdx) : 0
        entry.fadeFromAlpha := Max(0, Min(255, Integer(curWinAlpha)))
        entry.fadeToAlpha := targetAlphaForMon
        if (targetExtraAlpha = 0 || (entry.HasProp("removing") && entry.removing)) {
            entry.fadeToAlpha := 0
        } else {
            entry.fadeToAlpha := (previewMonIdx = entry.monIdx) ? targetExtraAlpha : GetEffectiveExtraMonAlpha(entry.monIdx)
        }
        entry.fadeMs := (customFadeMs >= 0) ? customFadeMs : GetExtraMonSetting(entry.monIdx, "FadeMs")
        if (entry.fadeFromAlpha != entry.fadeToAlpha) {
            needsFade := true
            maxFadeMs := Max(maxFadeMs, entry.fadeMs)
        }
    }

    startBase := currentExtraAlpha
    if (maxFadeMs <= 0 || !needsFade) {
        FinishExtraFade()
        return
    }

    extraFadeProgress := 0.0
    extraFadeTimerFn  := StepExtraFade.Bind(startBase, A_TickCount, maxFadeMs)
    SetTimer(extraFadeTimerFn, 15)
}

StepExtraFade(fadeStartBase := 0, startTick := 0, durationMs := 1) {
    global currentExtraAlpha, targetExtraAlpha, extraFadeProgress, extraFadeTimerFn

    elapsedMs := A_TickCount - startTick
    extraFadeProgress := Min(1.0, elapsedMs / Max(1, durationMs))
    eased := extraFadeProgress * extraFadeProgress * (3 - 2 * extraFadeProgress)
    currentExtraAlpha := Round(fadeStartBase + ((targetExtraAlpha - fadeStartBase) * eased))
    ApplyExtraDimmerScaledAlphas(elapsedMs, durationMs)

    if (extraFadeProgress >= 1.0) {
        if IsObject(extraFadeTimerFn) {
            SetTimer(extraFadeTimerFn, 0)
            extraFadeTimerFn := ""
        }
        FinishExtraFade()
    }
}

FinishExtraFade() {
    global currentExtraAlpha, targetExtraAlpha, ExtraDimmerGuis
    currentExtraAlpha := targetExtraAlpha
    if (targetExtraAlpha = 0) {
        DestroyExtraDimmerGuis()
        SyncWakeHooks()
        return
    }
    ; Fade finished: pin every overlay to its FINAL alpha.
    ; (The old call ApplyExtraDimmerScaledAlphas(1, 1) made progress = 1/fadeMs (~0), which snapped
    ;  the overlay back to its START alpha (0) the instant the fade ended = the dim-then-wake bug.)
    for entry in ExtraDimmerGuis {
        if (!IsObject(entry) || (entry.HasProp("removing") && entry.removing)) {
            continue
        }
        finalA := entry.HasProp("fadeToAlpha") ? entry.fadeToAlpha : GetEffectiveExtraMonAlpha(entry.monIdx)
        finalA := Max(0, Min(255, Integer(finalA)))
        entry.fadeFromAlpha := finalA
        entry.fadeToAlpha   := finalA
        try WinSetTransparent(finalA, entry.gui.Hwnd)
    }
    keep := []
    for entry in ExtraDimmerGuis {
        if !IsObject(entry) {
            continue
        }
        if (entry.HasProp("removing") && entry.removing) {
            try entry.gui.Destroy()
        } else {
            keep.Push(entry)
        }
    }
    ExtraDimmerGuis := keep
}

ApplyExtraDimmerScaledAlphas(elapsedMs, fallbackDurationMs := 1) {
    global ExtraDimmerGuis

    for entry in ExtraDimmerGuis {
        if !IsObject(entry) {
            continue
        }
        dur := entry.HasProp("fadeMs") ? entry.fadeMs : fallbackDurationMs
        p := (dur <= 0) ? 1.0 : Max(0.0, Min(1.0, elapsedMs / dur))
        eased := p * p * (3 - 2 * p)
        fromA := entry.HasProp("fadeFromAlpha") ? entry.fadeFromAlpha : 0
        toA   := entry.HasProp("fadeToAlpha")   ? entry.fadeToAlpha   : 0
        alphaNow := Round(fromA + ((toA - fromA) * eased))
        alphaNow := Max(0, Min(255, alphaNow))
        try WinSetTransparent(alphaNow, entry.gui.Hwnd)
    }
}

EnsureExtraDimmerGuis(previewMonIdx := 0) {
    global ExtraDimmerGuis, manualExtraMonSet, extraMonDimmedSet, isManualExtraDimOn, isAutoExtraDimmed

    desired := Map()
    monCount := GetDetectedMonitorCount()
    primaryIdx := MonitorGetPrimary()

    Loop monCount {
        mIdx := A_Index
        if (mIdx = primaryIdx) {
            continue
        }
        includeMon := (previewMonIdx = mIdx)
            || isManualExtraDimOn
            || (manualExtraMonSet.Count > 0 && manualExtraMonSet.Has(mIdx))
            || (manualExtraMonSet.Count = 0 && isAutoExtraDimmed && extraMonDimmedSet.Has(mIdx))
        if includeMon {
            desired[mIdx] := true
        }
    }

    ; Re-use overlays of monitors that stay dimmed (no flash); monitors no longer wanted fade out then get destroyed
    existing := Map()
    for entry in ExtraDimmerGuis {
        if !IsObject(entry) {
            continue
        }
        existing[entry.monIdx] := entry
        if desired.Has(entry.monIdx) {
            entry.removing := false
            try {
                MonitorGet(entry.monIdx, &mLeft, &mTop, &mRight, &mBottom)
                entry.gui.Move(mLeft, mTop, mRight - mLeft, mBottom - mTop)
            }
        } else {
            entry.removing := true
        }
    }

    for mIdx, _ in desired {
        if existing.Has(mIdx) {
            continue
        }
        MonitorGet(mIdx, &mLeft, &mTop, &mRight, &mBottom)
        g := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale +E0x20 +E0x80000")
        g.BackColor := "000000"
        WinSetTransparent(0, g.Hwnd)
        g.Show("x" mLeft " y" mTop " w" (mRight - mLeft) " h" (mBottom - mTop) " NA")
        ExtraDimmerGuis.Push({ monIdx: mIdx, gui: g, removing: false })
    }
}

DestroyExtraDimmerGuis() {
    global ExtraDimmerGuis
    for entry in ExtraDimmerGuis {
        try {
            if IsObject(entry) {
                entry.gui.Destroy()
            }
        }
    }
    ExtraDimmerGuis := []
}

; ==============================================================================
; 13. SYSTEM CURSOR & DISPLAY / GAMEPAD / CLEANUP HELPERS
; ==============================================================================
SetCursorIdleHidden(hidden) {
    global isCursorIdleHidden
    if (isCursorIdleHidden = hidden) {
        return
    }
    isCursorIdleHidden := hidden
    UpdateCursorVisibility()
}

UpdateCursorVisibility() {
    global isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed, isTestingPrimaryDim, isCursorIdleHidden, areCursorsHidden

    primaryDimActive := isManualBlackoutOn || isManualPrimaryDimOn || isAutoPrimaryDimmed || isTestingPrimaryDim
    cursorOnPrimary := false

    if primaryDimActive {
        pt := Buffer(8, 0)
        if DllCall("GetCursorPos", "Ptr", pt.Ptr) {
            cursorOnPrimary := IsPointOnPrimaryMonitor(NumGet(pt, 0, "Int"), NumGet(pt, 4, "Int"))
        }
    }

    shouldHide := (primaryDimActive && cursorOnPrimary) || isCursorIdleHidden
    if (shouldHide && !areCursorsHidden) {
        HideSystemCursors()
    } else if (!shouldHide && areCursorsHidden) {
        RestoreSystemCursors()
    }
}

HideSystemCursors() {
    global areCursorsHidden
    if areCursorsHidden {
        return
    }
    cursorIds := [32512, 32513, 32514, 32515, 32516, 32642, 32643, 32644, 32645, 32646, 32648, 32649, 32650]
    andMask := Buffer(128, 0xFF)
    xorMask := Buffer(128, 0x00)
    for id in cursorIds {
        hBlank := DllCall("CreateCursor", "Ptr", 0, "Int", 0, "Int", 0, "Int", 32, "Int", 32, "Ptr", andMask.Ptr, "Ptr", xorMask.Ptr, "Ptr")
        if hBlank {
            DllCall("SetSystemCursor", "Ptr", hBlank, "UInt", id)
        }
    }
    areCursorsHidden := true
}

RestoreSystemCursors() {
    global areCursorsHidden
    DllCall("SystemParametersInfo", "UInt", 0x0057, "UInt", 0, "Ptr", 0, "UInt", 0)
    areCursorsHidden := false
}

IsPointOnPrimaryMonitor(x, y) {
    primaryIdx := MonitorGetPrimary()
    MonitorGet(primaryIdx, &mLeft, &mTop, &mRight, &mBottom)
    return (x >= mLeft && x < mRight && y >= mTop && y < mBottom)
}

IsPointOnExtraMonitor(x, y) {
    return (GetExtraMonitorAtPoint(x, y) >= 2)
}

IsGamepadActive(&lastPackets) {
    static xinputDll := LoadXInputLibrary()
    static nextProbe := [0, 0, 0, 0]
    if !xinputDll {
        return false
    }
    stateBuf := Buffer(16, 0)
    active := false
    now := A_TickCount
    Loop 4 {
        i := A_Index
        if (now < nextProbe[i]) {
            continue
        }
        res := DllCall(xinputDll "\XInputGetState", "UInt", i - 1, "Ptr", stateBuf.Ptr, "UInt")
        if (res = 0) {
            pkt := NumGet(stateBuf, 0, "UInt")
            if (pkt != lastPackets[i]) {
                lastPackets[i] := pkt
                active := true
            }
        } else {
            nextProbe[i] := now + 3000   ; empty slot: ask again in 3 s
        }
    }
    return active
}

LoadXInputLibrary() {
    for dllName in ["xinput1_4.dll", "xinput9_1_0.dll", "xinput1_3.dll"] {
        if DllCall("LoadLibrary", "Str", dllName, "Ptr") {
            return dllName
        }
    }
    return ""
}

OnDisplayOrPowerChange(wParam, lParam, msg, hwnd) {
    global lastDisplayChangeTick
    ; WM_POWERBROADCAST also fires for harmless power events; only a resume from sleep matters here
    if (msg = 0x0218 && wParam != 0x7 && wParam != 0x12) {
        return
    }
    lastDisplayChangeTick := A_TickCount
    SetTimer(HandleDisplayOrPowerChange, -500)               ; a burst of messages becomes one handler run
}

HandleDisplayOrPowerChange() {
    global isManualBlackoutOn, isManualPrimaryDimOn, isAutoPrimaryDimmed, isAutoExtraDimmed, isManualExtraDimOn
    global manualExtraMonSet, cachedHdrState, Active_HDR_Mode, lastHdrCheckTick, lastConnectedMonitorCount, SettingsGui, SettingsActiveTab
    global lastDisplayChangeTick
    static lastSig := ""

    InvalidateDisplayTopoCache()
    newHdr := QueryWindowsPrimaryHdrState()
    newMonCount := GetDetectedMonitorCount()

    ; Some monitors re-announce the same setup again and again (VRR / HDR handshakes). If nothing really changed, leave everything alone.
    sig := newMonCount "|" (newHdr ? "1" : "0")
    Loop newMonCount {
        try {
            MonitorGet(A_Index, &l, &t, &r, &b)
            sig .= "|" l "," t "," r "," b
        }
    }
    if (sig = lastSig) {
        return
    }
    lastSig := sig

    cachedHdrState := newHdr
    Active_HDR_Mode := newHdr
    lastHdrCheckTick := A_TickCount
    lastDisplayChangeTick := A_TickCount
    DebugLogEvent("Display setup changed - " newMonCount " monitor(s) connected, Monitor 1 is in " (newHdr ? "HDR" : "SDR") " mode")

    if (isManualBlackoutOn || isManualPrimaryDimOn || isAutoPrimaryDimmed) {
        PositionPrimaryOverlay()
        if !isManualBlackoutOn {
            StartPrimaryOverlayFade(GetActivePrimaryDimAlpha())
        }
    }
    if (isAutoExtraDimmed || isManualExtraDimOn || manualExtraMonSet.Count > 0) {
        if (newMonCount <= 1) {
            isAutoExtraDimmed  := false
            isManualExtraDimOn := false
            manualExtraMonSet  := Map()
            StartExtraFade(0)
        } else {
            StartExtraFade(GetActiveExtraDimAlpha())
        }
    }
    RearmManualWakeAnchors()
    RegisterAllMonitorHotkeys()
    SetupTrayMenu()
    SyncLiveHdrIndicators()

    if (newMonCount != lastConnectedMonitorCount) {
        lastConnectedMonitorCount := newMonCount
        if IsObject(SettingsGui) {
            savedTab := SettingsActiveTab
            CloseSettingsGui()
            OpenSettingsGui(savedTab)
        }
    }
}

CleanupOnExit(exitReason, exitCode) {
    if (IsSet(IsGameModeActive) && IsGameModeActive) {
        ExitGameMode(false)
    }
    global hMinimalMonitorIcon, hActiveTrayIcon, hMenuAlertIcon
    global themeBgBrush, themeSurfaceBrush
    StopWakeMouseHook()
    try {
        LongIdleWakeAll()
        LongIdleWakeAll()
    }
    DebugLogEvent("OLED Engine stopped (" exitReason ")")
    RestoreWindowsTaskbarAutoHideOnExit()
    UnregisterSessionLockHook()
    UnregisterAllMonitorHotkeys()
    SaveOledCareState()
    RestoreDesktopIconsImmediate()
    RestoreSystemCursors()
    if (hActiveTrayIcon && hActiveTrayIcon != hMinimalMonitorIcon) {
        try DllCall("DestroyIcon", "Ptr", hActiveTrayIcon)
    }
    if hMenuAlertIcon {
        try DllCall("DestroyIcon", "Ptr", hMenuAlertIcon)
    }
    if hMinimalMonitorIcon {
        try DllCall("DestroyIcon", "Ptr", hMinimalMonitorIcon)
    }
    for br in [themeBgBrush, themeSurfaceBrush] {
        if br {
            try DllCall("DeleteObject", "Ptr", br)
        }
    }
}
; ==============================================================================
; 14. TASKBAR AUTO-HIDE, LONG-IDLE DISPLAY OFF, PRESETS
; ==============================================================================
QueryWindowsTaskbarAutoHide() {
    static ABM_GETSTATE := 0x00000004, ABS_AUTOHIDE := 0x1
    abd := Buffer(A_PtrSize = 8 ? 48 : 36, 0)
    NumPut("UInt", abd.Size, abd, 0)
    hwndTray := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
    if hwndTray {
        NumPut("Ptr", hwndTray, abd, A_PtrSize)
    }
    state := DllCall("shell32\SHAppBarMessage", "UInt", ABM_GETSTATE, "Ptr", abd.Ptr, "UInt")
    return (state & ABS_AUTOHIDE) != 0
}

SetWindowsTaskbarAutoHide(enable) {
    static ABM_SETSTATE := 0x0000000A, ABS_AUTOHIDE := 0x1, ABS_ALWAYSONTOP := 0x2
    abd := Buffer(A_PtrSize = 8 ? 48 : 36, 0)
    NumPut("UInt", abd.Size, abd, 0)
    hwndTray := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
    ; Explorer is restarting or not responding: leave the taskbar alone instead of stalling on it
    if (!hwndTray || DllCall("IsHungAppWindow", "Ptr", hwndTray, "Int")) {
        return false
    }
    NumPut("Ptr", hwndTray, abd, A_PtrSize)
    stateVal := enable ? ABS_AUTOHIDE : ABS_ALWAYSONTOP
    NumPut("Ptr", stateVal, abd, A_PtrSize = 8 ? 40 : 28)
    DllCall("shell32\SHAppBarMessage", "UInt", ABM_SETSTATE, "Ptr", abd.Ptr, "UInt")
    ; (The old system-wide "TraySettings" broadcast was removed: it made every window, including a busy Explorer, process a message at once.)
    return true
}

; The taskbar is only touched when the script really needs to: turning auto-hide ON when enabled, and undoing
; only what the script itself changed. With the option off and nothing changed by the script, Explorer is never touched.
SyncWindowsTaskbarAutoHide(enable, captureOriginal := false) {
    global originalTaskbarAutoHide, taskbarChangedByScript
    target := !!enable
    if (!target && originalTaskbarAutoHide = "") {
        return
    }
    cur := QueryWindowsTaskbarAutoHide()
    if (target && originalTaskbarAutoHide = "") {
        originalTaskbarAutoHide := cur
    }
    if (target && !cur) {
        if SetWindowsTaskbarAutoHide(true) {
            taskbarChangedByScript := true
            DebugLogEvent("Windows taskbar auto-hide set to ON")
        }
    } else if (!target && cur && taskbarChangedByScript) {
        if SetWindowsTaskbarAutoHide(false) {
            taskbarChangedByScript := false
            DebugLogEvent("Windows taskbar auto-hide set to OFF")
        }
    }
}

RestoreWindowsTaskbarAutoHideOnExit() {
    global originalTaskbarAutoHide, taskbarChangedByScript
    if (taskbarChangedByScript && originalTaskbarAutoHide != "") {
        cur := QueryWindowsTaskbarAutoHide()
        if (cur != !!originalTaskbarAutoHide) {
            SetWindowsTaskbarAutoHide(!!originalTaskbarAutoHide)
        }
    }
}

CheckLongIdle() {
    global LongIdle_Off_Enabled, LongIdle_Off_Min, isSessionLocked, isAutomationPaused, lastCursorInputTick
    static sent := false
    if (!LongIdle_Off_Enabled || isSessionLocked || isAutomationPaused) {
        sent := false
        return
    }
    idleMs := Min(A_TimeIdle, A_TickCount - lastCursorInputTick)
    if (idleMs < Max(1, LongIdle_Off_Min) * 60000) {
        sent := false
        return
    }
    if sent {
        return
    }
    if (IsExcludedProcessRunning() || IsCompGameRunning() || GetMoviePlayingMonitorsCached().Count > 0) {
        return
    }
    sent := true
    LongIdleTurnOff()
}

; ------------------------------------------------------------------------------
; LONG-IDLE DISPLAY OFF - which monitors, and how they are switched off
;   All monitors    -> Windows' own display-off signal (Windows wakes them on the first key or mouse move)
;   Some monitors   -> a DDC/CI "power off" sent to just those monitors; they are switched back on as soon as input arrives
; Nothing here runs while the feature is off, and the wake watcher only exists while a monitor is switched off.
; ------------------------------------------------------------------------------
LongIdleSelectedMonitors() {
    global LongIdle_Off_Monitors
    count := GetDetectedMonitorCount()
    out := []
    spec := StrLower(Trim(LongIdle_Off_Monitors))
    if (spec = "" || spec = "all") {
        Loop count {
            out.Push(A_Index)
        }
        return out
    }
    seen := Map()
    for part in StrSplit(spec, [",", ";", " "], " `t") {
        if (IsInteger(part) && part >= 1 && part <= count && !seen.Has(Integer(part))) {
            seen[Integer(part)] := true
            out.Push(Integer(part))
        }
    }
    return out
}

LongIdleSpecFromList(list, count) {
    if (list.Length >= count) {
        return "all"
    }
    spec := ""
    for m in list {
        spec .= (spec = "" ? "" : ",") m
    }
    return (spec = "") ? "all" : spec
}

; Sends the DDC/CI power command (VCP code 0xD6: 1 = on, 4 = off) to one monitor. True if the monitor accepted it.
LongIdleDdcPower(monIdx, turnOn) {
    ok := false
    try {
        MonitorGet(monIdx, &l, &t, &r, &b)
        cx := (l + r) // 2
        cy := (t + b) // 2
        hMon := DllCall("user32\MonitorFromPoint", "Int64", (cx & 0xFFFFFFFF) | (cy << 32), "UInt", 2, "Ptr")
        if !hMon {
            return false
        }
        cnt := 0
        if (!DllCall("dxva2\GetNumberOfPhysicalMonitorsFromHMONITOR", "Ptr", hMon, "UInt*", &cnt, "Int") || cnt < 1) {
            return false
        }
        stride := A_PtrSize + 256            ; PHYSICAL_MONITOR is packed: handle + 128 wide chars
        pm := Buffer(cnt * stride, 0)
        if !DllCall("dxva2\GetPhysicalMonitorsFromHMONITOR", "Ptr", hMon, "UInt", cnt, "Ptr", pm, "Int") {
            return false
        }
        Loop cnt {
            hPhys := NumGet(pm, (A_Index - 1) * stride, "Ptr")
            if (hPhys && DllCall("dxva2\SetVCPFeature", "Ptr", hPhys, "UChar", 0xD6, "UInt", turnOn ? 1 : 4, "Int")) {
                ok := true
            }
        }
        DllCall("dxva2\DestroyPhysicalMonitors", "UInt", cnt, "Ptr", pm)
    }
    return ok
}

LongIdleTurnOff(list := "") {
    global longIdleDdcOff, longIdleOffTick
    static warned := false
    if !IsObject(list) {
        list := LongIdleSelectedMonitors()
    }
    if (list.Length = 0) {
        return
    }
    if (list.Length >= GetDetectedMonitorCount()) {
        DebugLogEvent("Long idle - sending the display-off signal (all monitors)")
        try PostMessage(0x0112, 0xF170, 2, , "Program Manager")    ; WM_SYSCOMMAND, SC_MONITORPOWER, off
        return
    }
    longIdleOffTick := A_TickCount
    done := ""
    failed := ""
    for m in list {
        if LongIdleDdcPower(m, false) {
            longIdleDdcOff[m] := 0
            done .= (done = "" ? "" : ", ") m
        } else {
            failed .= (failed = "" ? "" : ", ") m
        }
    }
    if (done != "") {
        DebugLogEvent("Long idle - switched off monitor(s) " done " through DDC/CI")
    }
    if (failed != "") {
        DebugLogEvent("Long idle - monitor(s) " failed " did not accept the DDC/CI power command")
        if !warned {
            warned := true
            try TrayTip("Monitor " failed " did not accept the power-off command. Turn DDC/CI on in the monitor's own menu, or choose All monitors under OLED Care.", "OLED Engine", 2)
        }
    }
    if (longIdleDdcOff.Count > 0) {
        SetTimer(LongIdleWakeWatch, 250)
    }
}

; Runs only while a monitor is switched off: the first input after that moment switches everything back on
LongIdleWakeWatch() {
    global longIdleDdcOff, longIdleOffTick
    if (longIdleDdcOff.Count = 0) {
        SetTimer(LongIdleWakeWatch, 0)
        return
    }
    retry := false
    for m, fails in longIdleDdcOff {
        if (fails > 0) {
            retry := true
            break
        }
    }
    if (retry || A_TimeIdle < (A_TickCount - longIdleOffTick) - 150) {
        LongIdleWakeAll()
    }
}

LongIdleWakeAll() {
    global longIdleDdcOff
    if (longIdleDdcOff.Count = 0) {
        return
    }
    keys := []
    for m in longIdleDdcOff {
        keys.Push(m)
    }
    for m in keys {
        if LongIdleDdcPower(m, true) {
            longIdleDdcOff.Delete(m)
        } else {
            fails := longIdleDdcOff[m] + 1
            if (fails >= 8) {
                DebugLogEvent("Long idle - monitor " m " did not answer the wake command; giving up (use its power button if it stays dark)")
                longIdleDdcOff.Delete(m)
            } else {
                longIdleDdcOff[m] := fails
            }
        }
    }
    if (longIdleDdcOff.Count = 0) {
        SetTimer(LongIdleWakeWatch, 0)
    }
}

; Builds the two "turn displays off after long idle" rows on the OLED Care tab (checkbox + minutes, then the monitor picker).
; Changes are saved at once to the presets file, exactly like the Presets tab's old Extras box did.
BuildLongIdleCareRows(g, dark, y1, y2) {
    global LongIdle_Off_Enabled, LongIdle_Off_Min, SettingsLayout
    lay := SettingsLayout
    monCount := GetDetectedMonitorCount()
    ui := Map("busy", false)
    pickedSet := Map()
    for m in LongIdleSelectedMonitors() {
        pickedSet[m] := true
    }

    chkLong := g.AddCheckbox("x42 y" y1 " w262 Checked" LongIdle_Off_Enabled, "Turn displays off after long idle")
    lblLong := g.AddText("x310 y" (y1 + 4) " w70 +0x100", "after (min)")
    edtLong := g.AddEdit("x384 y" y1 " w56 Number Limit4", LongIdle_Off_Min)

    lblMons := g.AddText("x42 y" (y2 + 4) " w66 +0x100", "Monitors")
    cellW := Max(40, Min(64, Floor((lay.ir - 112 - 84 - 8) / (monCount + 1))))
    chkAll := g.AddCheckbox("x112 y" y2 " w" cellW, "All")
    monChks := []
    priIdx := MonitorGetPrimary()
    Loop monCount {
        mi := A_Index
        c := g.AddCheckbox("x" (112 + mi * cellW) " y" y2 " w" cellW, mi)
        c.Value := pickedSet.Has(mi) ? 1 : 0
        monChks.Push(c)
        RegisterTip(c, "Monitor " mi (mi = priIdx ? " [Main]" : "") " (" GetFriendlyMonitorName(mi) ").`nTick it to include this screen when the displays turn off after a long idle.")
    }
    chkAll.Value := (pickedSet.Count >= monCount) ? 1 : 0
    btnTest := g.AddButton("x" (lay.ir - 76) " y" (y2 - 2) " w76 h26", "Test")

    for c in [chkLong, lblLong, edtLong, lblMons, chkAll, btnTest] {
        StyleControlTheme(c, dark, (c.Type = "Text"))
    }
    for c in monChks {
        StyleControlTheme(c, dark)
    }

    RegisterTip(chkLong, "Turns your screens completely off when you have not touched the mouse or keyboard for the time set here, so an OLED panel can rest and run its own care cycle.`nAny key press or mouse move wakes them again.`nIt is skipped while a video plays, a competitive game runs, or a never-dim app is open.")
    RegisterTip(lblLong, "How many minutes without mouse or keyboard input before the screens turn off.")
    RegisterTip(edtLong, "How many minutes without mouse or keyboard input before the screens turn off (1 or more).")
    RegisterTip(lblMons, "Choose which screens turn off. Tick All for every screen, one number for a single screen, or several numbers for just those screens.")
    RegisterTip(chkAll, "Every screen turns off, using Windows' own display-off. Untick screens below to keep some of them on.")
    RegisterTip(btnTest, "Turns the chosen screens off right now so you can check it works. Press a key or move the mouse to wake them.`nScreens picked one by one need DDC/CI switched on in the monitor's own menu.")

    ReadPicks() {
        local out := []
        local i
        local c2
        for i, c2 in monChks {
            if c2.Value {
                out.Push(i)
            }
        }
        return out
    }

    SetStates() {
        local on := !!chkLong.Value
        SetControlsEnabled([lblLong, edtLong, lblMons, chkAll], on)
        SetControlsEnabled(monChks, on)
    }

    Save() {
        global LongIdle_Off_Enabled, LongIdle_Off_Min, LongIdle_Off_Monitors
        local v := PresetInt(edtLong.Value, 1440)
        LongIdle_Off_Enabled := !!chkLong.Value
        ; A blank or 0 box (mid-typing) keeps the previous value, so it can never turn the screens off after 1 minute by accident
        if (v >= 1) {
            LongIdle_Off_Min := v
        }
        LongIdle_Off_Monitors := LongIdleSpecFromList(ReadPicks(), monCount)
        SetStates()
        MarkSettingsDirty()
        SetTimer(SavePresetsToIni, -500)
    }

    OnPick(*) {
        local c3
        if ui["busy"] {
            return
        }
        ; At least one screen must stay ticked: if the last one was unticked, tick them all again
        if (ReadPicks().Length = 0) {
            ui["busy"] := true
            for c3 in monChks {
                c3.Value := 1
            }
            ui["busy"] := false
        }
        chkAll.Value := (ReadPicks().Length >= monCount) ? 1 : 0
        Save()
    }

    OnAll(*) {
        local c4
        if ui["busy"] {
            return
        }
        ui["busy"] := true
        for c4 in monChks {
            c4.Value := 1
        }
        chkAll.Value := 1
        ui["busy"] := false
        Save()
    }

    OnTest(*) {
        local picked := ReadPicks()
        if (picked.Length > 0) {
            LongIdleTurnOff(picked)
        }
    }

    chkLong.OnEvent("Click", (*) => Save())
    edtLong.OnEvent("Change", (*) => Save())
    edtLong.OnEvent("LoseFocus", (*) => (edtLong.Value := LongIdle_Off_Min))
    chkAll.OnEvent("Click", OnAll)
    for c in monChks {
        c.OnEvent("Click", OnPick)
    }
    btnTest.OnEvent("Click", OnTest)
    SetStates()
}

; ------------------------------------------------------------------------------
; PRESETS - data model
; A preset is a named bundle of overrides that switches on while its apps run (or are focused), or when
; it is activated by hand. The first enabled preset in the list that matches wins (list order = priority).
; Every number is "0 = keep the normal setting".
; ------------------------------------------------------------------------------
NewPresetObj(name) {
    return { name: name, enabled: true, paths: [], neverDim: false, fgOnly: false, tbHide: false, m1Sec: 0, m1Dim: 0, m2Sec: 0, m2Dim: 0, deskSec: 0 }
}

PresetMax() {
    return 50
}

PresetInt(v, maxV := 3600) {
    return IsInteger(v) ? Max(0, Min(maxV, Integer(v))) : 0
}

InvalidatePresetCache() {
    global presetCacheTick, presetActiveIdx
    presetCacheTick := 0
    presetActiveIdx := 0
}

ClonePresetObj(src) {
    c := NewPresetObj(src.name)
    c.enabled := !!src.enabled
    c.neverDim := !!src.neverDim
    c.fgOnly := !!src.fgOnly
    c.tbHide := !!src.tbHide
    c.m1Sec := src.m1Sec
    c.m1Dim := src.m1Dim
    c.m2Sec := src.m2Sec
    c.m2Dim := src.m2Dim
    c.deskSec := src.deskSec
    for pa in src.paths {
        c.paths.Push(pa)
    }
    return c
}

; "C:\Apps\Foo\foo.exe" -> "foo.exe"; "foo.exe" -> "foo.exe"
PresetExeName(path) {
    p := Trim(path, " `t`"")
    if (p = "") {
        return ""
    }
    SplitPath(p, &exeName)
    return exeName
}

; Turns whatever the user typed into a clean .exe file name, or "" when it can't be one
PresetNormalizeExe(nm) {
    n := Trim(nm, " `t`"'")
    if (n = "") {
        return ""
    }
    SplitPath(n, &base)
    if (base = "" || StrLen(base) > 120 || RegExMatch(base, '[\*\?"<>\|/:]')) {
        return ""
    }
    if !RegExMatch(base, "i)\.exe$") {
        base .= ".exe"
    }
    return base
}

PresetHasExe(p, exeName) {
    for pa in p.paths {
        if (PresetExeName(pa) = exeName) {
            return true
        }
    }
    return false
}

PresetNameTaken(nm, skip, list) {
    for q in list {
        if (IsObject(skip) && ObjPtr(q) = ObjPtr(skip)) {
            continue
        }
        if (q.name = nm) {
            return true
        }
    }
    return false
}

PresetUniqueName(name, skip := "", list := "") {
    global Presets
    if !IsObject(list) {
        list := Presets
    }
    cand := name
    n := 1
    while PresetNameTaken(cand, skip, list) {
        n += 1
        cand := name " (" n ")"
    }
    return cand
}

; Makes any preset (loaded, imported or hand-edited) safe to use: clean name, no blank / duplicate apps, numbers in range
PresetSanitize(p, idx := 1) {
    p.name := Trim(StrReplace(StrReplace(p.name, "`r", " "), "`n", " "))
    if (p.name = "") {
        p.name := "Preset " idx
    }
    if (StrLen(p.name) > 48) {
        p.name := SubStr(p.name, 1, 48)
    }
    cleaned := []
    seen := Map()
    for pa in p.paths {
        en := PresetExeName(pa)
        if (en = "" || seen.Has(StrLower(en)) || cleaned.Length >= 40) {
            continue
        }
        seen[StrLower(en)] := 1
        cleaned.Push(pa)
    }
    p.paths := cleaned
    p.enabled := !!p.enabled
    p.neverDim := !!p.neverDim
    p.fgOnly := !!p.fgOnly
    p.tbHide := !!p.tbHide
    p.m1Sec := PresetInt(p.m1Sec)
    p.m1Dim := PresetInt(p.m1Dim, 100)
    p.m2Sec := PresetInt(p.m2Sec)
    p.m2Dim := PresetInt(p.m2Dim, 100)
    p.deskSec := PresetInt(p.deskSec)
}

; Name of an earlier (higher-priority) enabled preset that shares an app with p, or ""
PresetConflictName(p) {
    global Presets
    for q in Presets {
        if (ObjPtr(q) = ObjPtr(p)) {
            return ""
        }
        if !q.enabled {
            continue
        }
        for pa in p.paths {
            en := PresetExeName(pa)
            if (en != "" && PresetHasExe(q, en)) {
                return q.name
            }
        }
    }
    return ""
}

PresetIsPinned(p) {
    global presetPinned
    return IsObject(p) && IsObject(presetPinned) && ObjPtr(p) = ObjPtr(presetPinned)
}

; Ready-made starting points offered by the New button
PresetTemplates() {
    list := []

    t := NewPresetObj("Creative apps")
    t.label := "Creative apps (never dim)"
    t.paths := ["Resolve.exe", "Adobe Premiere Pro.exe", "AfterFX.exe", "Photoshop.exe", "Illustrator.exe", "blender.exe"]
    t.neverDim := true
    list.Push(t)

    t := NewPresetObj("Meetings and calls")
    t.label := "Meetings and calls (never dim)"
    t.paths := ["Zoom.exe", "ms-teams.exe", "Teams.exe", "slack.exe"]
    t.neverDim := true
    list.Push(t)

    t := NewPresetObj("Streaming and recording")
    t.label := "Streaming and recording (never dim)"
    t.paths := ["obs64.exe", "obs32.exe"]
    t.neverDim := true
    list.Push(t)

    t := NewPresetObj("Presentations")
    t.label := "Presentations (never dim while focused)"
    t.paths := ["POWERPNT.EXE"]
    t.fgOnly := true
    t.neverDim := true
    list.Push(t)

    t := NewPresetObj("Reading and documents")
    t.label := "Reading and documents (slower dimming)"
    t.paths := ["AcroRd32.exe", "Acrobat.exe", "SumatraPDF.exe", "WINWORD.EXE"]
    t.fgOnly := true
    t.m1Sec := 120
    t.m2Sec := 60
    list.Push(t)

    t := NewPresetObj("Keep screens on")
    t.label := "Manual: keep screens on (use Activate Now)"
    t.neverDim := true
    list.Push(t)

    return list
}

; ------------------------------------------------------------------------------
; PRESETS - matching (what the engine asks, many times a second, so it is cached)
; ------------------------------------------------------------------------------
; Exe name of the window you are working in. Our own windows (Settings, overlays) never change the answer.
GetPresetForegroundExe() {
    global presetFgExe
    try {
        hwnd := WinExist("A")
        if hwnd {
            pid := WinGetPID("ahk_id " hwnd)
            if (pid != ProcessExist()) {
                presetFgExe := WinGetProcessName("ahk_id " hwnd)
            }
        }
    }
    return presetFgExe
}

PresetAppRunning(p) {
    fgExe := ""
    if p.fgOnly {
        fgExe := GetPresetForegroundExe()
        if (fgExe = "") {
            return false
        }
    }
    for path in p.paths {
        exeName := PresetExeName(path)
        if (exeName = "") {
            continue
        }
        if (fgExe != "") {
            if (exeName = fgExe) {
                return true
            }
        } else if ProcessExist(exeName) {
            return true
        }
    }
    return false
}

GetActivePresetIdx(force := false) {
    global Presets, presetActiveIdx, presetCacheTick, presetPinned
    if (!force && (A_TickCount - presetCacheTick) < 1500) {
        return presetActiveIdx
    }
    presetCacheTick := A_TickCount
    found := 0
    ; A preset activated by hand wins over everything, until it is released, disabled or deleted
    if IsObject(presetPinned) {
        for i, p in Presets {
            if (ObjPtr(p) = ObjPtr(presetPinned)) {
                if p.enabled {
                    found := i
                }
                break
            }
        }
        if !found {
            presetPinned := ""
        }
    }
    if !found {
        for i, p in Presets {
            if (p.enabled && PresetAppRunning(p)) {
                found := i
                break
            }
        }
    }
    if (found != presetActiveIdx) {
        presetActiveIdx := found
        DebugLogEvent(found ? ("Preset active: " Presets[found].name) : "No preset active - using the normal settings")
        SetTimer(PresetApplyTaskbar, -150)
    }
    return presetActiveIdx
}

GetPresetValue(key) {
    global Presets
    idx := GetActivePresetIdx()
    if (idx < 1 || idx > Presets.Length) {
        return 0
    }
    p := Presets[idx]
    return p.HasProp(key) ? p.%key% : 0
}

PresetNeverDimActive() {
    return !!GetPresetValue("neverDim")
}

GetDesktopIdleSec() {
    global Desktop_Idle_Sec
    v := GetPresetValue("deskSec")
    return (v > 0) ? v : Desktop_Idle_Sec
}

; The taskbar hides when the General-tab switch is on, or while a preset with "Hide the taskbar" is active
PresetTaskbarTarget() {
    global Taskbar_AutoHide_Enabled
    if Taskbar_AutoHide_Enabled {
        return true
    }
    return (GetPresetValue("tbHide") && !GetPresetValue("neverDim")) ? true : false
}

PresetApplyTaskbar() {
    try SyncWindowsTaskbarAutoHide(PresetTaskbarTarget())
}

; ------------------------------------------------------------------------------
; PRESETS - storage (<script>.presets.ini, written atomically with a .bak of the previous save)
; ------------------------------------------------------------------------------
ParsePresetsText(text, extras := "") {
    list := []
    cur := ""
    section := ""
    if (SubStr(text, 1, 1) = Chr(0xFEFF)) {
        text := SubStr(text, 2)
    }
    for rawLine in StrSplit(StrReplace(text, "`r", ""), "`n") {
        ln := Trim(rawLine)
        if (ln = "" || SubStr(ln, 1, 1) = ";") {
            continue
        }
        if (ln = "[Extras]") {
            section := "extras"
            continue
        }
        if (ln = "[Preset]") {
            cur := NewPresetObj("")
            list.Push(cur)
            section := "preset"
            continue
        }
        if (SubStr(ln, 1, 1) = "[") {
            section := ""
            continue
        }
        eq := InStr(ln, "=")
        if !eq {
            continue
        }
        k := Trim(SubStr(ln, 1, eq - 1))
        v := Trim(SubStr(ln, eq + 1))
        if (section = "extras") {
            if IsObject(extras) {
                extras[k] := v
            }
        } else if (section = "preset" && IsObject(cur)) {
            switch k {
                case "Name": cur.name := v
                case "Enabled": cur.enabled := (v = "1")
                case "Paths": cur.paths := (v = "") ? [] : StrSplit(v, "|", " `t")
                case "NeverDim": cur.neverDim := (v = "1")
                case "FgOnly": cur.fgOnly := (v = "1")
                case "TbHide": cur.tbHide := (v = "1")
                case "M1Sec": cur.m1Sec := PresetInt(v)
                case "M1Dim": cur.m1Dim := PresetInt(v, 100)
                case "M2Sec": cur.m2Sec := PresetInt(v)
                case "M2Dim": cur.m2Dim := PresetInt(v, 100)
                case "DeskSec": cur.deskSec := PresetInt(v)
            }
        }
    }
    return list
}

PresetToIniText(p) {
    t := "`n[Preset]`n"
    t .= "Name=" StrReplace(StrReplace(p.name, "`r", " "), "`n", " ") "`n"
    t .= "Enabled=" (p.enabled ? 1 : 0) "`n"
    t .= "Paths=" JoinArray(p.paths, "|") "`n"
    t .= "NeverDim=" (p.neverDim ? 1 : 0) "`n"
    t .= "FgOnly=" (p.fgOnly ? 1 : 0) "`n"
    t .= "TbHide=" (p.tbHide ? 1 : 0) "`n"
    t .= "M1Sec=" p.m1Sec "`n"
    t .= "M1Dim=" p.m1Dim "`n"
    t .= "M2Sec=" p.m2Sec "`n"
    t .= "M2Dim=" p.m2Dim "`n"
    t .= "DeskSec=" p.deskSec "`n"
    return t
}

PresetsToIniText(list, withExtras := true) {
    global Taskbar_AutoHide_Enabled, LongIdle_Off_Enabled, LongIdle_Off_Min, LongIdle_Off_Monitors, Run_As_Admin
    out := ""
    if withExtras {
        out .= "[Extras]`n"
        out .= "TaskbarAutoHide=" (Taskbar_AutoHide_Enabled ? 1 : 0) "`n"
        out .= "LongIdleOff=" (LongIdle_Off_Enabled ? 1 : 0) "`n"
        out .= "LongIdleMin=" LongIdle_Off_Min "`n"
        out .= "LongIdleMonitors=" LongIdle_Off_Monitors "`n"
        out .= "RunAsAdmin=" (Run_As_Admin ? 1 : 0) "`n"
    }
    for p in list {
        out .= PresetToIniText(p)
    }
    return out
}

LoadPresetsFromIni() {
    global Presets, PresetsIniPath, Taskbar_AutoHide_Enabled, LongIdle_Off_Enabled, LongIdle_Off_Min, LongIdle_Off_Monitors, Run_As_Admin
    Presets := []
    ; Main file first; if it is unreadable or damaged, fall back to the backup of the previous save
    for srcPath in [PresetsIniPath, PresetsIniPath ".bak"] {
        if !FileExist(srcPath) {
            continue
        }
        text := ""
        try {
            text := FileRead(srcPath, "UTF-8")
        } catch {
            continue
        }
        if (Trim(text) = "") {
            continue
        }
        extras := Map()
        list := ParsePresetsText(text, extras)
        if (list.Length = 0 && extras.Count = 0) {
            continue
        }
        if extras.Has("TaskbarAutoHide") {
            Taskbar_AutoHide_Enabled := (extras["TaskbarAutoHide"] = "1")
        }
        if extras.Has("LongIdleOff") {
            LongIdle_Off_Enabled := (extras["LongIdleOff"] = "1")
        }
        if extras.Has("LongIdleMin") {
            LongIdle_Off_Min := Max(1, PresetInt(extras["LongIdleMin"], 1440))
        }
        if extras.Has("LongIdleMonitors") {
            LongIdle_Off_Monitors := (Trim(extras["LongIdleMonitors"]) = "") ? "all" : Trim(extras["LongIdleMonitors"])
        }
        if extras.Has("RunAsAdmin") {
            Run_As_Admin := (extras["RunAsAdmin"] = "1")
        }
        for i, p in list {
            if (Presets.Length >= PresetMax()) {
                break
            }
            PresetSanitize(p, i)
            p.name := PresetUniqueName(p.name)
            Presets.Push(p)
        }
        if (srcPath != PresetsIniPath) {
            DebugLogEvent("Presets file was unreadable - restored from the backup copy")
        }
        return
    }
}

PresetNotifySaveFailure() {
    static lastTick := 0
    if (lastTick && (A_TickCount - lastTick) < 60000) {
        return
    }
    lastTick := A_TickCount
    try TrayTip("Your presets could not be saved. Check that the config folder is writable and the disk is not full.", "OLED Engine - Presets", 2)
}

SavePresetsToIni() {
    global Presets, PresetsIniPath
    if (PresetsIniPath = "") {
        return false
    }
    out := PresetsToIniText(Presets, true)
    tmp := PresetsIniPath ".tmp"
    try {
        if FileExist(tmp) {
            FileDelete(tmp)
        }
        f := FileOpen(tmp, "w", "UTF-8")
        f.Write(out)
        f.Close()
        if (FileGetSize(tmp) < 1) {
            throw Error("The temporary presets file came out empty")
        }
        if FileExist(PresetsIniPath) {
            try FileCopy(PresetsIniPath, PresetsIniPath ".bak", 1)
        }
        FileMove(tmp, PresetsIniPath, 1)
        return true
    } catch as err {
        DebugLogEvent("Saving presets failed: " err.Message)
        PresetNotifySaveFailure()
        return false
    }
}

; ------------------------------------------------------------------------------
; PRESETS - one-line description of what a preset does (shown on the tab)
; ------------------------------------------------------------------------------
PresetSummaryText(p) {
    if !p.enabled {
        return "This preset is switched off, so it never activates."
    }
    parts := []
    n := p.paths.Length
    if (n = 0) {
        parts.Push("No apps added yet: it only turns on with Activate Now.")
    } else if p.fgOnly {
        parts.Push("Active while " (n = 1 ? "this app is" : "one of these " n " apps is") " the focused window.")
    } else {
        parts.Push("Active while " (n = 1 ? "this app is" : "any of these " n " apps is") " running.")
    }
    if p.neverDim {
        parts.Push("Nothing dims, blacks out or hides.")
    } else {
        ov := []
        if (p.m1Sec > 0) {
            ov.Push("Monitor 1 dims after " p.m1Sec " s")
        }
        if (p.m1Dim > 0) {
            ov.Push("Monitor 1 dim " p.m1Dim "%")
        }
        if (p.m2Sec > 0) {
            ov.Push("Monitors 2+ dim after " p.m2Sec " s")
        }
        if (p.m2Dim > 0) {
            ov.Push("Monitors 2+ dim " p.m2Dim "%")
        }
        if (p.deskSec > 0) {
            ov.Push("icons hide after " p.deskSec " s")
        }
        if p.tbHide {
            ov.Push("taskbar hidden")
        }
        parts.Push(ov.Length ? ("Changes: " JoinArray(ov, ", ") ".") : "No overrides set, so the normal settings still apply.")
    }
    cf := PresetConflictName(p)
    if (cf != "") {
        parts.Push("Shares an app with '" cf "' (higher in the list), which wins.")
    }
    return JoinArray(parts, " ")
}

; ------------------------------------------------------------------------------
; PRESETS - "pick from running programs" window (returns an array of .exe names, empty if cancelled)
; ------------------------------------------------------------------------------
PresetPickRunningApps(owner, dark, p) {
    result := []
    seen := Map()
    ownPid := ProcessExist()
    for hwnd in WinGetList() {
        exe := ""
        title := ""
        try {
            if (DllCall("IsWindowVisible", "Ptr", hwnd, "Int") && !(WinGetExStyle("ahk_id " hwnd) & 0x80)) {
                title := WinGetTitle("ahk_id " hwnd)
                if (WinGetPID("ahk_id " hwnd) != ownPid) {
                    exe := WinGetProcessName("ahk_id " hwnd)
                }
            }
        }
        if (exe = "" || title = "" || title = "Program Manager" || seen.Has(StrLower(exe)) || PresetHasExe(p, exe)) {
            continue
        }
        seen[StrLower(exe)] := Map("exe", exe, "title", title)
    }
    if (seen.Count = 0) {
        owner.Opt("+OwnDialogs")
        MsgBox("No other open programs were found (or they are already in this preset).`n`nOpen the program first, or use 'Type an .exe name'.", "Add a running program", "Iconi")
        return result
    }
    lst := ""
    for k in seen {
        lst .= k "`n"
    }
    order := StrSplit(Sort(RTrim(lst, "`n")), "`n")

    pg := Gui("+Owner" owner.Hwnd " +ToolWindow", "Add a running program")
    ApplyGuiTheme(pg, dark)
    pg.MarginX := 14
    pg.MarginY := 12
    pg.AddText("w500", "Pick one or more programs (hold Ctrl or Shift to select several).")
    lv := pg.AddListView("w500 r14", ["Program", "Window title"])
    for key in order {
        it := seen[key]
        lv.Add(, it["exe"], it["title"])
    }
    lv.ModifyCol(1, 190)
    lv.ModifyCol(2, 290)
    StyleControlTheme(lv, dark)
    btnOk := pg.AddButton("xm y+12 w150 h28 Default", "Add Selected")
    btnCancel := pg.AddButton("x+8 yp w100 h28", "Cancel")
    StyleControlTheme(btnOk, dark)
    StyleControlTheme(btnCancel, dark)

    DoOk(*) {
        local rowNo := 0
        local chosen := []
        while (rowNo := lv.GetNext(rowNo)) {
            chosen.Push(lv.GetText(rowNo, 1))
        }
        if (chosen.Length = 0) {
            return
        }
        for nm in chosen {
            result.Push(nm)
        }
        pg.Destroy()
    }
    DoCancel(*) {
        pg.Destroy()
    }
    btnOk.OnEvent("Click", DoOk)
    btnCancel.OnEvent("Click", DoCancel)
    lv.OnEvent("DoubleClick", DoOk)
    pg.OnEvent("Close", DoCancel)
    pg.OnEvent("Escape", DoCancel)

    try {
        owner.Opt("+Disabled")
        pg.Show()
        WinWaitClose("ahk_id " pg.Hwnd)
    } finally {
        owner.Opt("-Disabled")
        try WinActivate("ahk_id " owner.Hwnd)
    }
    return result
}

; ------------------------------------------------------------------------------
; PRESETS TAB
; ------------------------------------------------------------------------------
BuildPresetsTab(g, dark, tabIdx := 0) {
    global Presets, SettingsLayout, SettingsTabsCtrl
    lay := SettingsLayout
    state := Map("busy", false, "sel", 0)
    gHwnd := g.Hwnd
    arrow := Chr(0x25BE)

    ; ---- top row: preset picker + list actions ----
    tbW := 76
    moreX := lay.ir - tbW
    delX := moreX - 6 - tbW
    dupX := delX - 6 - tbW
    newX := dupX - 6 - tbW
    lblPreset := g.AddText("x28 y49 w60 +0x100", "Preset")
    ddl := g.AddDropDownList("x92 y45 w" (newX - 8 - 92))
    btnNew := g.AddButton("x" newX " y44 w" tbW " h26", "New " arrow)
    btnDup := g.AddButton("x" dupX " y44 w" tbW " h26", "Duplicate")
    btnDel := g.AddButton("x" delX " y44 w" tbW " h26", "Delete")
    btnMore := g.AddButton("x" moreX " y44 w" tbW " h26", "More " arrow)
    txtActive := g.AddText("x28 y76 w" (lay.bw - 6) " h20 +0x100", "")

    ; ---- selected preset ----
    AddSectionBox(g, lay.bx, 100, lay.bw, 410, "Selected Preset", dark)
    lblName := g.AddText("x42 y128 w50 +0x100", "Name")
    edtName := g.AddEdit("x96 y124 w" (lay.ir - 110 - 10 - 96) " -Multi Limit48")
    chkOn := g.AddCheckbox("x" (lay.ir - 110) " y126 w110", "Enabled")
    lblApps := g.AddText("x42 y156 w" lay.iw " +0x100", "Apps that activate this preset  (the first matching preset in the list wins)")
    lbApps := g.AddListBox("x42 y178 w" (lay.ir - 120 - 10 - 42) " r4")
    btnAdd := g.AddButton("x" (lay.ir - 120) " y178 w120 h26", "Add App " arrow)
    btnRem := g.AddButton("x" (lay.ir - 120) " y208 w120 h26", "Remove")
    chkFg := g.AddCheckbox("x42 y262 w" lay.iw, "Only while one of these apps is the focused window (not just open)")
    chkNever := g.AddCheckbox("x42 y288 w" lay.iw, "Never dim, black out or hide anything while this preset is active")
    lblCaption := g.AddText("x42 y320 w" lay.iw " +0x100", "Overrides while active  (0 = keep the normal setting)")
    lblM1S := g.AddText("x42 y346 w" lay.lblW " +0x100", "Monitor 1 delay (s)")
    edtM1S := g.AddEdit("x" lay.e1 " y342 w56 Number Limit4")
    lblM1D := g.AddText("x" lay.c2x " y346 w" lay.lblW " +0x100", "Monitor 1 dim %")
    edtM1D := g.AddEdit("x" lay.e2 " y342 w56 Number Limit3")
    lblM2S := g.AddText("x42 y376 w" lay.lblW " +0x100", "Monitors 2+ delay (s)")
    edtM2S := g.AddEdit("x" lay.e1 " y372 w56 Number Limit4")
    lblM2D := g.AddText("x" lay.c2x " y376 w" lay.lblW " +0x100", "Monitors 2+ dim %")
    edtM2D := g.AddEdit("x" lay.e2 " y372 w56 Number Limit3")
    lblDesk := g.AddText("x42 y406 w" lay.lblW " +0x100", "Desktop icons idle (s)")
    edtDesk := g.AddEdit("x" lay.e1 " y402 w56 Number Limit4")
    chkTbHide := g.AddCheckbox("x" lay.c2x " y404 w" lay.colW, "Hide the taskbar while active")
    txtSum := g.AddText("x42 y438 w" lay.iw " h36", "")
    btnW4 := Floor((lay.iw - 18) / 4)
    btnUp := g.AddButton("x42 y476 w" btnW4 " h26", "Move Up")
    btnDn := g.AddButton("x" (42 + btnW4 + 6) " y476 w" btnW4 " h26", "Move Down")
    btnPin := g.AddButton("x" (42 + 2 * (btnW4 + 6)) " y476 w" btnW4 " h26", "Activate Now")
    btnReset := g.AddButton("x" (42 + 3 * (btnW4 + 6)) " y476 w" btnW4 " h26", "Reset Overrides")

    ruleCtrls := [lblApps, lbApps, btnAdd, btnRem, chkFg, chkNever]
    overrideCtrls := [lblM1S, edtM1S, lblM1D, edtM1D, lblM2S, edtM2S, lblM2D, edtM2D, lblDesk, edtDesk, chkTbHide, btnReset]
    allCtrls := [lblPreset, ddl, btnNew, btnDup, btnDel, btnMore, lblName, edtName, chkOn, lblApps, lbApps, btnAdd, btnRem, chkFg, chkNever
        , lblM1S, edtM1S, lblM1D, edtM1D, lblM2S, edtM2S, lblM2D, edtM2D, lblDesk, edtDesk, chkTbHide, btnUp, btnDn, btnPin, btnReset
]
    for ctlItem in allCtrls {
        StyleControlTheme(ctlItem, dark)
    }
    for ctlItem in [txtActive, txtSum, lblCaption] {
        StyleControlTheme(ctlItem, dark, true)
    }

    RegisterTip(ddl, "Presets are checked from the top of this list down; the first enabled one that matches is used. Reorder them with Move Up / Move Down.")
    RegisterTip(btnNew, "Start from a ready-made preset (creative apps, meetings, streaming, presentations, reading) or a blank one.")
    RegisterTip(btnMore, "Export your presets to a file, import presets from one, or open the presets file.")
    RegisterTip(lbApps, "The preset is active while any of these programs is running (or focused, if that box is ticked). Matching is by .exe file name.")
    RegisterTip(btnAdd, "Browse for a program, pick one that is open right now, or type its .exe name.")
    RegisterTip(chkFg, "On: the preset only applies while one of these programs is the window you are working in. Off: it applies whenever one of them is running, even in the background.")
    RegisterTip(chkNever, "While this preset is active nothing dims or blacks out, and the cursor, icons and taskbar are left alone.")
    RegisterTip(edtM1S, "Idle delay for Monitor 1 in every situation except a paused video. 0 = use the normal delays.")
    RegisterTip(edtM1D, "Dim level for Monitor 1 while this preset is active (100 = full blackout). 0 = use the normal level.")
    RegisterTip(edtM2S, "Idle delay for Monitors 2 and up. 0 = use the normal delays.")
    RegisterTip(edtM2D, "Dim level for Monitors 2 and up (100 = full blackout). 0 = use the normal level.")
    RegisterTip(edtDesk, "Seconds of idle time before the cursor is hidden and desktop icons fade. 0 = use the normal delay.")
    RegisterTip(chkTbHide, "Turns on Windows' taskbar auto-hide while this preset is active, then puts it back as it was. Ignored by 'Never dim' presets.")
    RegisterTip(btnPin, "Switches this preset on right now, whatever is running. It stays on until you release it, disable the preset or restart OLED Engine.")
    RegisterTip(btnReset, "Sets every override above back to 0 (use the normal settings).")

    ; ---- helpers (nested functions: every variable they assign is declared local on purpose) ----
    SelPreset() {
        local ix := state["sel"]
        return (ix >= 1 && ix <= Presets.Length) ? Presets[ix] : ""
    }

    SyncPresetGreyStates() {
        local sp := SelPreset()
        local hasSel := IsObject(sp)
        local presetOn := hasSel && !!chkOn.Value
        local neverOn := presetOn && !!chkNever.Value
        SetControlsEnabled([btnDup, btnDel, lblName, edtName, chkOn], hasSel)
        SetControlsEnabled(ruleCtrls, presetOn)
        SetControlsEnabled(overrideCtrls, presetOn && !neverOn)
        SetControlsEnabled([btnUp], hasSel && state["sel"] > 1)
        SetControlsEnabled([btnDn], hasSel && state["sel"] < Presets.Length)
        SetControlsEnabled([btnPin], presetOn)
    }

    RefreshActiveText() {
        local ai := GetActivePresetIdx(true)
        local msg := "Active right now: none (normal settings)"
        local sp := SelPreset()
        if (ai >= 1 && ai <= Presets.Length) {
            msg := "Active right now: " Presets[ai].name (PresetIsPinned(Presets[ai]) ? "  (activated by hand)" : "")
        } else if IsObject(sp) {
            ; Explain why the selected preset is not active, so the line never looks stuck
            if !sp.enabled {
                msg .= "  -  '" sp.name "' is switched off"
            } else if (sp.paths.Length = 0) {
                msg .= "  -  '" sp.name "' has no apps yet (add one or use Activate Now)"
            } else {
                msg .= "  -  waiting for one of its apps " (sp.fgOnly ? "to be focused" : "to start")
            }
        }
        if (txtActive.Text != msg) {
            txtActive.Text := msg
        }
        local pinTxt := PresetIsPinned(sp) ? "Stop Activating" : "Activate Now"
        if (btnPin.Text != pinTxt) {
            btnPin.Text := pinTxt
        }
    }

    RefreshSummary() {
        local sp := SelPreset()
        txtSum.Text := IsObject(sp) ? PresetSummaryText(sp) : "No presets yet. Click New to start from a ready-made preset, or add a blank one."
    }

    FillAppList() {
        local sp := SelPreset()
        local names := []
        local nm := ""
        lbApps.Delete()
        if (IsObject(sp) && sp.paths.Length > 0) {
            for nm in sp.paths {
                names.Push(PresetExeName(nm))
            }
            lbApps.Add(names)
        }
    }

    LoadSel() {
        local sp
        state["busy"] := true
        try {
            state["sel"] := (Presets.Length > 0) ? ddl.Value : 0
            sp := SelPreset()
            if IsObject(sp) {
                edtName.Value := sp.name
                chkOn.Value := sp.enabled ? 1 : 0
                chkFg.Value := sp.fgOnly ? 1 : 0
                chkNever.Value := sp.neverDim ? 1 : 0
                chkTbHide.Value := sp.tbHide ? 1 : 0
                edtM1S.Value := sp.m1Sec
                edtM1D.Value := sp.m1Dim
                edtM2S.Value := sp.m2Sec
                edtM2D.Value := sp.m2Dim
                edtDesk.Value := sp.deskSec
            } else {
                edtName.Value := ""
                chkOn.Value := 0
                chkFg.Value := 0
                chkNever.Value := 0
                chkTbHide.Value := 0
                edtM1S.Value := ""
                edtM1D.Value := ""
                edtM2S.Value := ""
                edtM2D.Value := ""
                edtDesk.Value := ""
            }
            FillAppList()
        } finally {
            state["busy"] := false
        }
        SyncPresetGreyStates()
        RefreshActiveText()
        RefreshSummary()
    }

    RebuildDdl(pick) {
        local names := []
        local pn
        ddl.Delete()
        for pn in Presets {
            names.Push(pn.name != "" ? pn.name : "(unnamed)")
        }
        if (names.Length > 0) {
            ddl.Add(names)
            ddl.Choose(Max(1, Min(names.Length, pick)))
        }
    }

    FillDdl(pick) {
        RebuildDdl(pick)
        LoadSel()
    }

    SaveSoon() {
        InvalidatePresetCache()
        SetTimer(SavePresetsToIni, -500)
    }

    ReadEditors(*) {
        local pe
        if (state["busy"]) {
            return
        }
        pe := SelPreset()
        if !IsObject(pe) {
            return
        }
        pe.name := Trim(edtName.Value)
        pe.enabled := !!chkOn.Value
        pe.fgOnly := !!chkFg.Value
        pe.neverDim := !!chkNever.Value
        pe.tbHide := !!chkTbHide.Value
        pe.m1Sec := PresetInt(edtM1S.Value)
        pe.m1Dim := PresetInt(edtM1D.Value, 100)
        pe.m2Sec := PresetInt(edtM2S.Value)
        pe.m2Dim := PresetInt(edtM2D.Value, 100)
        pe.deskSec := PresetInt(edtDesk.Value)
        SyncPresetGreyStates()
        SaveSoon()
        RefreshActiveText()
        RefreshSummary()
    }

    ; When a box loses focus, show what was really stored (blank -> 0, 5000 -> 3600, name made unique)
    NormalizeNumbers(*) {
        local sp := SelPreset()
        if !IsObject(sp) {
            return
        }
        state["busy"] := true
        edtM1S.Value := sp.m1Sec
        edtM1D.Value := sp.m1Dim
        edtM2S.Value := sp.m2Sec
        edtM2D.Value := sp.m2Dim
        edtDesk.Value := sp.deskSec
        state["busy"] := false
    }

    FinalizeName(*) {
        local sp := SelPreset()
        local nm
        if !IsObject(sp) {
            return
        }
        nm := Trim(edtName.Value)
        if (nm = "") {
            nm := "Preset " state["sel"]
        }
        nm := PresetUniqueName(nm, sp)
        if (nm != sp.name || nm != edtName.Value) {
            sp.name := nm
            state["busy"] := true
            edtName.Value := nm
            state["busy"] := false
            SetTimer(SavePresetsToIni, -500)
        }
        RebuildDdl(state["sel"])
        RefreshSummary()
    }

    AddNewPreset(tplObj) {
        local np
        if (Presets.Length >= PresetMax()) {
            g.Opt("+OwnDialogs")
            MsgBox("You can have up to " PresetMax() " presets. Delete one you no longer need first.", "Presets", "Icon!")
            return
        }
        np := ClonePresetObj(tplObj)
        PresetSanitize(np, Presets.Length + 1)
        np.name := PresetUniqueName(np.name = "" ? ("Preset " (Presets.Length + 1)) : np.name)
        Presets.Push(np)
        SaveSoon()
        FillDdl(Presets.Length)
        try edtName.Focus()
    }

    MakeTemplateAdder(tplObj) {
        return (*) => AddNewPreset(tplObj)
    }

    OnNew(*) {
        local m := Menu()
        local tpl
        m.Add("Blank preset", (*) => AddNewPreset(NewPresetObj("Preset " (Presets.Length + 1))))
        m.Add()
        for tpl in PresetTemplates() {
            m.Add(tpl.label, MakeTemplateAdder(tpl))
        }
        m.Show()
    }

    OnDuplicate(*) {
        local sp := SelPreset()
        local cp
        if !IsObject(sp) {
            return
        }
        if (Presets.Length >= PresetMax()) {
            g.Opt("+OwnDialogs")
            MsgBox("You can have up to " PresetMax() " presets. Delete one you no longer need first.", "Presets", "Icon!")
            return
        }
        cp := ClonePresetObj(sp)
        cp.name := PresetUniqueName(sp.name " (copy)")
        Presets.InsertAt(state["sel"] + 1, cp)
        SaveSoon()
        FillDdl(state["sel"] + 1)
    }

    OnDelete(*) {
        local ix := state["sel"]
        local sp := SelPreset()
        local ans
        if !IsObject(sp) {
            return
        }
        g.Opt("+OwnDialogs")
        ans := MsgBox("Delete the preset '" sp.name "'?`n`nThis cannot be undone.", "Delete preset", "YesNo Icon! Default2")
        if (ans != "Yes") {
            return
        }
        Presets.RemoveAt(ix)
        SaveSoon()
        FillDdl(Min(ix, Presets.Length))
    }

    MovePreset(dir) {
        local ix := state["sel"]
        local sp := SelPreset()
        local target := ix + dir
        if (!IsObject(sp) || target < 1 || target > Presets.Length) {
            return
        }
        Presets.RemoveAt(ix)
        Presets.InsertAt(target, sp)
        SaveSoon()
        FillDdl(target)
    }

    OnPin(*) {
        global presetPinned
        local sp := SelPreset()
        if (!IsObject(sp) || !sp.enabled) {
            return
        }
        presetPinned := PresetIsPinned(sp) ? "" : sp
        InvalidatePresetCache()
        RefreshActiveText()
    }

    OnResetOverrides(*) {
        local sp := SelPreset()
        if !IsObject(sp) {
            return
        }
        sp.m1Sec := 0
        sp.m1Dim := 0
        sp.m2Sec := 0
        sp.m2Dim := 0
        sp.deskSec := 0
        sp.tbHide := false
        state["busy"] := true
        chkTbHide.Value := 0
        state["busy"] := false
        NormalizeNumbers()
        SaveSoon()
        RefreshActiveText()
        RefreshSummary()
    }

    ; ---- apps ----
    AddExeNames(names) {
        local sp := SelPreset()
        local nm, ex
        local added := 0
        local dups := 0
        local bad := []
        if !IsObject(sp) {
            return
        }
        for nm in names {
            ex := PresetNormalizeExe(nm)
            if (ex = "") {
                if (Trim(nm) != "") {
                    bad.Push(Trim(nm))
                }
                continue
            }
            if PresetHasExe(sp, ex) {
                dups += 1
                continue
            }
            if (sp.paths.Length >= 40) {
                break
            }
            sp.paths.Push(ex)
            added += 1
        }
        FillAppList()
        SaveSoon()
        RefreshSummary()
        RefreshActiveText()
        if (bad.Length > 0) {
            g.Opt("+OwnDialogs")
            MsgBox("These don't look like program names and were skipped:`n`n" JoinArray(bad, "`n"), "Add App", "Icon!")
        }
    }

    OnAddBrowse(*) {
        local picked
        if !IsObject(SelPreset()) {
            return
        }
        g.Opt("+OwnDialogs")
        picked := FileSelect(3, , "Pick the app's .exe", "Programs (*.exe)")
        if (picked != "") {
            AddExeNames([PresetExeName(picked)])
        }
    }

    OnAddRunning(*) {
        local sp := SelPreset()
        local picked
        if !IsObject(sp) {
            return
        }
        picked := PresetPickRunningApps(g, dark, sp)
        if (picked.Length > 0) {
            AddExeNames(picked)
        }
    }

    OnAddByName(*) {
        local ib
        if !IsObject(SelPreset()) {
            return
        }
        g.Opt("+OwnDialogs")
        ib := InputBox("Type the program's .exe file name, for example  Code.exe  or  vlc.exe`nSeparate several names with commas.", "Add by .exe name", "w400 h150")
        if (ib.Result != "OK") {
            return
        }
        AddExeNames(StrSplit(ib.Value, [",", ";", "|", "`n"], " `t`r"))
    }

    OnAddMenu(*) {
        local m := Menu()
        m.Add("Browse for a program (.exe)...", (*) => OnAddBrowse())
        m.Add("Pick from running programs...", (*) => OnAddRunning())
        m.Add("Type an .exe name...", (*) => OnAddByName())
        m.Show()
    }

    OnRemoveApp(*) {
        local sp := SelPreset()
        local row := lbApps.Value
        if (!IsObject(sp) || row < 1 || row > sp.paths.Length) {
            return
        }
        sp.paths.RemoveAt(row)
        FillAppList()
        if (sp.paths.Length > 0) {
            lbApps.Choose(Min(row, sp.paths.Length))
        }
        SaveSoon()
        RefreshSummary()
        RefreshActiveText()
    }

    ; ---- export / import ----
    OnExport(*) {
        local dest, f
        if (Presets.Length = 0) {
            g.Opt("+OwnDialogs")
            MsgBox("There are no presets to export yet.", "Export presets", "Iconi")
            return
        }
        g.Opt("+OwnDialogs")
        dest := FileSelect("S16", A_Desktop "\OLED Engine presets.ini", "Export presets", "Preset files (*.ini)")
        if (dest = "") {
            return
        }
        if !RegExMatch(dest, "i)\.ini$") {
            dest .= ".ini"
        }
        try {
            f := FileOpen(dest, "w", "UTF-8")
            f.Write(PresetsToIniText(Presets, false))
            f.Close()
            MsgBox("Exported " Presets.Length " preset(s) to:`n" dest, "Export presets", "Iconi")
        } catch as err {
            MsgBox("That file could not be written:`n" err.Message, "Export presets", "Icon!")
        }
    }

    OnImport(*) {
        local picked, text, list, ip, added
        g.Opt("+OwnDialogs")
        picked := FileSelect(1, A_Desktop, "Import presets", "Preset files (*.ini)")
        if (picked = "") {
            return
        }
        text := ""
        try {
            text := FileRead(picked, "UTF-8")
        } catch as err {
            MsgBox("That file could not be read:`n" err.Message, "Import presets", "Icon!")
            return
        }
        list := ParsePresetsText(text)
        if (list.Length = 0) {
            MsgBox("No presets were found in that file.", "Import presets", "Icon!")
            return
        }
        added := 0
        for ip in list {
            if (Presets.Length >= PresetMax()) {
                break
            }
            PresetSanitize(ip, Presets.Length + 1)
            ip.name := PresetUniqueName(ip.name)
            Presets.Push(ip)
            added += 1
        }
        SaveSoon()
        FillDdl(Max(1, Presets.Length - added + 1))
        MsgBox("Imported " added " preset(s)." (added < list.Length ? "`n`nThe limit of " PresetMax() " presets was reached, so the rest were skipped." : ""), "Import presets", "Iconi")
    }

    OnShowFile(*) {
        global PresetsIniPath
        try {
            if FileExist(PresetsIniPath) {
                Run('explorer.exe /select,"' PresetsIniPath '"')
            } else {
                Run('explorer.exe "' A_ScriptDir '"')
            }
        }
    }

    OnMore(*) {
        local m := Menu()
        m.Add("Export presets to a file...", (*) => OnExport())
        m.Add("Import presets from a file...", (*) => OnImport())
        m.Add()
        m.Add("Show the presets file", (*) => OnShowFile())
        m.Show()
    }

    ; Keeps the "Active right now" line live while this tab is on screen.
    ; A hiccup in one tick is ignored; the timer only stops when the Settings window is really gone.
    LiveTick() {
        local live := false
        try {
            if !DllCall("IsWindow", "Ptr", gHwnd, "Int") {
                SetTimer(LiveTick, 0)
                return
            }
            if (tabIdx > 0 && IsObject(SettingsTabsCtrl)) {
                live := (SettingsTabsCtrl.Value = tabIdx)
            } else {
                live := DllCall("IsWindowVisible", "Ptr", txtActive.Hwnd, "Int")
            }
            if (live && !state["busy"] && DllCall("IsWindowVisible", "Ptr", gHwnd, "Int")) {
                RefreshActiveText()
            }
        }
    }

    ddl.OnEvent("Change", (*) => LoadSel())
    btnNew.OnEvent("Click", OnNew)
    btnDup.OnEvent("Click", OnDuplicate)
    btnDel.OnEvent("Click", OnDelete)
    btnMore.OnEvent("Click", OnMore)
    btnAdd.OnEvent("Click", OnAddMenu)
    btnRem.OnEvent("Click", OnRemoveApp)
    btnUp.OnEvent("Click", (*) => MovePreset(-1))
    btnDn.OnEvent("Click", (*) => MovePreset(1))
    btnPin.OnEvent("Click", OnPin)
    btnReset.OnEvent("Click", OnResetOverrides)
    for ctlItem in [edtName, edtM1S, edtM1D, edtM2S, edtM2D, edtDesk] {
        ctlItem.OnEvent("Change", ReadEditors)
    }
    for ctlItem in [chkOn, chkFg, chkNever, chkTbHide] {
        ctlItem.OnEvent("Click", ReadEditors)
    }
    for ctlItem in [edtM1S, edtM1D, edtM2S, edtM2D, edtDesk] {
        ctlItem.OnEvent("LoseFocus", NormalizeNumbers)
    }
    edtName.OnEvent("LoseFocus", FinalizeName)

    FillDdl(1)
    SetTimer(LiveTick, 1000)
}

; ==============================================================================
; 15. DEV WORKFLOW HOTKEYS
; ==============================================================================
Hotkey("^!r", (*) => (DebugLogEvent("Dev reload hotkey triggered (Ctrl+Alt+R)"), Reload()))
#Requires AutoHotkey v2.0

; ==============================================================================
; GAME & G-SYNC AUTOMATION MODULE (AHK v2) - OLED Engine Integrated
; ==============================================================================

if !DirExist(A_ScriptDir "\config") {
    DirCreate(A_ScriptDir "\config")
}
global AutoIniPath           := A_ScriptDir "\config\AutomationConfig.ini"
global AutoCfg               := Map()
global DraftCfg              := Map()
global AutoUI                := Map()
global HasPendingChanges     := false
global IsGameModeActive      := false
global IsManualTestMode      := false
global ActiveTriggerGame     := ""
global LastAppliedGsyncState := "ON" ; "OFF" or "ON"
global LiveGsyncState        := "Unknown" ; "Enabled", "Disabled", "Unsupported", or "Unknown"
global PendingAction         := ""   ; "", "OFF", or "ON"
global PendingTriggerName    := ""
global ActionDeadline        := 0
global ClosedAppsMap         := Map()
global PickerTipState        := Map()

if (A_LineFile = A_ScriptFullPath) {
    StandaloneGui := Gui("+Resize +MinSize554x620", "Display & Game Automation")
    StandaloneGui.SetFont("s9.5", "Segoe UI")
    MainTabs := StandaloneGui.AddTab3("x16 y14 w522 h566 -Wrap", ["Automation"])
    StartGameAutomation()
    InitGameAutomation(StandaloneGui, MainTabs, "Automation")
    StandaloneGui.OnEvent("Size", (g, minMax, w, h) => (minMax != -1) ? (MainTabs.Move(,, w - 32, h - 28), GaResizeAutomation(w, h)) : 0)
    StandaloneGui.OnEvent("Close", (*) => ExitApp())
    StandaloneGui.Show("w554 h594 Center")
}

StartGameAutomation() {
    LoadAutomationConfig()
    SyncDraftFromConfig()
    DetectExternalGsyncState()
    OnMessage(0x0111, GaOnListBoxCommand) ; WM_COMMAND for instant ListBox selection updates
    SetTimer(CheckGameAutomation, 1000)
}

InitGameAutomation(TargetGui, TabControl, TabName := "Automation") {
    global AutoCfg, DraftCfg, AutoUI

    if (AutoCfg.Count = 0) {
        LoadAutomationConfig()
    }
    if (DraftCfg.Count = 0) {
        SyncDraftFromConfig()
    }
    DetectExternalGsyncState()
    OnMessage(0x0111, GaOnListBoxCommand)

    dark := GaIsDarkMode()
    TabControl.UseTab(TabName)

    if !DraftCfg.Has("GsyncEnabled") {
        DraftCfg["GsyncEnabled"] := false
    }

    ; --- Master Enable, G-Sync Toggle & Live Status ---
    AutoUI["ChkEnabled"] := TargetGui.AddCheckbox("x28 y44 w220 h22 Checked" DraftCfg["Enabled"], "Enable Game Automation")
    AutoUI["ChkEnabled"].OnEvent("Click", OnToggleAutomation)
    GaStyle(AutoUI["ChkEnabled"], dark)
    GaTip(AutoUI["ChkEnabled"], "Master toggle for per-game app close/reopen and optional G-Sync profile switching when trigger games run.")

    AutoUI["ChkGsync"] := TargetGui.AddCheckbox("x28 y68 w220 h22 Checked" DraftCfg["GsyncEnabled"], "Enable G-Sync Automation")
    AutoUI["ChkGsync"].OnEvent("Click", OnToggleGsyncAutomation)
    GaStyle(AutoUI["ChkGsync"], dark)
    GaTip(AutoUI["ChkGsync"], "When enabled, switches G-Sync OFF when a trigger game starts and back ON when it exits. Turn off to use app close/reopen automation without changing G-Sync.")

    AutoUI["TxtStatus"] := TargetGui.AddText("x252 y45 w272 h18 Right +0x100 +0x200 -Wrap", GetAutomationStatusText())
    GaStyleStatusLabel()

    AutoUI["TxtGsyncControl"] := TargetGui.AddText("x252 y+2 w272 h16 Right +0x100 +0x200 -Wrap", GetGsyncControlStatusText())
    GaStyle(AutoUI["TxtGsyncControl"], dark, true)

    AutoUI["TxtCountdown"] := TargetGui.AddText("x252 y+2 w272 h16 Right +0x100 +0x200 -Wrap", GetCountdownStatusText())
    GaStyle(AutoUI["TxtCountdown"], dark, true)

    ; --- NVIDIA Profile Inspector & .nip Paths ---
    AutoUI["BoxNpi"] := GaSectionBox(TargetGui, 28, 102, 496, 144, "NVIDIA Profile Inspector && G-Sync Profiles", dark)

    lblNpi := TargetGui.AddText("x42 y126 w74 h20 +0x100 -Wrap", "NPI.exe")
    AutoUI["EdtNpi"] := TargetGui.AddEdit("x118 y122 w312 h24 -Multi ReadOnly", DraftCfg["NpiExe"])
    AutoUI["BtnNpi"] := TargetGui.AddButton("x436 y122 w74 h24", "Browse...")
    AutoUI["BtnNpi"].OnEvent("Click", (*) => BrowseFileSetting("NpiExe", "EdtNpi", "Select nvidiaProfileInspector.exe", "Executables (*.exe)"))

    lblOff := TargetGui.AddText("x42 y155 w74 h20 +0x100 -Wrap", "G-Sync OFF")
    AutoUI["EdtNipOff"] := TargetGui.AddEdit("x118 y151 w312 h24 -Multi ReadOnly", DraftCfg["NipOff"])
    AutoUI["BtnOff"] := TargetGui.AddButton("x436 y151 w74 h24", "Browse...")
    AutoUI["BtnOff"].OnEvent("Click", (*) => BrowseFileSetting("NipOff", "EdtNipOff", "Select G-Sync OFF Profile", "NVIDIA Profiles (*.nip)"))

    lblOn := TargetGui.AddText("x42 y184 w74 h20 +0x100 -Wrap", "G-Sync ON")
    AutoUI["EdtNipOn"] := TargetGui.AddEdit("x118 y180 w312 h24 -Multi ReadOnly", DraftCfg["NipOn"])
    AutoUI["BtnOn"] := TargetGui.AddButton("x436 y180 w74 h24", "Browse...")
    AutoUI["BtnOn"].OnEvent("Click", (*) => BrowseFileSetting("NipOn", "EdtNipOn", "Select G-Sync ON Profile", "NVIDIA Profiles (*.nip)"))

    AutoUI["TxtGuideHint"] := TargetGui.AddText("x42 y214 w332 h20 +0x100 -Wrap", "Need .nip files? Export G-Sync OFF && ON in NVPI.")
    AutoUI["BtnGuide"] := TargetGui.AddButton("x380 y210 w130 h24", "Setup Guide (?)")
    AutoUI["BtnGuide"].OnEvent("Click", (*) => OpenNvpiGuidePopup())

    for c in [lblNpi, AutoUI["EdtNpi"], AutoUI["BtnNpi"], lblOff, AutoUI["EdtNipOff"], AutoUI["BtnOff"], lblOn, AutoUI["EdtNipOn"], AutoUI["BtnOn"], AutoUI["BtnGuide"]] {
        GaStyle(c, dark)
    }
    GaStyle(AutoUI["TxtGuideHint"], dark, true)

    tipNpi := "Path to nvidiaProfileInspector.exe. Used in the background to import your G-Sync ON and OFF .nip profiles."
    tipOff := "NVIDIA Profile Inspector (.nip) profile with G-Sync disabled. Automatically imported when any Trigger Game launches."
    tipOn  := "NVIDIA Profile Inspector (.nip) profile with G-Sync enabled. Automatically imported after all Trigger Games exit."

    GaTip(lblNpi, tipNpi)
    GaTip(AutoUI["EdtNpi"], tipNpi)
    GaTip(lblOff, tipOff)
    GaTip(AutoUI["EdtNipOff"], tipOff)
    GaTip(lblOn, tipOn)
    GaTip(AutoUI["EdtNipOn"], tipOn)
    GaTip(AutoUI["BtnGuide"], "Open a step-by-step guide on creating G-Sync OFF and G-Sync ON .nip profiles in NVIDIA Profile Inspector.")

    ; --- Dual Lists: Trigger Games (Left) & Per-Game Close/Reopen Apps (Right) ---
    AutoUI["BoxGames"] := GaSectionBox(TargetGui, 28, 254, 244, 202, DraftCfg["GsyncEnabled"] ? "Trigger Games (G-Sync OFF)" : "Trigger Games", dark)
    AutoUI["LbGames"]        := TargetGui.AddListBox("x40 y276 w220 h140 Sort +VScroll", DraftCfg["TriggerGames"])
    AutoUI["BtnPickGame"]    := TargetGui.AddButton("x40 y422 w88 h25", "Running...")
    AutoUI["BtnAddGameFile"] := TargetGui.AddButton("x132 y422 w66 h25", "Add...")
    AutoUI["BtnRemGame"]     := TargetGui.AddButton("x202 y422 w58 h25", "Remove")

    AutoUI["LbGames"].OnEvent("Change", OnTriggerGameSelected)
    AutoUI["LbGames"].OnEvent("DoubleClick", OnTriggerGameSelected)
    AutoUI["BtnPickGame"].OnEvent("Click", (*) => OpenProcessPicker("TriggerGames"))
    AutoUI["BtnAddGameFile"].OnEvent("Click", (*) => AddExeFromFile("TriggerGames"))
    AutoUI["BtnRemGame"].OnEvent("Click", (*) => RemoveSelectedTriggerGame())

    AutoUI["BoxApps"] := GaSectionBox(TargetGui, 280, 254, 244, 202, "Close on Start / Reopen on Exit", dark)
    AutoUI["LbApps"]        := TargetGui.AddListBox("x292 y276 w220 h140 Sort +VScroll", [])
    AutoUI["BtnPickApp"]    := TargetGui.AddButton("x292 y422 w88 h25", "Running...")
    AutoUI["BtnAddAppFile"] := TargetGui.AddButton("x384 y422 w66 h25", "Add...")
    AutoUI["BtnRemApp"]     := TargetGui.AddButton("x454 y422 w58 h25", "Remove")

    AutoUI["BtnPickApp"].OnEvent("Click", (*) => OpenProcessPicker("CloseApps"))
    AutoUI["BtnAddAppFile"].OnEvent("Click", (*) => AddExeFromFile("CloseApps"))
    AutoUI["BtnRemApp"].OnEvent("Click", (*) => RemoveSelectedGameApp())

    for c in [
        AutoUI["LbGames"], AutoUI["BtnPickGame"], AutoUI["BtnAddGameFile"], AutoUI["BtnRemGame"],
        AutoUI["LbApps"], AutoUI["BtnPickApp"], AutoUI["BtnAddAppFile"], AutoUI["BtnRemApp"]
    ] {
        GaStyle(c, dark)
    }
    GaTip(AutoUI["LbGames"], "Click or select a trigger game to view and edit the apps closed/reopened for that game.")
    GaTip(AutoUI["LbApps"], "Apps closed on start and reopened on exit for the currently selected trigger game. Click Apply in OLED Engine to save.")

    ; --- Exit Grace Delay & Manual Test Buttons ---
    AutoUI["BoxTiming"] := GaSectionBox(TargetGui, 28, 464, 496, 60, "Timing && Manual Test", dark)
    AutoUI["LblDelay"] := TargetGui.AddText("x42 y490 w128 h20 +0x100 -Wrap", "Exit Grace Delay (s)")
    AutoUI["EdtDelay"] := TargetGui.AddEdit("x174 y486 w52 h24 Number")
    AutoUI["UdDelay"]  := TargetGui.AddUpDown("Range0-300", DraftCfg["ExitDelaySec"])
    AutoUI["EdtDelay"].OnEvent("Change", OnDelayChanged)

    AutoUI["BtnTestOff"] := TargetGui.AddButton("x254 y486 w124 h24", "Test Game Mode")
    AutoUI["BtnTestOff"].OnEvent("Click", (*) => EnterGameMode(true, GetSelectedOrActiveGameLabel()))

    AutoUI["BtnTestOn"] := TargetGui.AddButton("x386 y486 w124 h24", "Test Restore")
    AutoUI["BtnTestOn"].OnEvent("Click", (*) => ExitGameMode(true))

    for c in [AutoUI["LblDelay"], AutoUI["EdtDelay"], AutoUI["BtnTestOff"], AutoUI["BtnTestOn"]] {
        GaStyle(c, dark)
    }

    ; Small hint along the very bottom (only when not running as Administrator)
    if (!A_IsAdmin) {
        AutoUI["TxtAdminWarn"] := TargetGui.AddText("x28 y532 w496 h18 +0x100 -Wrap", "Tip: for G-Sync switching to work reliably, run OLED Engine as administrator.")
        GaStyle(AutoUI["TxtAdminWarn"], dark, true)
    }
    GaTip(AutoUI["EdtDelay"], "Seconds to wait after a trigger game exits before restoring G-Sync ON and reopening apps.")
    GaTip(AutoUI["BtnTestOff"], "Immediately enters game mode (closes selected game's apps and switches G-Sync OFF if enabled).")
    GaTip(AutoUI["BtnTestOn"], "Immediately exits game mode, restores G-Sync ON (if enabled), and reopens closed apps.")

    AutoUI["GsyncControls"] := [
        AutoUI["BoxNpi"],
        lblNpi, AutoUI["EdtNpi"], AutoUI["BtnNpi"],
        lblOff, AutoUI["EdtNipOff"], AutoUI["BtnOff"],
        lblOn, AutoUI["EdtNipOn"], AutoUI["BtnOn"],
        AutoUI["TxtGuideHint"], AutoUI["BtnGuide"]
    ]

    AutoUI["LinkedControls"] := [
        AutoUI["ChkGsync"],
        AutoUI["LbGames"], AutoUI["BtnPickGame"], AutoUI["BtnAddGameFile"], AutoUI["BtnRemGame"],
        AutoUI["LbApps"], AutoUI["BtnPickApp"], AutoUI["BtnAddAppFile"], AutoUI["BtnRemApp"],
        AutoUI["LblDelay"], AutoUI["EdtDelay"], AutoUI["UdDelay"], AutoUI["BtnTestOff"], AutoUI["BtnTestOn"]
    ]

    SelectInitialTriggerGame()
    UpdateAutomationControlsState()

    TabControl.UseTab()
    SetTimer(CheckGameAutomation, 1000)
}

; Call GaApplyAutomation() (or ApplyAutomationChanges()) from the main OLED Engine Apply handler
GaApplyAutomation() {
    ApplyAutomationChanges()
}

ApplyAutomationChanges() {
    global AutoCfg, DraftCfg, AutoUI, HasPendingChanges, IsGameModeActive, PendingAction, PendingTriggerName, ActionDeadline

    if (DraftCfg.Count = 0) {
        return
    }

    if AutoUI.Has("EdtDelay") && IsNumber(AutoUI["EdtDelay"].Value) {
        DraftCfg["ExitDelaySec"] := Max(0, Integer(AutoUI["EdtDelay"].Value))
    }

    AutoCfg := Map(
        "Enabled", DraftCfg["Enabled"],
        "GsyncEnabled", DraftCfg.Has("GsyncEnabled") ? DraftCfg["GsyncEnabled"] : true,
        "ExitDelaySec", DraftCfg["ExitDelaySec"],
        "NpiExe", DraftCfg["NpiExe"],
        "NipOff", DraftCfg["NipOff"],
        "NipOn", DraftCfg["NipOn"],
        "TriggerGames", DraftCfg["TriggerGames"].Clone(),
        "PerGameApps", Map()
    )
    for k, arr in DraftCfg["PerGameApps"] {
        AutoCfg["PerGameApps"][k] := arr.Clone()
    }

    SaveAutomationConfig()
    HasPendingChanges := false

    if (!AutoCfg["Enabled"]) {
        PendingAction := ""
        PendingTriggerName := ""
        ActionDeadline := 0
        if (IsGameModeActive) {
            ExitGameMode(false)
        }
    }

    UpdateAutomationControlsState()
    GaLog("Game Automation settings applied.")
}

SyncDraftFromConfig() {
    global AutoCfg, DraftCfg, HasPendingChanges
    DraftCfg := Map(
        "Enabled", AutoCfg["Enabled"],
        "GsyncEnabled", AutoCfg.Has("GsyncEnabled") ? AutoCfg["GsyncEnabled"] : true,
        "ExitDelaySec", AutoCfg["ExitDelaySec"],
        "NpiExe", AutoCfg["NpiExe"],
        "NipOff", AutoCfg["NipOff"],
        "NipOn", AutoCfg["NipOn"],
        "TriggerGames", AutoCfg["TriggerGames"].Clone(),
        "PerGameApps", Map()
    )
    for k, arr in AutoCfg["PerGameApps"] {
        DraftCfg["PerGameApps"][k] := arr.Clone()
    }
    HasPendingChanges := false
}

MarkAutomationDirty() {
    global HasPendingChanges
    HasPendingChanges := true

    for fnName in ["MarkDirty", "SetDirty", "EnableApplyButton", "UpdateApplyState", "OnSettingChanged", "MarkSettingsDirty"] {
        try {
            fn := %fnName%
            if IsSet(fn) {
                fn()
                break
            }
        }
    }
}

GaOnListBoxCommand(wParam, lParam, msg, hwnd) {
    global AutoUI
    if !AutoUI.Has("LbGames") {
        return
    }
    lbHwnd := 0
if (IsSet(AutoUI) && AutoUI.Has("LbGames") && IsObject(AutoUI["LbGames"])) {
    try lbHwnd := AutoUI["LbGames"].Hwnd
}
If (lbHwnd && lParam = lbHwnd) {
        notifyCode := (wParam >> 16) & 0xFFFF
        if (notifyCode = 1 || notifyCode = 2) { ; LBN_SELCHANGE or LBN_DBLCLK
            SetTimer(OnTriggerGameSelected, -1)
        }
    }
}

GaStyleStatusLabel() {
    global AutoUI, AutoCfg, DraftCfg, LastAppliedGsyncState, IsGameModeActive
    if !AutoUI.Has("TxtStatus") {
        return
    }

    dark := GaIsDarkMode()
    if (AutoCfg.Has("Enabled") && !AutoCfg["Enabled"]) {
        GaStyle(AutoUI["TxtStatus"], dark, true)
        return
    }

    gsyncOn := DraftCfg.Has("GsyncEnabled") ? !!DraftCfg["GsyncEnabled"] : (AutoCfg.Has("GsyncEnabled") ? !!AutoCfg["GsyncEnabled"] : true)
    GaStyle(AutoUI["TxtStatus"], dark, false)
    if (!gsyncOn) {
        colorHex := IsGameModeActive ? "6EE7B7" : (dark ? "D4D4D8" : "374151")
    } else {
        colorHex := (LastAppliedGsyncState = "OFF") ? "F28B82" : "6EE7B7"
    }
    try {
        AutoUI["TxtStatus"].Opt("c" colorHex)
        AutoUI["TxtStatus"].Redraw()
    }
}

GetSelectedTriggerGame() {
    global AutoUI, DraftCfg
    if AutoUI.Has("LbGames") {
        idx := AutoUI["LbGames"].Value
        if (idx && idx <= DraftCfg["TriggerGames"].Length) {
            txt := Trim(AutoUI["LbGames"].Text)
            if (txt != "") {
                return txt
            }
        }
    }
    return (DraftCfg["TriggerGames"].Length > 0) ? DraftCfg["TriggerGames"][1] : ""
}

GetSelectedOrActiveGameLabel() {
    global ActiveTriggerGame
    if (ActiveTriggerGame != "") {
        return ActiveTriggerGame
    }
    sel := GetSelectedTriggerGame()
    return (sel != "") ? sel : "Manual Test"
}

SelectInitialTriggerGame() {
    global DraftCfg, AutoUI
    if (DraftCfg["TriggerGames"].Length > 0) {
        if AutoUI.Has("LbGames") {
            try AutoUI["LbGames"].Choose(1)
        }
        SetActiveGameEditor(DraftCfg["TriggerGames"][1])
    } else {
        SetActiveGameEditor("")
    }
}

OnTriggerGameSelected(*) {
    global AutoUI
    if !AutoUI.Has("LbGames") {
        return
    }
    chosen := Trim(AutoUI["LbGames"].Text)
    if (chosen != "") {
        SetActiveGameEditor(chosen)
    }
}

SetActiveGameEditor(gameExe) {
    global DraftCfg, AutoUI
    key := StrLower(Trim(gameExe))

    if (key != "" && !DraftCfg["PerGameApps"].Has(key)) {
        DraftCfg["PerGameApps"][key] := []
    }

    if AutoUI.Has("LbApps") {
        try {
            AutoUI["LbApps"].Delete()
            if (key != "" && DraftCfg["PerGameApps"].Has(key)) {
                AutoUI["LbApps"].Add(DraftCfg["PerGameApps"][key])
            }
        }
    }
}

GaResizeAutomation(guiW, guiH) {
    global AutoUI
    if !AutoUI.Has("BoxNpi") {
        return
    }

    contentW := Max(496, guiW - 58)
    rightEdge := 28 + contentW
    timingY := Max(464, guiH - 132)
    listBoxH := Max(202, timingY - 262)
    listH := listBoxH - 62
    listBtnY := 254 + listBoxH - 34
    colW := Floor((contentW - 8) / 2)
    rightColX := 28 + colW + 8

   try {
        AutoUI["TxtStatus"].Move(252,, rightEdge - 252)
        if AutoUI.Has("TxtGsyncControl") {
            AutoUI["TxtGsyncControl"].Move(252,, rightEdge - 252)
        }
        if AutoUI.Has("TxtCountdown") {
            AutoUI["TxtCountdown"].Move(252,, rightEdge - 252)
        }
        if AutoUI.Has("TxtAdminWarn") {
            AutoUI["TxtAdminWarn"].Move(28, timingY + 68, contentW)
        }

        AutoUI["BoxNpi"].Move(,, contentW)
        edtW := contentW - 184
        btnX := rightEdge - 88
        AutoUI["EdtNpi"].Move(,, edtW)
        AutoUI["BtnNpi"].Move(btnX)
        AutoUI["EdtNipOff"].Move(,, edtW)
        AutoUI["BtnOff"].Move(btnX)
        AutoUI["EdtNipOn"].Move(,, edtW)
        AutoUI["BtnOn"].Move(btnX)
        AutoUI["TxtGuideHint"].Move(,, contentW - 164)
        AutoUI["BtnGuide"].Move(rightEdge - 144)

        AutoUI["BoxGames"].Move(,, colW, listBoxH)
        AutoUI["LbGames"].Move(,, colW - 24, listH)
        remW := 58
        addW := 66
        pickW := Max(76, (colW - 24) - remW - addW - 8)
        AutoUI["BtnPickGame"].Move(, listBtnY, pickW)
        AutoUI["BtnAddGameFile"].Move(40 + pickW + 4, listBtnY, addW)
        AutoUI["BtnRemGame"].Move(40 + pickW + addW + 8, listBtnY, remW)

        AutoUI["BoxApps"].Move(rightColX,, colW, listBoxH)
        AutoUI["LbApps"].Move(rightColX + 12,, colW - 24, listH)
        AutoUI["BtnPickApp"].Move(rightColX + 12, listBtnY, pickW)
        AutoUI["BtnAddAppFile"].Move(rightColX + 12 + pickW + 4, listBtnY, addW)
        AutoUI["BtnRemApp"].Move(rightColX + 12 + pickW + addW + 8, listBtnY, remW)

        AutoUI["BoxTiming"].Move(, timingY, contentW)
        AutoUI["LblDelay"].Move(, timingY + 26)
        AutoUI["EdtDelay"].Move(, timingY + 22)
        AutoUI["UdDelay"].Move(, timingY + 22)
        AutoUI["BtnTestOn"].Move(rightEdge - 138, timingY + 22)
        AutoUI["BtnTestOff"].Move(rightEdge - 270, timingY + 22)
    }
}

UpdateAutomationControlsState() {
    global DraftCfg, AutoUI
    enabled := !!(DraftCfg.Has("Enabled") && DraftCfg["Enabled"])
    gsyncOn := enabled && (!DraftCfg.Has("GsyncEnabled") || !!DraftCfg["GsyncEnabled"])

    if AutoUI.Has("LinkedControls") {
        for ctrl in AutoUI["LinkedControls"] {
            try {
                if (ctrl.Enabled != enabled) {
                    ctrl.Enabled := enabled
                    ctrl.Redraw()
                }
            }
        }
    }
    if AutoUI.Has("GsyncControls") {
        for ctrl in AutoUI["GsyncControls"] {
            try {
                if (ctrl.Enabled != gsyncOn) {
                    ctrl.Enabled := gsyncOn
                    ctrl.Redraw()
                }
            }
        }
    }
    if AutoUI.Has("BoxGames") {
        wantTitle := (!DraftCfg.Has("GsyncEnabled") || !!DraftCfg["GsyncEnabled"]) ? "Trigger Games (G-Sync OFF)" : "Trigger Games"
        if (AutoUI["BoxGames"].Text != wantTitle) {
            AutoUI["BoxGames"].Text := wantTitle
        }
    }
    RefreshStatusLabels()
}

OpenNvpiGuidePopup() {
    dark := GaIsDarkMode()
    Guide := Gui("-DPIScale", "NVPI G-Sync Profile Setup Guide")
    try {
        fnTheme := %("ApplyGuiTheme")%
        fnTheme(Guide, dark)
    } catch {
        Guide.SetFont("s9.5", "Segoe UI")
    }
    Guide.MarginX := 16
    Guide.MarginY := 14

    GaSectionBox(Guide, 16, 12, 488, 86, "1. Select NVIDIA Profile Inspector", dark)
    t1 := Guide.AddText("x30 y35 w460 h56 +0x100",
        "Download NVIDIA Profile Inspector (NVPI) and browse to nvidiaProfileInspector.exe in the 'NPI.exe' field so OLED Engine can switch profiles silently.")

    GaSectionBox(Guide, 16, 106, 488, 148, "2. Create 'G-Sync OFF' Profile (.nip)", dark)
    t2 := Guide.AddText("x30 y129 w460 h118 +0x100",
        "- Open NVPI (stay on _GLOBAL_DRIVER_PROFILE / Base Profile).`n"
        "- Under '2 - Sync and Refresh', set GSYNC - Global Mode & Global Feature to Off.`n"
        "- Click 'Apply changes' (top right), then click Export (green up-arrow) -> 'Export current profile only' and save as Gsync OFF.nip.`n"
        "- Browse to that file in the 'G-Sync OFF' field.")

    GaSectionBox(Guide, 16, 262, 488, 148, "3. Create 'G-Sync ON' Profile (.nip)", dark)
    t3 := Guide.AddText("x30 y285 w460 h118 +0x100",
        "- Back in NVPI, set GSYNC - Global Mode & Global Feature back to On / Fullscreen and Windowed (your normal G-Sync setting).`n"
        "- Click 'Apply changes', then click Export -> 'Export current profile only' again and save as Gsync ON.nip.`n"
        "- Browse to that file in the 'G-Sync ON' field.")

    tAdmin := Guide.AddText("x18 y422 w366 h36 +0x100", "Tip: Enable 'Run as admin' on the Presets tab so profile switches apply without UAC prompts.")
    BtnOk := Guide.AddButton("x400 y426 w104 h28 Default", "Got It")
    BtnOk.OnEvent("Click", (*) => Guide.Destroy())
    Guide.OnEvent("Escape", (*) => Guide.Destroy())

    for c in [t1, t2, t3, tAdmin, BtnOk] {
        GaStyle(c, dark)
    }

    Guide.Show("w520 h472 Center Hide")
    try DllCall("AnimateWindow", "Ptr", Guide.Hwnd, "UInt", 180, "UInt", 0x40000 | 0x4 | 0x20000)
    Guide.Show("Center")
}

; ==============================================================================
; CORE AUTOMATION LOOP, COUNTDOWN & REAL G-SYNC PROFILE STATE
; ==============================================================================
DetectExternalGsyncState(force := false) {
    global LastAppliedGsyncState, LiveGsyncState, AutoIniPath
    static lastProbeTick := 0

    if (!force && lastProbeTick > 0 && (A_TickCount - lastProbeTick) < 15000) {
        return LastAppliedGsyncState
    }
    lastProbeTick := A_TickCount

    detected := QueryDriverGsyncState()
    if (detected = "ON" || detected = "OFF") {
        LiveGsyncState := (detected = "ON") ? "Enabled" : "Disabled"
        if (LastAppliedGsyncState != detected) {
            LastAppliedGsyncState := detected
            try IniWrite(detected, AutoIniPath, "State", "LastGsyncState")
        }
        return detected
    }

    if WinExist("NVIDIA Profile Inspector") {
        try {
            txt := WinGetText("NVIDIA Profile Inspector")
            if (txt ~= "i)GSYNC\s*-?\s*Global\s*(Mode|Feature)[^\r\n]*\b(Off|Disabled)\b") {
                LiveGsyncState := "Disabled"
                LastAppliedGsyncState := "OFF"
                try IniWrite("OFF", AutoIniPath, "State", "LastGsyncState")
                return "OFF"
            }
            if (txt ~= "i)GSYNC\s*-?\s*Global\s*(Mode|Feature)[^\r\n]*\b(On|Fullscreen|Windowed)\b") {
                LiveGsyncState := "Enabled"
                LastAppliedGsyncState := "ON"
                try IniWrite("ON", AutoIniPath, "State", "LastGsyncState")
                return "ON"
            }
        }
    }

    ; No live reading available: always mirror the last state that was really applied / saved.
    ; (Before, this only ran once, so the label stayed stuck on its first value forever.)
    if (LiveGsyncState != "Unsupported") {
        LiveGsyncState := (LastAppliedGsyncState = "OFF") ? "Disabled" : "Enabled"
    }
    return LastAppliedGsyncState
}

QueryDriverGsyncState() {
    return ""
}

GetLiveGsyncLabel() {
    global LiveGsyncState, LastAppliedGsyncState
    if (LiveGsyncState = "Enabled" || LiveGsyncState = "Disabled" || LiveGsyncState = "Unsupported") {
        return "G-Sync: " LiveGsyncState
    }
    return "G-Sync: " ((LastAppliedGsyncState = "OFF") ? "Disabled" : "Enabled")
}

GetGsyncControlStatusText() {
    global DraftCfg, AutoCfg, AutoUI
    if AutoUI.Has("ChkGsync") {
        gsyncAutoOn := false
try gsyncAutoOn := !!AutoUI["ChkGsync"].Value
    } else if DraftCfg.Has("GsyncEnabled") {
        gsyncAutoOn := !!DraftCfg["GsyncEnabled"]
    } else {
        gsyncAutoOn := AutoCfg.Has("GsyncEnabled") ? !!AutoCfg["GsyncEnabled"] : true
    }
    return gsyncAutoOn ? "G-Sync control: ON" : "G-Sync control: OFF"
}

GetAutomationStatusText() {
    global AutoCfg, IsGameModeActive, ActiveTriggerGame
    liveGs := GetLiveGsyncLabel()
    if (IsGameModeActive && ActiveTriggerGame != "") {
        return liveGs "  •  Game Mode (" ActiveTriggerGame ")"
    }
    return liveGs
}

GetCountdownStatusText() {
    global AutoCfg, DraftCfg, PendingAction, ActionDeadline
    if (!AutoCfg.Has("Enabled") || !AutoCfg["Enabled"]) {
        return ""
    }
    if (PendingAction = "" || ActionDeadline <= 0) {
        return ""
    }
    rem := Ceil((ActionDeadline - A_TickCount) / 1000)
    if (rem <= 0) {
        return ""
    }
    gsyncOn := DraftCfg.Has("GsyncEnabled") ? !!DraftCfg["GsyncEnabled"] : (AutoCfg.Has("GsyncEnabled") ? !!AutoCfg["GsyncEnabled"] : true)
    if (!gsyncOn) {
        return (PendingAction = "OFF") ? ("Starting Game Mode in " rem "s...") : ("Reopening apps in " rem "s...")
    }
    targetLabel := (PendingAction = "OFF") ? "G-Sync OFF" : "G-Sync ON"
    return "Setting " targetLabel " in " rem "s..."
}

RefreshStatusLabels() {
    global AutoUI
    static lastStatus := "", lastGsyncCtrl := "", lastCountdown := ""
    if AutoUI.Has("TxtStatus") {
        newStatus := GetAutomationStatusText()
        if (newStatus != lastStatus) {
            lastStatus := newStatus
            try {
                AutoUI["TxtStatus"].Text := newStatus
                GaStyleStatusLabel()
            }
        }
    }
    if AutoUI.Has("TxtGsyncControl") {
        newCtrl := GetGsyncControlStatusText()
        if (newCtrl != lastGsyncCtrl) {
            lastGsyncCtrl := newCtrl
            try {
                AutoUI["TxtGsyncControl"].Text := newCtrl
                AutoUI["TxtGsyncControl"].Redraw()
            }
        }
    }
    if AutoUI.Has("TxtCountdown") {
        newCd := GetCountdownStatusText()
        if (newCd != lastCountdown) {
            lastCountdown := newCd
            try {
                AutoUI["TxtCountdown"].Text := newCd
                AutoUI["TxtCountdown"].Redraw()
            }
        }
    }
}

CheckGameAutomation() {
    global AutoCfg, IsGameModeActive, IsManualTestMode, PendingAction, PendingTriggerName, ActionDeadline

    DismissNvpiImportPopup()

    if (!AutoCfg.Has("Enabled") || !AutoCfg["Enabled"]) {
        PendingAction := ""
        PendingTriggerName := ""
        ActionDeadline := 0
        DetectExternalGsyncState()
        RefreshStatusLabels()
        return
    }

    if (PendingAction != "" && ActionDeadline > 0) {
        if (A_TickCount < ActionDeadline) {
            RefreshStatusLabels()
            return
        }
        act := PendingAction
        trig := PendingTriggerName
        PendingAction := ""
        PendingTriggerName := ""
        ActionDeadline := 0
        RefreshStatusLabels()
        if (act = "OFF") {
            EnterGameMode(false, trig != "" ? trig : "Trigger Game")
        } else {
            ExitGameMode(false)
        }
        return
    }

    activeGame := ""
    try {
        for gameExe in AutoCfg["TriggerGames"] {
            if (gameExe != "" && ProcessExist(gameExe)) {
                activeGame := gameExe
                break
            }
        }
    }

    if (activeGame != "") {
        IsManualTestMode := false
        if (!IsGameModeActive) {
            EnterGameMode(false, activeGame)
        }
    } else if (IsGameModeActive && !IsManualTestMode) {
        delaySec := Max(0, Integer(AutoCfg.Has("ExitDelaySec") ? AutoCfg["ExitDelaySec"] : 0))
        if (delaySec <= 0) {
            ExitGameMode(false)
        } else {
            PendingAction := "ON"
            PendingTriggerName := ""
            ActionDeadline := A_TickCount + (delaySec * 1000)
            RefreshStatusLabels()
        }
    } else {
        DetectExternalGsyncState()
        RefreshStatusLabels()
    }
}

EnterGameMode(isManual := false, triggerName := "Manual Test") {
    global IsGameModeActive, IsManualTestMode, ActiveTriggerGame, AutoCfg, DraftCfg, PendingAction, PendingTriggerName, ActionDeadline
    cfg := (isManual && DraftCfg.Count > 0) ? DraftCfg : AutoCfg
    PendingAction := ""
    PendingTriggerName := ""
    ActionDeadline := 0
    IsGameModeActive := true
    IsManualTestMode := isManual
    ActiveTriggerGame := triggerName

    try SuspendAppsForGame(triggerName, cfg)
    gsyncOn := cfg.Has("GsyncEnabled") ? !!cfg["GsyncEnabled"] : true
    if (gsyncOn) {
        ApplyNipProfile(cfg["NipOff"], "OFF", cfg)
    }
    RefreshStatusLabels()
    GaLog("Game Automation active (" triggerName ")" (gsyncOn ? " - G-Sync OFF" : " - Apps Only"))
}

ExitGameMode(isManual := false) {
    global IsGameModeActive, IsManualTestMode, ActiveTriggerGame, AutoCfg, DraftCfg, PendingAction, PendingTriggerName, ActionDeadline
    cfg := (isManual && DraftCfg.Count > 0) ? DraftCfg : AutoCfg
    PendingAction := ""
    PendingTriggerName := ""
    ActionDeadline := 0
    IsGameModeActive := false
    IsManualTestMode := false
    ActiveTriggerGame := ""

    gsyncOn := cfg.Has("GsyncEnabled") ? !!cfg["GsyncEnabled"] : true
    if (gsyncOn) {
        ApplyNipProfile(cfg["NipOn"], "ON", cfg)
    }
    try ResumeSuspendedApps()
    RefreshStatusLabels()
    GaLog("Game Automation restored" (gsyncOn ? " - G-Sync ON" : " - Apps Reopened"))
}

ApplyNipProfile(nipPath, targetState := "", cfgOverride := 0) {
    global AutoCfg, LastAppliedGsyncState, LiveGsyncState, AutoIniPath
    cfg := IsObject(cfgOverride) ? cfgOverride : AutoCfg
    npi := cfg["NpiExe"]
    if (npi = "" || !FileExist(npi) || nipPath = "" || !FileExist(nipPath)) {
        ; Nothing was imported, so G-Sync did not change - do not pretend it did
        GaLog("G-Sync profile NOT applied (missing NVPI exe or .nip file)")
        return false
    }

    SetTimer(DismissNvpiImportPopup, 50)
    ok := true
    try {
        RunWait('"' npi '" -silentImport "' nipPath '"', , "Hide")
    } catch {
        try {
            RunWait('"' npi '" "' nipPath '"', , "Hide")
        } catch {
            ok := false
        }
    }
    DismissNvpiImportPopup()
    SetTimer(DismissNvpiImportPopup, 0)

    if (ok && targetState != "") {
        LastAppliedGsyncState := targetState
        LiveGsyncState := (targetState = "ON") ? "Enabled" : "Disabled"
        try IniWrite(targetState, AutoIniPath, "State", "LastGsyncState")
    }
    return ok
}

DismissNvpiImportPopup() {
    try {
        for hwnd in WinGetList("NVIDIA Profile Inspector") {
            txt := ""
            try txt := WinGetText(hwnd)
            if (InStr(txt, "successfully imported") || InStr(txt, "Profile(s)")) {
                try ControlClick("Button1", hwnd, , , , "NA")
                if WinExist(hwnd) {
                    try PostMessage(0x0010, 0, 0, hwnd) ; WM_CLOSE
                }
            }
        }
    }
}

GetAppsForGame(gameExe, cfgOverride := 0) {
    global AutoCfg
    cfg := IsObject(cfgOverride) ? cfgOverride : AutoCfg
    key := StrLower(Trim(gameExe))
    if (key != "" && cfg["PerGameApps"].Has(key)) {
        return cfg["PerGameApps"][key]
    }
    return []
}

GetProcessSnapshot() {
    procs := []
    hSnap := DllCall("CreateToolhelp32Snapshot", "UInt", 0x2, "UInt", 0, "Ptr")
    if (hSnap = -1 || !hSnap) {
        return procs
    }
    pe := Buffer(568, 0)
    NumPut("UInt", 568, pe, 0)
    if DllCall("Process32FirstW", "Ptr", hSnap, "Ptr", pe.Ptr, "Int") {
        Loop {
            pid  := NumGet(pe, 8, "UInt")
            ppid := NumGet(pe, 24, "UInt")
            exe  := StrGet(pe.Ptr + 44, 260, "UTF-16")
            fullPath := ""
            try fullPath := ProcessGetPath(pid)
            procs.Push({ pid: pid, ppid: ppid, exe: exe, path: fullPath })
            if !DllCall("Process32NextW", "Ptr", hSnap, "Ptr", pe.Ptr, "Int") {
                break
            }
        }
    }
    DllCall("CloseHandle", "Ptr", hSnap)
    return procs
}

IsDedicatedAppFolder(dirPath) {
    if (dirPath = "") {
        return false
    }
    norm := StrLower(RTrim(dirPath, "\"))
    parts := StrSplit(norm, "\")
    if (parts.Length < 3) {
        return false
    }
    if (norm = StrLower(A_WinDir)
        || norm = StrLower(A_WinDir "\system32")
        || norm = StrLower(A_WinDir "\syswow64")
        || norm = StrLower(A_ProgramFiles)
        || norm = "c:\program files (x86)"
        || norm = StrLower(EnvGet("LocalAppData"))
        || norm = StrLower(EnvGet("AppData"))) {
        return false
    }
    return true
}

SuspendAppsForGame(gameExe, cfgOverride := 0) {
    global ClosedAppsMap
    ClosedAppsMap.Clear()

    appsToClose := GetAppsForGame(gameExe, cfgOverride)
    if (appsToClose.Length = 0) {
        return
    }

    snap := GetProcessSnapshot()
    for exeName in appsToClose {
        cleanExe := Trim(exeName)
        if (cleanExe = "") {
            continue
        }
        targetLow := StrLower(cleanExe)

        seedPids := Map()
        launchPath := ""
        launchDir  := ""

        for p in snap {
            if (StrLower(p.exe) = targetLow) {
                seedPids[p.pid] := true
                if (p.path != "" && launchPath = "") {
                    launchPath := p.path
                    SplitPath(p.path, , &launchDir)
                }
            }
        }

        if (seedPids.Count = 0) {
            continue
        }

        ; Store executable path & working directory BEFORE terminating processes so ExitGameMode can reliably reopen it
        ClosedAppsMap[cleanExe] := {
            exe: cleanExe,
            path: launchPath,
            workDir: launchDir
        }

        killPids := Map()
        for pid, _ in seedPids {
            killPids[pid] := true
        }

        ; 1) Expand to all child/descendant processes spawned by the app
        added := true
        while added {
            added := false
            for p in snap {
                if (!killPids.Has(p.pid) && killPids.Has(p.ppid)) {
                    killPids[p.pid] := true
                    added := true
                }
            }
        }

        ; 2) Expand to sibling/helper services running from the same dedicated app installation directory
        if IsDedicatedAppFolder(launchDir) {
            dirPrefix := StrLower(launchDir) "\"
            for p in snap {
                if (!killPids.Has(p.pid) && p.path != "" && SubStr(StrLower(p.path), 1, StrLen(dirPrefix)) = dirPrefix) {
                    killPids[p.pid] := true
                }
            }
        }

        ; Gracefully close main windows first
        for pid, _ in seedPids {
            if (WinExist("ahk_pid " pid)) {
                try WinClose("ahk_pid " pid)
            }
        }
        Sleep(250)

        ; Force-terminate all remaining seed + linked processes
        for pid, _ in killPids {
            if ProcessExist(pid) {
                try ProcessClose(pid)
            }
        }
        Sleep(100)
        for pid, _ in killPids {
            if ProcessExist(pid) {
                try RunWait('taskkill /F /T /PID ' pid, , "Hide")
            }
        }
    }
}

ResumeSuspendedApps() {
    global ClosedAppsMap
    if (ClosedAppsMap.Count = 0) {
        return
    }
    for exeName, info in ClosedAppsMap {
        if ProcessExist(info.exe) {
            continue
        }
        launched := false
        if (info.path != "" && FileExist(info.path)) {
            try {
                Run('"' info.path '"', (info.workDir != "" && DirExist(info.workDir)) ? info.workDir : "")
                launched := true
            }
        }
        if !launched {
            try Run(info.exe)
        }
        Sleep(150)
    }
    ClosedAppsMap.Clear()
}

; ==============================================================================
; HELPER HOOKS FOR GENERAL TAB & AUTO-DIMMING
; ==============================================================================
GaOpenProcessPickerCallback(onPickedFn) {
    OpenProcessPicker("", onPickedFn)
}

GaIsTriggerGameRunning() {
    global AutoCfg
    if !AutoCfg.Has("TriggerGames") {
        return false
    }
    for gameExe in AutoCfg["TriggerGames"] {
        if (gameExe != "" && ProcessExist(gameExe)) {
            return true
        }
    }
    return false
}

GaShouldSkipDimming(compGamesArray := []) {
    if GaIsTriggerGameRunning() {
        return true
    }
    for gameExe in compGamesArray {
        if (gameExe != "" && ProcessExist(gameExe)) {
            return true
        }
    }
    return false
}

; ==============================================================================
; LIVE RUNNING PROCESS PICKER MODAL (ALWAYS-DARK FILTER + FULL HOVER TOOLTIPS)
; ==============================================================================
GetPickerExclusionSet(targetKey) {
    global DraftCfg
    excl := Map()
    if (targetKey = "TriggerGames") {
        for gExe in DraftCfg["TriggerGames"] {
            excl[StrLower(Trim(gExe))] := true
        }
    } else if (targetKey = "CloseApps") {
        gKey := StrLower(GetSelectedTriggerGame())
        if (gKey != "" && DraftCfg["PerGameApps"].Has(gKey)) {
            for aExe in DraftCfg["PerGameApps"][gKey] {
                excl[StrLower(Trim(aExe))] := true
            }
        }
    }
    return excl
}

OpenProcessPicker(targetKey, customCallback := 0) {
    global PickerTipState
    if (targetKey = "CloseApps" && GetSelectedTriggerGame() = "") {
        MsgBox("Add or select a Trigger Game first so its apps can be configured.", "Select Trigger Game", "Icon!")
        return
    }

    isMultiCheck := (targetKey = "CloseApps")
    dark := GaIsDarkMode()
    Picker := Gui("+AlwaysOnTop -DPIScale", isMultiCheck ? "Select Apps to Close / Reopen (Check Multiple)" : "Select Running Process")
    try {
        fnTheme := %("ApplyGuiTheme")%
        fnTheme(Picker, dark)
    } catch {
        Picker.SetFont("s9.5", "Segoe UI")
    }
    Picker.MarginX := 16
    Picker.MarginY := 14

    lblFilter := Picker.AddText("x16 y18 w44 h20 +0x100 -Wrap cFFFFFF", "Filter")
    EdtSearch := Picker.AddEdit("x62 y14 w384 h24 -Multi cFFFFFF Background1E1E1E")
    lvOpts    := isMultiCheck ? "x16 y46 w430 h290 Checked Grid" : "x16 y46 w430 h290 -Multi Grid"
    LvProcs   := Picker.AddListView(lvOpts, ["Process (.exe)", "Window Title / Path"])
    LvProcs.ModifyCol(1, 175)
    LvProcs.ModifyCol(2, 233)

    BtnAdd     := Picker.AddButton("x16 y346 w124 h26 Default", isMultiCheck ? "Add Checked" : "Add Selected")
    BtnRefresh := Picker.AddButton("x148 y346 w90 h26", "Refresh")
    BtnCancel  := Picker.AddButton("x366 y346 w80 h26", "Cancel")

    for c in [LvProcs, BtnAdd, BtnRefresh, BtnCancel] {
        GaStyle(c, dark)
    }
    GaLockDarkSearchBox(Picker, lblFilter, EdtSearch)

    allProcs := GetUniqueRunningProcesses(GetPickerExclusionSet(targetKey))
    PickerTipState := Map(
        "Active", true,
        "Hwnd", LvProcs.Hwnd,
        "Rows", PopulatePickerList(LvProcs, allProcs, ""),
        "LastKey", ""
    )

    OnMessage(0x200, OnPickerMouseMove) ; WM_MOUSEMOVE

    closePicker := (*) => (
        PickerTipState["Active"] := false,
        ToolTip(),
        Picker.Destroy()
    )

    EdtSearch.OnEvent("Change", (*) => PickerTipState["Rows"] := PopulatePickerList(LvProcs, allProcs, EdtSearch.Value))
    BtnRefresh.OnEvent("Click", (*) => (
        allProcs := GetUniqueRunningProcesses(GetPickerExclusionSet(targetKey)),
        PickerTipState["Rows"] := PopulatePickerList(LvProcs, allProcs, EdtSearch.Value),
        PickerTipState["LastKey"] := "",
        ToolTip()
    ))
    BtnCancel.OnEvent("Click", closePicker)
    Picker.OnEvent("Escape", closePicker)
    Picker.OnEvent("Close", closePicker)
    LvProcs.OnEvent("DoubleClick", (*) => (CommitPickerSelection(Picker, LvProcs, targetKey, customCallback, true), PickerTipState["Active"] := false, ToolTip()))
    BtnAdd.OnEvent("Click", (*) => (CommitPickerSelection(Picker, LvProcs, targetKey, customCallback, false), PickerTipState["Active"] := false, ToolTip()))

    Picker.Show("AutoSize Center Hide")
    GaLockDarkSearchBox(Picker, lblFilter, EdtSearch)
    try DllCall("AnimateWindow", "Ptr", Picker.Hwnd, "UInt", 160, "UInt", 0x40000 | 0x4 | 0x20000)
    Picker.Show("Center")
}
GaLockDarkSearchBox(guiObj, lblCtrl, editCtrl) {
    try {
        guiObj.BackColor := "141414"
    }
    try {
        lblCtrl.Opt("cFFFFFF")
        lblCtrl.Redraw()
    }
    try {
        editCtrl.Opt("cFFFFFF Background1E1E1E")
        DllCall("uxtheme\SetWindowTheme", "Ptr", editCtrl.Hwnd, "Str", "DarkMode_CFD", "Ptr", 0)
        editCtrl.Redraw()
    }
}

OnPickerMouseMove(wParam, lParam, msg, hwnd) {
    global PickerTipState
    if (!PickerTipState.Has("Active") || !PickerTipState["Active"]) {
        return
    }
    if (hwnd != PickerTipState["Hwnd"]) {
        if (PickerTipState["LastKey"] != "") {
            PickerTipState["LastKey"] := ""
            ToolTip()
        }
        return
    }

    x := lParam & 0xFFFF
    y := (lParam >> 16) & 0xFFFF
    if (x & 0x8000)
        x -= 0x10000
    if (y & 0x8000)
        y -= 0x10000

    lvHit := Buffer(28, 0)
    NumPut("Int", x, lvHit, 0)
    NumPut("Int", y, lvHit, 4)
    hitRow := SendMessage(0x1039, 0, lvHit.Ptr, hwnd)
    subItem := NumGet(lvHit, 16, "Int")

    rowIndex := hitRow + 1
    rows := PickerTipState["Rows"]
    if (hitRow < 0 || rowIndex < 1 || rowIndex > rows.Length) {
        if (PickerTipState["LastKey"] != "") {
            PickerTipState["LastKey"] := ""
            ToolTip()
        }
        return
    }

    key := rowIndex ":" subItem
    if (key = PickerTipState["LastKey"]) {
        return
    }
    PickerTipState["LastKey"] := key

    item := rows[rowIndex]
    tipText := "Process: " item["exe"]
    if (item["title"] != "") {
        tipText .= "`nWindow: " item["title"]
    }
    if (item["path"] != "") {
        tipText .= "`nPath: " item["path"]
    }
    ToolTip(tipText)
}

GetUniqueRunningProcesses(excludeSet := 0) {
    seen := Map()
    results := []
    wmiOk := false
    hasExcl := IsObject(excludeSet)

    try {
        wmi := ComObjGet("winmgmts:")
        for proc in wmi.ExecQuery("SELECT Name, ProcessId, ExecutablePath FROM Win32_Process") {
            wmiOk := true
            exe := proc.Name
            low := StrLower(exe)
            if (!exe || seen.Has(low) || (hasExcl && excludeSet.Has(low))) {
                continue
            }
            if (exe ~= "i)^(svchost|conhost|csrss|smss|wininit|services|lsass|dwm|fontdrvhost|RuntimeBroker|dllhost|taskhostw|sihost|ctfmon|System|Idle)\.exe$") {
                continue
            }
            seen[low] := true

            title := ""
            for hwnd in WinGetList("ahk_pid " proc.ProcessId) {
                t := WinGetTitle(hwnd)
                if (t != "" && WinGetStyle(hwnd) & 0x10000000) {
                    title := t
                    break
                }
            }

            exePath := ""
            try exePath := ProcessGetPath(proc.ProcessId)
            if (exePath = "" && proc.ExecutablePath) {
                exePath := proc.ExecutablePath
            }

            info := (title != "") ? title : exePath
            results.Push(Map("exe", exe, "title", title, "path", exePath, "info", info))
        }
    }

    if (!wmiOk || results.Length = 0) {
        for hwnd in WinGetList() {
            pid := WinGetPID(hwnd)
            if (!pid) {
                continue
            }
            exePath := ""
            try exePath := ProcessGetPath(pid)
            if (exePath = "") {
                continue
            }
            SplitPath(exePath, &exe)
            low := StrLower(exe)
            if (!exe || seen.Has(low) || (hasExcl && excludeSet.Has(low))) {
                continue
            }
            seen[low] := true
            title := WinGetTitle(hwnd)
            info := (title != "") ? title : exePath
            results.Push(Map("exe", exe, "title", title, "path", exePath, "info", info))
        }
    }

    return results
}

PopulatePickerList(Lv, procArray, filterText) {
    Lv.Opt("-Redraw")
    Lv.Delete()
    visibleRows := []
    needle := StrLower(Trim(filterText))
    for item in procArray {
        if (needle = "" || InStr(StrLower(item["exe"]), needle) || InStr(StrLower(item["info"]), needle) || InStr(StrLower(item["path"]), needle)) {
            Lv.Add(, item["exe"], item["info"])
            visibleRows.Push(item)
        }
    }
    Lv.Opt("+Redraw")
    return visibleRows
}

CommitPickerSelection(PickerGui, Lv, targetKey, customCallback := 0, isDoubleClick := false) {
    picked := []
    if (targetKey = "CloseApps" && !isDoubleClick) {
        row := 0
        Loop {
            row := Lv.GetNext(row, "Checked")
            if !row {
                break
            }
            picked.Push(Lv.GetText(row, 1))
        }
    }
    if (picked.Length = 0) {
        row := Lv.GetNext(0)
        if (row) {
            picked.Push(Lv.GetText(row, 1))
        }
    }
    for chosenExe in picked {
        if (IsObject(customCallback)) {
            customCallback(chosenExe)
        } else if (targetKey != "") {
            AddExeToConfigList(targetKey, chosenExe)
        }
    }
    PickerGui.Destroy()
}

; ==============================================================================
; CONFIG PERSISTENCE & UI HELPERS
; ==============================================================================
AddExeFromFile(targetKey) {
    selected := FileSelect(1, , "Select Executable", "Executables (*.exe)")
    if (selected = "") {
        return
    }
    SplitPath(selected, &fileName)
    AddExeToConfigList(targetKey, fileName)
}

AddExeToConfigList(targetKey, exeName) {
    global DraftCfg, AutoUI

    if (targetKey = "TriggerGames") {
        for existing in DraftCfg["TriggerGames"] {
            if (StrLower(existing) = StrLower(exeName)) {
                SetActiveGameEditor(existing)
                return
            }
        }
        DraftCfg["TriggerGames"].Push(exeName)
        key := StrLower(exeName)
        if !DraftCfg["PerGameApps"].Has(key) {
            DraftCfg["PerGameApps"][key] := []
        }
        if AutoUI.Has("LbGames") {
            try AutoUI["LbGames"].Add([exeName])
        }
        SetActiveGameEditor(exeName)
        MarkAutomationDirty()
        return
    }

    gameExe := GetSelectedTriggerGame()
    if (gameExe = "") {
        MsgBox("Add or select a Trigger Game first so its apps can be configured.", "Select Trigger Game", "Icon!")
        return
    }
    gKey := StrLower(gameExe)
    if !DraftCfg["PerGameApps"].Has(gKey) {
        DraftCfg["PerGameApps"][gKey] := []
    }
    for existing in DraftCfg["PerGameApps"][gKey] {
        if (StrLower(existing) = StrLower(exeName)) {
            return
        }
    }
    DraftCfg["PerGameApps"][gKey].Push(exeName)
    if AutoUI.Has("LbApps") {
        try AutoUI["LbApps"].Add([exeName])
    }
    MarkAutomationDirty()
}

RemoveSelectedTriggerGame() {
    global DraftCfg, AutoUI
    if !AutoUI.Has("LbGames") {
        return
    }
    idx := AutoUI["LbGames"].Value
    if (!idx) {
        return
    }
    selectedText := AutoUI["LbGames"].Text
    AutoUI["LbGames"].Delete(idx)

    newArr := []
    for item in DraftCfg["TriggerGames"] {
        if (StrLower(item) != StrLower(selectedText)) {
            newArr.Push(item)
        }
    }
    DraftCfg["TriggerGames"] := newArr
    DraftCfg["PerGameApps"].Delete(StrLower(selectedText))
    SelectInitialTriggerGame()
    MarkAutomationDirty()
}

RemoveSelectedGameApp() {
    global DraftCfg, AutoUI
    gameExe := GetSelectedTriggerGame()
    if (gameExe = "" || !AutoUI.Has("LbApps")) {
        return
    }
    idx := AutoUI["LbApps"].Value
    if (!idx) {
        return
    }
    selectedText := AutoUI["LbApps"].Text
    AutoUI["LbApps"].Delete(idx)

    gKey := StrLower(gameExe)
    newArr := []
    if DraftCfg["PerGameApps"].Has(gKey) {
        for item in DraftCfg["PerGameApps"][gKey] {
            if (StrLower(item) != StrLower(selectedText)) {
                newArr.Push(item)
            }
        }
    }
    DraftCfg["PerGameApps"][gKey] := newArr
    MarkAutomationDirty()
}

BrowseFileSetting(cfgKey, editKey, dialogTitle, filter) {
    global DraftCfg, AutoUI
    selected := FileSelect(1, DraftCfg[cfgKey], dialogTitle, filter)
    if (selected = "") {
        return
    }
    DraftCfg[cfgKey] := selected
    if AutoUI.Has(editKey) {
        AutoUI[editKey].Value := selected
    }
    MarkAutomationDirty()
}

OnToggleAutomation(ctrl, *) {
    global DraftCfg
    DraftCfg["Enabled"] := !!ctrl.Value
    UpdateAutomationControlsState()
    MarkAutomationDirty()
}

OnToggleGsyncAutomation(ctrl, *) {
    global DraftCfg, AutoUI
    DraftCfg["GsyncEnabled"] := !!ctrl.Value
    if AutoUI.Has("TxtGsyncControl") {
        AutoUI["TxtGsyncControl"].Text := AutoUI["ChkGsync"].Value ? "G-Sync control: ON" : "G-Sync control: OFF"
    }
    UpdateAutomationControlsState()
    MarkAutomationDirty()
}

OnDelayChanged(ctrl, *) {
    global DraftCfg
    if (ctrl.Value = "" || !IsNumber(ctrl.Value)) {
        return
    }
    DraftCfg["ExitDelaySec"] := Max(0, Integer(ctrl.Value))
    MarkAutomationDirty()
}

LoadAutomationConfig() {
    global AutoCfg, AutoIniPath, LastAppliedGsyncState

    AutoCfg["Enabled"]      := 0
    AutoCfg["GsyncEnabled"] := 0
    AutoCfg["ExitDelaySec"] := Integer(IniRead(AutoIniPath, "General", "ExitDelaySec", "6"))
    AutoCfg["NpiExe"]       := IniRead(AutoIniPath, "Paths", "NpiExe", "")
    AutoCfg["NipOff"]       := IniRead(AutoIniPath, "Paths", "NipOff", "")
    AutoCfg["NipOn"]        := IniRead(AutoIniPath, "Paths", "NipOn", "")

    ; Restore the last state that was really applied (default ON = your normal G-Sync setting)
    savedGs := StrUpper(IniRead(AutoIniPath, "State", "LastGsyncState", "ON"))
    LastAppliedGsyncState := (savedGs = "OFF") ? "OFF" : "ON"

    AutoCfg["TriggerGames"] := []
    AutoCfg["PerGameApps"] := Map()
}

SaveAutomationConfig() {
    global AutoCfg, AutoIniPath, LastAppliedGsyncState
    IniWrite(AutoCfg["Enabled"], AutoIniPath, "General", "Enabled")
    IniWrite(AutoCfg.Has("GsyncEnabled") ? (AutoCfg["GsyncEnabled"] ? 1 : 0) : 1, AutoIniPath, "General", "GsyncEnabled")
    IniWrite(AutoCfg["ExitDelaySec"], AutoIniPath, "General", "ExitDelaySec")
    IniWrite(AutoCfg["NpiExe"], AutoIniPath, "Paths", "NpiExe")
    IniWrite(AutoCfg["NipOff"], AutoIniPath, "Paths", "NipOff")
    IniWrite(AutoCfg["NipOn"], AutoIniPath, "Paths", "NipOn")
    IniWrite(LastAppliedGsyncState, AutoIniPath, "State", "LastGsyncState")
    IniWrite(GaJoinArray(AutoCfg["TriggerGames"], "|"), AutoIniPath, "Lists", "TriggerGames")

    for gameExe in AutoCfg["TriggerGames"] {
        gKey := StrLower(gameExe)
        appList := AutoCfg["PerGameApps"].Has(gKey) ? AutoCfg["PerGameApps"][gKey] : []
        IniWrite(GaJoinArray(appList, "|"), AutoIniPath, "GameApps", gKey)
    }
}

GaJoinArray(arr, delim) {
    out := ""
    for idx, val in arr {
        out .= (idx > 1 ? delim : "") . val
    }
    return out
}

GaIsDarkMode() {
    try {
        return !!%("UI_Dark_Mode")%
    }
    return false
}

GaStyle(ctrl, dark, muted := false) {
    try {
        fn := %("StyleControlTheme")%
        fn(ctrl, dark, muted)
    }
}

GaSectionBox(guiObj, x, y, w, h, titleText, dark) {
    try {
        fn := %("AddSectionBox")%
        return fn(guiObj, x, y, w, h, titleText, dark)
    } catch {
        return guiObj.AddGroupBox("x" x " y" y " w" w " h" h, titleText)
    }
}

GaTip(ctrl, tipText) {
    try {
        fn := %("RegisterTip")%
        fn(ctrl, tipText)
    }
}

GaLog(msg) {
    try {
        fn := %("DebugLogEvent")%
        fn(msg)
    }
}
; END OF FILE
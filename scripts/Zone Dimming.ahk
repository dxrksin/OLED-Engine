#Requires AutoHotkey v2.0

class ZoneDimming {
    ; --- Active Saved Settings ---
    static MonitorAwareEnabled    := true
    static PerBrowserHeightEnabled := false
    static BrowserHeights          := ZoneDimming._CreateCaseInsensitiveMap()

    ; --- UI Draft & Runtime State ---
    static _DraftMonitorAware      := true
    static _DraftPerBrowser        := false
    static _DraftHeights           := ZoneDimming._CreateCaseInsensitiveMap()
    static _IsDirty                := false
    static _Controls               := Map()

    ; --- Integration Callbacks (wired from OLED Engine.ahk) ---
    static OnDirtyCallback           := ""   ; Called when user edits a setting (enables Apply button)
    static OnSettingsAppliedCallback := ""   ; Called after Apply / Save & Close
    static MonitorEnabledProvider    := ""   ; Optional fn(monIdx) -> Bool

    static _CreateCaseInsensitiveMap() {
        m := Map()
        m.CaseSense := "Off"
        return m
    }

    static _CloneMap(src) {
        dst := ZoneDimming._CreateCaseInsensitiveMap()
        for k, v in src {
            dst[k] := v
        }
        return dst
    }

    static _NormalizeProcName(name) {
        clean := Trim(name)
        if (clean = "")
            return ""
        if !RegExMatch(clean, "i)\.exe$")
            clean .= ".exe"
        return StrLower(clean)
    }

    static _GetConfigPath() {
        cfgDir := A_ScriptDir "\config"
        if !DirExist(cfgDir) {
            try DirCreate(cfgDir)
        }
        return cfgDir "\zone_dimming.ini"
    }

    ; =========================================================================
    ; 1. Initialization & Portable Config Persistence (config\zone_dimming.ini)
    ; =========================================================================
    static Init(onDirty := "", onApplied := "", monitorEnabledFn := "") {
        ZoneDimming.OnDirtyCallback           := onDirty
        ZoneDimming.OnSettingsAppliedCallback := onApplied
        ZoneDimming.MonitorEnabledProvider    := monitorEnabledFn
        ZoneDimming.LoadConfig()
        ZoneDimming.DiscardDraft()
    }

    static LoadConfig() {
        ini := ZoneDimming._GetConfigPath()
        ZoneDimming.MonitorAwareEnabled     := Integer(IniRead(ini, "BrowserDimming", "MonitorAwareEnabled", 1)) != 0
        ZoneDimming.PerBrowserHeightEnabled := Integer(IniRead(ini, "BrowserDimming", "PerBrowserHeightEnabled", 0)) != 0

        loaded := ZoneDimming._CreateCaseInsensitiveMap()
        rawSection := IniRead(ini, "PerBrowserHeights", , "")
        if (rawSection != "") {
            for line in StrSplit(rawSection, "`n", "`r") {
                eqPos := InStr(line, "=")
                if !eqPos
                    continue
                proc := ZoneDimming._NormalizeProcName(SubStr(line, 1, eqPos - 1))
                val  := Trim(SubStr(line, eqPos + 1))
                if (proc != "" && IsInteger(val)) {
                    px := Integer(val)
                    if (px >= 20 && px <= 400)
                        loaded[proc] := px
                }
            }
        }
        ZoneDimming.BrowserHeights := loaded
    }

    static SaveConfig() {
        ini := ZoneDimming._GetConfigPath()
        IniWrite(ZoneDimming.MonitorAwareEnabled ? 1 : 0, ini, "BrowserDimming", "MonitorAwareEnabled")
        IniWrite(ZoneDimming.PerBrowserHeightEnabled ? 1 : 0, ini, "BrowserDimming", "PerBrowserHeightEnabled")

        ; Rewrite PerBrowserHeights section cleanly so deleted entries are removed
        try IniDelete(ini, "PerBrowserHeights")
        for proc, px in ZoneDimming.BrowserHeights {
            IniWrite(px, ini, "PerBrowserHeights", proc)
        }
    }

    ; =========================================================================
    ; 2. Runtime Evaluation (Monitor-Aware Check + Per-Browser Height Lookup)
    ; =========================================================================
    static GetWindowMonitorIndex(hwnd) {
        hMon := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr") ; MONITOR_DEFAULTTONEAREST
        if !hMon
            return 1

        count := MonitorGetCount()
        Loop count {
            MonitorGet(A_Index, &l, &t, &r, &b)
            rc := Buffer(16, 0)
            NumPut("Int", l, rc, 0), NumPut("Int", t, rc, 4)
            NumPut("Int", r, rc, 8), NumPut("Int", b, rc, 12)
            if (DllCall("MonitorFromRect", "Ptr", rc.Ptr, "UInt", 0, "Ptr") = hMon)
                return A_Index
        }
        return 1
    }

    static IsMonitorDimmingEnabled(monIdx) {
        ; 1. Use explicit callback if provided by OLED Engine.ahk
        if (ZoneDimming.MonitorEnabledProvider != "") {
            try return !!ZoneDimming.MonitorEnabledProvider.Call(monIdx)
        }

        ; 2. Fallback checks against common OLED Engine monitor globals
        global MonitorDimEnabled, MonEnabled, MonitorSettings
        if IsSet(MonitorDimEnabled) && IsObject(MonitorDimEnabled) && MonitorDimEnabled.Has(monIdx)
            return !!MonitorDimEnabled[monIdx]
        if IsSet(MonEnabled) && IsObject(MonEnabled) && MonEnabled.Has(monIdx)
            return !!MonEnabled[monIdx]
        if IsSet(MonitorSettings) && IsObject(MonitorSettings) && MonitorSettings.Has(monIdx) {
            item := MonitorSettings[monIdx]
            if IsObject(item) && item.HasOwnProp("Enabled")
                return !!item.Enabled
        }
        return true
    }

    ; Live preview: while the settings hold unapplied edits, the runtime uses those edits right away
    ; (no Apply needed). Cancel / X discards them and the saved values are used again.
    static _EffMonitorAware() {
        return ZoneDimming._IsDirty ? ZoneDimming._DraftMonitorAware : ZoneDimming.MonitorAwareEnabled
    }

    static _EffPerBrowser() {
        return ZoneDimming._IsDirty ? ZoneDimming._DraftPerBrowser : ZoneDimming.PerBrowserHeightEnabled
    }

    static _EffHeights() {
        return ZoneDimming._IsDirty ? ZoneDimming._DraftHeights : ZoneDimming.BrowserHeights
    }

    static ResolveToolbarHeight(procName, globalDefaultHeight) {
        if !ZoneDimming._EffPerBrowser()
            return globalDefaultHeight

        heights := ZoneDimming._EffHeights()
        key := ZoneDimming._NormalizeProcName(procName)
        if (key != "" && heights.Has(key))
            return heights[key]

        return globalDefaultHeight
    }

    ; Main runtime query called by the browser toolbar overlay loop
    static EvaluateBrowserWindow(hwnd, procName, globalDefaultHeight) {
        monIdx := ZoneDimming.GetWindowMonitorIndex(hwnd)
        if (ZoneDimming._EffMonitorAware() && !ZoneDimming.IsMonitorDimmingEnabled(monIdx)) {
            return { allowed: false, height: globalDefaultHeight, monitor: monIdx }
        }
        resolvedHeight := ZoneDimming.ResolveToolbarHeight(procName, globalDefaultHeight)
        return { allowed: true, height: resolvedHeight, monitor: monIdx }
    }

    ; =========================================================================
    ; 3. Settings GUI Controls (Browser Tab) & Apply / Cancel Lifecycle
    ; =========================================================================
    static BuildBrowserTabUI(guiObj, tabCtrl, tabIndex, x, y, w := 460) {
        ZoneDimming.DiscardDraft()
        ZoneDimming._Controls := Map()

        tabCtrl.UseTab(tabIndex)

  global UI_Dark_Mode
        dark := IsSet(UI_Dark_Mode) ? UI_Dark_Mode : true

        boxH := 152
        try {
            tabCtrl.GetPos(&tabX, &tabY, &tabW, &tabH)
            if (tabH > 0) {
                boxH := Max(152, (tabY + tabH - 12) - y)
            }
        }
        ; Compact, evenly spaced layout: monitor scope on top, a gap, then the per-browser options and a smaller table.
        lvH  := Max(54, Min(96, boxH - 126))
        boxH := 126 + lvH

        grp := AddSectionBox(guiObj, x, y, w, boxH, "Monitor Scope && Per-Browser Toolbar Heights", dark)
        ZoneDimming._Controls["Group"] := grp

        cbMonAware := guiObj.AddCheckBox(Format("x{} y{} w{}", x + 14, y + 21, w - 28), "Only dim browser toolbar on monitors with dimming enabled")
        cbMonAware.Value := ZoneDimming._DraftMonitorAware
        cbMonAware.OnEvent("Click", (*) => ZoneDimming._OnToggleChanged())
        ZoneDimming._Controls["MonitorAware"] := cbMonAware

        cbPerBrowser := guiObj.AddCheckBox(Format("x{} y{} w{}", x + 14, y + 52, w - 28), "Enable custom toolbar height per browser (overrides global height)")
        cbPerBrowser.Value := ZoneDimming._DraftPerBrowser
        cbPerBrowser.OnEvent("Click", (*) => ZoneDimming._OnToggleChanged())
        ZoneDimming._Controls["PerBrowser"] := cbPerBrowser

        rowY := y + 80
        lblProc := guiObj.AddText(Format("x{} y{} w50 +0x100", x + 14, rowY + 3), "Browser:")
        ZoneDimming._Controls["LblProc"] := lblProc

        presets := ["brave.exe", "chrome.exe", "msedge.exe", "firefox.exe", "vivaldi.exe", "zen.exe", "opera.exe"]
        cmbProc := guiObj.AddComboBox(Format("x{} y{} w134 r8", x + 66, rowY), presets)
        cmbProc.Text := "brave.exe"
        ZoneDimming._Controls["CmbProc"] := cmbProc

        lblPx := guiObj.AddText(Format("x{} y{} w44 +0x100", x + 208, rowY + 3), "Height:")
        ZoneDimming._Controls["LblPx"] := lblPx

        edPx := guiObj.AddEdit(Format("x{} y{} w54 Number", x + 254, rowY), "80")
        udPx := guiObj.AddUpDown("Range20-400", 80)
        ZoneDimming._Controls["EdPx"] := edPx
        ZoneDimming._Controls["UdPx"] := udPx

        btnSet := guiObj.AddButton(Format("x{} y{} w62 h23", x + 316, rowY - 1), "Set")
        btnSet.OnEvent("Click", (*) => ZoneDimming._OnAddOrUpdateOverride())
        ZoneDimming._Controls["BtnSet"] := btnSet

        btnDel := guiObj.AddButton(Format("x{} y{} w64 h23", x + 384, rowY - 1), "Remove")
        btnDel.OnEvent("Click", (*) => ZoneDimming._OnRemoveOverride())
        ZoneDimming._Controls["BtnDel"] := btnDel

   lv := guiObj.AddListView(Format("x{} y{} w{} h{} -Multi -HScroll Grid", x + 14, rowY + 32, w - 28, lvH), ["Browser Process", "Toolbar Height (px)"])
        lv.ModifyCol(1, w - 180)
        lv.ModifyCol(2, "AutoHdr")    ; last column fills the rest, so no empty strip
        lv.OnEvent("Click", (ctrl, row) => ZoneDimming._OnListRowSelect(ctrl, row))
        lv.OnEvent("DoubleClick", (*) => ZoneDimming._OnRemoveOverride())
        ZoneDimming._Controls["ListView"] := lv

        for ctrl in [cbMonAware, cbPerBrowser, lblProc, cmbProc, lblPx, edPx, udPx, btnSet, btnDel, lv] {
            StyleControlTheme(ctrl, dark)
        }
        try PostMessage(0x0142, 0, -1, cmbProc.Hwnd) ; CB_SETEDITSEL: clear red text selection highlight

        tabCtrl.UseTab()

        ZoneDimming._PopulateListView()
        ZoneDimming.SyncUiState()
        ZoneDimming.ApplyTheme()
    }

static SyncUiState() {
        c := ZoneDimming._Controls
        if !c.Has("PerBrowser")
            return

        enabled := !!c["PerBrowser"].Value
        for key in ["LblProc", "CmbProc", "LblPx", "EdPx", "UdPx", "BtnSet", "BtnDel"] {
            if c.Has(key) {
                c[key].Enabled := enabled
            }
        }

        if c.Has("ListView") {
            ; Keep Win32 WS_DISABLED off so SysListView32 preserves its dark background instead of turning light grey
            c["ListView"].Enabled := true
            if !enabled {
                try c["ListView"].Modify(0, "-Select -Focus")
            }
        }

        if c.Has("BtnDel") && c.Has("ListView") {
            c["BtnDel"].Enabled := enabled && (c["ListView"].GetNext(0) > 0)
        }
        ZoneDimming.ApplyTheme()

        if c.Has("CmbProc") {
            try PostMessage(0x0142, 0, -1, c["CmbProc"].Hwnd)
        }
        for key in ["LblProc", "CmbProc", "LblPx", "EdPx", "UdPx", "BtnSet", "BtnDel", "ListView"] {
            if c.Has(key) {
                try c[key].Redraw()
            }
        }
    }

static ApplyTheme() {
        global UI_Dark_Mode
        c := ZoneDimming._Controls
        if !c.Has("ListView")
            return

        dark    := IsSet(UI_Dark_Mode) ? UI_Dark_Mode : true
        enabled := !!c["PerBrowser"].Value

        lv := c["ListView"]
        StyleControlTheme(lv, dark)

        if !enabled {
            disHex := dark ? "686B82" : "8C8C96"
            disBgr := dark ? 0x826B68 : 0x968C8C
            lv.Opt("+c" disHex)
            try SendMessage(0x1024, 0, disBgr, lv.Hwnd) ; LVM_SETTEXTCOLOR
        }
        try lv.Redraw()

        txtHex := enabled ? (dark ? "EAEAF2" : "111111") : (dark ? "686B82" : "8C8C96")
        for key in ["LblProc", "LblPx"] {
            if c.Has(key) {
                c[key].SetFont("c" txtHex)
                try c[key].Redraw()
            }
        }
    }
    static _PopulateListView() {
        c := ZoneDimming._Controls
        if !c.Has("ListView")
            return

        lv := c["ListView"]
        lv.Delete()
        for proc, px in ZoneDimming._DraftHeights {
            lv.Add("", proc, px)
        }
        lv.ModifyCol(2, "AutoHdr")    ; re-fit: keeps the last column clear of the vertical scrollbar
    }

    static _OnToggleChanged(*) {
        c := ZoneDimming._Controls
        ZoneDimming._DraftMonitorAware := !!c["MonitorAware"].Value
        ZoneDimming._DraftPerBrowser   := !!c["PerBrowser"].Value
        ZoneDimming.SyncUiState()
        ZoneDimming._MarkDirty()
    }

    static _OnListRowSelect(lv, rowNum) {
        if !ZoneDimming._DraftPerBrowser {
            try lv.Modify(0, "-Select -Focus")
            return
        }
        if (rowNum <= 0) {
            ZoneDimming.SyncUiState()
            return
        }
        c := ZoneDimming._Controls
        c["CmbProc"].Text := lv.GetText(rowNum, 1)
        c["EdPx"].Value   := lv.GetText(rowNum, 2)
        ZoneDimming.SyncUiState()
    }

    static _OnAddOrUpdateOverride(*) {
        c := ZoneDimming._Controls
        proc := ZoneDimming._NormalizeProcName(c["CmbProc"].Text)
        if (proc = "")
            return

        px := IsInteger(c["EdPx"].Value) ? Integer(c["EdPx"].Value) : 80
        px := Max(20, Min(400, px))
        c["EdPx"].Value := px

        ZoneDimming._DraftHeights[proc] := px
        ZoneDimming._PopulateListView()
        ZoneDimming.SyncUiState()
        ZoneDimming._MarkDirty()
    }

  static _OnRemoveOverride(*) {
        if !ZoneDimming._DraftPerBrowser
            return
        c := ZoneDimming._Controls
        lv := c["ListView"]
        row := lv.GetNext(0)
        if (row <= 0)
            return

        proc := ZoneDimming._NormalizeProcName(lv.GetText(row, 1))
        if ZoneDimming._DraftHeights.Has(proc) {
            ZoneDimming._DraftHeights.Delete(proc)
        }
        ZoneDimming._PopulateListView()
        ZoneDimming.SyncUiState()
        ZoneDimming._MarkDirty()
    }

    static _MarkDirty() {
        ZoneDimming._IsDirty := true
        if (ZoneDimming.OnDirtyCallback != "") {
            try ZoneDimming.OnDirtyCallback.Call()
        }
    }

    ; Called when user clicks Apply or Save & Close
    static ApplyAndSave() {
        ZoneDimming.MonitorAwareEnabled     := ZoneDimming._DraftMonitorAware
        ZoneDimming.PerBrowserHeightEnabled := ZoneDimming._DraftPerBrowser
        ZoneDimming.BrowserHeights          := ZoneDimming._CloneMap(ZoneDimming._DraftHeights)
        ZoneDimming._IsDirty                := false
        ZoneDimming.SaveConfig()

        if (ZoneDimming.OnSettingsAppliedCallback != "") {
            try ZoneDimming.OnSettingsAppliedCallback.Call()
        }
    }

    ; Called when Settings GUI closes via Cancel / X without saving
    static DiscardDraft() {
        ZoneDimming._DraftMonitorAware := ZoneDimming.MonitorAwareEnabled
        ZoneDimming._DraftPerBrowser   := ZoneDimming.PerBrowserHeightEnabled
        ZoneDimming._DraftHeights      := ZoneDimming._CloneMap(ZoneDimming.BrowserHeights)
        ZoneDimming._IsDirty           := false
    }
}
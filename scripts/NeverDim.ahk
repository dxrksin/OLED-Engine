#Requires AutoHotkey v2.0
; ==============================================================================
; scripts\NeverDim.ahk  -  "Never dim" apps with per-app conditions for OLED Engine
; ------------------------------------------------------------------------------
; Keeps the engine's existing Excluded_Processes_List text, but each item may now say WHEN it counts:
;
;     obs64.exe            counts in every state (same as before)
;     game.exe:F           only while it is Fullscreen
;     zoom.exe:WBN         only while Windowed, in the Background, or Minimized / tray only
;     old.exe:-            rule switched off (kept in the list, never blocks dimming)
;
; Letters:  F = Fullscreen   M = Maximized   W = Windowed   B = In the background   N = Minimized / tray only
;
; How a window is judged (only when an app with a limited rule is running, once per second):
;   - minimized, or the app has no window            -> N
;   - another window covers more than half of it     -> B  (this is how "the one in front wins": the app in front
;                                                          gets its size state, the one behind it counts as B)
;   - covers its whole monitor                       -> F  (also borderless-fullscreen games and fullscreen video)
;   - maximized                                      -> M
;   - anything else that is open and visible         -> W
; With several windows of one app, its front-most window decides. Dimming stays off while ANY listed app matches.
; Click-through overlays (NVIDIA / Steam / Game Bar style), tool windows and the shell are ignored.
;
; This file only defines a class. The engine calls NeverDim.Parse() / NeverDim.Evaluate() / NeverDim.Open().
; ==============================================================================
class NeverDim {
    static ALL        := 31                ; F + M + W + B + N
    static Rules      := Map()             ; lowercase exe -> state mask (live rules used for dimming)
    static Why        := ""                ; last match, e.g. "obs64.exe (Windowed)" - shown in Live Status
    static ExeCache   := Map()             ; process id -> lowercase exe name
    static ExeCacheTick := 0

    ; ---- dialog runtime ---------------------------------------------------------
    static Dlg   := ""
    static Ui    := 0
    static Draft := []
    static Edt   := ""
    static AllItems := []                  ; every entry offered by the picker (the filter box narrows what the combo shows)

    ; ==========================================================================
    ; Parsing
    ; ==========================================================================
    ; Text -> [{exe, mask}, ...] (duplicates merged). Pure function, does not touch the live rules.
    static ParseItems(text) {
        items := []
        index := Map()
        for part in StrSplit(text, ",") {
            part := Trim(part)
            if (part = "") {
                continue
            }
            exe := part
            mask := this.ALL
            p := InStr(part, ":")
            if p {
                exe := Trim(SubStr(part, 1, p - 1))
                letters := StrUpper(Trim(SubStr(part, p + 1)))
                if (letters != "") {
                    mask := 0
                    Loop Parse letters {
                        q := InStr("FMWBN", A_LoopField)
                        if q {
                            mask |= (1 << (q - 1))
                        }
                    }
                }
            }
            if (exe = "") {
                continue
            }
            key := StrLower(exe)
            if index.Has(key) {
                items[index[key]].mask |= mask
            } else {
                items.Push({ exe: exe, mask: mask })
                index[key] := items.Length
            }
        }
        return items
    }

    ; Loads the live rules and returns the plain exe names (what the engine's Excluded_Processes array always held).
    static Parse(text) {
        rules := Map()
        names := []
        for it in this.ParseItems(text) {
            rules[StrLower(it.exe)] := it.mask
            names.Push(it.exe)
        }
        this.Rules := rules
        return names
    }

    static StateName(bit) {
        static names := ["Fullscreen", "Maximized", "Windowed", "In the background", "Minimized / tray only"]
        Loop 5 {
            if (bit = (1 << (A_Index - 1))) {
                return names[A_Index]
            }
        }
        return ""
    }

    static Summary(mask) {
        if (mask = this.ALL) {
            return "Always (any state)"
        }
        if (mask = 0) {
            return "Never (rule is off)"
        }
        out := ""
        Loop 5 {
            if ((mask >> (A_Index - 1)) & 1) {
                out .= (out = "" ? "" : ", ") this.StateName(1 << (A_Index - 1))
            }
        }
        return out
    }

    ; ==========================================================================
    ; Evaluation (called by the engine's IsExcludedProcessRunning, cached there for 1 s)
    ; ==========================================================================
    static Evaluate() {
        this.Why := ""
        need := Map()
        for key, mask in this.Rules {
            if (mask = 0 || !ProcessExist(key)) {
                continue
            }
            if (mask = this.ALL) {
                this.Why := key " (running)"
                return true                         ; plain "never dim while running": no window check needed
            }
            need[key] := true
        }
        if (need.Count = 0) {
            return false
        }
        states := this.WalkWindows(need)
        for key in need {
            st := states.Has(key) ? states[key] : 16      ; running but no usable window = minimized / tray only
            if (this.Rules[key] & st) {
                this.Why := key " (" this.StateName(st) ")"
                return true
            }
        }
        return false
    }

    ; One pass over the windows from front to back. Returns Map(exe -> state bit) for the apps in `need`.
    static WalkWindows(need) {
        states := Map()
        aboves := []                               ; rectangles of the real windows seen so far (they are in front of the rest)
        rc := Buffer(16, 0)
        mi := Buffer(40, 0)
        h := DllCall("GetTopWindow", "Ptr", 0, "Ptr")
        Loop 500 {
            if !h {
                break
            }
            cur := h
            h := DllCall("GetWindow", "Ptr", cur, "UInt", 2, "Ptr")      ; GW_HWNDNEXT
            pid := 0
            if !this.IsAppWindow(cur, &pid) {
                continue
            }
            if DllCall("IsIconic", "Ptr", cur, "Int") {
                continue                                                   ; minimized windows cover nothing
            }
            if !DllCall("GetWindowRect", "Ptr", cur, "Ptr", rc.Ptr) {
                continue
            }
            wl := NumGet(rc, 0, "Int"), wt := NumGet(rc, 4, "Int"), wr := NumGet(rc, 8, "Int"), wb := NumGet(rc, 12, "Int")
            if (wr - wl < 2 || wb - wt < 2) {
                continue
            }
            exe := this.ExeOf(cur, pid)
            if (exe != "" && need.Has(exe) && !states.Has(exe)) {
                ; mostly covered by a window that is in front of it?
                area := (wr - wl) * (wb - wt)
                covered := false
                for a in aboves {
                    ix := Min(wr, a[3]) - Max(wl, a[1])
                    iy := Min(wb, a[4]) - Max(wt, a[2])
                    if (ix > 0 && iy > 0 && ix * iy * 2 > area) {
                        covered := true
                        break
                    }
                }
                if covered {
                    st := 8
                } else {
                    hMon := DllCall("MonitorFromWindow", "Ptr", cur, "UInt", 2, "Ptr")
                    NumPut("UInt", 40, mi, 0)
                    DllCall("GetMonitorInfoW", "Ptr", hMon, "Ptr", mi.Ptr)
                    ml := NumGet(mi, 4, "Int"), mt := NumGet(mi, 8, "Int"), mr := NumGet(mi, 12, "Int"), mb := NumGet(mi, 16, "Int")
                    spans := (wl <= ml + 1 && wt <= mt + 1 && wr >= mr - 1 && wb >= mb - 1)
                    zoomed := DllCall("IsZoomed", "Ptr", cur, "Int")
                    caption := ((DllCall("GetWindowLongW", "Ptr", cur, "Int", -16, "UInt") & 0xC00000) = 0xC00000)
                    if (zoomed && caption) {
                        st := 2                                            ; maximized with a title bar
                    } else if spans {
                        st := 1                                            ; covers the whole monitor
                    } else if zoomed {
                        st := 2
                    } else {
                        st := 4
                    }
                }
                states[exe] := st
                if (states.Count >= need.Count) {
                    break
                }
            }
            if (aboves.Length < 200) {
                aboves.Push([wl, wt, wr, wb])
            }
        }
        return states
    }

    ; True for a real application window: visible, not cloaked, not a tool / click-through / no-activate overlay,
    ; not the shell (taskbar, desktop, flyouts) and not one of our own windows.
    static IsAppWindow(h, &pid) {
        static skip := Map("Progman", 1, "WorkerW", 1, "Shell_TrayWnd", 1, "Shell_SecondaryTrayWnd", 1,
            "Windows.UI.Core.CoreWindow", 1, "XamlExplorerHostIslandWindow", 1, "TopLevelWindowForOverflowXamlIsland", 1,
            "NotifyIconOverflowWindow", 1, "#32768", 1, "Xaml_WindowedPopupClass", 1)
        static cls := Buffer(512, 0)
        static own := DllCall("GetCurrentProcessId", "UInt")
        pid := 0
        if !DllCall("IsWindowVisible", "Ptr", h, "Int") {
            return false
        }
        ex := DllCall("GetWindowLongW", "Ptr", h, "Int", -20, "UInt")
        if (((ex & 0x80) && !(ex & 0x40000)) || (ex & 0x08000000) || (ex & 0x20)) {
            return false                  ; tool window (without app-window flag), no-activate overlay, click-through overlay
        }
        cloaked := 0
        DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", h, "UInt", 14, "UInt*", &cloaked, "UInt", 4)
        if cloaked {
            return false
        }
        DllCall("GetWindowThreadProcessId", "Ptr", h, "UInt*", &pid, "UInt")
        if (!pid || pid = own) {
            return false
        }
        if DllCall("GetClassNameW", "Ptr", h, "Ptr", cls.Ptr, "Int", 256) {
            if skip.Has(StrGet(cls.Ptr, "UTF-16")) {
                return false
            }
        }
        return true
    }

    static ExeOf(h, pid) {
        if (A_TickCount - this.ExeCacheTick > 60000) {      ; process ids get reused: forget the names now and then
            this.ExeCache := Map()
            this.ExeCacheTick := A_TickCount
        }
        if this.ExeCache.Has(pid) {
            return this.ExeCache[pid]
        }
        name := ""
        try name := StrLower(WinGetProcessName("ahk_id " h))
        this.ExeCache[pid] := name
        return name
    }

    ; ==========================================================================
    ; Running-app lists for the picker
    ; ==========================================================================
    ; Apps that currently have a titled window, front-most first: [{exe, title}, ...]
    static ListWindowApps() {
        apps := []
        seen := Map()
        h := DllCall("GetTopWindow", "Ptr", 0, "Ptr")
        Loop 500 {
            if !h {
                break
            }
            cur := h
            h := DllCall("GetWindow", "Ptr", cur, "UInt", 2, "Ptr")
            pid := 0
            if !this.IsAppWindow(cur, &pid) {
                continue
            }
            exe := this.ExeOf(cur, pid)
            if (exe = "" || seen.Has(exe)) {
                continue
            }
            title := ""
            try title := WinGetTitle("ahk_id " cur)
            if (title = "") {
                continue
            }
            seen[exe] := true
            apps.Push({ exe: exe, title: SubStr(title, 1, 60) })
        }
        return apps
    }

    ; Every running process name (lowercase -> original case), through a toolhelp snapshot.
    static AllProcessNames() {
        names := Map()
        snap := DllCall("CreateToolhelp32Snapshot", "UInt", 0x2, "UInt", 0, "Ptr")     ; TH32CS_SNAPPROCESS
        if (!snap || snap = -1) {
            return names
        }
        pe := Buffer(A_PtrSize = 8 ? 568 : 556, 0)
        NumPut("UInt", pe.Size, pe, 0)
        off := (A_PtrSize = 8) ? 44 : 36
        ok := DllCall("Process32FirstW", "Ptr", snap, "Ptr", pe.Ptr, "Int")
        while ok {
            nm := StrGet(pe.Ptr + off, "UTF-16")
            if (nm != "") {
                names[StrLower(nm)] := nm
            }
            ok := DllCall("Process32NextW", "Ptr", snap, "Ptr", pe.Ptr, "Int")
        }
        DllCall("CloseHandle", "Ptr", snap)
        return names
    }

    static IsNoise(key) {
        static noise := Map("system", 1, "system idle process", 1, "registry", 1, "memory compression", 1,
            "smss.exe", 1, "csrss.exe", 1, "wininit.exe", 1, "services.exe", 1, "lsass.exe", 1, "svchost.exe", 1,
            "fontdrvhost.exe", 1, "winlogon.exe", 1, "dwm.exe", 1, "conhost.exe", 1, "runtimebroker.exe", 1,
            "sihost.exe", 1, "taskhostw.exe", 1, "ctfmon.exe", 1, "dllhost.exe", 1, "audiodg.exe", 1,
            "wudfhost.exe", 1, "spoolsv.exe", 1, "searchindexer.exe", 1, "securityhealthservice.exe", 1)
        return noise.Has(key)
    }

    ; Strings for the picker's combo box: "obs64.exe | OBS 30.0.2 ..." (apps with windows first, then background processes).
    static BuildItems(includeBackground) {
        items := []
        seen := Map()
        for a in this.ListWindowApps() {
            items.Push(a.exe " | " a.title)
            seen[a.exe] := true
        }
        if includeBackground {
            lst := ""
            for key, nm in this.AllProcessNames() {
                if (!seen.Has(key) && !this.IsNoise(key)) {
                    lst .= nm " | (no window)`n"
                }
            }
            if (lst != "") {
                for line in StrSplit(Sort(RTrim(lst, "`n")), "`n") {
                    items.Push(line)
                }
            }
        }
        return items
    }

    ; ==========================================================================
    ; Picker dialog (opened from the "Never Dim Apps" box on the General tab)
    ; ==========================================================================
    static Open(edt) {
        global UI_Dark_Mode, SettingsGui, ThemeSurfaceRgb
        if IsObject(this.Dlg) {
            try {
                this.Dlg.Show()
                return
            }
        }
        this.Edt := edt
        this.Draft := this.ParseItems(edt.Value)
        this.AllItems := this.BuildItems(false)
        dark := UI_Dark_Mode
        owner := IsObject(SettingsGui) ? (" +Owner" SettingsGui.Hwnd) : ""
        g := Gui("+DPIScale -MaximizeBox -MinimizeBox" owner, "Never Dim - apps and conditions")
        ApplyGuiTheme(g, dark)
        g.MarginX := 16
        g.MarginY := 14
        ui := {}

        t0 := g.AddText("x16 y14 w588 +0x100", "Pick an app, then choose when it should keep the screen from dimming.")
        StyleControlTheme(t0, dark)
        tRun := g.AddText("x16 y46 w588 +0x100", "Running apps  (pick one, search, or type an .exe name)")
        StyleControlTheme(tRun, dark, true)
        ui.cmb := g.AddComboBox("x16 y68 w356 r14", this.AllItems)
        ui.btnRef := g.AddButton("x378 y67 w90 h26", "Refresh")
        ui.btnAdd := g.AddButton("x474 y67 w130 h26 Default", "Add to list")
        ui.flt := g.AddEdit("x16 y100 w356 r1")
        try DllCall("SendMessageW", "Ptr", ui.flt.Hwnd, "UInt", 0x1501, "Ptr", 0, "Str", "Filter apps or .exe names...", "Ptr")    ; EM_SETCUEBANNER: faint hint, hidden while the box has focus
        ui.chkBg := g.AddCheckbox("x378 y103 w226", "Include background processes")
        for c in [ui.cmb, ui.btnRef, ui.btnAdd, ui.flt, ui.chkBg] {
            StyleControlTheme(c, dark)
        }

        tList := g.AddText("x16 y134 w588 +0x100", "Apps that keep the screen from dimming")
        StyleControlTheme(tList, dark, true)
        lvColors := (dark ? "cFFFFFF" : "c000000") " Background" Format("{:06X}", ThemeSurfaceRgb)
        ui.lv := g.AddListView("x16 y154 w588 h138 -Multi NoSortHdr Grid " lvColors, ["App", "Dimming is blocked while it is..."])
        StyleControlTheme(ui.lv, dark)
        ui.btnDel := g.AddButton("x16 y298 w110 h26", "Remove")
        StyleControlTheme(ui.btnDel, dark)

        AddSectionBox(g, 16, 334, 588, 224, "Block dimming while the selected app is...", dark)
        rows := [
            ["Fullscreen", "Covers its whole monitor (games, borderless games, fullscreen video)."],
            ["Maximized", "Fills the screen apart from the taskbar."],
            ["Windowed", "Open at a normal size and not hidden behind other windows."],
            ["In the background", "Another window is covering most of it."],
            ["Minimized / tray only", "Minimized, or running without any window."]
        ]
        ui.chks := []
        ui.descs := []
        y := 360
        for r in rows {
            c := g.AddCheckbox("x32 y" y " w190", r[1])
            d := g.AddText("x226 y" (y + 2) " w366 h34 +0x100", r[2])
            StyleControlTheme(c, dark)
            StyleControlTheme(d, dark, true)
            c.OnEvent("Click", (*) => this.OnToggle())
            ui.chks.Push(c)
            ui.descs.Push(d)
            y += 38
        }

        hint := g.AddText("x16 y566 w588 h36", "Dimming stays off while ANY listed app matches. If an app is mostly covered by another window it counts as 'In the background'; otherwise it is judged by its size.")
        StyleControlTheme(hint, dark, true)

        ui.btnAll := g.AddButton("x16 y610 w100 h30", "Select all")
        ui.btnNone := g.AddButton("x122 y610 w100 h30", "Clear")
        ui.btnOk := g.AddButton("x404 y610 w96 h30", "OK")
        ui.btnCancel := g.AddButton("x508 y610 w96 h30", "Cancel")
        for c in [ui.btnAll, ui.btnNone, ui.btnOk, ui.btnCancel] {
            StyleControlTheme(c, dark)
        }

        ui.btnRef.OnEvent("Click", (*) => this.RefreshItems())
        ui.chkBg.OnEvent("Click", (*) => this.RefreshItems())
        ui.flt.OnEvent("Change", (*) => this.ApplyFilter())
        ui.btnAdd.OnEvent("Click", (*) => this.AddFromCombo())
        ui.btnDel.OnEvent("Click", (*) => this.RemoveSelected())
        ui.btnAll.OnEvent("Click", (*) => this.SetAllStates(true))
        ui.btnNone.OnEvent("Click", (*) => this.SetAllStates(false))
        ui.btnOk.OnEvent("Click", (*) => this.Accept())
        ui.btnCancel.OnEvent("Click", (*) => this.CloseDlg())
        ui.lv.OnEvent("ItemSelect", (*) => this.OnSelect())
        g.OnEvent("Close", (*) => this.CloseDlg())
        g.OnEvent("Escape", (*) => this.CloseDlg())

        this.Dlg := g
        this.Ui := ui
        this.FillList(1)
        if IsObject(SettingsGui) {
            try SettingsGui.Opt("+Disabled")          ; behaves like a modal dialog; re-enabled in CloseDlg
        }
        g.Show("w620 h656 Center")
    }

    static FillList(sel := 0) {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        ui.lv.Delete()
        for it in this.Draft {
            ui.lv.Add("", it.exe, this.Summary(it.mask))
        }
        ui.lv.ModifyCol(1, 210)
        ui.lv.ModifyCol(2, 360)
        if (sel >= 1 && this.Draft.Length >= 1) {
            ui.lv.Modify(Min(sel, this.Draft.Length), "Select Focus")
        }
        this.OnSelect()
    }

    ; Selected row changed: show its states in the checkboxes (all greyed out when nothing is selected).
    static OnSelect() {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        row := ui.lv.GetNext(0)
        has := (row >= 1 && row <= this.Draft.Length)
        mask := has ? this.Draft[row].mask : 0
        Loop 5 {
            ui.chks[A_Index].Value := (mask >> (A_Index - 1)) & 1
        }
        SetControlsEnabled(ui.chks, has)
        SetControlsEnabled(ui.descs, has)
        ui.btnDel.Enabled := has
        for c in ui.chks {
            c.Redraw()
        }
    }

    ; A state checkbox was clicked: store it for the selected app and update the list text.
    static OnToggle() {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        row := ui.lv.GetNext(0)
        if (row < 1 || row > this.Draft.Length) {
            return
        }
        mask := 0
        Loop 5 {
            if ui.chks[A_Index].Value {
                mask |= (1 << (A_Index - 1))
            }
        }
        this.Draft[row].mask := mask
        ui.lv.Modify(row, "Col2", this.Summary(mask))
    }

    static SetAllStates(on) {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        row := ui.lv.GetNext(0)
        if (row < 1 || row > this.Draft.Length) {
            return
        }
        this.Draft[row].mask := on ? this.ALL : 0
        ui.lv.Modify(row, "Col2", this.Summary(this.Draft[row].mask))
        this.OnSelect()
    }

    static RefreshItems() {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        this.AllItems := this.BuildItems(!!ui.chkBg.Value)
        this.ApplyFilter()
    }

    ; Fills the combo with the entries that contain every word typed in the search box (blank box = everything).
    static ApplyFilter() {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        query := Trim(ui.flt.Value)
        shown := []
        for line in this.AllItems {
            ok := true
            for term in StrSplit(query, " ") {
                if (term != "" && !InStr(line, term)) {
                    ok := false
                    break
                }
            }
            if ok {
                shown.Push(line)
            }
        }
        ui.cmb.Delete()
        if (shown.Length >= 1) {
            ui.cmb.Add(shown)
            if (query != "") {
                try ui.cmb.Choose(1)                ; first match is ready for "Add to list" / Enter
            }
        }
    }

    ; "obs64.exe | OBS 30.0" (picked) or "obs64" (typed) -> adds the app with every state ticked.
    static AddFromCombo() {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        txt := Trim(ui.cmb.Text)
        if (txt = "") {
            return
        }
        p := InStr(txt, " | ")
        if p {
            txt := SubStr(txt, 1, p - 1)
        }
        last := 0
        for piece in StrSplit(txt, ",") {
            exe := Trim(piece)
            if (exe = "") {
                continue
            }
            if !InStr(exe, ".") {
                exe .= ".exe"
            }
            idx := 0
            for i, it in this.Draft {
                if (StrLower(it.exe) = StrLower(exe)) {
                    idx := i
                    break
                }
            }
            if !idx {
                this.Draft.Push({ exe: exe, mask: this.ALL })
                idx := this.Draft.Length
            }
            last := idx
        }
        if !last {
            return
        }
        this.FillList(last)
        try ui.cmb.Choose(0)
        DllCall("SendMessageW", "Ptr", ui.cmb.Hwnd, "UInt", 0xC, "Ptr", 0, "Str", "")    ; clear the combo's text
    }

    static RemoveSelected() {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        row := ui.lv.GetNext(0)
        if (row < 1 || row > this.Draft.Length) {
            return
        }
        this.Draft.RemoveAt(row)
        this.FillList(row)
    }

    ; OK: write the list back into the General tab's text box (saved with Apply / Save & Close like every other setting).
    static Accept() {
        parts := []
        for it in this.Draft {
            if (it.mask = this.ALL) {
                parts.Push(it.exe)
            } else if (it.mask = 0) {
                parts.Push(it.exe ":-")
            } else {
                letters := ""
                Loop 5 {
                    if ((it.mask >> (A_Index - 1)) & 1) {
                        letters .= SubStr("FMWBN", A_Index, 1)
                    }
                }
                parts.Push(it.exe ":" letters)
            }
        }
        text := JoinArray(parts, ", ")
        edt := this.Edt
        this.CloseDlg()
        try {
            edt.Value := text
            MarkSettingsDirty()
        }
    }

    static CloseDlg() {
        global SettingsGui
        if IsObject(SettingsGui) {
            try SettingsGui.Opt("-Disabled")
        }
        dlg := this.Dlg
        this.Dlg := ""
        this.Ui := 0
        if IsObject(dlg) {
            try dlg.Destroy()
        }
        if IsObject(SettingsGui) {
            try WinActivate("ahk_id " SettingsGui.Hwnd)
        }
    }
}
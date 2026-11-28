#Requires AutoHotkey v2.0
; ==============================================================================
; scripts\TaskbarDimming.ahk  -  Windows taskbar dimming for OLED Engine
; ------------------------------------------------------------------------------
; Makes the Windows taskbar (Shell_TrayWnd on the primary monitor, Shell_SecondaryTrayWnd on
; the other monitors) see-through on the monitors you enable. The dim level is how INVISIBLE the
; taskbar becomes (0% = untouched, 100% = fully see-through), so the Windows logo, pinned icons,
; tray and clock all fade together. No overlay window is used any more.
;   - The taskbar returns to full visibility while the mouse is over it (and for a moment
;     after it leaves), and while the taskbar / Start / tray flyouts have focus.
;   - It is restored to normal while a window covers the whole monitor (fullscreen), while
;     an auto-hidden taskbar is slid away, while Windows is locked, and when the script exits.
; Works together with Windows' "Automatically hide the taskbar": with both on, the taskbar is dimmed while it is
; shown, becomes fully visible while the mouse is over it, and dims again shortly after the mouse leaves.
; Settings live in the engine's settings.ini, section [TaskbarDim].
; This file only defines a class: nothing runs until OLED_Engine.ahk calls
; TaskbarDimming.Init(), so it is safe to #Include near the top of the engine.
; ==============================================================================
class TaskbarDimming {
    ; ---- saved settings -------------------------------------------------------
    static Enabled  := false
    static Percent  := 60            ; 0-100, 100 = taskbar fully see-through
    static Monitors := "all"         ; "all" or a list such as "1,3"

    ; ---- tuning ---------------------------------------------------------------
    static TICK_MS         := 33     ; fade / hover poll
    static SYNC_MS         := 500    ; how often taskbar windows are re-enumerated
    static HOVER_RELEASE_MS := 350   ; taskbar stays fully visible this long after the mouse leaves
    static FADE_OUT_MS     := 120    ; see-through -> fully visible (mouse arrives)
    static FADE_IN_MS      := 450    ; fully visible -> see-through (mouse left)

    ; ---- runtime --------------------------------------------------------------
    static States   := Map()         ; taskbar hwnd -> state object
    static TimerFn  := 0
    static Ui       := 0             ; Settings-window controls (only while the window is open)
    static lastSync := 0
    static running  := false
    static DdlTipFn := 0
    static WdPid    := 0             ; process id of scripts\TaskbarWatchdog.ahk while it runs
    static AutoHideOn := false       ; Windows' own taskbar auto-hide is on (a slid-away bar keeps its fade state; hover still brightens it)

    ; ==========================================================================
    ; Start-up / settings
    ; ==========================================================================
    static Init() {
        this.SweepStale()              ; a crash / kill of an earlier run may have left the taskbar see-through
        this.LoadSettings()
        this.ApplyRuntime()
    }

    ; Restores any taskbar window that is still see-through (alpha below 255). Runs once at start-up.
    static SweepStale() {
        prevHidden := A_DetectHiddenWindows
        DetectHiddenWindows(true)                  ; also reach a taskbar that is currently hidden / slid away
        try {
            for cls in ["Shell_TrayWnd", "Shell_SecondaryTrayWnd"] {
                for hwnd in WinGetList("ahk_class " cls) {
                    key := 0, alpha := 255, flags := 0
                    if (DllCall("GetLayeredWindowAttributes", "Ptr", hwnd, "UInt*", &key, "UChar*", &alpha, "UInt*", &flags, "Int")
                        && (flags & 0x2) && alpha < 255) {
                        this.RestoreTaskbar(hwnd)
                    }
                }
            }
        }
        DetectHiddenWindows(prevHidden)
    }

    ; The watchdog (separate tiny script) only runs while taskbar dimming is on. Needs the AutoHotkey interpreter,
    ; so it is skipped silently for a compiled .exe without AutoHotkey installed (the other failsafes still apply).
    static StartWatchdog() {
        if (this.WdPid && ProcessExist(this.WdPid)) {
            return
        }
        wd := A_ScriptDir "\scripts\TaskbarWatchdog.ahk"
        if (A_IsCompiled || !FileExist(wd) || !FileExist(A_AhkPath)) {
            return
        }
        try {
            Run('"' A_AhkPath '" "' wd '" ' DllCall("GetCurrentProcessId", "UInt") ' "' A_ScriptFullPath '"', , "Hide", &pid)
            this.WdPid := pid
        }
    }

    static StopWatchdog() {
        if this.WdPid {
            try ProcessClose(this.WdPid)
            this.WdPid := 0
        }
    }

    static LoadSettings() {
        global IniPath
        try {
            this.Enabled := (IniRead(IniPath, "TaskbarDim", "Enabled", "0") = "1")
            p := IniRead(IniPath, "TaskbarDim", "Percent", "60")
            this.Percent := IsNumber(p) ? Max(0, Min(100, Integer(p))) : 60
            m := Trim(IniRead(IniPath, "TaskbarDim", "Monitors", "all"))
            this.Monitors := (m = "") ? "all" : m
        }
    }

    static SaveSettings() {
        global IniPath
        try IniWrite(this.Enabled ? 1 : 0, IniPath, "TaskbarDim", "Enabled")
        try IniWrite(this.Percent,         IniPath, "TaskbarDim", "Percent")
        try IniWrite(this.Monitors,        IniPath, "TaskbarDim", "Monitors")
    }

    ; Starts / stops the timer to match the current settings.
    static ApplyRuntime() {
        if !this.TimerFn {
            this.TimerFn := ObjBindMethod(this, "Tick")
        }
        if (this.Enabled && this.Percent > 0) {
            this.lastSync := 0
            this.running := true
            SetTimer(this.TimerFn, this.TICK_MS)
            this.StartWatchdog()
        } else {
            this.running := false
            SetTimer(this.TimerFn, 0)
            this.DestroyAll()
            this.StopWatchdog()
        }
    }

    static Shutdown() {
        this.running := false
        if this.TimerFn {
            SetTimer(this.TimerFn, 0)
        }
        this.DestroyAll()
        this.SweepStale()                  ; also catches a taskbar window that was not (or no longer) tracked
        this.StopWatchdog()
    }

    ; ==========================================================================
    ; Settings window (OLED Care tab, next to "Auto-hide the taskbar")
    ; ==========================================================================
    ; Builds BOTH toggles of the Care tab's taskbar section so they are created and styled identically:
    ;   left  = "Dim the taskbar" (+ Dim level slider underneath)
    ;   right = "Auto-hide the taskbar in Windows" (+ Monitors dropdown underneath)
    ; They work independently and can both be on. Returns the auto-hide checkbox, which the engine
    ; keeps using as chkCareTbar.
    static BuildCareUI(g, lay, darkMode, y, autoHideOn := false) {
        ui := {}
        n := MonitorGetCount()
        items := ["All monitors"]
        Loop n {
            items.Push("Monitor " A_Index (A_Index = MonitorGetPrimary() ? " (primary)" : ""))
        }
        sel := 1
        ui.n := n
        ui.custom := ""
        ui.tips := ["Dim the taskbar on every monitor."]
        Loop n {
            ui.tips.Push(this.MonitorLabel(A_Index))
        }
        if (StrLower(Trim(this.Monitors)) != "all") {
            if (RegExMatch(Trim(this.Monitors), "^\d+$") && Integer(Trim(this.Monitors)) >= 1 && Integer(Trim(this.Monitors)) <= n) {
                sel := Integer(Trim(this.Monitors)) + 1
            } else {
                ui.custom := Trim(this.Monitors)               ; a list typed into settings.ini, e.g. 1,3
                items.Push("Custom (" ui.custom ")")
                ui.tips.Push("Monitor list from settings.ini: " ui.custom)
                sel := n + 2
            }
        }
        ui.chk  := g.AddCheckbox("x" lay.ix " y" y " w" lay.colW " Checked" (this.Enabled ? 1 : 0), "Dim the taskbar")
        ui.auto := g.AddCheckbox("x" lay.c2x " y" y " w" lay.colW " Checked" (autoHideOn ? 1 : 0), "Auto-hide the taskbar in Windows")
        ui.lbl  := g.AddText("x" lay.ix " y" (y + 32) " w72 +0x100", "Dim level")
        ui.sld  := g.AddSlider("x" (lay.ix + 74) " y" (y + 30) " w" (lay.colW - 74 - 50) " NoTicks ToolTip +AltSubmit Range0-100", this.Percent)
        ui.pct  := g.AddText("x" (lay.ix + lay.colW - 46) " y" (y + 32) " w46 +0x100", this.Percent "%")
        ui.lblM := g.AddText("x" lay.c2x " y" (y + 32) " w74 +0x100", "Monitors")
        ui.ddl  := g.AddDDL("x" (lay.c2x + 76) " y" (y + 29) " w" (lay.colW - 76) " r8 Choose" sel, items)
        for c in [ui.chk, ui.auto, ui.lbl, ui.sld, ui.pct, ui.lblM, ui.ddl] {
            StyleControlTheme(c, darkMode)
        }
        RegisterTip(ui.chk, "Makes the Windows taskbar (including the Windows logo) see-through. It becomes fully visible while your mouse is over it and while a game or video is fullscreen. Also works with 'Auto-hide the taskbar': it brightens while you hover it after it slides in, and dims again when you leave.")
        RegisterTip(ui.sld, "How see-through the taskbar gets. 0% = normal, 100% = invisible (shows whatever is behind it, so a black wallpaper gives pure black OLED pixels).")
        RegisterTip(ui.ddl, "Which monitor's taskbar gets dimmed.")

        ; The two toggles are independent: both on = the auto-hidden taskbar appears at the dim level.
        sync := (*) => SetControlsEnabled([ui.lbl, ui.sld, ui.pct, ui.lblM, ui.ddl], !!ui.chk.Value)
        ui.chk.OnEvent("Click", (*) => (sync(), MarkSettingsDirty(), this.Preview()))
        ui.auto.OnEvent("Click", (*) => (sync(), this.Preview()))
        ui.sld.OnEvent("Change", (*) => (
            ui.pct.Text := ui.sld.Value "%",
            DllCall("RedrawWindow", "Ptr", ui.sld.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0101),
            MarkSettingsDirty(),
            this.Preview()
        ))
        ui.ddl.OnEvent("Change", (*) => (MarkSettingsDirty(), this.Preview()))
        ui.ddl.OnCommand(7, (*) => this.StartDdlTip())     ; CBN_DROPDOWN: list opened
        ui.ddl.OnCommand(8, (*) => this.StopDdlTip())      ; CBN_CLOSEUP: list closed
        ; A themed checkbox can repaint itself with Windows' plain tick right after a click; repaint a moment later.
        fix := (*) => (SetTimer(() => this.RepaintToggle(ui.auto, ui.chk), -40), SetTimer(() => this.RepaintToggle(ui.auto, ui.chk), -250))
        ui.auto.OnEvent("Click", fix)
        ui.chk.OnEvent("Click", fix)
        sync()
        this.Ui := ui
        return ui.auto
    }

    ; Same text as the hover tip on the Monitor tabs: "Monitor 2 (Secondary): <real model name> - 2560x1440 @ 240 Hz".
    ; Uses the engine's GetMonitorHoverInfo, so the real EDID name is shown instead of "Generic PnP Monitor".
    static MonitorLabel(idx) {
        txt := ""
        try txt := GetMonitorHoverInfo(idx)
        if (txt = "") {
            txt := "Monitor " idx (idx = MonitorGetPrimary() ? " (primary)" : "")
        }
        return txt
    }

    static StartDdlTip() {
        if !this.DdlTipFn {
            this.DdlTipFn := ObjBindMethod(this, "DdlTipTick")
        }
        SetTimer(this.DdlTipFn, 50)
    }

    static StopDdlTip() {
        if this.DdlTipFn {
            SetTimer(this.DdlTipFn, 0)
        }
        try ToolTip(, , , 19)
    }

    ; While the dropdown list is open: find the entry under the mouse and show its monitor name.
    static DdlTipTick() {
        static lastItem := -2
        ui := this.Ui
        if !IsObject(ui) {
            this.StopDdlTip()
            return
        }
        cbi := Buffer(A_PtrSize = 8 ? 64 : 52, 0)       ; COMBOBOXINFO
        NumPut("UInt", cbi.Size, cbi, 0)
        if !DllCall("GetComboBoxInfo", "Ptr", ui.ddl.Hwnd, "Ptr", cbi.Ptr, "Int") {
            return
        }
        hList := NumGet(cbi, A_PtrSize = 8 ? 56 : 48, "Ptr")
        if (!hList || !DllCall("IsWindowVisible", "Ptr", hList, "Int")) {
            lastItem := -2
            try ToolTip(, , , 19)
            return
        }
        pt := Buffer(8, 0)
        DllCall("GetCursorPos", "Ptr", pt.Ptr)
        sx := NumGet(pt, 0, "Int"), sy := NumGet(pt, 4, "Int")
        DllCall("ScreenToClient", "Ptr", hList, "Ptr", pt.Ptr)
        cx := NumGet(pt, 0, "Int"), cy := NumGet(pt, 4, "Int")
        r := DllCall("SendMessageW", "Ptr", hList, "UInt", 0x1A9, "Ptr", 0, "Ptr", ((cy & 0xFFFF) << 16) | (cx & 0xFFFF), "Ptr")   ; LB_ITEMFROMPOINT
        item := r & 0xFFFF
        outside := (r >> 16) & 0xFFFF
        if (outside || item >= ui.tips.Length) {
            lastItem := -2
            try ToolTip(, , , 19)
            return
        }
        if (item != lastItem) {
            lastItem := item
            CoordMode("ToolTip", "Screen")
            ToolTip(ui.tips[item + 1], sx + 24, sy + 24, 19)
        }
    }

    static RepaintToggle(a, b) {
        for c in [a, b] {
            try {
                if (this.Ui && c.Hwnd) {
                    DllCall("RedrawWindow", "Ptr", c.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0185)   ; INVALIDATE | UPDATENOW | FRAME | ERASE
                }
            }
        }
    }

    ; Live preview while the window is open (not saved until Apply / Save & Close).
    static Preview() {
        ui := this.Ui
        if !IsObject(ui) {
            return
        }
        this.ReadUi(ui)
        this.ApplyRuntime()
    }

    static ReadUi(ui) {
        this.Enabled := !!ui.chk.Value
        this.Percent := Max(0, Min(100, Integer(ui.sld.Value)))
        v := ui.ddl.Value
        if (v <= 1) {
            this.Monitors := "all"
        } else if (v <= ui.n + 1) {
            this.Monitors := String(v - 1)
        } else if (ui.custom != "") {
            this.Monitors := ui.custom
        }
    }

    ; Called by the engine's Apply / Save & Close.
    static ApplyAndSave() {
        ui := this.Ui
        if IsObject(ui) {
            this.ReadUi(ui)
        }
        this.SaveSettings()
        this.ApplyRuntime()
    }

    ; Called when the Settings window closes: drop unsaved preview values.
    static DiscardDraft() {
        this.StopDdlTip()
        this.Ui := 0
        this.LoadSettings()
        this.ApplyRuntime()
    }

    ; ==========================================================================
    ; Main loop
    ; ==========================================================================
    static Tick() {
        static busy := false
        if (busy || !this.running) {
            return
        }
        busy := true
        try {
            this.DoTick()
        } catch as e {
            try DebugLogEvent("Error in taskbar dimming: " e.Message)
        } finally {
            busy := false
        }
    }

    static DoTick() {
        global isSessionLocked
        now := A_TickCount

        if (IsSet(isSessionLocked) && isSessionLocked) {
            this.HideAll()
            return
        }

        resynced := false
        if (now - this.lastSync >= this.SYNC_MS) {
            this.lastSync := now
            this.SyncTaskbars()
            resynced := true                   ; also re-applies the opacity below, in case Explorer reset it
        }
        if (this.States.Count = 0) {
            return
        }

        pt := Buffer(8, 0)
        DllCall("GetCursorPos", "Ptr", pt.Ptr)
        cx := NumGet(pt, 0, "Int"), cy := NumGet(pt, 4, "Int")

        fg := DllCall("GetForegroundWindow", "Ptr")
        fgCls := ""
        if fg {
            try fgCls := WinGetClass("ahk_id " fg)
        }
        fgRect := 0
        if (fg && this.IsTaskbarFlyoutClass(fgCls)) {
            fgRect := Buffer(16, 0)
            if !DllCall("GetWindowRect", "Ptr", fg, "Ptr", fgRect.Ptr) {
                fgRect := 0
            }
        }
        full := Round(255 * this.Percent / 100)      ; how much opacity is taken away at most

        for hwnd, st in this.States {
            ; --- where is the taskbar, and how much of it is actually on screen? ---
            rc := Buffer(16, 0)
            if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rc.Ptr) {
                continue
            }
            tl := NumGet(rc, 0, "Int"), tt := NumGet(rc, 4, "Int"), tr := NumGet(rc, 8, "Int"), tb := NumGet(rc, 12, "Int")
            ml := st.mon[1], mt := st.mon[2], mr := st.mon[3], mb := st.mon[4]
            il := Max(tl, ml), it := Max(tt, mt), ir := Min(tr, mr), ib := Min(tb, mb)
            iw := ir - il, ih := ib - it
            slidAway := (iw < 6 || ih < 6 || !DllCall("IsWindowVisible", "Ptr", hwnd, "Int"))

            hovering := (cx >= il && cx < ir && cy >= it && cy < ib)
            ; The focused window is the taskbar itself or a flyout (Start, tray overflow, jump list) touching this taskbar.
            ; A hidden leftover CoreWindow that merely keeps focus no longer holds the taskbar visible.
            shellFocus := false
            if IsObject(fgRect) {
                fl := NumGet(fgRect, 0, "Int"), ft := NumGet(fgRect, 4, "Int"), fr := NumGet(fgRect, 8, "Int"), fb := NumGet(fgRect, 12, "Int")
                shellFocus := (fr > fl && fb > ft && fl < tr + 16 && fr > tl - 16 && ft < tb + 16 && fb > tt - 16)
            }
            if (hovering || shellFocus) {
                st.clearUntil := now + this.HOVER_RELEASE_MS
            }
            clear := (now < st.clearUntil)
            fullscreen := this.IsFullscreenOnMonitor(fg, fgCls, st)

            ; --- target dim amount and fade (st.cur = opacity currently taken away, 0 .. full) ---
            dt := Max(1, now - st.lastTick)
            st.lastTick := now
            if (fullscreen || (slidAway && !this.AutoHideOn)) {
                st.cur := 0                        ; leave a fullscreen window or a hidden bar completely alone
            } else {
                ; Same hover rule with Windows auto-hide on or off: fully visible while the mouse is over the taskbar (or it has
                ; focus) and for a moment after, then back to the dim level. With auto-hide on, a slid-away bar keeps its fade
                ; state instead of being restored, so it does not flip the window style every time it slides in and out.
                target := clear ? 0 : full
                if (st.cur > target) {
                    st.cur := Max(target, st.cur - Max(1, Round(full * dt / this.FADE_OUT_MS)))
                } else if (st.cur < target) {
                    st.cur := Min(target, st.cur + Max(1, Round(full * dt / this.FADE_IN_MS)))
                }
            }

            if (st.cur <= 0) {
                if (st.applied != -1) {
                    this.RestoreTaskbar(hwnd)      ; back to completely normal (layered style removed again)
                    st.applied := -1
                }
                continue
            }

            ; Keep at least alpha 1 so the taskbar window always stays a valid, hit-testable target.
            alpha := Max(1, 255 - st.cur)
            if (alpha != st.applied || resynced) {
                try WinSetTransparent(alpha, "ahk_id " hwnd)
                st.applied := alpha
            }
        }
    }

    ; ==========================================================================
    ; Taskbar discovery
    ; ==========================================================================
    static SyncTaskbars() {
        this.AutoHideOn := this.QueryAutoHide()
        found := Map()
        for cls in ["Shell_TrayWnd", "Shell_SecondaryTrayWnd"] {
            for hwnd in WinGetList("ahk_class " cls) {
                monIdx := this.MonitorIndexOf(hwnd)
                if (monIdx && this.IsMonitorEnabled(monIdx)) {
                    found[hwnd] := monIdx
                }
            }
        }
        ; drop entries whose taskbar is gone (Explorer restart, monitor unplugged, monitor switched off in the list)
        gone := []
        for hwnd, st in this.States {
            if !found.Has(hwnd) {
                gone.Push(hwnd)
            }
        }
        for hwnd in gone {
            this.DestroyState(hwnd)
        }
        ; add new ones and refresh monitor rectangles
        for hwnd, monIdx in found {
            try MonitorGet(monIdx, &l, &t, &r, &b)
            catch {
                continue
            }
            if this.States.Has(hwnd) {
                this.States[hwnd].mon := [l, t, r, b]
                continue
            }
            this.States[hwnd] := {
                mon: [l, t, r, b], monIdx: monIdx,
                cur: 0, applied: -1,               ; applied = -1: the taskbar is untouched
                clearUntil: 0, lastTick: A_TickCount
            }
        }
    }

    ; True when Windows' "Automatically hide the taskbar" is on (ABM_GETSTATE).
    static QueryAutoHide() {
        abd := Buffer(A_PtrSize = 8 ? 48 : 36, 0)
        NumPut("UInt", abd.Size, abd, 0)
        hwndTray := DllCall("FindWindow", "Str", "Shell_TrayWnd", "Ptr", 0, "Ptr")
        if hwndTray {
            NumPut("Ptr", hwndTray, abd, A_PtrSize)
        }
        return (DllCall("shell32\SHAppBarMessage", "UInt", 0x4, "Ptr", abd.Ptr, "UInt") & 0x1) != 0
    }

    static MonitorIndexOf(hwnd) {
        hMon := DllCall("MonitorFromWindow", "Ptr", hwnd, "UInt", 2, "Ptr")    ; MONITOR_DEFAULTTONEAREST
        if !hMon {
            return 0
        }
        mi := Buffer(40, 0)
        NumPut("UInt", 40, mi, 0)
        if !DllCall("GetMonitorInfoW", "Ptr", hMon, "Ptr", mi.Ptr) {
            return 0
        }
        ml := NumGet(mi, 4, "Int"), mt := NumGet(mi, 8, "Int")
        Loop MonitorGetCount() {
            MonitorGet(A_Index, &l, &t, &r, &b)
            if (l = ml && t = mt) {
                return A_Index
            }
        }
        return 0
    }

    static IsMonitorEnabled(idx) {
        m := StrLower(Trim(this.Monitors))
        if (m = "" || m = "all") {
            return true
        }
        for part in StrSplit(RegExReplace(m, "[^\d]+", ","), ",") {
            if (part != "" && Integer(part) = idx) {
                return true
            }
        }
        return false
    }

    ; ==========================================================================
    ; Clear conditions
    ; ==========================================================================
    ; Focus is on the taskbar itself or one of its flyouts (Start, tray overflow, jump lists).
    static IsTaskbarFlyoutClass(cls) {
        static set := Map(
            "Shell_TrayWnd", 1, "Shell_SecondaryTrayWnd", 1, "XamlExplorerHostPopupWindow", 1,
            "NotifyIconOverflowWindow", 1, "TopLevelWindowForOverflowXamlIsland", 1,
            "Windows.UI.Core.CoreWindow", 1, "#32768", 1
        )
        return (cls != "" && set.Has(cls))
    }

    ; True when the focused window covers the whole monitor of this taskbar (game, video, presentation).
    static IsFullscreenOnMonitor(fg, cls, st) {
        static ignore := Map("Progman", 1, "WorkerW", 1, "Shell_TrayWnd", 1, "Shell_SecondaryTrayWnd", 1)
        if (!fg || cls = "" || ignore.Has(cls)) {
            return false
        }
        try {
            if (WinGetMinMax("ahk_id " fg) = -1) {
                return false
            }
            WinGetPos(&x, &y, &w, &h, "ahk_id " fg)
        } catch {
            return false
        }
        ml := st.mon[1], mt := st.mon[2], mr := st.mon[3], mb := st.mon[4]
        return (x <= ml + 1 && y <= mt + 1 && x + w >= mr - 1 && y + h >= mb - 1
            && x + w <= mr + 24 && y + h <= mb + 24)     ; spans THIS monitor, not a window stretched over several
    }

    ; ==========================================================================
    ; Cleanup helpers
    ; ==========================================================================
    static HideAll() {
        for hwnd, st in this.States {
            st.cur := 0
            if (st.applied != -1) {
                this.RestoreTaskbar(hwnd)
                st.applied := -1
            }
        }
    }

    ; Removes the see-through effect from one taskbar window (back to the normal, non-layered window).
    static RestoreTaskbar(hwnd) {
        ; Step 1: put the opacity back to 255 with the API directly. This works on any window handle (even a hidden
        ; taskbar) and is what actually makes the taskbar look normal again.
        try {
            ex := DllCall("GetWindowLongW", "Ptr", hwnd, "Int", -20, "UInt")
            if (ex & 0x80000) {
                DllCall("SetLayeredWindowAttributes", "Ptr", hwnd, "UInt", 0, "UChar", 255, "UInt", 0x2)
            }
        }
        ; Step 2: remove the layered style again (back to a completely normal window).
        try WinSetTransparent("Off", "ahk_id " hwnd)
    }

    static DestroyState(hwnd) {
        if !this.States.Has(hwnd) {
            return
        }
        st := this.States[hwnd]
        this.States.Delete(hwnd)
        if (st.applied != -1) {
            this.RestoreTaskbar(hwnd)
        }
    }

    static DestroyAll() {
        keys := []
        for hwnd in this.States {
            keys.Push(hwnd)
        }
        for hwnd in keys {
            this.DestroyState(hwnd)
        }
    }
}
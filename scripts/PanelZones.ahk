#Requires AutoHotkey v2.0
; ==============================================================================
; PanelZones.ahk  -  custom per-app dimming zones for OLED Engine
;
;  - Pick any app window, then draw a RECTANGLE or a FREEFORM shape over the part you want protected
;    (a static panel, HUD, sidebar, chat list...). The shape is saved relative to the window, so it follows
;    the window when it is moved, resized, or dragged to another monitor (any DPI).
;  - Every zone has its own settings: Expand (px) per edge, and "clear while the mouse is over it" + return delay.
;  - The zone is covered by a black overlay that sits directly above that app window only.
;  - Settings are stored in config\panel_zones.ini.
;
;  Hooked into OLED Engine with: #Include, PanelZones.Init, a "Zones" Settings tab, ApplyAndSave, DiscardDraft.
; ==============================================================================

class PanelZones {
    ; ---- saved settings ----
    static Enabled     := false
    static DimPct      := 100
    static FadeMs      := 300
    ; each zone: { name, exe, title, shape: "rect"|"free", on, pts: [[fx, fy], ...],
    ;              gl, gt, gr, gb (expand px per edge), hover (bool), delay (seconds) }
    static Zones       := []

    ; ---- draft (what the Settings tab edits until Apply) ----
    static _DEnabled   := false
    static _DDim       := 100
    static _DFade      := 300
    static _DZones     := []

    ; ---- UI ----
    static _Gui        := ""
    static _Ctl        := Map()
    static _Filling    := false
    static _OnDirty    := ""
    static _TipFn      := ""
    static _TipKey     := ""

    ; ---- runtime ----
    static _Run          := ""
    static _Ov           := Map()
    static _ScanTick     := 0
    static _LastTick     := 0
    static _TickMs       := 16    ; how often windows are tracked (16 = ~60 times / s, 50 = 20 times / s)
    static _PreviewUntil := 0
    static _HoldMs       := 86400000    ; "live" preview: stays until Apply / Discard / master switch off
    static _Picking      := false
    static _TickFn       := ""

    ; =========================================================================
    ; 1. Init, load / save
    ; =========================================================================
    static Init(onDirty := "") {
        PanelZones._OnDirty := onDirty
        PanelZones._TickFn  := ObjBindMethod(PanelZones, "_Tick")
        PanelZones._TipFn   := ObjBindMethod(PanelZones, "_TipTick")
        PanelZones.Load()
        PanelZones.DiscardDraft()
        PanelZones._SyncRuntime()
    }

    static _Ini() {
        cfgDir := A_ScriptDir "\config"
        if !DirExist(cfgDir) {
            try DirCreate(cfgDir)
        }
        return cfgDir "\panel_zones.ini"
    }

    static _Int(txt, def, lo, hi) {
        return IsInteger(txt) ? Max(lo, Min(hi, Integer(txt))) : def
    }

    static Load() {
        ini := PanelZones._Ini()
        PanelZones.Enabled := Integer(IniRead(ini, "General", "Enabled", 0)) != 0
        PanelZones.DimPct  := PanelZones._Int(IniRead(ini, "General", "DimPct", 100), 100, 0, 100)
        PanelZones.FadeMs  := PanelZones._Int(IniRead(ini, "General", "FadeMs", 300), 300, 0, 2000)
        ; older versions kept hover / delay as one global value: use it as the default for zones that have none
        legacyHover := PanelZones._Int(IniRead(ini, "General", "HoverClear", 1), 1, 0, 1)
        legacyDelay := PanelZones._Int(IniRead(ini, "General", "ReturnSec", 2), 2, 0, 600)
        zones := []
        cnt := Integer(IniRead(ini, "General", "Count", 0))
        Loop cnt {
            sec := "Zone" A_Index
            exe := Trim(IniRead(ini, sec, "Exe", ""))
            pts := PanelZones._ParsePts(IniRead(ini, sec, "Pts", ""))
            if (exe = "" || pts.Length < 3) {
                continue
            }
            zones.Push({ name: IniRead(ini, sec, "Name", "Zone " A_Index), exe: exe
                , title: IniRead(ini, sec, "Title", "")
                , shape: (IniRead(ini, sec, "Shape", "rect") = "free") ? "free" : "rect"
                , on: Integer(IniRead(ini, sec, "On", 1)) != 0, pts: pts
                , gl: PanelZones._Int(IniRead(ini, sec, "GrowL", 0), 0, -1000, 1000)
                , gt: PanelZones._Int(IniRead(ini, sec, "GrowT", 0), 0, -1000, 1000)
                , gr: PanelZones._Int(IniRead(ini, sec, "GrowR", 0), 0, -1000, 1000)
                , gb: PanelZones._Int(IniRead(ini, sec, "GrowB", 0), 0, -1000, 1000)
                , hover: PanelZones._Int(IniRead(ini, sec, "Hover", legacyHover), 1, 0, 1) != 0
                , delay: PanelZones._Int(IniRead(ini, sec, "Delay", legacyDelay), 2, 0, 600) })
        }
        PanelZones.Zones := zones
    }

    static Save() {
        ini := PanelZones._Ini()
        oldCnt := 0
        try oldCnt := Integer(IniRead(ini, "General", "Count", 0))
        Loop oldCnt {
            try IniDelete(ini, "Zone" A_Index)
        }
        IniWrite(PanelZones.Enabled ? 1 : 0, ini, "General", "Enabled")
        IniWrite(PanelZones.DimPct, ini, "General", "DimPct")
        IniWrite(PanelZones.FadeMs, ini, "General", "FadeMs")
        IniWrite(PanelZones.Zones.Length, ini, "General", "Count")
        for i, z in PanelZones.Zones {
            sec := "Zone" i
            IniWrite(z.name, ini, sec, "Name")
            IniWrite(z.exe, ini, sec, "Exe")
            IniWrite(z.title, ini, sec, "Title")
            IniWrite(z.shape, ini, sec, "Shape")
            IniWrite(z.on ? 1 : 0, ini, sec, "On")
            IniWrite(z.gl, ini, sec, "GrowL")
            IniWrite(z.gt, ini, sec, "GrowT")
            IniWrite(z.gr, ini, sec, "GrowR")
            IniWrite(z.gb, ini, sec, "GrowB")
            IniWrite(z.hover ? 1 : 0, ini, sec, "Hover")
            IniWrite(z.delay, ini, sec, "Delay")
            IniWrite(PanelZones._FormatPts(z.pts), ini, sec, "Pts")
        }
    }

    static _ParsePts(str) {
        pts := []
        for pair in StrSplit(str, ";") {
            xy := StrSplit(pair, ",")
            if (xy.Length = 2 && IsNumber(xy[1]) && IsNumber(xy[2])) {
                pts.Push([Max(0, Min(1, Number(xy[1]))), Max(0, Min(1, Number(xy[2])))])
            }
        }
        return pts
    }

    static _FormatPts(pts) {
        s := ""
        for p in pts {
            s .= (s = "" ? "" : ";") Format("{:.5f}", p[1]) "," Format("{:.5f}", p[2])
        }
        return s
    }

    static _CloneZones(src) {
        out := []
        for z in src {
            pts := []
            for p in z.pts {
                pts.Push([p[1], p[2]])
            }
            out.Push({ name: z.name, exe: z.exe, title: z.title, shape: z.shape, on: z.on, pts: pts
                , gl: z.gl, gt: z.gt, gr: z.gr, gb: z.gb, hover: z.hover, delay: z.delay })
        }
        return out
    }

    static DiscardDraft() {
        PanelZones._StopPreview()
        PanelZones._DEnabled := PanelZones.Enabled
        PanelZones._DDim     := PanelZones.DimPct
        PanelZones._DFade    := PanelZones.FadeMs
        PanelZones._DZones   := PanelZones._CloneZones(PanelZones.Zones)
        PanelZones._Gui := ""
        PanelZones._Ctl := Map()
        if IsObject(PanelZones._TipFn) {
            SetTimer(PanelZones._TipFn, 0)
        }
        ToolTip(, , , 4)
    }

    static ApplyAndSave() {
        PanelZones.Enabled := PanelZones._DEnabled
        PanelZones.DimPct  := PanelZones._DDim
        PanelZones.FadeMs  := PanelZones._DFade
        PanelZones.Zones   := PanelZones._CloneZones(PanelZones._DZones)
        PanelZones.Save()
        PanelZones._PreviewUntil := 0
        PanelZones._ClearOverlays()
        PanelZones._SyncRuntime()
    }

    static _SyncRuntime() {
        PanelZones._Run := { on: PanelZones.Enabled, dim: PanelZones.DimPct, fade: PanelZones.FadeMs
            , zones: PanelZones._CloneZones(PanelZones.Zones) }
        PanelZones._EnsureTimer()
    }

    static _EnsureTimer() {
        run := PanelZones._Run
        if (IsObject(run) && (run.on || PanelZones._PreviewUntil)) {
            SetTimer(PanelZones._TickFn, PanelZones._TickMs)
        } else {
            SetTimer(PanelZones._TickFn, 0)
            PanelZones._ClearOverlays()
        }
    }

    static _Dirty() {
        if IsObject(PanelZones._OnDirty) {
            try PanelZones._OnDirty.Call()
        }
    }

    ; =========================================================================
    ; 2. Live tracking + overlay rendering (one 50 ms timer, only runs when needed)
    ; =========================================================================
    static Preview(ms := 3000) {
        if !PanelZones._DEnabled {
            return
        }
        zs := PanelZones._CloneZones(PanelZones._DZones)
        for z in zs {
            z.on := true
        }
        PanelZones._Run := { on: true, dim: PanelZones._DDim, fade: PanelZones._DFade, zones: zs }
        PanelZones._ClearOverlays()
        PanelZones._PreviewUntil := A_TickCount + ms
        PanelZones._EnsureTimer()
    }

    static _Tick() {
        global isSessionLocked, isAutomationPaused
        run := PanelZones._Run
        if !IsObject(run) {
            SetTimer(PanelZones._TickFn, 0)
            return
        }
        now := A_TickCount
        if (PanelZones._PreviewUntil && now >= PanelZones._PreviewUntil) {
            PanelZones._PreviewUntil := 0
            PanelZones._ClearOverlays()
            PanelZones._SyncRuntime()
            return
        }
        preview := (PanelZones._PreviewUntil != 0)
        if (!run.on && !preview) {
            SetTimer(PanelZones._TickFn, 0)
            PanelZones._ClearOverlays()
            return
        }
        if (PanelZones._Picking || (IsSet(isSessionLocked) && isSessionLocked)) {
            PanelZones._ClearOverlays()
            return
        }
        blocked := false
        if !preview {
            blocked := IsSet(isAutomationPaused) && isAutomationPaused
            if !blocked {
                try blocked := !!IsExcludedProcessRunning()
            }
        }
        dt := PanelZones._LastTick ? Max(1, Min(250, now - PanelZones._LastTick)) : 50
        PanelZones._LastTick := now

        Critical "On"
        oldCtx := DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")
        try {
            if (now - PanelZones._ScanTick >= 500) {
                PanelZones._ScanTick := now
                PanelZones._Scan(run)
            }
            if (PanelZones._Ov.Count = 0) {
                return
            }
            pt := Buffer(8, 0)
            DllCall("GetCursorPos", "Ptr", pt)
            cx := NumGet(pt, 0, "Int")
            cy := NumGet(pt, 4, "Int")
            under := DllCall("WindowFromPoint", "Int64", NumGet(pt, 0, "Int64"), "Ptr")
            underRoot  := under ? DllCall("GetAncestor", "Ptr", under, "UInt", 2, "Ptr") : 0
            underOwner := under ? DllCall("GetAncestor", "Ptr", under, "UInt", 3, "Ptr") : 0
            full := Round(Max(0, Min(100, run.dim)) * 2.55)
            step := (run.fade <= 0) ? 255 : Max(1, Round(255 * dt / run.fade))

            for key, e in PanelZones._Ov {
                try {
                    if blocked {
                        e.alpha := Max(0, e.alpha - step)
                        PanelZones._Place(e)
                        continue
                    }
                    rc := PanelZones._WinRect(e.hwnd)
                    if !rc {
                        e.alpha := 0
                        PanelZones._Place(e)
                        continue
                    }
                    PanelZones._Layout(e, rc)
                    ; per-zone "clear while the mouse is over it"
                    inZone := e.z.hover && (underRoot = e.hwnd || underOwner = e.hwnd) && PanelZones._PtInPoly(cx, cy, e.abs)
                    if inZone {
                        e.last := now
                    }
                    awake := inZone || (e.z.hover && e.last && (now - e.last) < e.z.delay * 1000)
                    target := awake ? 0 : full
                    if (e.alpha < target) {
                        e.alpha := Min(target, e.alpha + step)
                    } else if (e.alpha > target) {
                        e.alpha := Max(target, e.alpha - step)
                    }
                    PanelZones._Place(e)
                }
            }
        } finally {
            if oldCtx {
                DllCall("SetThreadDpiAwarenessContext", "Ptr", oldCtx, "Ptr")
            }
            Critical "Off"
        }
    }

    ; Finds the windows each zone belongs to; creates / removes overlays
    static _Scan(run) {
        seen := Map()
        for idx, z in run.zones {
            if !z.on {
                continue
            }
            for hwnd in WinGetList("ahk_exe " z.exe) {
                if !PanelZones._IsMainWindow(hwnd, z) {
                    continue
                }
                key := idx "|" hwnd
                seen[key] := true
                if !PanelZones._Ov.Has(key) {
                    try PanelZones._Ov[key] := PanelZones._Create(hwnd, z)
                }
            }
        }
        dead := []
        for key, e in PanelZones._Ov {
            if !seen.Has(key) {
                dead.Push(key)
            }
        }
        for key in dead {
            try PanelZones._Ov[key].ov.Destroy()
            PanelZones._Ov.Delete(key)
        }
    }

    static _IsMainWindow(hwnd, z) {
        if !DllCall("IsWindowVisible", "Ptr", hwnd, "Int") {
            return false
        }
        if DllCall("GetWindow", "Ptr", hwnd, "UInt", 4, "Ptr") {        ; owned popup / dialog
            return false
        }
        ex := DllCall("GetWindowLongPtr", "Ptr", hwnd, "Int", -20, "Ptr")
        if ((ex & 0x80) && !(ex & 0x40000)) {                            ; tool window without app-window flag
            return false
        }
        rc := Buffer(16, 0)
        if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rc, "Int") {
            return false
        }
        if (NumGet(rc, 8, "Int") - NumGet(rc, 0, "Int") < 120 || NumGet(rc, 12, "Int") - NumGet(rc, 4, "Int") < 80) {
            return false
        }
        if (z.title != "" && !InStr(WinGetTitle(hwnd), z.title)) {
            return false
        }
        return true
    }

    static _Create(hwnd, z) {
        oldCtx := DllCall("SetThreadDpiAwarenessContext", "Ptr", -4, "Ptr")
        try {
            ov := Gui("-Caption +ToolWindow -DPIScale +E0x20 +E0x80000 +E0x08000000")
            ov.BackColor := "000000"
            DllCall("SetLayeredWindowAttributes", "Ptr", ov.Hwnd, "UInt", 0, "UChar", 0, "UInt", 2)
            DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", ov.Hwnd, "UInt", 3, "Int*", 1, "UInt", 4)    ; no show / hide animation
        } finally {
            if oldCtx {
                DllCall("SetThreadDpiAwarenessContext", "Ptr", oldCtx, "Ptr")
            }
        }
        return { hwnd: hwnd, ov: ov, z: z, alpha: 0, shownAlpha: -1, shown: false, last: 0
            , x: 0, y: 0, w: 1, h: 1, gx: 0, gy: 0, gw: 0, gh: 0
            , key: "", winW: 0, winH: 0, rgnPending: true, abs: [] }
    }

    ; Visible frame of the window in physical pixels; 0 = nothing to cover (minimized, hidden, cloaked)
    static _WinRect(hwnd) {
        if (!DllCall("IsWindowVisible", "Ptr", hwnd, "Int") || DllCall("IsIconic", "Ptr", hwnd, "Int")) {
            return 0
        }
        cloaked := 0
        DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 14, "UInt*", &cloaked, "UInt", 4)
        if cloaked {
            return 0
        }
        rc := Buffer(16, 0)
        if (DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", hwnd, "UInt", 9, "Ptr", rc, "UInt", 16, "Int") != 0) {
            if !DllCall("GetWindowRect", "Ptr", hwnd, "Ptr", rc, "Int") {
                return 0
            }
        }
        l := NumGet(rc, 0, "Int"), t := NumGet(rc, 4, "Int"), r := NumGet(rc, 8, "Int"), b := NumGet(rc, 12, "Int")
        if (r - l < 20 || b - t < 20) {
            return 0
        }
        return { l: l, t: t, r: r, b: b }
    }

    ; Converts the saved window-relative shape (fractions) into screen pixels for the window's current rect,
    ; then applies the zone's own Expand values (left / top / right / bottom, in pixels).
    ; Rectangles expand exactly. For freeform shapes, the points sitting on an outer edge (within 3 px) move outward.
    static _Layout(e, rc) {
        w := rc.r - rc.l
        h := rc.b - rc.t
        key := rc.l "," rc.t "," w "," h
        if (key = e.key) {
            return
        }
        e.key := key
        if (w != e.winW || h != e.winH) {
            e.winW := w
            e.winH := h
            e.rgnPending := true
        }
        z := e.z
        base := []
        minX := 0x7FFFFFFF, minY := 0x7FFFFFFF, maxX := -0x7FFFFFFF, maxY := -0x7FFFFFFF
        for p in z.pts {
            ax := rc.l + Round(p[1] * w)
            ay := rc.t + Round(p[2] * h)
            base.Push([ax, ay])
            minX := Min(minX, ax), maxX := Max(maxX, ax)
            minY := Min(minY, ay), maxY := Max(maxY, ay)
        }
        tol := (z.shape = "free") ? 3 : 0
        abs := []
        minX2 := 0x7FFFFFFF, minY2 := 0x7FFFFFFF, maxX2 := -0x7FFFFFFF, maxY2 := -0x7FFFFFFF
        for p in base {
            ax := p[1]
            ay := p[2]
            if (ax <= minX + tol) {
                ax -= z.gl
            }
            if (ax >= maxX - tol) {
                ax += z.gr
            }
            if (ay <= minY + tol) {
                ay -= z.gt
            }
            if (ay >= maxY - tol) {
                ay += z.gb
            }
            abs.Push([ax, ay])
            minX2 := Min(minX2, ax), maxX2 := Max(maxX2, ax)
            minY2 := Min(minY2, ay), maxY2 := Max(maxY2, ay)
        }
        e.abs := abs
        e.x := minX2
        e.y := minY2
        e.w := Max(1, maxX2 - minX2)
        e.h := Max(1, maxY2 - minY2)
    }

    static _Place(e) {
        ovHwnd := e.ov.Hwnd
        if (e.alpha <= 0) {
            if e.shown {
                DllCall("ShowWindow", "Ptr", ovHwnd, "Int", 0)
                e.shown := false
            }
            return
        }
        ; Owned by the app window: Windows keeps the overlay directly above it and never puts the app in front on click
        if (DllCall("GetWindowLongPtr", "Ptr", ovHwnd, "Int", -8, "Ptr") != e.hwnd) {
            DllCall("SetWindowLongPtr", "Ptr", ovHwnd, "Int", -8, "Ptr", e.hwnd, "Ptr")
            e.shown := false
        }
        if (e.alpha != e.shownAlpha) {
            DllCall("SetLayeredWindowAttributes", "Ptr", ovHwnd, "UInt", 0, "UChar", e.alpha, "UInt", 2)
            e.shownAlpha := e.alpha
        }
        prev := DllCall("GetWindow", "Ptr", e.hwnd, "UInt", 3, "Ptr")
        changed := (!e.shown || e.gx != e.x || e.gy != e.y || e.gw != e.w || e.gh != e.h)
        if (!changed && prev = ovHwnd && !e.rgnPending) {
            return
        }
        flags := 0x0050        ; SWP_NOACTIVATE | SWP_SHOWWINDOW
        after := 0
        if (prev = ovHwnd) {
            flags |= 0x0004    ; SWP_NOZORDER
        } else if prev {
            after := prev
        } else if (DllCall("GetWindowLongPtr", "Ptr", e.hwnd, "Int", -20, "Ptr") & 0x8) {
            after := -1        ; app is AlwaysOnTop
        }
        DllCall("SetWindowPos", "Ptr", ovHwnd, "Ptr", after, "Int", e.x, "Int", e.y, "Int", e.w, "Int", e.h, "UInt", flags)
        if (e.z.shape = "free" && (e.rgnPending || changed)) {
            PanelZones._ApplyRegion(e)
        }
        e.rgnPending := false
        e.shown := true
        e.gx := e.x
        e.gy := e.y
        e.gw := e.w
        e.gh := e.h
    }

    ; Clips the overlay to the freeform polygon
    static _ApplyRegion(e) {
        n := e.abs.Length
        if (n < 3) {
            return
        }
        buf := Buffer(8 * n, 0)
        for i, p in e.abs {
            ; GDI polygon regions leave out the right / bottom edge: push those points 1 px out so the edge is covered
            NumPut("Int", p[1] - e.x + (p[1] = e.x + e.w ? 1 : 0), buf, (i - 1) * 8)
            NumPut("Int", p[2] - e.y + (p[2] = e.y + e.h ? 1 : 0), buf, (i - 1) * 8 + 4)
        }
        rgn := DllCall("gdi32\CreatePolygonRgn", "Ptr", buf, "Int", n, "Int", 2, "Ptr")    ; 2 = WINDING
        if rgn {
            DllCall("user32\SetWindowRgn", "Ptr", e.ov.Hwnd, "Ptr", rgn, "Int", 1)        ; Windows owns the region now
        }
    }

    static _PtInPoly(x, y, pts) {
        n := pts.Length
        if (n < 3) {
            return false
        }
        inside := false
        j := n
        Loop n {
            i := A_Index
            xi := pts[i][1], yi := pts[i][2], xj := pts[j][1], yj := pts[j][2]
            if ((yi > y) != (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi) {
                inside := !inside
            }
            j := i
        }
        return inside
    }

    static _ClearOverlays() {
        for key, e in PanelZones._Ov {
            try e.ov.Destroy()
        }
        PanelZones._Ov := Map()
    }

    ; =========================================================================
    ; 3. Picker: choose a window, isolate it, draw a rectangle or a freeform shape
    ; =========================================================================
    static AddZoneFlow() {
        if (PanelZones._Picking || !PanelZones._DEnabled) {
            return
        }
        g := PanelZones._Gui
        PanelZones._Picking := true
        PanelZones._ClearOverlays()
        ToolTip(, , , 4)
        if IsObject(g) {
            try g.Hide()
        }
        zone := ""
        try {
            Sleep(250)
            hwnd := PanelZones._PickWindow()
            if hwnd {
                zone := PanelZones._DrawOnWindow(hwnd)
            }
        } catch as err {
            MsgBox("The zone picker stopped: " err.Message, "Panel Zones", 0x10)
        }
        PanelZones._Picking := false
        if IsObject(g) {
            try {
                g.Show()
                WinActivate("ahk_id " g.Hwnd)
            }
        }
        if IsObject(zone) {
            PanelZones._DZones.Push(zone)
            PanelZones._FillList(PanelZones._DZones.Length)
            PanelZones._Dirty()
            PanelZones.Preview(PanelZones._HoldMs)
        }
    }

    ; Step 1: hover highlights a window, click selects it. The click is swallowed, so the app never receives it.
    static _PickWindow() {
        ownPid := DllCall("GetCurrentProcessId", "UInt")
        hl := Gui("-Caption +ToolWindow +AlwaysOnTop -DPIScale +E0x20 +E0x80000 +E0x08000000")
        hl.BackColor := "2F6BFF"
        DllCall("SetLayeredWindowAttributes", "Ptr", hl.Hwnd, "UInt", 0, "UChar", 90, "UInt", 2)
        res := { hwnd: 0, done: false }
        isValid := (w) => (w && DllCall("IsWindow", "Ptr", w, "Int") && WinGetPID("ahk_id " w) != ownPid
            && !(WinGetClass("ahk_id " w) ~= "^(Progman|WorkerW|Shell_TrayWnd|Shell_SecondaryTrayWnd)$"))
        clickFn := (*) => (MouseGetPos(, , &w), isValid(w) ? (res.hwnd := w, res.done := true) : 0)
        stopFn  := (*) => (res.done := true)
        Hotkey("*LButton", clickFn, "On")
        Hotkey("*RButton", stopFn, "On")
        Hotkey("Escape", stopFn, "On")
        lastKey := ""
        try {
            while !res.done {
                MouseGetPos(, , &w)
                rc := isValid(w) ? PanelZones._WinRect(w) : 0
                if rc {
                    k := rc.l "," rc.t "," rc.r "," rc.b
                    if (k != lastKey) {
                        lastKey := k
                        hl.Show("x" rc.l " y" rc.t " w" (rc.r - rc.l) " h" (rc.b - rc.t) " NA")
                    }
                } else if (lastKey != "") {
                    lastKey := ""
                    hl.Hide()
                }
                ToolTip("Click the window to add a zone to.`nEsc or right-click = cancel")
                Sleep(15)
            }
        } finally {
            try Hotkey("*LButton", "Off")
            try Hotkey("*RButton", "Off")
            try Hotkey("Escape", "Off")
            ToolTip()
            try hl.Destroy()
        }
        if res.hwnd {
            KeyWait("LButton")
        }
        return res.hwnd
    }

    ; Step 2: a drawing layer sits exactly over the chosen window and captures all mouse input,
    ; so nothing underneath can be clicked or changed while you draw.
    static _DrawOnWindow(hwnd) {
        exe := WinGetProcessName("ahk_id " hwnd)
        try WinActivate("ahk_id " hwnd)
        Sleep(250)
        rc := PanelZones._WinRect(hwnd)
        if !rc {
            MsgBox("That window can't be used right now (minimized or hidden).", "Panel Zones", 0x30)
            return ""
        }
        w := rc.r - rc.l
        h := rc.b - rc.t

        ov := Gui("-Caption +AlwaysOnTop +ToolWindow -DPIScale +E0x08000000")    ; never takes focus, so it cannot cover the toolbar
        ov.BackColor := "202020"
        ov.Show("x" rc.l " y" rc.t " w" w " h" h " NA")
        WinSetTransparent(130, "ahk_id " ov.Hwnd)

        tb := Gui("+AlwaysOnTop +ToolWindow", "Draw zone - " exe)
        tb.SetFont("s9", "Segoe UI")
        tb.AddText("w430", "Drag over the window to mark the area to dim.`nFreeform: hold and trace the shape. Right-click clears the shape.`nEnter = save, Esc = cancel.")
        rbRect := tb.AddRadio("xm w110 Checked", "Rectangle")
        rbFree := tb.AddRadio("x+10 w110", "Freeform")
        btnClear := tb.AddButton("x+20 w70", "Clear")
        btnDone  := tb.AddButton("x+8 w70 Default", "Done")
        btnCancel := tb.AddButton("x+8 w70", "Cancel")

        st := { pts: [], free: false, drag: false, have: false, done: false, ok: false, x0: 0, y0: 0, x1: 0, y1: 0 }
        doneFn   := (*) => (st.have ? (st.ok := true, st.done := true) : ToolTip("Draw an area first", , , 2))
        cancelFn := (*) => (st.done := true)
        clearFn  := (*) => (st.have := false, st.drag := false, st.pts := [])
        btnDone.OnEvent("Click", doneFn)
        btnCancel.OnEvent("Click", cancelFn)
        btnClear.OnEvent("Click", clearFn)
        tb.OnEvent("Close", cancelFn)
        cursorFn := (wParam, lParam, msg, hWnd) => PanelZones._CrossCursor(hWnd, ov.Hwnd)
        OnMessage(0x20, cursorFn)
        Hotkey("Enter", doneFn, "On")
        Hotkey("Escape", cancelFn, "On")

        try {
            ; place the toolbar above the window if there is room, otherwise inside its top edge
            tb.Show("NA")
            tb.GetPos(, , &tbW, &tbH)
            tx := rc.l + Max(0, (w - tbW) // 2)
            ty := (rc.t - tbH - 8 >= 0) ? rc.t - tbH - 8 : rc.t + 8
            WinMove(tx, ty, , , "ahk_id " tb.Hwnd)

            prevL := false
            lastRaise := 0
            while !st.done {
                ; keep the toolbar above the drawing layer at all times
                if (A_TickCount - lastRaise >= 100) {
                    DllCall("SetWindowPos", "Ptr", tb.Hwnd, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)    ; TOPMOST | NOMOVE | NOSIZE | NOACTIVATE
                    lastRaise := A_TickCount
                }
                pt := Buffer(8, 0)
                DllCall("GetCursorPos", "Ptr", pt)
                cx := NumGet(pt, 0, "Int")
                cy := NumGet(pt, 4, "Int")
                lDown := GetKeyState("LButton", "P")
                if (lDown && !prevL) {
                    MouseGetPos(, , &under)
                    if (under = ov.Hwnd) {
                        st.drag := true
                        st.free := !!rbFree.Value
                        st.x0 := PanelZones._Snap(cx - rc.l, w)
                        st.y0 := PanelZones._Snap(cy - rc.t, h)
                        st.x1 := st.x0
                        st.y1 := st.y0
                        st.pts := [[st.x0, st.y0]]
                        st.have := false
                    }
                }
                if (lDown && st.drag) {
                    rx := PanelZones._Snap(cx - rc.l, w)
                    ry := PanelZones._Snap(cy - rc.t, h)
                    st.x1 := rx
                    st.y1 := ry
                    if st.free {
                        last := st.pts[st.pts.Length]
                        if (Abs(rx - last[1]) + Abs(ry - last[2]) >= 4 && st.pts.Length < 800) {
                            st.pts.Push([rx, ry])
                        }
                    }
                }
                if (!lDown && prevL && st.drag) {
                    st.drag := false
                    st.have := st.free ? (st.pts.Length >= 3) : (Abs(st.x1 - st.x0) >= 4 && Abs(st.y1 - st.y0) >= 4)
                }
                if GetKeyState("RButton", "P") {
                    st.have := false
                    st.drag := false
                    st.pts := []
                }
                PanelZones._Paint(ov.Hwnd, w, h, st)
                prevL := lDown
                Sleep(12)
            }
        } finally {
            try Hotkey("Enter", "Off")
            try Hotkey("Escape", "Off")
            OnMessage(0x20, cursorFn, 0)
            ToolTip(, , , 2)
            try tb.Destroy()
            try ov.Destroy()
        }
        if (!st.ok || !st.have) {
            return ""
        }

        pts := []
        if st.free {
            for p in st.pts {
                pts.Push([Max(0, Min(1, p[1] / w)), Max(0, Min(1, p[2] / h))])
            }
        } else {
            l := Min(st.x0, st.x1) / w, r := Max(st.x0, st.x1) / w
            t := Min(st.y0, st.y1) / h, b := Max(st.y0, st.y1) / h
            pts := [[l, t], [r, t], [r, b], [l, b]]
        }
        n := 1
        for z in PanelZones._DZones {
            if (z.exe = exe) {
                n += 1
            }
        }
        defName := RegExReplace(exe, "i)\.exe$") " zone " n
        ib := InputBox("Name for this zone:", "Panel Zones", "w320 h130", defName)
        name := (ib.Result = "OK" && Trim(ib.Value) != "") ? Trim(ib.Value) : defName
        return { name: name, exe: exe, title: "", shape: st.free ? "free" : "rect", on: true, pts: pts
            , gl: 0, gt: 0, gr: 0, gb: 0, hover: true, delay: 2 }
    }

    ; The cursor can never sit on the very last pixel (max = size - 1), so anything within 2 px of an edge snaps to the edge
    static _Snap(v, size) {
        if (v <= 2) {
            return 0
        }
        if (v >= size - 3) {
            return size
        }
        return v
    }

    static _CrossCursor(msgHwnd, ovHwnd) {
        if (msgHwnd = ovHwnd) {
            DllCall("SetCursor", "Ptr", DllCall("LoadCursorW", "Ptr", 0, "Ptr", 32515, "Ptr"), "Ptr")    ; IDC_CROSS
            return 1
        }
    }

    ; Double-buffered GDI paint of the live shape on the drawing layer
    static _Paint(hwnd, w, h, st) {
        hdc := DllCall("GetDC", "Ptr", hwnd, "Ptr")
        if !hdc {
            return
        }
        mdc := DllCall("gdi32\CreateCompatibleDC", "Ptr", hdc, "Ptr")
        bmp := DllCall("gdi32\CreateCompatibleBitmap", "Ptr", hdc, "Int", w, "Int", h, "Ptr")
        oldBmp := DllCall("gdi32\SelectObject", "Ptr", mdc, "Ptr", bmp, "Ptr")
        bg := DllCall("gdi32\CreateSolidBrush", "UInt", 0x202020, "Ptr")
        rcBuf := Buffer(16, 0)
        NumPut("Int", w, rcBuf, 8)
        NumPut("Int", h, rcBuf, 12)
        DllCall("user32\FillRect", "Ptr", mdc, "Ptr", rcBuf, "Ptr", bg)
        DllCall("gdi32\DeleteObject", "Ptr", bg)

        if (st.drag || st.have) {
            pts := []
            if st.free {
                pts := st.pts
            } else {
                l := Min(st.x0, st.x1), r := Max(st.x0, st.x1), t := Min(st.y0, st.y1), b := Max(st.y0, st.y1)
                pts := [[l, t], [r, t], [r, b], [l, b]]
            }
            n := pts.Length
            if (n >= 2) {
                buf := Buffer(8 * n, 0)
                for i, p in pts {
                    NumPut("Int", p[1], buf, (i - 1) * 8)
                    NumPut("Int", p[2], buf, (i - 1) * 8 + 4)
                }
                fill := DllCall("gdi32\CreateSolidBrush", "UInt", 0x2F6BFF, "Ptr")
                pen  := DllCall("gdi32\CreatePen", "Int", 0, "Int", 2, "UInt", 0xFFFFFF, "Ptr")
                oldBr := DllCall("gdi32\SelectObject", "Ptr", mdc, "Ptr", fill, "Ptr")
                oldPn := DllCall("gdi32\SelectObject", "Ptr", mdc, "Ptr", pen, "Ptr")
                DllCall("gdi32\SetPolyFillMode", "Ptr", mdc, "Int", 2)
                DllCall("gdi32\Polygon", "Ptr", mdc, "Ptr", buf, "Int", n)
                DllCall("gdi32\SelectObject", "Ptr", mdc, "Ptr", oldBr)
                DllCall("gdi32\SelectObject", "Ptr", mdc, "Ptr", oldPn)
                DllCall("gdi32\DeleteObject", "Ptr", fill)
                DllCall("gdi32\DeleteObject", "Ptr", pen)
            }
        }
        DllCall("gdi32\BitBlt", "Ptr", hdc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", mdc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)
        DllCall("gdi32\SelectObject", "Ptr", mdc, "Ptr", oldBmp)
        DllCall("gdi32\DeleteObject", "Ptr", bmp)
        DllCall("gdi32\DeleteDC", "Ptr", mdc)
        DllCall("user32\ReleaseDC", "Ptr", hwnd, "Ptr", hdc)
    }

    ; =========================================================================
    ; 4. Settings tab ("Zones")  -  call between tabs.UseTab(idx) and the next tab
    ; =========================================================================
    static BuildTab(g, dark) {
        global SettingsLayout
        lay := SettingsLayout
        PanelZones._Gui := g
        PanelZones._Ctl := Map()
        ctl := PanelZones._Ctl
        ctl["dark"] := dark

        chkOn := g.AddCheckbox("x" lay.bx " y46 w" (lay.bw - 8) " Checked" (PanelZones._DEnabled ? 1 : 0), "Dim custom zones on chosen app windows")
        StyleControlTheme(chkOn, dark)
        chkOn.SetFont("s9.5 bold " (dark ? "cFFFFFF" : "c000000"), "Segoe UI")

        ; ---- zone table (fixed columns, everything visible at a glance) ----
        secZones := AddSectionBox(g, lay.bx, 72, lay.bw, 152, "Zones", dark)
        lv := g.AddListView("x" lay.ix " y96 w" lay.iw " h94 -Multi -HScroll NoSortHdr Grid Checked", ["Name", "App", "Shape", "Expand L/R/T/B", "Hover"])
        StyleControlTheme(lv, dark)
        usable := lay.iw - 24
        c1 := Round(usable * 0.27), c2 := Round(usable * 0.22), c3 := Round(usable * 0.13), c4 := Round(usable * 0.24)
        lv.ModifyCol(1, c1)
        lv.ModifyCol(2, c2)
        lv.ModifyCol(3, c3)
        lv.ModifyCol(4, c4)
        lv.ModifyCol(5, "AutoHdr")    ; last column fills whatever is left, so no empty strip
        ; HDS_NOSIZING: the column dividers can't be dragged
        hdr := SendMessage(0x101F, 0, 0, lv)
        if hdr {
            style := DllCall("GetWindowLongPtr", "Ptr", hdr, "Int", -16, "Ptr")
            DllCall("SetWindowLongPtr", "Ptr", hdr, "Int", -16, "Ptr", style | 0x0800)
        }
        btnAdd  := g.AddButton("x" lay.ix " y194 w120 h26", "Add Zone...")
        btnDel  := g.AddButton("x+8 yp w90 h26", "Remove")
        btnTest := g.AddButton("x+8 yp w120 h26", "Preview (3 s)")
        for b in [btnAdd, btnDel, btnTest] {
            StyleControlTheme(b, dark)
        }
        ctl["lv"] := lv

        ; ---- per-zone settings (for the selected row) ----
        secSel := AddSectionBox(g, lay.bx, 232, lay.bw, 118, "Selected Zone  -  Expand edges (px)", dark)
        gw := lay.iw // 4
        grow := Map()
        growCtrls := []
        for i, def in [["gl", "Left"], ["gr", "Right"], ["gt", "Top"], ["gb", "Bottom"]] {
            gx := lay.ix + (i - 1) * gw
            lbl := g.AddText("x" gx " y259 w44 +0x100", def[2])
            edt := g.AddEdit("x" (gx + 46) " y256 w52")
            ud  := g.AddUpDown("+0x80 Range-1000-1000", 0)
            StyleControlTheme(lbl, dark)
            StyleControlTheme(edt, dark)
            grow[def[1]] := edt
            growCtrls.Push(lbl, edt, ud)
            RegisterTip(edt, "Pixels this zone is pushed outward on its " StrLower(def[2]) " edge (negative values shrink it). The change shows live on the window.")
            edt.OnEvent("Change", ObjBindMethod(PanelZones, "_OnGrow", def[1]))
        }
        chkHover := g.AddCheckbox("x" lay.ix " y292 w" (lay.iw - 200), "Clear this zone while the mouse is over it")
        tDelay := g.AddText("x" (lay.ix + lay.iw - 190) " y294 w116 +0x100", "Dim again after (s)")
        edtDelay := g.AddEdit("x" (lay.ix + lay.iw - 68) " y291 w52 Number Limit3")
        udDelay := g.AddUpDown("+0x80 Range0-600", 2)
        txtSel := g.AddText("x" lay.ix " y322 w" lay.iw " +0x100", "")
        for c in [chkHover, tDelay, edtDelay] {
            StyleControlTheme(c, dark)
        }
        StyleControlTheme(txtSel, dark, true)
        RegisterTip(chkHover, "On: the dim of this zone clears while the mouse is inside it and returns after the delay.")
        RegisterTip(edtDelay, "Seconds after the mouse leaves before this zone dims again.")
        chkHover.OnEvent("Click", (*) => PanelZones._OnHover())
        edtDelay.OnEvent("Change", (*) => PanelZones._OnDelay())
        ctl["grow"] := grow
        ctl["chkHover"] := chkHover
        ctl["edtDelay"] := edtDelay
        ctl["txtSel"] := txtSel

        ; ---- global dim level / fade ----
        secDim := AddSectionBox(g, lay.bx, 358, lay.bw, 90, "Dim Level && Fade (all zones)", dark)
        tLvl := g.AddText("x" lay.ix " y386 w" lay.dLblW " +0x100", "Dim Level")
        sldDim := g.AddSlider("x" lay.dSldX " y384 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-100", PanelZones._DDim)
        txtDim := g.AddText("x" (lay.dSldX + lay.dSldW + 6) " y386 w50 +0x100", PanelZones._DDim "%")
        tFade := g.AddText("x" lay.ix " y416 w" lay.dLblW " +0x100", "Fade (ms)")
        sldFade := g.AddSlider("x" lay.dSldX " y414 w" lay.dSldW " NoTicks ToolTip +AltSubmit Range0-2000", PanelZones._DFade)
        txtFade := g.AddText("x" (lay.dSldX + lay.dSldW + 6) " y416 w60 +0x100", PanelZones._DFade)
        for c in [tLvl, txtDim, tFade, txtFade, sldDim, sldFade] {
            StyleControlTheme(c, dark)
        }
        txtHelp := g.AddText("x" lay.ix " y456 w" lay.iw " +0x100", "Add Zone: click an app window, then drag a rectangle or trace a freeform shape over the area to protect.")
        StyleControlTheme(txtHelp, dark, true)

        RegisterTip(chkOn, "Master switch for custom zones. Click Apply or Save & Close to use your changes.")
        RegisterTip(btnAdd, "Click an app window to isolate it, then draw a rectangle or freeform shape over the static area. The zone follows that window everywhere.")
        RegisterTip(btnDel, "Removes the selected zone.")
        RegisterTip(btnTest, "Shows every zone for 3 seconds using the values on this page, even before you click Apply.")
        RegisterTip(sldDim, "How dark the zones get. 100% is pure black (#000000).")
        RegisterTip(sldFade, "Fade-in and fade-out time in milliseconds (0 = instant).")

        ; ---- events ----
        chkOn.OnEvent("Click", (c, *) => (PanelZones._DEnabled := !!c.Value, PanelZones._ApplyEnabled(), (PanelZones._DEnabled ? PanelZones._LiveRefresh() : PanelZones._StopPreview()), PanelZones._Dirty()))
        redraw := (c) => DllCall("RedrawWindow", "Ptr", c.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0101)
        sldDim.OnEvent("Change", (c, *) => (PanelZones._DDim := c.Value, txtDim.Text := c.Value "%", redraw(c), PanelZones._LiveRefresh(), PanelZones._Dirty()))
        sldFade.OnEvent("Change", (c, *) => (PanelZones._DFade := c.Value, txtFade.Text := c.Value, redraw(c), PanelZones._LiveRefresh(), PanelZones._Dirty()))
        lv.OnEvent("ItemCheck", (c, item, checked) => PanelZones._OnCheck(item, checked))
        lv.OnEvent("ItemSelect", (c, item, selected) => PanelZones._OnSelect())
        btnAdd.OnEvent("Click", (*) => PanelZones.AddZoneFlow())
        btnDel.OnEvent("Click", (*) => PanelZones._RemoveSelected())
        btnTest.OnEvent("Click", (*) => PanelZones.Preview())

        ; controls greyed out when the master switch is off (the table itself is faded by _ApplyEnabled)
        ctl["master"] := [secZones, secSel, secDim, btnAdd, btnTest, tLvl, sldDim, txtDim, tFade, sldFade, txtFade, txtHelp]
        ctl["sel"]    := [btnDel, chkHover]
        ctl["selAll"] := growCtrls
        ctl["delay"]  := [tDelay, edtDelay, udDelay]
        ctl["selAll"].Push(btnDel, chkHover, tDelay, edtDelay, udDelay)

        PanelZones._FillList()
        SetTimer(PanelZones._TipFn, 120)
    }

    static _RowText(z) {
        return [z.name, z.exe, (z.shape = "free") ? "Freeform" : "Rectangle"
            , z.gl "/" z.gr "/" z.gt "/" z.gb, z.hover ? (z.delay " s") : "Off"]
    }

    static _LV() {
        ctl := PanelZones._Ctl
        return ctl.Has("lv") ? ctl["lv"] : ""
    }

    static _FillList(selectRow := 0) {
        lv := PanelZones._LV()
        if !IsObject(lv) {
            return
        }
        PanelZones._Filling := true
        try {
            lv.Delete()
            for z in PanelZones._DZones {
                lv.Add(z.on ? "Check" : "", PanelZones._RowText(z)*)
            }
            lv.ModifyCol(5, "AutoHdr")    ; re-fit: keeps the last column clear of the vertical scrollbar
        }
        PanelZones._Filling := false
        if (selectRow >= 1 && selectRow <= PanelZones._DZones.Length) {
            try lv.Modify(selectRow, "Select Focus Vis")
        }
        PanelZones._OnSelect()
    }

    ; Master switch: fades the table and greys out every control; selection decides the per-zone editor
    static _ApplyEnabled() {
        ctl := PanelZones._Ctl
        if !ctl.Has("master") {
            return
        }
        on := PanelZones._DEnabled
        SetControlsEnabled(ctl["master"], on)
        PanelZones._FadeTable(on)
        sel := on && (PanelZones._SelIndex() > 0)
        SetControlsEnabled(ctl["selAll"], sel)
        zone := PanelZones._SelZone()
        SetControlsEnabled(ctl["delay"], sel && IsObject(zone) && zone.hover)
    }

    ; The ListView keeps its dark / light theme but its colours fade when the feature is off
    static _FadeTable(on) {
        lv := PanelZones._LV()
        if !IsObject(lv) {
            return
        }
        global ThemeSurfaceRgb, ThemeTextRgb, ThemeBgRgb
        try {
            if on {
                txt := ThemeTextRgb
                bg  := ThemeSurfaceRgb
            } else {
                txt := MixRgb(ThemeTextRgb, ThemeSurfaceRgb, 0.62)
                bg  := MixRgb(ThemeSurfaceRgb, ThemeBgRgb, 0.55)
            }
            lv.Opt("c" Format("{:06X}", txt) " Background" Format("{:06X}", bg))
            lv.Redraw()
        }
    }

    static _SelIndex() {
        lv := PanelZones._LV()
        if !IsObject(lv) {
            return 0
        }
        row := 0
        try row := lv.GetNext(0)
        return (row >= 1 && row <= PanelZones._DZones.Length) ? row : 0
    }

    static _SelZone() {
        i := PanelZones._SelIndex()
        return i ? PanelZones._DZones[i] : ""
    }

    ; Loads the selected zone's own settings into the editor
    static _OnSelect() {
        ctl := PanelZones._Ctl
        if (PanelZones._Filling || !ctl.Has("grow")) {
            return
        }
        z := PanelZones._SelZone()
        PanelZones._Filling := true
        try {
            for key, edt in ctl["grow"] {
                edt.Value := IsObject(z) ? z.%key% : 0
            }
            ctl["chkHover"].Value := IsObject(z) ? (z.hover ? 1 : 0) : 0
            ctl["edtDelay"].Value := IsObject(z) ? z.delay : 2
            ctl["txtSel"].Text := IsObject(z) ? ("Editing: " z.name "  (" z.exe ")") : "Select a zone in the table to edit its Expand, hover and delay settings."
        }
        PanelZones._Filling := false
        PanelZones._ApplyEnabled()
    }

    static _OnGrow(key, ctrl, *) {
        z := PanelZones._SelZone()
        if (PanelZones._Filling || !IsObject(z) || !PanelZones._DEnabled || !IsInteger(ctrl.Value)) {
            return
        }
        z.%key% := Max(-1000, Min(1000, Integer(ctrl.Value)))
        PanelZones._RefreshRow()
        PanelZones._LivePreview()
    }

    ; Shows / updates the zones on the real windows immediately (no Apply needed).
    ; If a preview is already running, the overlays are updated in place so they don't flash or re-fade.
    static _LivePreview() {
        if (!PanelZones._DEnabled || PanelZones._Picking) {
            return
        }
        if !PanelZones._PreviewUntil {
            PanelZones.Preview(PanelZones._HoldMs)
            return
        }
        zs := PanelZones._CloneZones(PanelZones._DZones)
        for z in zs {
            z.on := true
        }
        PanelZones._Run := { on: true, dim: PanelZones._DDim, fade: PanelZones._DFade, zones: zs }
        for key, e in PanelZones._Ov {
            idx := Integer(StrSplit(key, "|")[1])
            if (idx >= 1 && idx <= zs.Length) {
                e.z := zs[idx]
                e.key := ""            ; force re-layout with the new values
                e.rgnPending := true
            }
        }
        PanelZones._PreviewUntil := A_TickCount + PanelZones._HoldMs
    }

    ; Refreshes a running preview after any other edit (dim, fade, hover, delay)
    static _LiveRefresh() {
        if PanelZones._PreviewUntil {
            PanelZones._LivePreview()
        }
    }

    static _StopPreview() {
        if PanelZones._PreviewUntil {
            PanelZones._PreviewUntil := 0
            PanelZones._ClearOverlays()
            PanelZones._SyncRuntime()
        }
    }

    static _OnHover() {
        z := PanelZones._SelZone()
        if (PanelZones._Filling || !IsObject(z) || !PanelZones._DEnabled) {
            return
        }
        z.hover := !!PanelZones._Ctl["chkHover"].Value
        PanelZones._RefreshRow()
        PanelZones._LiveRefresh()
        PanelZones._ApplyEnabled()
    }

    static _OnDelay() {
        z := PanelZones._SelZone()
        v := PanelZones._Ctl["edtDelay"].Value
        if (PanelZones._Filling || !IsObject(z) || !PanelZones._DEnabled || !IsInteger(v)) {
            return
        }
        z.delay := Max(0, Min(600, Integer(v)))
        PanelZones._RefreshRow()
        PanelZones._LiveRefresh()
    }

    static _RefreshRow() {
        lv := PanelZones._LV()
        row := PanelZones._SelIndex()
        if (IsObject(lv) && row) {
            PanelZones._Filling := true
            try lv.Modify(row, "", PanelZones._RowText(PanelZones._DZones[row])*)
            PanelZones._Filling := false
        }
        PanelZones._Dirty()
    }

    static _OnCheck(item, checked) {
        if (PanelZones._Filling || item < 1 || item > PanelZones._DZones.Length) {
            return
        }
        if !PanelZones._DEnabled {
            SetTimer(() => PanelZones._FillList(PanelZones._SelIndex()), -1)    ; feature is off: undo the tick
            return
        }
        PanelZones._DZones[item].on := !!checked
        PanelZones._Dirty()
    }

    static _RemoveSelected() {
        row := PanelZones._SelIndex()
        if (!row || !PanelZones._DEnabled) {
            return
        }
        PanelZones._DZones.RemoveAt(row)
        PanelZones._FillList(Min(row, PanelZones._DZones.Length))
        PanelZones._Dirty()
        if PanelZones._PreviewUntil {
            PanelZones.Preview(PanelZones._HoldMs)
        }
    }

    ; Hover tooltip: when a table cell is too narrow for its text, show the full text next to the mouse
    static _TipTick() {
        lv := PanelZones._LV()
        if !IsObject(lv) {
            SetTimer(PanelZones._TipFn, 0)
            ToolTip(, , , 4)
            return
        }
        vis := false
        try vis := DllCall("IsWindowVisible", "Ptr", lv.Hwnd, "Int")
        if !vis {
            PanelZones._HideTip()
            return
        }
        pt := Buffer(8, 0)
        DllCall("GetCursorPos", "Ptr", pt)
        sx := NumGet(pt, 0, "Int")
        sy := NumGet(pt, 4, "Int")
        DllCall("ScreenToClient", "Ptr", lv.Hwnd, "Ptr", pt)
        x := NumGet(pt, 0, "Int")
        y := NumGet(pt, 4, "Int")
        rc := Buffer(16, 0)
        DllCall("GetClientRect", "Ptr", lv.Hwnd, "Ptr", rc)
        if (x < 0 || y < 0 || x >= NumGet(rc, 8, "Int") || y >= NumGet(rc, 12, "Int")) {
            PanelZones._HideTip()
            return
        }
        hit := Buffer(24, 0)
        NumPut("Int", x, hit, 0)
        NumPut("Int", y, hit, 4)
        SendMessage(0x1039, 0, hit.Ptr, lv)                    ; LVM_SUBITEMHITTEST
        row := NumGet(hit, 12, "Int") + 1
        col := NumGet(hit, 16, "Int") + 1
        if (row < 1 || col < 1) {
            PanelZones._HideTip()
            return
        }
        txt := lv.GetText(row, col)
        strW := SendMessage(0x1057, 0, StrPtr(txt), lv)       ; LVM_GETSTRINGWIDTHW
        colW := SendMessage(0x101D, col - 1, 0, lv)           ; LVM_GETCOLUMNWIDTH
        pad := (col = 1) ? 34 : 14                              ; first column also holds the checkbox
        if (txt = "" || strW + pad <= colW) {
            PanelZones._HideTip()
            return
        }
        key := row "," col
        if (key != PanelZones._TipKey) {
            PanelZones._TipKey := key
            ToolTip(txt, sx + 16, sy + 22, 4)
        }
    }

    static _HideTip() {
        if (PanelZones._TipKey != "") {
            PanelZones._TipKey := ""
            ToolTip(, , , 4)
        }
    }
}
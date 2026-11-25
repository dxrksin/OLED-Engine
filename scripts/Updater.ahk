; ==============================================================================
; Updater.ahk - "Check for Updates" for OLED Engine (GitHub Releases)
; ------------------------------------------------------------------------------
; How it works
;   1. Asks GitHub for the latest release of UPDATE_REPO (no account or API key needed).
;   2. Compares its tag (v1.0.2 -> 1.0.2) with APP_VERSION from the main script.
;   3. If newer and running as a compiled .exe: downloads the new exe into updates\,
;      checks it, swaps it in, and restarts. config\ (your settings) is never touched.
;      If running as a plain .ahk: just opens the release page.
;
; How to publish an update
;   - Bump APP_VERSION in OLED_Engine.ahk, compile, then create a GitHub Release
;     tagged v<APP_VERSION> and attach the exe named exactly as UPDATE_ASSET_NAME.
;   - Optional: put a line like  SHA256: <64 hex characters>  in the release notes and the
;     download will be verified against it. (PowerShell: Get-FileHash .\OLED-Engine.exe)
;
; Optional silent check at startup: the "Check at startup" tick on the Help / About tab
; (off by default, nothing is sent unless it is ticked; it is stored in config\settings.ini).
; ==============================================================================

UPDATE_REPO       := "dxrksin/OLED-Engine"   ; <-- CHANGE THIS, e.g. "dxrksin/OLED-Engine"
UPDATE_ASSET_NAME := "OLED-Engine.exe"              ; file name of the exe attached to each release

UpdateStatusCtrl := ""

; The Settings window hands us its little status label so results can be shown under the button.
SetUpdateStatusCtrl(ctrl) {
    global UpdateStatusCtrl
    UpdateStatusCtrl := ctrl
}

SetUpdateStatus(text) {
    global UpdateStatusCtrl
    try UpdateStatusCtrl.Text := text
}

; Called once at startup from the main script.
InitUpdater() {
    global IniPath
    SetTimer(UpdaterCleanup, -20000)   ; leftovers from a previous update (the old exe is still closing)
    if (IniRead(IniPath, "Updates", "AutoCheck", "0") = "1") {
        SetTimer(() => CheckForUpdates(true), -30000)
    }
}

; silent = true: never shows a dialog, only a tray notice when something newer exists.
CheckForUpdates(silent := false) {
    global UPDATE_REPO, APP_VERSION

    if InStr(UPDATE_REPO, "YOUR_GITHUB") {
        SetUpdateStatus("Updates are not set up yet")
        if !silent {
            MsgBox("Updates are not set up yet.`n`nOpen scripts\Updater.ahk and set UPDATE_REPO to your GitHub repository.", "Check for Updates", "Iconi")
        }
        return
    }

    SetUpdateStatus("Checking...")
    try {
        info := FetchLatestRelease()
    } catch as err {
        SetUpdateStatus("Could not check for updates")
        if !silent {
            MsgBox("Could not check for updates:`n" err.Message, "Check for Updates", "Icon!")
        }
        return
    }

    if !IsNewerVersion(info["version"], APP_VERSION) {
        SetUpdateStatus("You're on the latest version (v" APP_VERSION ") - checked " FormatTime(, "HH:mm"))
        if !silent {
            MsgBox("You're up to date (v" APP_VERSION ").", "Check for Updates", "Iconi")
        }
        return
    }

    SetUpdateStatus("Version " info["version"] " is available")
    if silent {
        try TrayTip("Version " info["version"] " is available. Open Settings > Help / About and click Check for Updates.", "OLED Engine", 1)
        return
    }

    page := "https://github.com/" UPDATE_REPO "/releases/latest"
    head := "Version " info["version"] " is available (you have v" APP_VERSION ")."
    if (!A_IsCompiled || info["url"] = "") {
        if (MsgBox(head "`n`nOpen the download page?", "Check for Updates", "YesNo Iconi") = "Yes") {
            Run(page)
        }
        return
    }

    if (MsgBox(head "`n`nInstall it now? OLED Engine will restart. Your settings are kept.", "Check for Updates", "YesNo Iconi") != "Yes") {
        return
    }
    InstallUpdate(info)
}

; Returns Map("version", "url", "hash"). Throws on any network / parsing problem.
FetchLatestRelease() {
    global UPDATE_REPO, UPDATE_ASSET_NAME
    req := ComObject("WinHttp.WinHttpRequest.5.1")
    req.SetTimeouts(5000, 5000, 10000, 15000)
    req.Open("GET", "https://api.github.com/repos/" UPDATE_REPO "/releases/latest", false)
    req.SetRequestHeader("User-Agent", "OLED-Engine-Updater")
    req.SetRequestHeader("Accept", "application/vnd.github+json")
    req.Send()
    if (req.Status != 200) {
        throw Error("GitHub answered with status " req.Status " (check UPDATE_REPO and that a release exists).")
    }
    json := req.ResponseText

    if !RegExMatch(json, '"tag_name"\s*:\s*"v?([^"]+)"', &tag) {
        throw Error("The latest release has no version tag.")
    }
    info := Map("version", tag[1], "url", "", "hash", "")

    assetRe := '"browser_download_url"\s*:\s*"([^"]*/' StrReplace(UPDATE_ASSET_NAME, ".", "\.") ')"'
    if RegExMatch(json, assetRe, &asset) {
        info["url"] := asset[1]
    }
    if RegExMatch(json, 'i)sha-?256.{0,12}?([0-9a-f]{64})', &hash) {
        info["hash"] := StrLower(hash[1])
    }
    return info
}

InstallUpdate(info) {
    global UpdatesDir, BackupsDir
    newExe := UpdatesDir "\new.exe"
    oldExe := UpdatesDir "\old.exe"
    swapped := false
    try {
        DirCreate(UpdatesDir)
        try FileDelete(newExe)
        try FileDelete(oldExe)

        Download(info["url"], newExe)

        ; Sanity checks before touching the running exe
        if (FileGetSize(newExe) < 100000) {
            throw Error("The download looks incomplete.")
        }
        f := FileOpen(newExe, "r")
        sig := f.Read(2)
        f.Close()
        if (sig != "MZ") {
            throw Error("The download is not a Windows program.")
        }
        if (info["hash"] != "" && UpdaterSha256(newExe) != info["hash"]) {
            throw Error("The download failed its SHA-256 check, so it was not installed.")
        }

        ; Safety net: settings backup + flush presets before restarting
        try BackupSettingsNow(true, " (before update)")
        try {
            SetTimer(SavePresetsToIni, 0)
            SavePresetsToIni()
        }

        ; Windows will not let you overwrite a running exe, but it does let you rename it.
        FileMove(A_ScriptFullPath, oldExe, 1)
        swapped := true
        FileMove(newExe, A_ScriptFullPath, 1)
    } catch as err {
        if swapped {
            try FileMove(oldExe, A_ScriptFullPath, 1)   ; roll back
        }
        try FileDelete(newExe)
        MsgBox("The update could not be installed:`n" err.Message "`n`nNothing was changed.", "Check for Updates", "Icon!")
        return
    }

    ; #SingleInstance Force makes the new copy replace this one.
    Run('"' A_ScriptFullPath '"')
    ExitApp()
}

; Runs shortly after startup: files the old exe away as a one-step rollback copy and clears staging.
UpdaterCleanup() {
    global UpdatesDir, BackupsDir
    oldExe := UpdatesDir "\old.exe"
    if FileExist(oldExe) {
        try {
            DirCreate(BackupsDir "\auto")
            FileMove(oldExe, BackupsDir "\auto\previous-version.exe", 1)
        }
    }
    try FileDelete(UpdatesDir "\new.exe")
    try DirDelete(UpdatesDir)   ; only succeeds when empty
}

UpdaterSha256(path) {
    tmp := A_Temp "\oled_sha_" A_TickCount ".txt"
    try RunWait(A_ComSpec ' /c certutil -hashfile "' path '" SHA256 > "' tmp '"', , "Hide")
    out := FileExist(tmp) ? FileRead(tmp) : ""
    try FileDelete(tmp)
    return RegExMatch(StrReplace(out, " "), "i)\b([0-9a-f]{64})\b", &m) ? StrLower(m[1]) : ""
}

IsNewerVersion(remote, current) {
    r := UpdaterVersionParts(remote)
    l := UpdaterVersionParts(current)
    Loop Max(r.Length, l.Length) {
        rv := (A_Index <= r.Length) ? r[A_Index] : 0
        lv := (A_Index <= l.Length) ? l[A_Index] : 0
        if (rv != lv) {
            return rv > lv
        }
    }
    return false
}

UpdaterVersionParts(v) {
    parts := []
    for p in StrSplit(v, ".") {
        n := RegExReplace(p, "\D.*$")
        parts.Push(n = "" ? 0 : Integer(n))
    }
    return parts
}
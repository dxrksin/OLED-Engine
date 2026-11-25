# OLED Engine

Multi-monitor OLED burn-in protection for Windows: per-category idle dimming and #000000 blackout, HDR/SDR profile switching, pixel refresh tracking, and game automation.

## Download

Get the latest version from the **[Releases page](../../releases/latest)**. Download `OLED-Engine.zip`.

## Install

1. Right-click the zip and choose **Extract All** (don't run it from inside the zip).
2. Put the extracted `OLED-Engine` folder somewhere you own, such as `Documents` or `C:\Tools`. Don't use `C:\Program Files`.
3. Run `OLED-Engine.exe`.

OLED Engine is portable. On first run it creates `config`, `logs` and `backups` folders next to the exe. Your settings live in `config`. To move the app, move the whole folder.

## Updating

Open **Settings > Help / About** and click **Check for Updates**. Your settings are kept. You can also tick "Check at startup" there.

## Game automation (optional)

Automatic G-Sync switching needs:

- [NVIDIA Profile Inspector](https://github.com/Orbmu2k/nvidiaProfileInspector) (a separate download)
- Your own G-Sync ON and OFF `.nip` profiles (Guide in App)
- OLED Engine running as administrator

Set the paths on the Automation tab.

## Notes

- Windows may show a SmartScreen or antivirus warning for new unsigned apps. Each release lists a SHA256 hash you can check with `Get-FileHash .\OLED-Engine.exe` in PowerShell.
- Found a bug or have an idea? Open an [issue](../../issues).

## Building from source

Requires [AutoHotkey v2](https://www.autohotkey.com/) and its Ahk2Exe compiler. Compile `OLED Engine.ahk`. The files in `scripts\` are included automatically.

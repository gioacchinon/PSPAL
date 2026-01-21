# PSPAL

> PSPAL is a modular PowerShell profile designed to let you use the shell as a command palette for Windows. It provides a simple launcher, a custom predictor that surfaces pinned items and history, and a small plugin set for file search, pinning, and web browsing with Microsoft Edge.

## Key features

- Simple launcher interface inside PowerShell
- Custom predictor loading suggestions from pinned items, history, and a manual `files` list
- Built-in plugins: file search, pinning, web browsing (Edge kiosk mode)
- Included AutoHotkey helper (and compiled EXE) to ease launching the profile
- Modular and easy to extend

## Requirements

- **Windows**
- **PowerShell** (latest recommended). Designed arrownd PowerShell 7+. Versions < 5.1 are not officially supported.
- Optional: **Windows Terminal** (`wt.exe`) if you want the included AHK to open the quake-style terminal. PSPAL itself does not require `wt.exe` to function.
- Optionally install AutoHotkey if you want to edit/run the AHK scripts. The compiled AHK helper works without AutoHotkey installed.


## Dir tree
```
|   .historylifecount
|   ALIASES.ps1
|   PROFILE.ps1
|   SETTINGS.ps1
|   testsettings.ps1
|   LICENSE
|   README.md
|   
+---ahk
|       PSPAL.ahk
|       PSPAL.exe
|       
+---icons
|       icon.ico
|       icon.png
|       
+---Plugins
|   +---browsing
|   |       browsing.ps1
|   |       
|   +---pinning
|   |       pinning.ps1
|   |       PINNED.ps1
|   |       
|   \---search
|           search.ps1
|
+---Predictor
|       PSPALPredictor.dll
|       history
|       pinned
|       files
|
+---log
|
\---doc
```

## Installation methods

1. [**Generic**](doc/InstallationMethods.md#Generic)
2. [**Usage with Windows Terminal**](doc/InstallationMethods.md#windows-terminal)

## Functions

see [`doc/functions.md`](doc/functions.md)

## Plugins

Plugins live in the `Plugins/` folder. Current simple plugins include:

- `browsing` — open web pages with Microsoft Edge (kiosk mode option)
- `pinning` — pin/unpin commands and items to the predictor
- `search` — a small file search helper

To add a plugin: create a new folder under `Plugins/` and follow the existing plugin patterns.

## Configuration

Primary settings are in `SETTINGS.ps1`. `ALIASES.ps1` contains shortcut commands and is expected to be edited manually.

PSPAL uses standard Windows environment variables (for example `$env:USERPROFILE`) and does not create new global environment variables by default. You may optionally configure an environment variable pointing to the PSPAL root if you want easier switching between profiles.

## License

This project is released under The Unlicense. See the `LICENSE` file for details.

## Attribution & Disclaimer

PSPAL is not affiliated with Microsoft, PowerShell, or AutoHotkey. Default functions may call or launch Microsoft Edge, Microsoft Bing, Mistal LeChat or other apps when requested, but PSPAL is independent of those services.

## Contact / Maintainer

Maintained by the repository owner. For questions or contributions, open an issue or PR in this repository.

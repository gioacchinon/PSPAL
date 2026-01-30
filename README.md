# PSPAL

> PSPAL is a modular PowerShell profile designed to let you use the shell as a command palette for Windows. It provides a simple launcher, a custom predictor that surfaces pinned items and history, and a small plugin set for file search, pinning, and configurable web browsing.

## Key features

- Simple launcher interface inside PowerShell
- Custom predictor loading suggestions from pinned items, history, and a manual `files` list
- Built-in plugins: file search, pinning, configurable web browsing with pluggable browser support
- Multiple search engines with easy switching (Bing, Google, image, video, translation)
- Included AutoHotkey helper (and compiled EXE) to ease launching the profile
- Modular and easy to extend

## Requirements

- **Windows**
- **PowerShell** (latest recommended). Designed around PowerShell 7+. Versions < 5.1 are not officially supported.
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

You can generate function docs with: `.\
pspal\doc\Get-PSPALFunctionsHelp.ps1 -OutputPath doc/functions.md`

## Plugins

Plugins live in the `Plugins/` folder. Current simple plugins include:

- `browsing` — open web pages in a configurable browser with multiple search engines
- `pinning` — pin/unpin commands, URLs, files, and items to the predictor
- `search` — fuzzy file search helper

To add a plugin: create a new folder under `Plugins/` and follow the existing plugin patterns.

## Configuration

### Settings

Primary settings are in `SETTINGS.ps1`. `ALIASES.ps1` contains shortcut commands and is expected to be edited manually.

PSPAL uses standard Windows environment variables (for example `$env:USERPROFILE`) and does not create new global environment variables by default. You may optionally configure an environment variable pointing to the PSPAL root if you want easier switching between profiles.

#### SETTINGS.ps1 Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `$global:PSPal_UserFilesDir` | User's files directory | `$env:USERPROFILE` |
| `$global:PSPal_Editor` | Default editor for opening files | `"notepad"` |
| `$global:PSPal_logFilePath` | Path to the log file | `"$PSScriptRoot\log\palette.log"` |
| `$global:PSPal_LogToFile` | Enable/disable logging to file | `$True` |
| `$global:PSPal_FavColor` | Favorite color for UI elements | `"Blue"` |
| `$global:PSPal_PinnedPath` | Path to pinned items script | `"$PSScriptRoot\plugins\pinning\pinned.ps1"` |
| `$global:PSPal_HistoryLifespan` | History lifespan in palette instances (0 = persistent) | `0` |
| `$global:PSPal_predictorPinnedPath` | Path to predictor pinned items | `"$PSScriptRoot\Predictor\pinned"` |
| `$global:PSPal_predictorFilesPath` | Path to predictor files | `"$PSScriptRoot\Predictor\pinned"` |
| `$global:PSPal_SearchEngine` | Default search engine | `"bing"` |
| `$global:PSPal_SearchEngines` | Available search engines and their URLs | Hash table with Bing, Google, Image, Video, and Translate |
| `$global:PSPal_BrowserProvider` | Browser configuration (command, URL launcher, private mode flag) | Microsoft Edge with `--app=<URL>` and `--inPrivate` |

## License

This project is released under The Unlicense. See the `LICENSE` file for details.

## Attribution & Disclaimer

PSPAL is not affiliated with Microsoft, PowerShell, or AutoHotkey. While the default browser is Microsoft Edge and search defaults to Bing, these are fully configurable. PSPAL is independent of these services and can be configured to use any browser or search engine.

## Contact / Maintainer

Maintained by the repository owner. For questions or contributions, open an issue or PR in this repository.

# PSPAL

**Palette (PSPAL)** is a customizable PowerShell environment designed to enhance productivity with aliases, command history, pinning, and modular plugins.

I use this for myself and thought it'd be usefull for others too.

---

## ✨ Features

| **Feature**                | **Description**                                                                                     | **Files/Scripts**                     |
|----------------------------|-----------------------------------------------------------------------------------------------------|---------------------------------------|
| **Aliases Management**     | Quickly access and manage your PowerShell aliases.                                                  | `ALIASES.ps1`                         |
| **Palette History**        | Track and review your command palette usage. (`palette_history.txt` replaces the default powershell history file)                                                       | `palette_history.txt`, `palette.log`  |
| **Pinning**                | Pin frequently used commands or scripts for fast access.                                          | `PINNED.ps1`                          |
| **Profile Customization**  | Personalize your PowerShell profile.                                                               | `PROFILE.ps1`                         |
| **Settings**               | Configure PSPAL behavior and preferences.                                                         | `SETTINGS.ps1`, `testsettings.ps1`    |
| **Plugins**                | Extend functionality with modular plugins.                                                        |                                       |

---

## 🛠 Set Up

### Recommended Setup

1. **Create a new Terminal profile:**
   - In `settings.json` > `profiles` > `list`, add:
     ```json
     "environment": {
         "WT_PROFILE_NAME": "PSPal"
     }
     ```
   - Set a different `WT_PROFILE_NAME` for your default PowerShell profile.

2. **Create folders:**
   - One for your default user `profile.ps1`.
   - One for the Palette profile.

3. **Update your `$PROFILE` script:**
   ```powershell
   switch ($env:WT_PROFILE_NAME) {
       "PSPal" {
           . $env:PaletteScriptPath
       }
       "PS" {
           . $env:UserScriptPath
       }
       default {
           Write-Warning "Profile not identified. Loading default."
           . $env:UserScript
       }
   }
   ```

4. **Launch Terminal with the Palette profile.**

5. **Get started:**
   - Explore `ALIASES.ps1` to understand available commands.
   - Dive into the code for more details.

> PSPAL.exe is a compiled .ahk file linking `Ctrl`+`Alt`+`Space` to the Windows Terminal profile named PSPAL,
> you might want to make it run at startup.
> the .ahk file is also provided if you need or want, and you probably do, to refine it.


---

## 📂 Directory Structure

```
PSPAL/
├── ALIASES.ps1
├── palette_history.txt
├── palette.log
├── PINNED.ps1
├── PROFILE.ps1
├── PSPAL.ico
├── SETTINGS.ps1
├── testsettings.ps1
└── Plugins/
    ├── browsing.ps1
    ├── fuzzysearch.ps1
    └── pinning.ps1
```

---

## 🔧 Aliases

### Overview
PSPAL provides a set of aliases for quick access to common functions. These aliases are defined in `ALIASES.ps1` and loaded in `PROFILE.ps1`.                                       |

---

## 📖 Help Section

### `Restart-Palette` [`rh`]

**Description:** Restarts the PSPAL environment by reloading the palette profile and clearing command history.
**Usage:** `Restart-Palette`
**When to use:**
- After editing `PROFILE.ps1`, `SETTINGS.ps1`, or plugins.
- To reset the session without closing the terminal.

---

### `Clear-Palette` [`c`]

**Description:** Clears the terminal and reprints the welcome banner with a colorful splash.
**Usage:** `Clear-Palette`
**When to use:**
- To declutter the terminal.
- For a visual reset after major commands.

---

### `Set-TemporaryHistory` [`np`]

**Description:** Switches to a temporary history file for experimental or sensitive commands.
**Usage:** `Set-TemporaryHistory`
**When to use:**
- During testing or debugging.
- To avoid cluttering your main history.

---

### `Set-PaletteHistory` [`yp`]

**Description:** Restores default history logging to `palette_history.txt`.
**Usage:** `Set-PaletteHistory`
**When to use:**
- After finishing a temporary session.
- To resume normal logging.

---

## 🔧 Plugins

### How Plugins Work

Plugins are modular scripts that extend PSPAL's functionality. They are loaded in the main script as follows:

```powershell
# PLUGINS ---------------------------------------------------------------#
. $PaletteRoot\Plugins\fuzzysearch.ps1
. $PaletteRoot\Plugins\pinning.ps1
if (Test-Path $pinnedPath) {
    . $pinnedPath
}
. $PaletteRoot\Plugins\browsing.ps1
```

---

### Preinstalled Plugins

#### **fuzzysearch.ps1**

Enables fuzzy search for files and commands. Provides the following functions:

| **Function**            | **Description**                                                                                     |
|-------------------------|-----------------------------------------------------------------------------------------------------|
| `FuzzySearch` [`fs`] | Searches for files matching a term in `$UserFilesDir` (or a specified directory).                     |
| `Start-SearchedFile`  [`fo`] | Opens the first file found by `FuzzySearch`.                                                       |
| `Get-SearchedFile`	[`fp`] | Displays the content of the first file found by `FuzzySearch`.                                    |
| `Edit-SearchedFile`	[`fe`] | Opens the first file found by `FuzzySearch` in your default editor.                               |

**Example Usage:**
```powershell
FuzzySearch "config"
Start-SearchedFile "report"
Edit-SearchedFile "script"
```

---

#### **pinning.ps1**

Allows you to pin applications, URLs, and files for quick access.

| **Function**            | **Description**                                                                                     |
|-------------------------|-----------------------------------------------------------------------------------------------------|
| `PinApp`	[`papp`] | Pins an application to a specified path with an alias.                                            |
| `PinURLandFile`	[`purl`] | Pins a URL using Microsoft Edge in app mode.                                                       |
| `Get-Pinned`		 | Displays all pinned applications and URLs.                                                         |

**Example Usage:**
```powershell
PinApp "C:\Windows\System32\notepad.exe" "note"
PinURLandFile "https://example.com" "example"
Get-Pinned
```

---

#### **browsing.ps1**

Enhances web browsing directly from the terminal.

| **Function**            | **Description**                                                                                     |
|-------------------------|-----------------------------------------------------------------------------------------------------|
| `Start-Website`	[`wb`] | Opens a URL in Microsoft Edge, optionally in private mode.                                         |
| `WebSearch`	[`ws`] | Performs a web search using a specified search engine and term, with an option for private browsing. |

**Parameters:**
- `-Engine`: Specifies the search engine URL (e.g., `$SearchEngine`, `$ImageSearch`). Defaults to `$SearchEngine` if not provided.

**Example Usage:**
```powershell
Start-Website "https://example.com" -Private
WebSearch "PowerShell tips" $ImageSearch -Private
```

**Tip:** Define your search engine URLs (e.g., `$DDG`, `$ImageSearch`) in `SETTINGS.ps1` for easy reuse.

---

## 🔧 Settings

### Overview
The `SETTINGS.ps1` file allows you to configure PSPAL's behavior and preferences. It includes variables for:
- User file directory
- Default editor
- Paths for pinned scripts and log files
- Logging preference
- Favorite color
- Search engine URLs for web, image, video, and translation searches

### Validation
Use `testsettings.ps1` to validate your `SETTINGS.ps1` file. The `Test-Settings` function checks:
- File existence
- Mandatory variables
- Optional variable validation
returns nothing if it's all right

**Example Usage:**
```powershell
Test-Settings -SettingsPath "path/to/SETTINGS.ps1"
```

> PSPAL runs Test-Settings at its startup

---

## ⚠ Troubleshooting

- **Current directory not displayed in the prompt:**
  The prompt function in `PROFILE.ps1` is designed to show the current directory only when it changes. If you want the directory to always be visible, modify the prompt function as follows:

  ```powershell
  function prompt {
      $currentDir = $executionContext.SessionState.Path.CurrentLocation
      "PS [$currentDir]> "
  }
  ```

---

## 📌 Third-Party Attributions

This project references, interacts with, or uses the following third-party tools and services:
- **Microsoft Edge**, **PowerShell**, and **Bing** are trademarks of **Microsoft Corporation**.
- **AutoHotkey (AHK)** is a scripting language for Windows, created by **Chris Mallett** and the **AutoHotkey Foundation**.
- This project is not affiliated with, endorsed by, or sponsored by Microsoft, the AutoHotkey Foundation, or any other third-party mentioned.

All trademarks, logos, and brand names are the property of their respective owners.

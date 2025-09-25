<#
.SYNOPSIS
    PSPAL Installer - Downloads and sets up PSPAL from GitHub.
#>

#region Welcome
Write-Host "============================================="
Write-Host "   Welcome to the PSPAL Installer!"
Write-Host "   This script will download and set up PSPAL for you."
Write-Host "=============================================`n"
$proceed = Read-Host "Do you want to proceed? (y/n)"
if ($proceed -ne "y") {
    exit
}
#endregion

#region Requirements
# check for PowerShell 5.1 or higher
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PSPAL is designed to run on PowerShell 5.1 or higher. Do you want to continue and install it's last version? (y/n)"
    $continue = Read-Host
    if ($continue -ne "y") {
        exit
    }
    winget install --id=Microsoft.PowerShell --source=winget
    Write-Host "Note: this script will continue on this instance of PowerShell, there's no need to restart it now."
}
#check for Windows Terminal
if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Windows Terminal is not installed. Do you want to install it now? (y/n)"
    $installWT = Read-Host
    if ($installWT -ne "y") {
        Write-Host "Windows Terminal is required for PSPAL. Exiting installer."
        exit
    }
    winget install --id=Microsoft.WindowsTerminal --source=winget
    Write-Host "Note: this script will continue on this instance of PowerShell, there's no need to restart it now."
}

#optional check for AutoHotkey
if (-not (Get-Command ahk.exe -ErrorAction SilentlyContinue)) {
    Write-Host "AutoHotkey is not required, but it's useful for customizing how PSPAL starts."
    Write-Host "An .ahk script, and its compiled, will be included in the installation. [Ctrl+Alt+Space] -> wt.exe -p 'PSPal'."
    Write-host "Do you want to install AutoHotkey? (y/n)"
    $installAHK = Read-Host
    if ($installAHK -eq "y") {
        winget install --id=AutoHotkey.AutoHotkey --source=winget
    }
}
#endregion

#region Install Directory
$defaultInstallDir = "$env:USERPROFILE\PSPAL"
$installDir = Read-Host "Enter the installation directory (default: $defaultInstallDir)"
if ([string]::IsNullOrEmpty($installDir)) {
    $installDir = $defaultInstallDir
}
#endregion

#region Create Directory
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "Created directory: $installDir"
}
if (-not (Test-Path "$installDir\temp")) {
    New-Item -ItemType Directory -Path "$installDir\temp" -Force | Out-Null
}

Write-Host "Installing PSPAL to: $installDir`n"
#endregion

#region Download Files from GitHub
Write-Host "`nDownloading PSPAL files from GitHub..."

$owner = "gioacchinon"
$repo = "PSPAL"
$zipUrl = "https://github.com/$owner/$repo/archive/refs/heads/main.zip"
$localZip = "$InstallDir\temp\PSPAL.zip"

Write-Host "⇩ Downloading $zipUrl..." -NoNewline
Invoke-WebRequest -Uri $zipUrl -OutFile $localZip
Write-Host "Done."
Write-Host "⁘ Extracting files..." -NoNewline
Expand-Archive -Path $localZip -DestinationPath "$InstallDir\temp" -Force
Move-Item -Path "$InstallDir\temp\$repo-main\*" -Destination $InstallDir -Force
Write-Host "Done."
Write-Host "⁕ Cleaning up..." -NoNewline
Remove-Item -Path "$InstallDir\temp" -Recurse -Force
Write-Host "Done."

#endregion

#region Update PowerShell Profile
Write-Host "`nUpdating PowerShell profile..."
$profileSwitch = $PROFILE
$profilePath = Read-Host "Where do you want your current user profile to be moved to? (default: $env:USERPROFILE\profile\user.ps1)"
if ([string]::IsNullOrEmpty($profilePath)) {
    $profilePath = "$env:USERPROFILE\profile\user.ps1"
}

if (-not (Test-Path $profileSwitch)) {
    New-Item -ItemType File -Path $profileSwitch -Force | Out-Null
} else {
    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    } else {
        Copy-Item -Path $profilePath -Destination "$profilePath.bak" -Force
    }
    Copy-Item -Path $profileSwitch -Destination "$profilePath.bak" -Force
    Copy-Item -Path $profileSwitch -Destination "$profilePath" -Force
}

$switchContent = @"
switch (`$env:WT_PROFILE_NAME) {
    "PSPal" {
        . $InstallDir\profile.ps1
    }
    "PS" {
        . $profilePath
    }
    default {
		write-warning "profile not identified. loading default"
        . $profilePath    
    }
}
"@

Set-Content -Path $profileSwitch -Value $switchContent -Force
#endregion

#region Windows Terminal Profile
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    Copy-Item $settingsPath "$settingsPath.bak" -Force

    # Check if settings.json exists
    if (-not (Test-Path $settingsPath)) {
        Write-Warning "Windows Terminal settings.json not found at $settingsPath"
        Write-Host "Please ensure Windows Terminal is installed and opened at least once."
    } else {
        try {
            # Read the current settings
            $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

            $palguid = "{" + ([guid]::NewGuid().ToString()) + "}"

            # Define the new profile
            $newPalProfile = @{
                name = "PSPAL"
                icon = "$installDir\icons\icon.ico"
                environment = @{
                    WT_PROFILE_NAME = "PSPal"
                }
                startingDirectory = "$env:USERPROFILE"
                source = "Windows.Terminal.PowershellCore"
                commandline = "pwsh.exe"
                guid = $palguid
                hidden = $false 
            }

            $usrguid = "{" + ([guid]::NewGuid().ToString()) + "}"

            $newUserProfile = @{
                name = [System.Environment]::UserName.ToString()
                icon = "$installDir\icons\icon.ico"
                environment = @{
                    WT_PROFILE_NAME = "PS"
                }
                startingDirectory = "$env:USERPROFILE"
                source = "Windows.Terminal.PowershellCore"
                commandline = "pwsh.exe"
                guid = $usrguid
                hidden = $false 
            }

            # Add the new profiles to the profiles list
            $settings.profiles.list += $newPalProfile
            $settings.profiles.list += $newUserProfile

            # Set the new profile as the default
            $settings.defaultProfile = $usrguid


            # Save the updated settings
            $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Force

            Write-Host "Windows Terminal profile 'PSPal' added and set as default."
        } catch {
            Write-Warning "Failed to update Windows Terminal settings: $_"
        }
    }
#endregion

#region Create Startup Shortcut
Write-Host "Creating startup shortcut..." -NoNewline
$startupFolder = [System.Environment]::GetFolderPath('Startup')
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut("$startupFolder\PSPAL.lnk")
$shortcut.TargetPath = "$InstallDir\ahk\PSPAL.exe"
$shortcut.WorkingDirectory = "$InstallDir\ahk"
$shortcut.IconLocation = "$InstallDir\icons\icon.ico"
$shortcut.Save()
Start-Process "$InstallDir\ahk\PSPAL.exe"
Write-Host "Done."
#endregion

#region Final Message
Write-Host "`n============================================="
Write-Host "   PSPAL has been installed to: $installDir"
Write-Host "   Please restart Windows Terminal to see the new profile."
Write-Host "=============================================`n"
#endregion

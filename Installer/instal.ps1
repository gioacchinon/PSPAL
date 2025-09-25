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
} else {
    Write-Host "Directory already exists: $installDir"
}
Write-Host "Installing PSPAL to: $installDir`n"
#endregion

#region Download Files from GitHub
Write-Host "`nDownloading PSPAL files from GitHub..."

$owner = "gioacchinon"
$repo = "PSPAL"
$zipUrl = "https://github.com/$owner/$repo/archive/refs/heads/main.zip"
$localZip = "$InstallDir\temp\PSPAL.zip"

Write-Host "Downloading $zipUrl..."
Invoke-WebRequest -Uri $zipUrl -OutFile $localZip
Write-Host "Done." -NoNewline
Write-Host " Extracting files..."
Expand-Archive -Path $localZip -DestinationPath "$InstallDir" -Force
Write-Host "Done." -NoNewline
Write-Host "Cleaning up..."
Remove-Item -Path $localZip
Write-Host "Done." -NoNewline

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
    }
    Copy-Item -Path $profileSwitch -Destination "$profilePath" -Force
}

$switchContent = @"
# PSPAL Auto-Load
if (`$env:WT_PROFILE_NAME -eq "PSPal") {
    if (Test-Path "$installDir\PROFILE.ps1") {
        . "$installDir\PROFILE.ps1"
    }
} else if (`$env:WT_PROFILE_NAME -eq "PS") {
    if (Test-Path "$profilePath") {
        . "$profilePath"
    }
}
"@

Add-Content -Path $profileSwitch -Value $switchContent -Force
#endregion

#region Windows Terminal Profile
    $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

    # Check if settings.json exists
    if (-not (Test-Path $settingsPath)) {
        Write-Warning "Windows Terminal settings.json not found at $settingsPath"
        Write-Host "Please ensure Windows Terminal is installed and opened at least once."
    } else {
        try {
            # Read the current settings
            $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

            # Define the new profile
            $newProfile = @{
                name = "PSPAL"
                icon = "$installDir\\icons\\icon.ico"
                environment = @{
                    WT_PROFILE_NAME = "PSPal"
                }
                startingDirectory = "$env:USERPROFILE"
            }

            $mainProfile = $settings.profiles.list | Where-Object { $_.name -eq "PowerShell"}
            if (-not $mainProfile) {
                Write-Warning "Main PowerShell profile not found in Windows Terminal settings."
                $CTA = "please manually add environment = { WT_PROFILE_NAME = `"PS`"} to settings.json > profiles > list for the main profile"
                Write-Host $CTA
            } else {
                $mainProfile.environment = @{ WT_PROFILE_NAME = "PS" }
            }

            # Add the new profile to the profiles list
            $settings.profiles.list += $newProfile

            # Save the updated settings
            $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Force

            Write-Host "Windows Terminal profile 'PSPal' added and set as default."
        } catch {
            Write-Warning "Failed to update Windows Terminal settings: $_"
        }
    }
#endregion

#region Final Message
Write-Host "`n============================================="
Write-Host "   PSPAL has been installed to: $installDir"
Write-Host "   Open a new terminal with the PSPAL profile to get started!"
Write-Host "=============================================`n"
#endregion

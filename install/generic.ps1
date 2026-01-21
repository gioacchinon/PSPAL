Clear-Host
Write-Host "`e[2J`e[H"

Write-Host "Welcome to PSPal Installer"
Write-Host ("-" * $Host.UI.RawUI.WindowSize.Width)
Write-Host ""

function PadDisplayWidth {
    param(
        [string]$Text,
        [int]$TargetWidth = $Host.UI.RawUI.WindowSize.Width
    )

    $current = $Text.Length
    $pad = $TargetWidth - $current

    if ($pad -gt 0) {
        return $Text + (" " * $pad)
    }
    else {
        return $Text
    }
}

function Write-CleanLine(
    [string]$text,
    [string]$color = "White"
) {
    Write-Host (PadDisplayWidth $text) -NoNewline -ForegroundColor $color
    Write-Host ""
}

function Get-InputType {
    param([string]$path)

    # 1. Local filesystem path (absolute or relative)
    if (Test-Path -LiteralPath "$path" -ErrorAction SilentlyContinue) {
        return "Local"
    }

    # 2. Try to parse as URI
    try {
        $uri = [uri]$path

        if ($uri.IsAbsoluteUri) {
            switch ($uri.Scheme) {
                "file" { return "File URI" }
                "http" { return "Remote" }
                "https" { return "Remote" }
                default { return "Other URI" }
            }
        }
    }
    catch {
    }

    # 3. Check if it looks like a Windows path (even if Test-Path failed)
    if ($path -match '^[a-zA-Z]:\\' -or $path -match '^\\\\') {
        return "Local"
    }

    # 4. Nothing matched
    return "Unknown"
}

function SETUP {

    $origLeft = 0
    $origTop = 5
    [Console]::SetCursorPosition($origLeft, $origTop)
    function AskForConfiguration {
        param (
            $message,
            $default
        )
        
        $answer = Read-Host $message
        if ([string]::IsNullOrWhiteSpace($answer)) {
            return $default
        }
        return $answer
    }

    $global:PSPalHome = AskForConfiguration "PSPal Installation Path [defaults to '$env:LOCALAPPDATA\programs\PSPAL']" "$env:LOCALAPPDATA\programs\PSPAL"
    $global:PSPalSource = AskForConfiguration "PSPal Source Archive [defaults to 'https://codeload.github.com/gioacchinon/PSPAL/zip/refs/heads/main']" "https://codeload.github.com/gioacchinon/PSPAL/zip/refs/heads/main"
    $global:Force = (AskForConfiguration "Force? [Y/n]" "y") -match '^(yes|y)$'
    $global:UpdateProfile = (AskForConfiguration "Update Powershell profile? [Y/n]" "y") -match '^(yes|y)$'
    $global:UserProfileHome = if ($global:UpdateProfile) { AskForConfiguration "Where to move your user profile [$env:USERPROFILE\Documents\PowerShell\Scripts\USER.ps1]?" "$env:USERPROFILE\Documents\PowerShell\Scripts\USER.ps1" }
    $global:ForWindowsTerminal = (AskForConfiguration "Setting up for Windows Terminal? [y/N]" "n") -match '^(yes|y)$'
    $global:WTProfileName = if ($global:ForWindowsTerminal) { AskForConfiguration "WT profile name [PSPal]:" "PSPal" }

    [Console]::SetCursorPosition($origLeft, $origTop)

    Write-CleanLine "PSPal Installation Path: $global:PSPalHome" "Blue"
    Write-CleanLine "PSPal source archive: $global:PSPalSource [$(Get-InputType $global:PSPalSource)]" "Blue"
    Write-CleanLine "Force: $global:Force" "Blue"
    Write-CleanLine "Update Powershell profile: $global:UpdateProfile" "Blue"
    if ($global:UpdateProfile) {
        Write-CleanLine "User Profile Location: $global:UserProfileHome" "Blue"
    }
    Write-CleanLine "Setting up for Windows Terminal: $global:ForWindowsTerminal" "Blue"
    if ($global:ForWindowsTerminal) {
        Write-CleanLine "WT profile name: $global:WTProfileName" "Blue"
    }
}

function Get-Requirements {
    $needsWinget = $false
    $InstallPWSH = $false
    $InstallTerminal = $false
    $installAHK = $false

    $topcheckpoint = [Console]::CursorTop

    # Enter alternate screen
    Write-Host "`e[?1049h"
    Write-Host "`e[2J`e[H"

    #check for PowerShell 5.1 or higher
    if ($PSVersionTable.PSVersion -lt [version]"5.1"){
        Write-Host "PSPAL is designed to run on PowerShell 5.1 or higher. Do you want to continue and install it's last version? (y/n)"
        $continue = (Read-Host).Trim().ToLower()
        if ($continue -notin @("y", "yes")) 
        { exit }

        $InstallPWSH = $true
        $needsWinget = $true
        Write-Host "Note: this script will continue on this instance of PowerShell, there's no need to restart it now."
    }
    #check for Windows Terminal
    if ($global:ForWindowsTerminal -and -not (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
        Write-Host "Windows Terminal is not installed. Do you want to install it now? (y/n)"
        $continue = (Read-Host).Trim().ToLower()

        if ($continue -notin @("y", "yes")) { 
            $global:ForWindowsTerminal = $false
            Write-Host "Installation will continue for generic terminals"
        } else {
            $InstallTerminal = $true
            $needsWinget = $true

            Write-Host "Note: this script will continue on this instance of PowerShell, there's no need to restart it now."
        }
    }

    #optional check for AutoHotkey
    if (-not (Get-Command ahk.exe -ErrorAction SilentlyContinue)) {
        Write-Host "AutoHotkey is not required, but it's useful for customizing how PSPAL starts."
        Write-Host "An .ahk script, and its compiled, will be included in the installation. [Alt+Space] -> wt.exe -p 'PSPal'."
        if (-not $global:ForWindowsTerminal) {
            Write-Host "note that since your not setting up for WT.exe, you would need to edit the script for your terminal"
        }
        Write-host "Do you want to install AutoHotkey? (y/n)"
        $continue = (Read-Host).Trim().ToLower()

        if ($continue -notin @("y", "yes")) { 
            $installAHK = $false
        }
        else {
            $installAHK = $true
            $needsWinget = $true
        }
    }

    #check for winget
    if ($needsWinget -and -not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
        Write-Warning "Winget (Windows Package Manager) is not available on this system."
        Write-Host "Winget is required to install missing components."
        Write-Host "You can install it by downloading 'App Installer' from the Microsoft Store:"
        Write-Host "→ https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1"
        Write-Host "After installing, restart this script."
        exit
    }

    if ($InstallPWSH) {
        winget install --id Microsoft.PowerShell -e --source winget
    }
    if ($InstallTerminal) {
        winget install --id Microsoft.WindowsTerminal -e --source winget
    }
    if ($installAHK) {
        winget install --id AutoHotkey.AutoHotkey -e --source winget
    }

    # Exit alternate screen
    Write-Host "`e[?1049l"
    
    [Console]::SetCursorPosition(0, $topcheckpoint)
    $summary = @()
    if ($InstallPWSH) { $summary += "PowerShell" }
    if ($InstallTerminal) { $summary += "Windows Terminal" }
    if ($installAHK) { $summary += "AutoHotkey" }

    if ($summary.Count -gt 0) {
        Write-CleanLine "✓ | Installed: $($summary -join ', ')" "green"
    }
    else {
        Write-CleanLine "✓ | All requirements already met" "Green"
    }

}

function DownloadPSPal {
    $topcheckpoint = [Console]::CursorTop
    $installDir = $global:PSPalHome

    # Create temporary directory if it doesn't exist
    if (-not (Test-Path -LiteralPath "$env:TEMP\pspal")) {
        New-Item -ItemType Directory -Path "$env:TEMP\pspal" -Force | Out-Null
    }

    $inputType = Get-InputType $global:PSPalSource
    
    if ($inputType -eq "Local" -or $inputType -eq "File URI") {
        # Handle both local paths and file URIs
        $sourcePath = $global:PSPalSource
        
        # Convert file URI to local path if necessary
        if ($inputType -eq "File URI") {
            try {
                $uri = [uri]$global:PSPalSource
                $sourcePath = $uri.LocalPath
            }
            catch {
                Write-Error "Failed to parse file URI: $_"
                exit
            }
        }
        
        # Validate that the local file exists
        if (-not (Test-Path -LiteralPath $sourcePath)) {
            Write-Error "Local file not found: $sourcePath"
            exit
        }
        
        try {
            Copy-Item -LiteralPath $sourcePath -Destination "$env:TEMP\pspal\Pspal.zip" -Force
            $localZip = "$env:TEMP\pspal\Pspal.zip"
        }
        catch {
            Write-Error "Failed to copy local file: $_"
            exit
        }
    }
    else {

        $zipUrl = $global:PSPalSource
        $localZip = "$env:TEMP\pspal\PSPAL.zip"

        try {
            Write-Host "⁕ | Downloading $zipUrl..." -NoNewline
            Invoke-WebRequest -Uri $zipUrl -OutFile $localZip
            Write-Host "Done."
        }
        catch {
            Write-Error "Failed to download PSPAL files: $_"
            exit
        }
    }

    try {
        Write-Host "⁕ | Extracting files..." -NoNewline
        Expand-Archive -Path $localZip -DestinationPath "$env:TEMP\pspal" -Force
        $mainfolder = Get-ChildItem -Path "$env:TEMP\pspal" -Filter "PROFILE.ps1" -Recurse | Select-Object -ExpandProperty DirectoryName
        
        # Copy contents from extracted folder to install directory, avoiding self-copy
        Get-ChildItem -Path $mainfolder -Force | ForEach-Object {
            $destPath = Join-Path $InstallDir $_.Name
            
            # Skip if source and destination are the same
            if ((Resolve-Path $_.FullName).Path -ne (Resolve-Path $destPath -ErrorAction SilentlyContinue).Path) {
                if ($_.PSIsContainer) {
                    Copy-Item -Path $_.FullName -Destination $InstallDir -Recurse -Force
                }
                else {
                    Copy-Item -Path $_.FullName -Destination $InstallDir -Force
                }
            }
        }
        
        Write-Host "Done."
        Write-Host "⁕ | Cleaning up..." -NoNewline
        Remove-Item -Path "$env:TEMP\pspal" -Recurse -Force
        Write-Host "Done."
    }
    catch {
        Write-Error "Failed to extract PSPAL files: $_"
        exit
    } 
    [Console]::SetCursorPosition(0, $topcheckpoint)
    Write-CleanLine ""
    Write-CleanLine "✓ | Downloaded $zipUrl" "green"
    Write-CleanLine "✓ | Extracted to $env:TEMP\pspal" "green"
    Write-CleanLine "✓ | Cleaned up temp" "green"
}

function Set-PSpalAndUserProfile {
    $installDir = $global:PSPalHome
    $topcheckpoint = [Console]::CursorTop
    Write-Host "⁕ | Updating PowerShell profile..."

    try {
        $profileSwitch = $PROFILE
        $profilePath = $global:UserProfileHome

        # Ensure destination directory exists
        $profileDir = Split-Path $profilePath
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
        }

        # Backup or create user profile
        if (Test-Path $profilePath) {
            Copy-Item -Path $profilePath -Destination "$profilePath.bak" -Force
        }
        else {
            New-Item -ItemType File -Path $profilePath -Force | Out-Null
        }

        # Backup existing profile switch
        if (Test-Path $profileSwitch) {
            Copy-Item -Path $profileSwitch -Destination "$profileSwitch.bak" -Force
            Copy-Item -Path $profileSwitch -Destination $profilePath -Force
        }

        $switchContent = @"
switch (`$env:WT_PROFILE_NAME) {
    "PSPal" {
        . "$InstallDir\profile.ps1"
    }
    "PS" {
        . "$profilePath"
    }
    default {
        . "$profilePath"    
    }
}
"@

        Set-Content -Path $profileSwitch -Value $switchContent -Force
    }
    catch {
        [Console]::SetCursorPosition(0, $topcheckpoint)
        Write-CleanLine ""
        Write-CleanLine "✕ | Failed to update PowerShell profile: $_" "red"
        return
    }
    [Console]::SetCursorPosition(0, $topcheckpoint)
    Write-CleanLine ""
    Write-CleanLine "✓ | PowerShell profile updated." "green"

}
function New-WTExtension {
    $installDir = $global:PSPalHome
    $fragmentName = $global:WTProfileName
    $fragmentFile = "profiles.json"

    $topcheckpoint = [Console]::CursorTop
    Write-Host "⁕ | Creating Json Fragments..."
    
    try {
        # Build profile GUIDs
        $palguid = "{" + ([guid]::NewGuid().ToString()) + "}"
        $usrguid = "{" + ([guid]::NewGuid().ToString()) + "}"
    
        # Build fragment JSON structure
        $fragment = @{
            profiles = @(
                @{
                    name              = "$fragmentName"
                    icon              = "$($installDir)\icons\icon.ico"
                    environment       = @{
                        WT_PROFILE_NAME = "$fragmentName"
                    }
                    startingDirectory = "$env:USERPROFILE"
                    commandline       = "pwsh.exe"
                    guid              = $palguid
                    hidden            = $false
                },
                @{
                    name              = [System.Environment]::UserName.ToString()
                    icon              = "ms-appx:///ProfileIcons/pwsh.png"
                    environment       = @{
                        WT_PROFILE_NAME = "PS"
                    }
                    startingDirectory = "$env:USERPROFILE"
                    commandline       = "pwsh.exe"
                    guid              = $usrguid
                    hidden            = $false
                }
            )
        }
    
        # Convert to JSON
        $json = $fragment | ConvertTo-Json -Depth 10
    
        # Possible fragment roots
        $fragmentRoots = @(
            "$env:LOCALAPPDATA\Microsoft\Windows Terminal\Fragments",
            "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\Fragments",
            "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\Fragments"
        )
    
        foreach ($root in $fragmentRoots) {
            if (Test-Path $root) {
                $targetDir = Join-Path $root $fragmentName
                $targetFile = Join-Path $targetDir $fragmentFile
    
                # Ensure directory exists
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
    
                # Write fragment JSON
                $json | Set-Content -Path $targetFile -Force -Encoding UTF8
            }
        }
    }
    catch {
        [Console]::SetCursorPosition(0, $topcheckpoint)
        Write-CleanLine ""
        Write-CleanLine "✕ | couldn't install fragments" "red"
        return
    }
    [Console]::SetCursorPosition(0, $topcheckpoint)
    Write-CleanLine ""
    Write-CleanLine "✓ | Fragment installed at: $targetFile" "green"
}


#=========================================================

do {
    SETUP
    [Console]::SetCursorPosition(0, 12)
    $confirm = Read-Host "Confirm? [y, n]"
} until ($confirm -match '^(y|yes)$')

[Console]::SetCursorPosition(0, 12)
Write-CleanLine ""

Get-Requirements

Write-CleanLine ""
if (-not (Test-Path $global:PSPalHome)) {
    New-Item -ItemType Directory -Path $global:PSPalHome -Force | Out-Null
    Write-CleanLine "Created directory: $global:PSPalHome" "green"
} else {
    Write-CleanLine "Found existing directory: $global:PSPalHome" "Yellow"
    if (-not $Force) {
        Write-Host "Destination '$global:PSPalHome' already exists. Force to overwrite or remove it manually." -ForegroundColor Yellow
        exit
    }
}

DownloadPSPal

if ($global:UpdateProfile) {
    Set-PSpalAndUserProfile
}

if ($global:ForWindowsTerminal) {
    New-WTExtension
}
<#
.SYNOPSIS
    Installadore de PSPAL – Iscàrriga e cunfigurat PSPAL dae GitHub.
#>

#region Benebènnidu
Write-Host "============================================================"
Write-Host "   Installadore de PSPAL"
Write-Host "   Custu script iscàrrigat e cunfigurat PSPAL pro tue."
Write-Host "============================================================`n"
$proceed = Read-Host "Boles sighire? (s/n)"
if ($proceed -ne "s") {
    exit
}
#endregion

#region Requisitos
$needsWinget = $false
# controllu de PowerShell 5.1 o prus nou
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "PSPAL est pensadu pro PowerShell 5.1 o prus nou. Boles sighire e installare s’ùrtima versione cumpatìbile? (s/n)"
    $continue = Read-Host
    if ($continue -ne "s") {
        exit
    }
    $InstallPWSH = $true
    $needsWinget = $true
    Write-Host "Nota: su script sighit in custa istàntzia de PowerShell, no est netzessàriu torrare a aviare."
}
# controllu de Windows Terminal
if (-not (Get-Command wt.exe -ErrorAction SilentlyContinue)) {
    Write-Host "Windows Terminal no est installadu. Boles installare·lu como? (s/n)"
    $installWT = Read-Host
    if ($installWT -ne "s") {
        Write-Host "Windows Terminal est netzessàriu pro PSPAL. Installatzione interrùmpida."
        exit
    }
    $InstallTerminal = $true
    $needsWinget = $true
    Write-Host "Nota: su script sighit in custa istàntzia de PowerShell, no est netzessàriu torrare a aviare."
}

# controllu optzionale de AutoHotkey
if (-not (Get-Command ahk.exe -ErrorAction SilentlyContinue)) {
    Write-Host "AutoHotkey no est netzessàriu, ma est ùtile pro personalizare s’avviu de PSPAL."
    Write-Host "Unu script .ahk e s’executàbile suo ant a èssere inclùdidos. [Alt+Space] → wt.exe -p 'PSPal'."
    Write-host "Boles installare AutoHotkey? (s/n)"
    $installAHK = Read-Host
    if ($installAHK -eq "s") {
        $installAHK = $true
        $needsWinget = $true
    } else {
        $installAHK = $false
    }
}

# controllu de winget
if ($needsWinget -and -not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
    Write-Warning "Winget (Windows Package Manager) no est disponìbile in custu sistema."
    Write-Host "Winget est netzessàriu pro installare is cumpunentes chi mancant."
    Write-Host "Podes installare·lu iscarrighende 'App Installer' dae su Microsoft Store:"
    Write-Host "→ https://apps.microsoft.com/store/detail/app-installer/9NBLGGH4NNS1"
    Write-Host "A pustis de s’installatzione, torra a aviare custu script."
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
#endregion

#region Cartella de installatzione
$defaultInstallDir = "$env:USERPROFILE\PSPAL"
$installDir = Read-Host "Inserta sa cartella de installatzione (predefinida: $defaultInstallDir)"
if ([string]::IsNullOrEmpty($installDir)) {
    $installDir = $defaultInstallDir
}
#endregion

#region Creare is cartellas
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
    Write-Host "Cartella creada: $installDir"
}
if (-not (Test-Path "$installDir\temp")) {
    New-Item -ItemType Directory -Path "$installDir\temp" -Force | Out-Null
}

Write-Host "Installende PSPAL in: $installDir`n"
#endregion

#region Iscarrigamentu de is files

# controllu pro unu zip locale
if (Test-Path ".\customPspal.touse.zip") {
    Write-Host "Zip locale agatadu. Impreadu pro s’installatzione..." -NoNewline
    Move-Item ".\customPspal.touse.zip" "$installDir\temp\Pspal.zip" -Force
    $localZip = "$installDir\temp\Pspal.zip"
} else {
    Write-Host "`nIscarrighende is files de PSPAL..."

    $owner = "gioacchinon"
    $repo = "PSPAL"
    $zipUrl = "https://github.com/$owner/$repo/archive/refs/heads/main.zip"
    $localZip = "$InstallDir\temp\PSPAL.zip"

    try {
        Write-Host "⬇️ Iscarrighende dae $zipUrl..." -NoNewline
        Invoke-WebRequest -Uri $zipUrl -OutFile $localZip
        Write-Host "Fatu.✨"
    }
    catch {
        Write-Warning "Faddina in s’iscarrigamentu de is files de PSPAL: $_"
        exit
    }
}

try {
    Write-Host "📤 Ispacende su zip..." -NoNewline
    Expand-Archive -Path $localZip -DestinationPath "$InstallDir\temp" -Force
    Move-Item -Path "$InstallDir\temp\$repo-main\*" -Destination $InstallDir -Force
    Write-Host "Fatu.✨"
    Write-Host "🫧 Nettende..." -NoNewline
    Remove-Item -Path "$InstallDir\temp" -Recurse -Force
    Write-Host "Fatu.✨"
}
catch {
    Write-Warning "Faddina in s’iscarrigamentu o in s’ispacadura: $_"
    exit
}
#endregion

#region Atualizatzione de su profilu PowerShell
Write-Host "`nAtualizende su profilu de PowerShell..."
try {
    $profileSwitch = $PROFILE
    $profilePath = Read-Host "In ue boles mòvere su profilu de usuàriu atuale? (predefinidu: $env:USERPROFILE\profile\user.ps1)"
    if ([string]::IsNullOrEmpty($profilePath)) {
        $profilePath = "$env:USERPROFILE\profile\user.ps1"
    }

    $profileDir = Split-Path $profilePath
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    if (Test-Path $profilePath) {
        Copy-Item -Path $profilePath -Destination "$profilePath.bak" -Force
    } else {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    if (Test-Path $profileSwitch) {
        Copy-Item -Path $profileSwitch -Destination "$profileSwitch.bak" -Force
        Copy-Item -Path $profileSwitch -Destination $profilePath -Force
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
        . $profilePath    
    }
}
"@

    Set-Content -Path $profileSwitch -Value $switchContent -Force
    Write-Host "Profilu de PowerShell atualizadu.✨"
}
catch {
    Write-Warning "Faddina in s’actualizatzione de su profilu: $_"
}
#endregion

#region Profilu de Windows Terminal
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
Copy-Item $settingsPath "$settingsPath.bak" -Force

if (-not (Test-Path $settingsPath)) {
    Write-Warning "settings.json de Windows Terminal no agatadu in $settingsPath"
    Write-Host "Assegura·ti chi Windows Terminal siat installadu e abertu a su mancu una borta."
} else {
    try {
        $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json

        $palguid = "{" + ([guid]::NewGuid().ToString()) + "}"

        $newPalProfile = @{
            name = "PSPAL"
            icon = "$installDir\icons\icon.ico"
            environment = @{
                WT_PROFILE_NAME = "PSPal"
            }
            startingDirectory = "$env:USERPROFILE"
            commandline = "pwsh.exe"
            guid = $palguid
            hidden = $false 
        }

        $usrguid = "{" + ([guid]::NewGuid().ToString()) + "}"

        $newUserProfile = @{
            name = [System.Environment]::UserName.ToString()
            icon = "ms-appx:///ProfileIcons/pwsh.png"
            environment = @{
                WT_PROFILE_NAME = "PS"
            }
            startingDirectory = "$env:USERPROFILE"
            commandline = "pwsh.exe"
            guid = $usrguid
            hidden = $false 
        }

        $settings.profiles.list += $newPalProfile
        $settings.profiles.list += $newUserProfile

        $settings.defaultProfile = $usrguid

        $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath -Force

        Write-Host "Profilu 'PSPAL' agiuntu e impostadu comente predefinidu.✨"
    } catch {
        Write-Warning "Faddina in s’actualizatzione de is cunfiguratziones de Windows Terminal: $_" 
    }
}
#endregion

#region Collegamentu de avviu
Write-Host "Creende unu collegamentu de avviu..." -NoNewline
$startupFolder = [System.Environment]::GetFolderPath('Startup')
$WScriptShell = New-Object -ComObject WScript.Shell
$shortcut = $WScriptShell.CreateShortcut("$startupFolder\PSPAL.lnk")
$shortcut.TargetPath = "$InstallDir\ahk\PSPAL.exe"
$shortcut.WorkingDirectory = "$InstallDir\ahk"
$shortcut.IconLocation = "$InstallDir\icons\icon.ico"
$shortcut.Save()
Start-Process "$InstallDir\ahk\PSPAL.exe"
Write-Host "Fatu."
#endregion

#region Messàgiu finale
Write-Host "`n============================================================"
Write-Host "   PSPAL est istadu installadu in: $installDir"
Write-Host "   Incarca [Alt]+[Space] 🛸"
Write-Host "============================================================`n"
#endregion

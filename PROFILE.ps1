# SET UP ----------------------------------------------------------------#

$datetime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$User = [System.Environment]::UserName
$PCName = [System.Environment]::MachineName
$global:previousDir = Get-Location
$currentDir = Get-Location
$charIndex = 0
$PaletteRoot = $PSScriptRoot

# load settings from settings.ps1 if it exists

$settingsPath = "$PSScriptRoot\settings.ps1"
$testsettingsPath = "$PSScriptRoot\testsettings.ps1"
. $settingsPath
. $testsettingsPath
. $settingsPath
if (-not (Test-Settings)) {
    Write-Error "Settings validation failed. Please fix your settings.ps1 file. [check README.md for help]"
    Read-Host "Press Enter to exit..."
    exit
}

#logging settings
if (-not (Test-Path $logFilePath)) {
    New-Item -Path $logFilePath -ItemType File -Force | Out-Null
}
function Log {
    param (
        [string]$action,
        [string]$level = "INFO"
    )
    if ($logtofile) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "$timestamp [$level] | $User@$PCName | $action"
            Add-Content -Path $logFilePath -Value $logEntry
    }
}


# INTERFACE -------------------------------------------------------------#

$message =  "$datetime | $User@$PCName | $currentDir`n | Palette Profile Loaded |`n"

$Welcome = @"

 ##### #####           ###
..### ..###           .###
 ..### ###    ######  .###
  ..#####    ###..### .###
   ..###    .### .### .###
    .###    .### .### ... 
    #####   ..######   ###
   .....     ......   ...
"@    

$colors = @("Red", "Yellow", "Green", "Cyan", "Blue", "Magenta")
Write-Host $message
foreach ($line in $welcome.Split("`n")) {
    $color = $colors[$($charIndex++ % $colors.Length)]
    Write-Host $line -ForegroundColor $color
}

Log $welcome

# Set a custom prompt
function Prompt {
    $currentDir = Get-Location
    if ($global:previousDir.path -ne $currentDir.path) {
        Write-Host "`n--- $previousDir -> $currentDir ---" -ForegroundColor Yellow
        $global:previousDir = $currentDir
    }
    $prompt = "●"
    Write-Host $prompt -NoNewline -ForegroundColor $FavColor
    return " "
}


# BUILTIN ---------------------------------------------------------------#

function Clear-Palette {
    Clear-Host
    Write-Host "Palette cleared." -ForegroundColor Green
    foreach ($line in $welcome.Split("`n")) {
        $color = $colors[$($charIndex++ % $colors.Length)]
        Write-Host $line -ForegroundColor $color
    }

}

function Restart-Palette {
    . $PaletteRoot\profile.ps1
    Clear-History
    log "Palette restarted."
}

function Set-TemporaryHistory {
    Set-PSReadLineOption -HistorySavePath "$PaletteRoot\temp_palette_history.txt"
    $logtofile = $false
}

function Set-PaletteHistory {
    Set-PSReadLineOption -HistorySavePath "$PaletteRoot\palette_history.txt"
    Remove-Item $PaletteRoot\temp_palette_history.txt -ErrorAction SilentlyContinue
}

# PLUGINS ---------------------------------------------------------------#

. $PaletteRoot\Pluggins\fuzzysearch.ps1

. $PaletteRoot\Pluggins\pinning.ps1
if (Test-Path $pinnedPath) {
    . $pinnedPath
}

. $PaletteRoot\Pluggins\browsing.ps1

. $PaletteRoot\Pluggins\time.ps1

. $PaletteRoot\Pluggins\notes.ps1


# ALIASES ---------------------------------------------------------------#

. $PaletteRoot\aliases.ps1

Set-PaletteHistory

# SET UP ----------------------------------------------------------------#

$datetime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$User = [System.Environment]::UserName
$PCName = [System.Environment]::MachineName
$global:PSPal_previousDir = Get-Location
$currentDir = Get-Location
$PaletteRoot = $PSScriptRoot

$PSPal_FunctionsBeforeLoading = Get-ChildItem Function:\ | Select-Object -ExpandProperty Name

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
if (-not (Test-Path $global:PSPal_logFilePath)) {
    New-Item -Path $global:PSPal_logFilePath -ItemType File -Force | Out-Null
}
function Log {
    param (
        [string]$action,
        [string]$level = "INFO"
    )
    if ($global:PSPal_LogToFile) {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "$timestamp [$level] | $User@$PCName | $action"
            Add-Content -Path $global:PSPal_logFilePath -Value $logEntry
    }
}

#history management
if ($global:PSPal_HistoryLifespan -gt 0) {
    $historyLifeCountPath = "$PaletteRoot\.historylifecount"
    $historyLifeCount = [int](Get-Content $historyLifeCountPath)
    $historyLifeCount += 1
    if ($global:PSPal_HistoryLifespan -lt $historyLifeCount) {
        Set-Content -Path "$PaletteRoot\Predictor\history" -Value ""
        $historyLifeCount = 1
    }
    Set-Content -Path $historyLifeCountPath -Value $historyLifeCount
}

# INTERFACE -------------------------------------------------------------#
function SayHello {

    $message = "| $datetime | $User@$PCName | $currentDir |`n| Palette Profile Loaded |`n"

    $Welcome = @'
··············································
:    88""Yb .dP"Y8 88""Yb    db    88        :
:    88__dP `Ybo." 88__dP   dPYb   88        :
:    88"""  o.`Y8b 88"""   dP__Yb  88  .o    :
:    88     8bodP' 88     dP""""Yb 88ood8    :
··············································
'@    

    Write-Host $message
    Write-Host $Welcome -ForegroundColor $global:PSPal_FavColor
    
}

SayHello
Log "started"

# Set a custom prompt
function Prompt {
    $currentDir = Get-Location
    if ($global:PSPal_previousDir.path -ne $currentDir.path) {
        Write-Host "`n--- $previousDir -> $currentDir ---" -ForegroundColor Yellow
        $global:PSPal_previousDir = $currentDir
    }
    $prompt = "●"
    Write-Host $prompt -NoNewline -ForegroundColor $global:PSPal_FavColor
    return " "
}


# BUILTIN ---------------------------------------------------------------#

function Clear-Palette {
    Clear-Host
    SayHello
}

function Restart-Palette {
    foreach ($function in $global:PSPal_FunctionsLoaded) {
        Remove-Item Function:\$function
    }
    Clear-History

    . $PaletteRoot\PROfILE.ps1
    log "Palette restarted."
}

function Set-TemporaryHistory {
    Set-PSReadLineOption -HistorySavePath "$PaletteRoot\temp_palette_history.txt"
    $global:PSPal_LogToFile = $false 
}

function Set-PaletteHistory {
    $historyPath = "$PaletteRoot\Predictor\history"

    Set-PSReadLineOption -HistorySavePath $historyPath
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

    Remove-Item "$PaletteRoot\temp_palette_history.txt" -ErrorAction SilentlyContinue
}

# PLUGINS ---------------------------------------------------------------#

. $PaletteRoot\Plugins\search\search.ps1

. $PaletteRoot\Plugins\pinning\pinning.ps1
if (Test-Path $global:PSPal_pinnedPath) {
    . $global:PSPal_pinnedPath
}

. $PaletteRoot\Plugins\browsing\browsing.ps1


# ALIASES ---------------------------------------------------------------#

. $PaletteRoot\aliases.ps1

# PREDICTOR -------------------------------------------------------------#

Set-PaletteHistory

$predictorDll = Join-Path $PaletteRoot "Predictor\PSPALPredictor.dll"
if (Test-Path $predictorDll) {
    try {
        Set-PSReadLineOption -PredictionSource HistoryAndPlugin
        Import-Module $predictorDll -Force -ErrorAction SilentlyContinue
        Log "Loaded predictor: $predictorDll"
    } catch {
        Log "Failed to load predictor: $predictorDll"
    }
}

$PSPal_FunctionsAfterLoading = Get-ChildItem Function:\ | Select-Object -ExpandProperty Name
$global:PSPal_FunctionsLoaded = Compare-Object $PSPal_FunctionsBeforeLoading $PSPal_FunctionsAfterLoading -PassThru | Where-Object { $_ -notin $PSPal_FunctionsBeforeLoading }
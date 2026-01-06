function Test-Settings {
    param (
        [string]$Path = $settingsPath
    )

    if (-not (Test-Path $Path)) {
        Write-Warning "Settings file not found at $Path."
        return $false
    }

    try {
        . $Path
    } catch {
        Write-Error "Error loading settings file: $_"
        return $false
    }

    $mandatoryVars = @(
        'PSPal_UserFilesDir',
        'PSPal_pinnedPath',
        'PSPal_logFilePath',
        'PSPal_logtofile',
        'PSPal_Editor',
        'PSPal_FavColor',
        'PSPal_SearchEngine',
        'PSPal_HistoryLifespan'
    )

    $missingVars = @()
    foreach ($var in $mandatoryVars) {
        if (-not (Get-Variable -Name $var -Scope Script -ErrorAction SilentlyContinue)) {
            $missingVars += $var
        }
    }

    if ($missingVars.Count -gt 0) {
        Write-Error "Missing mandatory settings: $($missingVars -join ', ')"
        return $false
    }

    # validate values
    if (-not (Test-Path $PSPal_UserFilesDir)) {
        Write-Warning "UserFilesDir path does not exist: $PSPal_UserFilesDir"
    }

    if (-not ($PSPal_SearchEngine -match '\{query\}')) {
        Write-Warning "SearchEngine URL missing '{query}' placeholder: $PSPal_SearchEngine"
    }

    return $true
}
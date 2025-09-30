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
        'UserFilesDir',
        'pinnedPath',
        'logFilePath',
        'logtofile',
        'Editor',
        'FavColor',
        'SearchEngine',
        'NotesPath'
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

    # Optional: validate values
    if (-not (Test-Path $UserFilesDir)) {
        Write-Warning "UserFilesDir path does not exist: $UserFilesDir"
    }

    if (-not ($SearchEngine -match '\{query\}')) {
        Write-Warning "SearchEngine URL missing '{query}' placeholder: $SearchEngine"
    }

    return $true
}
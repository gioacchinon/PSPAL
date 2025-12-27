function Pin {
    param(
        [Parameter(Mandatory)]
        [string]$InputItem,

        [Parameter(Mandatory)]
        [string]$AliasName
    )

    # --- DETECTION LOGIC ---
    $isURL      = $InputItem -match '^(http|https)://'
    $isFile     = Test-Path $InputItem
    $cmd        = Get-Command $InputItem -ErrorAction SilentlyContinue
    $isCommand  = $cmd -ne $null
    $isExe      = $isFile -and ($InputItem -match '\.(exe|bat|cmd|ps1)$')

    # protocol, but not drive letter
    $isProtocol = ($InputItem -match '^[a-zA-Z][a-zA-Z0-9+\-.]*:') -and
                  -not ($InputItem -match '^[a-zA-Z]:\\')

    # --- ACTION LOGIC ---
    if ($isURL) {
        $entry = "function global:$AliasName { start-process 'msedge' --app=`"$InputItem`" }"
        Add-Content -Path $pinnedPath -Value "`r`n$entry"
        . $pinnedPath

        Add-Content -Path $predictorPinnedPath -Value "`r`n$AliasName"
        Write-Host "Pinned URL $InputItem as $AliasName." -ForegroundColor Green
        Log "Pinned URL $InputItem as $AliasName."
    }
    elseif ($isFile) {
        $entry = "function global:$AliasName { start-process `"$InputItem`" }"
        Add-Content -Path $pinnedPath -Value "`r`n$entry"
        . $pinnedPath

        Add-Content -Path $predictorPinnedPath -Value "`r`n$AliasName"
        Write-Host "Pinned file $InputItem as $AliasName." -ForegroundColor Green
        Log "Pinned file $InputItem as $AliasName."
    }
    elseif ($isProtocol -and -not $isURL) {
        $entry = "function global:$AliasName { start-process `"$InputItem`" }"
        Add-Content -Path $pinnedPath -Value "`r`n$entry"
        . $pinnedPath

        Add-Content -Path $predictorPinnedPath -Value "`r`n$AliasName"
        Write-Host "Pinned protocol $InputItem as $AliasName." -ForegroundColor Green
        Log "Pinned protocol $InputItem as $AliasName."
    }
    elseif ($isExe) {
        $entry = "function global:$AliasName { start-process `"$InputItem`" }"
        Add-Content -Path $pinnedPath -Value "`r`n$entry"
        . $pinnedPath

        Add-Content -Path $predictorPinnedPath -Value "`r`n$AliasName"
        Write-Host "Pinned application $InputItem as $AliasName." -ForegroundColor Green
        Log "Pinned application $InputItem as $AliasName."
    }
    elseif ($isCommand) {
        Add-Content -Path $predictorPinnedPath -Value $InputItem
        Write-Host "Pinned command '$InputItem'." -ForegroundColor Green
        Log "Pinned command $InputItem."
    }
    else {
        Write-Host "Could not determine type of input: $InputItem" -ForegroundColor Yellow
        Log "Failed to pin: $InputItem" "WARNING"
    }
}
function Get-Pinned {
    if (Test-Path $pinnedPath) {
        Get-Content $pinnedPath | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
        Log "Displayed pinned applications and URLs."
    } else {
        Write-Host "No pinned applications or URLs found." -ForegroundColor Yellow
        Log "No pinned applications or URLs to display." "WARNING"
    }
}

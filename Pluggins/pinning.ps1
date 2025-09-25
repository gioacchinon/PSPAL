function PinApp {
    param (
        [string]$appPath,
        [string]$aliasName
    )

    $entry = "function global:$aliasName {start-process `"$appPath`"}"
    Add-Content -Path $pinnedPath -Value $entry
    . $pinnedPath
    Write-Host "Pinned $appPath as $aliasName." -ForegroundColor Green
    Log "Pinned application $appPath as $aliasName."
}

function PinURLandFile {
    param (
        [string]$URL,
        [string]$aliasName
    )
    $entry = "function global:$aliasname {'msedge' --app=`"$URL`"}"
    Add-Content -Path $pinnePath -Value $entry
    . $pinnedPath
    Write-Host "Pinned $URL as $aliasName." -ForegroundColor Green
    Log "Pinned application $URL as $aliasName."
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

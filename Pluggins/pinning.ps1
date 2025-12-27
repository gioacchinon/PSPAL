#ToDo: unify above functions into one that automatically distinguish between apps, commands, files or web urls

function PinApp {
    param (
        [string]$appPath,
        [string]$aliasName
    )

    $entry = "function global:$aliasName {start-process `"$appPath`"}"
    Add-Content -Path $pinnedPath -Value $entry
    . $pinnedPath
    Add-Content -Path $predictorPinnedPath -Value $aliasName
    Write-Host "Pinned $appPath as $aliasName." -ForegroundColor Green
    Log "Pinned application $appPath as $aliasName."
}

function PinCommand {
    param (
        [string]$command
    )
    Add-Content -Path $predictorPinnedPath -Value $command
}

function PinURLandFile {
    param (
        [string]$URL,
        [string]$aliasName
    )
    $entry = "function global:$aliasname {start-process 'msedge' --app=`"$URL`"}"
    Add-Content -Path $pinnedPath -Value $entry
    . $pinnedPath
    
    Add-Content -Path $predictorPinnedPath -Value $aliasName
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

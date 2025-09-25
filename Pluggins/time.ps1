
function Start-TUIClock {
    while ($true) {
        $currentTime = Get-Date -Format "HH:mm:ss"
        Write-Host "`r$currentTime" -NoNewline
        Start-Sleep -Seconds 1
    }
}

function Start-GUIClock {
    Start-Process -FilePath "detui" -ArgumentList "time"
}

function Start-BinClock {
    Start-Process -FilePath "detui" -ArgumentList "bintime"
}

function Start-Stopwatch {
    Start-Process -FilePath "detui" -ArgumentList "binstopwatch"
}

function Start-Timer {
    param (
        [int]$seconds
    )
    Start-Process -FilePath "detui" -ArgumentList ("timer", "$seconds")
}

function Start-BinTimer {
    param (
        [int]$seconds
    )
    Start-Process -FilePath "detui" -ArgumentList ("bintimer", "$seconds")
}
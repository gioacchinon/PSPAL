
<#
.SYNOPSIS
    Displays a real-time TUI (Text User Interface) clock

.DESCRIPTION
    Shows the current time in HH:mm:ss format in the terminal, updating every second.
    Press Ctrl+C to stop the clock.

.EXAMPLE
    Start-TUIClock
    Displays a continuously updating clock in the terminal

.NOTES
    This function runs in an infinite loop. Use Ctrl+C to exit.
#>
function Start-TUIClock {
    while ($true) {
        $currentTime = Get-Date -Format "HH:mm:ss"
        Write-Host "`r$currentTime" -NoNewline
        Start-Sleep -Seconds 1
    }
}

<#
.SYNOPSIS
    Launches a GUI clock using detui

.DESCRIPTION
    Opens a graphical clock display using the detui utility.

.EXAMPLE
    Start-GUIClock
    Launches the GUI clock

.NOTES
    Requires detui to be installed and available in PATH.
#>
function Start-GUIClock {
    Start-Process -FilePath "detui" -ArgumentList "time"
}

<#
.DESCRIPTION
    Opens a binary (LED-style) clock display using the detui utility.

.EXAMPLE
    Start-BinClock
    Launches the binary clock

.NOTES
    Requires detui to be installed and available in PATH.
#>
function Start-BinClock {
    Start-Process -FilePath "detui" -ArgumentList "bintime"
}

<#
.DESCRIPTION
    Opens a stopwatch display using the detui utility for timing events and activities.

.EXAMPLE
    Start-Stopwatch
    Launches the stopwatch

.NOTES
    Requires detui to be installed and available in PATH.
#>
function Start-Stopwatch {
    Start-Process -FilePath "detui" -ArgumentList "binstopwatch"
}

<#
.SYNOPSIS
    Starts a countdown timer for a specified duration

.DESCRIPTION
    Launches a GUI timer that counts down from the specified number of seconds using the detui utility.

.PARAMETER seconds
    The duration of the timer in seconds.

.EXAMPLE
    Start-Timer 300
    Starts a 5-minute timer

.EXAMPLE
    Start-Timer 60
    Starts a 1-minute timer

.NOTES
    Requires detui to be installed and available in PATH.
#>
function Start-Timer {
    param (
        [int]$seconds
    )
    Start-Process -FilePath "detui" -ArgumentList ("timer", "$seconds")
}

<#
.SYNOPSIS
    Starts a binary countdown timer for a specified duration

.DESCRIPTION
    Launches a binary (LED-style) countdown timer using the detui utility.

.PARAMETER seconds
    The duration of the timer in seconds.

.EXAMPLE
    Start-BinTimer 300
    Starts a 5-minute binary timer

.NOTES
    Requires detui to be installed and available in PATH.
#>
function Start-BinTimer {
    param (
        [int]$seconds
    )
    Start-Process -FilePath "detui" -ArgumentList ("bintimer", "$seconds")
}
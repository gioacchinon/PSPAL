function Select-FromList {
    param(
        [string[]]$Items,
        $maxVisible = [Math]::Max(1, [Math]::Min($Items.Count, $Host.UI.RawUI.WindowSize.Height - 3))
        )

    if ($Items.Count -eq 1) {
        return $Items[0]
    }

    $index = 0
    $key = $null

    # Enter alternate screen
    Write-Host "`e[?1049h"
    Write-Host "`e[2J`e[H"
    # Hide cursor
    Write-Host "`e[?25l"


    $origLeft = 0
    $origTop = 0

    $width = $Host.UI.RawUI.WindowSize.Width

    function Get-DisplayWidth {
        param([string]$Text)

        $width = 0

        foreach ($rune in $Text.EnumerateRunes()) {
            $cp = $rune.Value

            if (
                # CJK Unified Ideographs
                ($cp -ge 0x4E00 -and $cp -le 0x9FFF) -or
                # CJK Extensions
                ($cp -ge 0x3400 -and $cp -le 0x4DBF) -or
                ($cp -ge 0x20000 -and $cp -le 0x2A6DF) -or
                # Hiragana
                ($cp -ge 0x3040 -and $cp -le 0x309F) -or
                # Katakana
                ($cp -ge 0x30A0 -and $cp -le 0x30FF) -or
                # Hangul
                ($cp -ge 0xAC00 -and $cp -le 0xD7AF) -or
                # Fullwidth forms
                ($cp -ge 0xFF00 -and $cp -le 0xFFEF) -or
                # Emoji (basic range)
                ($cp -ge 0x1F300 -and $cp -le 0x1FAFF) -or
                # Supplemental Symbols and Pictographs
                ($cp -ge 0x1F900 -and $cp -le 0x1F9FF) -or
                # Symbols and Pictographs Extended-A
                ($cp -ge 0x1FA70 -and $cp -le 0x1FAFF) -or
                # Misc Symbols
                ($cp -ge 0x2600 -and $cp -le 0x26FF)
            ) {
                $width += 2
            }
            else {
                $width += 1
            }
        }

        return $width
    }

    function Pad-DisplayWidth {
        param(
            [string]$Text,
            [int]$TargetWidth = $Host.UI.RawUI.WindowSize.Width
        )

        $current = Get-DisplayWidth $Text
        $pad = $TargetWidth - $current

        if ($pad -gt 0) {
            return $Text + (" " * $pad)
        } else {
            return $Text
        }
    }

    function Write-CleanLine(
        [string]$text,
        [string]$color = "Black"
    ) {
        Write-Host (Pad-DisplayWidth $text) -NoNewline -BackgroundColor $color
        Write-Host ""
    }

    function RenderMenu {
        [Console]::SetCursorPosition($origLeft, $origTop)

        Write-CleanLine "Select a file (↑↓, Enter):"

        # Compute scrolling window
        $start = [Math]::Max(0, $index - [int]($maxVisible / 2))
        if ($start + $maxVisible - 1 -ge $Items.Count) {
            $start = [Math]::Max(0, $Items.Count - $maxVisible)
        }

        $end = [Math]::Min($Items.Count - 1, $start + $maxVisible - 1)

        for ($i = $start; $i -le $end; $i++) {
            if ($i -eq $index) {
                Write-CleanLine "> $($Items[$i])" "DarkMagenta"
            }
            else {
                Write-CleanLine "  $($Items[$i])"
            }
        }

        # Fill remaining lines
        $printed = ($end - $start + 1)
        for ($i = $printed; $i -lt $maxVisible; $i++) {
            Write-CleanLine ""
        }
    }

    RenderMenu

    while ($key -ne "Enter" -and $key -ne "Escape") {
        $keyInfo = [Console]::ReadKey($true)
        $key = $keyInfo.Key

        switch ($key) {
            "UpArrow" { if ($index -gt 0) { $index-- } }
            "DownArrow" { if ($index -lt $Items.Count - 1) { $index++ } }
        }

        RenderMenu
    }

    # Show cursor
    Write-Host "`e[?25h"

    # Exit alternate screen
    Write-Host "`e[?1049l"
    Write-Host "`e[0m"

    if ($key -eq "Enter"){
        return $Items[$index]
    } else {
        return $null
    }
}

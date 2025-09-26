function New-Note {
    param (
        $content = "",
        $title = "",
        $path = "$NotesRoot\$DefaultNote"
    )

    if (-not (Test-Path $NotesRoot)) {
        New-Item -ItemType Directory -Path $NotesRoot -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $entry =
@"
$timestamp $user@$pcname
------------------------
$title

$content

========================
"@

    Add-Content -Path $path -Value $entry
    Write-Host "Note added to $path"
    Log "Note added to $path"
    
}

function Get-Note {
    param (
        $searchterm = $null,
        $index = -1,
        $path = "$NotesRoot\$DefaultNote"
    )
    if (-not (Test-Path $path)) {
        Write-Host "No notes found at $path"
        return
    }
    # gather all notes, split by ======
    $notes = Get-Content -Path $path -Raw -ErrorAction SilentlyContinue
    $notes = $notes -split "========================" | Where-Object { $_.Trim() -ne "" }
    if ($searchterm) {
        $filteredNotes = $notes | Where-Object { $_ -match "(?i)$([regex]::Escape($searchterm))" }
        if ($filteredNotes.Count -eq 0) {
            Write-Host "No notes found matching '$searchterm'"
            return
        }
        $notes = $filteredNotes
    }

    $maxIndex = $notes.Count - 1

    if ($index -ge $notes.Count) {
        Write-Host "Index $index is out of range. Max index is $maxIndex."
        return
    }

    # If index is negative, show all notes
    if ($index -ge 0 -and $index -le $maxIndex) {
        $notes = $notes[$index]
    }

    if ($notes) {
        Write-Host $notes
    } else {
        Write-Host "No notes found."
    }
}

function Remove-Note {
    param (
        $index,
        $path = "$NotesRoot\$DefaultNote"
    )
    if (-not (Test-Path $path)) {
        Write-Host "No notes found at $path"
        return
    }
    # gather all notes, split by ======
    $notes = Get-Content -Path $path -Raw -ErrorAction SilentlyContinue
    $notes = $notes -split "========================" | Where-Object { $_.Trim() -ne "" }

    if ($index -ge $notes.Count) {
        Write-Host "Index $index is out of range. Max index is $(($notes.Count) - 1)."
        return
    }

    if ($index -lt 0) {
        Write-Host "Index must be a non-negative integer."
        return
    }

    $removedNote = $notes[$index]
    $notes = $notes | Where-Object { $_ -ne $removedNote }

    # Join notes back with separator and save to file
    $notesString = ($notes -join "`n========================`n")
    Set-Content -Path $path -Value $notesString

    Write-Host "Removed note at index $index from $path"
    Log "Removed note at index $index from $path"
}

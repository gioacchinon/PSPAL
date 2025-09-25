function FuzzySearch {
    param (
        [string]$searchTerm,
        [string]$directory = $UserFilesDir
    )

    if (-not $searchTerm) {
        Write-Host "Please provide a search term." -ForegroundColor Yellow
        Log "FuzzySearch called without a search term." "WARNING"
        return
    }

    $files = Get-ChildItem $directory -Recurse -File | Where-Object { $_.Name -like "*$searchTerm*" }
    if ($files) {
        $files | ForEach-Object { Write-Host $_.FullName -ForegroundColor Cyan }
        Log "FuzzySearch found files matching '$searchTerm'."
        return $files.FullName
    } else {
        Write-Host "No files found matching '$searchTerm'." -ForegroundColor Red
        Log "FuzzySearch found no files matching '$searchTerm'." "WARNING"
    }
}

function Start-SearchedFile { #AKA Fuzzy Open
    param (
        [string]$searchTerm,
        [string]$directory = $UserFilesDir
    )
    $results = FuzzySearch $searchTerm $directory
    if ($results) {
        $fileToOpen = $results | Select-Object -First 1
        Log "Opening file '$fileToOpen'."
        Start-Process $fileToOpen
    } else {
        Log "No files found to open for search term '$searchTerm'." "WARNING"
        Write-Host "No files found to open." -ForegroundColor Red
    }
}

function Get-SearchedFile { #AKA Fuzzy Print
    param (
        [string]$searchTerm,
        [string]$directory = $UserFilesDir
    )
    $results = FuzzySearch $searchTerm $directory
    if ($results) {
        $fileToEdit = $results | Select-Object -First 1
        Get-Content $fileToEdit
        Log "Displayed content of file '$fileToEdit'."
    } else {
        Write-Host "No files found to edit." -ForegroundColor Red
        Log "No files found to display for search term '$searchTerm'." "WARNING"
    }
}

function Edit-SearchedFile { #AKA Fuzzy Edit
    param (
        [string]$searchTerm,
        [string]$directory = $UserFilesDir
    )
    $results = FuzzySearch $searchTerm $directory
    if ($results) {
        $fileToEdit = $results | Select-Object -First 1
        & $Editor $fileToEdit
        Log "Edited file $fileToEdit with editor $Editor."
    } else {
        Write-Host "No files found to edit." -ForegroundColor Red
        Log "No files found to edit for search term $searchTerm." "WARNING"
    }
}
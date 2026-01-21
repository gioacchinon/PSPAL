. $Paletteroot\plugins\search\selectFromList.ps1

<#
.SYNOPSIS
    Performs a fuzzy search for files matching a search term

.DESCRIPTION
    Recursively searches a directory for files containing the search term in their filename.
    Uses wildcard matching for flexible file discovery.

.PARAMETER searchTerm
    The file name pattern to search for. Supports wildcards.

.PARAMETER directory
    The directory to search in. Defaults to $PSPal_UserFilesDir.

.EXAMPLE
    FuzzySearch "report"
    Finds all files with "report" in their name

.EXAMPLE
    FuzzySearch "config" -directory "C:\configs"
    Searches C:\configs for files matching "config"
#>
function FuzzySearch {
    param (
        [string]$searchTerm,
        [string]$directory = $global:PSPal_UserFilesDir
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

<#
.SYNOPSIS
    Opens the first file matching the search term

.DESCRIPTION
    Performs a fuzzy search for files and opens the first matching file with the default handler.

.PARAMETER searchTerm
    The file name pattern to search for.

.PARAMETER directory
    The directory to search in. Defaults to $PSPal_UserFilesDir.

.EXAMPLE
    Start-SearchedFile "document"
    Finds and opens the first file containing "document" in its name
#>
function Start-SearchedFile { #AKA Fuzzy Open
    param (
        [string]$searchTerm,
        [string]$directory = $global:PSPal_UserFilesDir
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

<#
.SYNOPSIS
    Displays the content of the first file matching the search term

.DESCRIPTION
    Performs a fuzzy search for files and displays the content of the first matching file.

.PARAMETER searchTerm
    The file name pattern to search for.

.PARAMETER directory
    The directory to search in. Defaults to $PSPal_UserFilesDir.

.EXAMPLE
    Get-SearchedFile "config"
    Finds and displays the content of the first file containing "config" in its name
#>
function Get-SearchedFile { #AKA Fuzzy Print
    param (
        [string]$searchTerm,
        [string]$directory = $global:PSPal_UserFilesDir
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

<#
.SYNOPSIS
    Opens the first file matching the search term in the configured editor

.DESCRIPTION
    Performs a fuzzy search for files and opens the first matching file with the configured editor.
    Editor is specified in $PSPal_Editor.

.PARAMETER searchTerm
    The file name pattern to search for.

.PARAMETER directory
    The directory to search in. Defaults to $PSPal_UserFilesDir.

.EXAMPLE
    Edit-SearchedFile "config"
    Finds and opens the first file containing "config" in its name with the default editor
#>
function Edit-SearchedFile { #AKA Fuzzy Edit
    param (
        [string]$searchTerm,
        [string]$directory = $global:PSPal_UserFilesDir
    )
    $results = FuzzySearch $searchTerm $directory
    if ($results) {
        $fileToEdit = $results | Select-Object -First 1
        & $global:PSPal_Editor $fileToEdit
        Log "Opened file $fileToEdit with editor $global:PSPal_Editor."
    } else {
        Write-Host "No files found to edit." -ForegroundColor Red
        Log "No files found to edit for search term $searchTerm." "WARNING"
    }
}
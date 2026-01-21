#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generates help documentation for all PSPAL functions.

.DESCRIPTION
    This script scans the PSPAL directory structure and collects help information
    for all PowerShell functions defined in the project. It can display help to the
    console or export to a markdown file.

.PARAMETER OutputPath
    Optional path to save the help documentation as markdown. If not specified,
    help is displayed to the console.

.PARAMETER Function
    Optional specific function name to get help for. If not specified, all functions
    are documented.

.EXAMPLE
    # Display all function help to console
    .\Get-PSPALFunctionsHelp.ps1

.EXAMPLE
    # Export all function help to markdown file
    .\Get-PSPALFunctionsHelp.ps1 -OutputPath "PSPAL-Functions.md"

.EXAMPLE
    # Get help for a specific function
    .\Get-PSPALFunctionsHelp.ps1 -Function "Log"
#>

param(
    [string]$OutputPath,
    [string]$Function
)

# Get the PSPAL root directory (parent of doc folder)
$PSPALRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Find all PowerShell files
$psFiles = Get-ChildItem -Path $PSPALRoot -Filter "*.ps1" -Recurse -Exclude "*.ahk" | 
    Where-Object { $_.FullName -notlike "*\.git*" }

# Dictionary to store function information
$functions = @{}

# Parse each PS1 file for function definitions
foreach ($file in $psFiles) {
    try {
        $content = Get-Content -Path $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($null -eq $content) { continue }

        # Find all function declarations
        $functionMatches = [regex]::Matches($content, 'function\s+(\w+)\s*{', [System.Text.RegularExpressions.RegexOptions]::Multiline)
        
        foreach ($match in $functionMatches) {
            $funcName = $match.Groups[1].Value
            
            # Try to get comment-based help
            $helpMatch = [regex]::Match($content, "(?s)\.\s*<#(.+?)#>.*?function\s+$funcName\s*{", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
            
            if ($helpMatch.Success) {
                $helpText = $helpMatch.Groups[1].Value
            } else {
                $helpText = "(No help available)"
            }
            
            $functions[$funcName] = @{
                Name = $funcName
                File = $file.FullName.Replace($PSPALRoot, "").TrimStart("\")
                Help = $helpText
            }
        }
    }
    catch {
        Write-Warning "Error processing file $($file.FullName): $_"
    }
}

# Filter by specific function if requested
if ($Function) {
    $functionsToDocument = $functions | Where-Object { $_.Keys -match "^$Function$" }
} else {
    $functionsToDocument = $functions
}

# Generate output
$output = @()
$output += "# PSPAL Functions Reference"
$output += ""
$output += "This document contains help information for all functions defined in PSPAL."
$output += ""
$output += "**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$output += ""
$output += "## Functions"
$output += ""

foreach ($funcName in ($functionsToDocument.Keys | Sort-Object)) {
    $func = $functionsToDocument[$funcName]
    
    $output += "### $($func.Name)"
    $output += ""
    $output += "**File:** ``$PSPAL/$($func.File)``"
    $output += ""
    $output += "**Help:**"
    $output += ""
    $output += $func.Help
    $output += ""
    $output += "---"
    $output += ""
}

# Output results
if ($OutputPath) {
    $output | Out-File -FilePath $OutputPath -Encoding UTF8
    Write-Host "Function documentation exported to: $OutputPath" -ForegroundColor Green
} else {
    $output | Out-Host
}

Write-Host "Total functions documented: $($functionsToDocument.Count)" -ForegroundColor Cyan

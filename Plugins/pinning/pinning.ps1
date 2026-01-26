function New-PinnedEntry {
    param ([String]$fn, [string]$alias)

    try {
        Add-Content -Path $global:PSPal_pinnedPath -Value "`r`nfunction global:$alias {$fn}"
        Add-Content -Path $global:PSPal_predictorPinnedPath -Value $alias
        . $global:PSPal_pinnedPath
        return $true
    }
    catch {
        return $false
    }
}

function Convert-FunctionName {
    param([string]$Name)

    $sanitized = $Name -replace '[^a-zA-Z0-9_-]', '_'
    
    $sanitized = $sanitized -replace '-{2,}', '-'

    return $sanitized
}

<#
.SYNOPSIS
    Pins a URL, file, command, or protocol to create a quick-access alias

.DESCRIPTION
    Creates a persistent alias for various types of input including URLs, files, applications, commands, and protocols.
    The alias is stored in the pinned file and available in all new PowerShell sessions.

.PARAMETER InputItem
    The URL, file path, command name, or protocol to pin. Mandatory parameter.

.PARAMETER AliasName
    The name of the alias to create. Defaults to the input item name if not specified.

.EXAMPLE
    Pin "https://www.example.com" "example"
    Creates an alias 'example' that opens the website

.EXAMPLE
    Pin "C:\tools\app.exe" "myapp"
    Creates an alias 'myapp' that launches the application

.EXAMPLE
    Pin "npm" "n"
    Creates an alias 'n' for the npm command
#>
function Pin {
    param(
        [Parameter(Mandatory)][string]$InputItem,
        [Parameter()][string]$AliasName = $InputItem
    )

    $isURL = $InputItem -match '^https?://'
    $isFile = Test-Path $InputItem
    if ($isFile) { $InputItem = Get-Item $InputItem | Select-Object -ExpandProperty FullName }
    $isPs1 = $isFile -and ($InputItem -match '\.ps1$')
    $isExe = $isFile -and ($InputItem -match '\.(exe|bat|cmd)$')
    $isCommand = -not $isFile -and ($null -ne (Get-Command $InputItem -EA SilentlyContinue))
    $protocolName = $InputItem.Split(':')[0]
    $isProtocol = -not $isURL -and ($InputItem -match '^[a-zA-Z][a-zA-Z0-9+\-.]*:') -and -not ($InputItem -match '^[a-zA-Z]:') -and 
    ( (Test-Path "HKCU:\Software\Classes\$protocolName") -or (Test-Path "HKLM:\Software\Classes\$protocolName") -or (Test-Path "HKCR:\$protocolName" ))
    
    if ($isURL) { $type = 'URL' }
    elseif ($isPs1) { $type = 'powershell script' }
    elseif ($isExe) { $type = 'application' }
    elseif ($isFile) { $type = 'file' }
    elseif ($isCommand) { $type = 'command' }
    elseif ($isProtocol) { $type = 'protocol' }
    else {
        Write-Host "Could not determine type of input: $InputItem" -ForegroundColor Yellow
        $type = 'Unidentified'
    }

    if ($isURL) {
        $browser = $global:PSPal_BrowserProvider
        $urlArg = $browser.URLLauncher -replace "<URL>", $inputItem
        $entry = "start-process '$($browser.Command)' -ArgumentList '$urlArg'"
    }
    elseif ($isPs1) {
        $entry = "pwsh -File '$inputItem'"

    }
    else {
        $entry = "start-process '$inputItem'"
    }

    if ($isCommand) {
        Add-Content -Path $global:PSPal_predictorPinnedPath -Value $InputItem
        $success = $true
    }
    else {
        $AliasName = Convert-FunctionName $AliasName
        $success = New-PinnedEntry $entry $AliasName
    }

    if ($success) {
        $message = "Pinned $type $InputItem as $AliasName."
        Write-Host $message -ForegroundColor Green
        Log $message
    }
    else {
        $message = "Failed to pin $type $InputItem as $AliasName."
        Write-Host $message -ForegroundColor Yellow
        Log $message "WARNING"
    }
}

<#
.SYNOPSIS
    Displays all pinned aliases and URLs

.DESCRIPTION
    Lists all previously pinned applications, URLs, commands, and other pinned items stored in the pinned file.

.EXAMPLE
    Get-Pinned
    Displays all pinned items

.NOTES
    Pinned items are stored in $PSPal_pinnedPath file.
#>
function Get-Pinned {
    if (Test-Path $global:PSPal_pinnedPath) {
        Get-Content $global:PSPal_pinnedPath | ForEach-Object {
            Write-Host $_ -ForegroundColor Cyan
        }
        Log "Displayed pinned applications and URLs."
    }
    else {
        Write-Host "No pinned applications or URLs found." -ForegroundColor Yellow
        Log "No pinned applications or URLs to display." "WARNING"
    }
}

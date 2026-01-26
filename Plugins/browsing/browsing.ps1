
<#
.SYNOPSIS
    Launches a website in set browser

.DESCRIPTION
    Opens the specified URL in set browser. Supports both normal and private browsing modes.

.PARAMETER URL
    The website URL to open. If not provided, Edge launches normally.

.PARAMETER Private
    Switch to open the website in private browsing mode.

.EXAMPLE
    Start-Website "https://www.example.com"
    Opens example.com in Edge

.EXAMPLE
    Start-Website "https://www.example.com" -Private
    Opens example.com in Edge private mode
#>
function Start-Website {
    param (
        [string]$URL,
		[switch]$Private
    )

    try {
        $browser = $global:PSPal_BrowserProvider
        $arguments = @()
        
        if ($Private) {
            $arguments += $browser.PrivateTag
        }
        
        if ($URL) {
            $urlArg = $browser.URLLauncher -replace "<URL>", $url
            $arguments += $urlArg
        }
        
        Start-Process $browser.Command -ArgumentList $arguments
        Log "Opened website '$URL'."
    }
    catch {
        Write-Host "couldn't launch the browser" -ForegroundColor Yellow
        return
    }
    Write-Host "Opened website '$URL'." -ForegroundColor Green
}

<#
.SYNOPSIS
    Performs a web search using the configured search engine

.DESCRIPTION
    Searches the web using the specified search engine. Default engine is configured in PSPal settings.
    Results are opened in the default browser.

.PARAMETER searchTerm
    The search query to execute.

.PARAMETER engine
    The search engine URL template to use. Defaults to $PSPal_SearchEngine. Use {query} as placeholder.

.PARAMETER private
    Switch to open the search results in private browsing mode.

.EXAMPLE
    WebSearch "PowerShel"
    Searches for PowerShell using default search engine

.EXAMPLE
    WebSearch "PowerShell" -private
    Searches and opens results in private browsing mode
#>
function WebSearch {
    param (
        [string]$searchTerm,
        [string]$engineId = $global:PSPal_SearchEngine,
		[switch]$private
    )
    if (-not $searchTerm) {
        Write-Host "Please provide a search term." -ForegroundColor Yellow
        Log "WebSearch called without a search term." "WARNING"
        return
    }

    $engine = $global:PSPal_SearchEngines[$engineid]

    $url = $engine -replace "{query}", [uri]::EscapeDataString($searchTerm)
	if ($private) {
		Start-Website $url -private

	} else {
		Start-Website $url
        Log "Searched '$searchTerm'| $engine."
	}
	

    Write-Host "Searched '$searchTerm'." -ForegroundColor Green
}

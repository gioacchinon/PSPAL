# currently msedge is the only supported browser, but ya can manually check the correct
# command to lounch your browser, chrome should work similarly for instance.
# If you do, remember to update also the Pin function inside Plugins/pinning.ps1

<#
.SYNOPSIS
    Launches a website in Microsoft Edge

.DESCRIPTION
    Opens the specified URL in Microsoft Edge browser. Supports both normal and private browsing modes.

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
        #if no Url is provided msedge will launch normally 
        if ($Private) {
            Start-Process 'msedge' -ArgumentList "--inPrivate", --app="$url"
        }
        else {
            Start-Process 'msedge' --app="$url"
            Log "Opened website '$URL'."
        }
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
    WebSearch "PowerShell functions"
    Searches for PowerShell functions using default search engine

.EXAMPLE
    WebSearch "PowerShell functions" -private
    Searches and opens results in private browsing mode
#>
function WebSearch {
    param (
        [string]$searchTerm,
        [string]$engine = $global:PSPal_SearchEngine,
		[switch]$private
    )
    if (-not $searchTerm) {
        Write-Host "Please provide a search term." -ForegroundColor Yellow
        Log "WebSearch called without a search term." "WARNING"
        return
    }

    $url = $engine -replace "{query}", [uri]::EscapeDataString($searchTerm)
	if ($private) {
		Start-Website $url -private

	} else {
		Start-Website $url
        Log "Searched '$searchTerm'| $engine."
	}
	

    Write-Host "Searched '$searchTerm'." -ForegroundColor Green
}

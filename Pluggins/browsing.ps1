# currently msedge is the only supported browser, but ya can manually check the correct
# command to lounch your browser

function Start-Website {
    param (
        [string]$URL,
		[switch]$Private
    )
    
    #if no Url is provided msedge will launch normally 
    if ($Private) {
        Start-Process 'msedge' -ArgumentList "--inPrivate", --app="$url"
    } else {
    	Start-Process 'msedge' --app="$url"
        Log "Opened website '$URL'."
    }
	
    Write-Host "Opened website '$URL'." -ForegroundColor Green
}

function WebSearch {
    param (
        [string]$searchTerm,
        [string]$engine = $SearchEngine,
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

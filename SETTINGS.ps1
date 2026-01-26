# settings for profile.ps1
$global:PSPal_UserFilesDir = "$env:USERPROFILE"
$global:PSPal_Editor = "notepad"
$global:PSPal_logFilePath = "$PSScriptRoot\log\palette.log"
$global:PSPal_LogToFile = $True
$global:PSPal_FavColor = "Blue"

$global:PSPal_PinnedPath = "$PSScriptRoot\plugins\pinning\pinned.ps1"

$global:PSPal_HistoryLifespan = 0 #in palette instances, 0: persistent
$global:PSPal_predictorPinnedPath = "$PSScriptRoot\Predictor\pinned"
$global:PSPal_predictorFilesPath = "$PSScriptRoot\Predictor\pinned"


$global:PSPal_SearchEngine = "bing"
$global:PSPal_SearchEngines = @{
    "bing"     = "https://www.bing.com/search?q={query}"
    "google"   = "https://www.google.com/search?q={query}"

    "image"    = "https://www.bing.com/images/search?q={query}"
    "video"    = "https://www.bing.com/videos/search?q={query}"
    "translate" = "https://www.bing.com/translator?from=&to=en&text={query}"

}

$global:PSPal_BrowserProvider = [PSCustomObject]@{
  Command = "msedge"
  URLLauncher = "--app=<URL>"
  PrivateTag = "--inPrivate"
}

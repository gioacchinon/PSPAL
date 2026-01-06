# settings for profile.ps1
$global:PSPal_UserFilesDir = "E:\gioac"
$global:PSPal_Editor = "edit"
$global:PSPal_pinnedPath = "$PSScriptRoot\pinned.ps1"
$global:PSPal_logFilePath = "$PSScriptRoot\palette.log"
$global:PSPal_LogToFile = $True
$global:PSPal_FavColor = "Yellow"
$global:PSPal_SearchEngine = "https://www.bing.com/search?q={query}"

$global:PSPal_HistoryLifespan = 60 #in palette instances, 0: persistent
$global:PSPal_predictorPinnedPath = "$PSScriptRoot\Predictor\pinned"
$global:PSPal_predictorFilesPath = "$PSScriptRoot\Predictor\pinned"

#ya can use this like `WebSearch "hello" $imageSearch`
$global:ImageSearch = "https://www.bing.com/images/search?q={query}"
$global:VideoSearch = "https://www.bing.com/videos/search?q={query}"
$global:Translate = "https://www.bing.com/translator?from=&to=en&text={query}"
$global:copilot = "https://copilot.microsoft.com/?q={query}"
$global:lechat = "https://chat.mistral.ai/chat?q={query}"

$global:ptemp = [Environment]::GetFolderPath("Desktop") + "\Personal Temp"

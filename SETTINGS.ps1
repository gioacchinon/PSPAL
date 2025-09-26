# settings for profile.ps1
$UserFilesDir = "E:\gioac"
$Editor = "edit"
$pinnedPath = "$PSScriptRoot\pinned.ps1"
$logFilePath = "$PSScriptRoot\palette.log"
$logtofile = $True
$FavColor = "Yellow"
$SearchEngine = "https://www.bing.com/search?q={query}"

$NotesRoot = [Environment]::GetFolderPath("Documents") + "\Notes"
$DefaultNote = "PerAsperaAdAstra"

#ya can use this like WebSearch "hello" $imageSearch
$ImageSearch = "https://www.bing.com/images/search?q={query}"
$VideoSearch = "https://www.bing.com/videos/search?q={query}"
$Translate = "https://www.bing.com/translator?from=&to=en&text={query}"

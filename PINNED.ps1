function global:crunchy { Start-Process 'msedge' --app="https://crunchyroll.com" }
function global:yt { Start-Process 'msedge' --app="https://youtube.com" }
function global:lechat { Start-Process 'msedge' --app="https://chat.mistral.ai" }
function global:achat {param ($q="hello") websearch $q $lechat}
function global:camera {start-process "microsoft.windows.camera:"}
function global:copilot {start-process "ms-copilot://"}
function global:acopilot {param ($q="hello") websearch $q $copilot}
function global:paint {start-process "C:\Program Files\Paint.NET\paintdotnet.exe"}
function global:rnote {start-process "C:\Program Files\Rnote\bin\rnote.exe"}
function global:classroom {start-process 'msedge' --app="https://classroom.google.com/"}
function global:music {start-process "ms-media-player:"}
function global:wa {start-process "whatsapp:"}
function global:github {start-process 'msedge' --app="https://github.com"}
function global:m365 {start-process 'msedge' --app="https://cloud.microsoft"}
function global:mywifi {Start-Process "netsh.exe" -ArgumentList "wlan connect name=GF5L"}
function global:mail {start-process "ms-outlook:"}
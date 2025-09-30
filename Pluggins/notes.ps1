function Get-Notes {
    param (
        $path = $NotesPath
    )
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType "File" -Force | Out-Null
        $notes = @()
        # Save an empty array
        @($notes) | ConvertTo-Json -Depth 10 | Set-Content $path
        return $notes
    }
    try {
        $jsonNotes = Get-Content $path -Raw
        if ([string]::IsNullOrWhiteSpace($jsonNotes)) {
            $notes = @()
        }
        else {
            $notes = $jsonNotes | ConvertFrom-Json
            if ($notes -isnot [System.Collections.IList]) {
                $notes = @($notes)
            }
            if ($notes.Count -eq 1) {
                $dollNote = @{
                    Title     = "__doll__"
                    Content   = "This is a placeholder note to prevent array unrolling."
                    Timestamp = "01 Jan 0001 00.00.00"
                    User      = "system"
                    id        = -1
                }
                $notes = @(
                    $notes,
                    $dollNote
                )
            }
        }
    }
    catch {
        Write-Warning "Failed to parse JSON: $_"
        $notes = @()
    }
    return $notes
}

function New-Note {
    param (
        $content,
        $title = "",
        $path = $NotesPath
    )
    $notes = Get-Notes $path
    $notes = $notes | Where-Object { $_.id -ne -1 }
    $newNote = @{
        Title     = $title
        Content   = $content
        Timestamp = Get-Date -Format "d MMM yyyy H.mm.ss"
        User      = "$env:USERNAME@$env:COMPUTERNAME"
        id        = if ($notes) { ($notes | Measure-Object -Property id -Maximum).Maximum + 1 } else { 0 }
    }
    $notes += $newNote
    try {
        , $notes | ConvertTo-Json -Depth 10 | Set-Content $path
        Write-Host "Note '$title' added to $path"
    }
    catch {
        Write-Error "Error occurred saving to $path"
    }
}



function Get-Note {
    param (
        $path = $NotesPath,
        $inContent = $null,
        $inTitle = $null,
        $user = $null,
        $date = $null,
        $id = $null
    )
    $notes = Get-Notes $path
    $notes = $notes | Where-Object { $_.id -ne -1 }
    $filteredNotes = $notes
    if ($inContent) {
        $filteredNotes = $filteredNotes | Where-Object { $_.Content -match $inContent }
    }
    if ($inTitle) {
        $filteredNotes = $filteredNotes | Where-Object { $_.Title -match $inTitle }
    }
    if ($user) {
        $filteredNotes = $filteredNotes | Where-Object { $_.User -match $user }
    }
    if ($date) {
        $filteredNotes = $filteredNotes | Where-Object { $_.Timestamp -match $date }
    }
    if ($id) {
        $filteredNotes = $filteredNotes | Where-Object { $_.id -eq $id }
    }
    return $filteredNotes
}


function Remove-Note {
    param (
        $id,
        $path = $NotesPath,
        $askconfirm = $true
    )
    $notes = Get-Notes $path
    $notes = $notes | Where-Object { $_.id -ne -1 }
    $noteToRemove = $notes | Where-Object { $_.id -eq $id }
    if (-not $noteToRemove) {
        Write-Warning "Note with ID $id not found."
        return
    }
    if ($askconfirm) {
        $confirmation = Read-Host "Are you sure you want to remove the note '$($noteToRemove.Title)' (ID: $id)? [Y/N]"
        if ($confirmation -ne 'Y') {
            Write-Host "Removal cancelled."
            return
        }
    }
    $notes = $notes | Where-Object { $_.id -ne $id }
    try {
        # Save the notes as a JSON array
        , $notes | ConvertTo-Json -Depth 10 | Set-Content $path
        Write-Host "Note with ID $id removed."
    }
    catch {
        Write-Error "Error occurred saving to $path"
    }
}




function NoteRenderTemplate {
    param (
        [hashtable]$data,
        $templatePath = "$paletteroot\Pluggins\notes\template.html"
    )
    $template = Get-Content -Raw -Path $templatePath

    foreach ($key in $data.Keys) {
        $placeholder = "{{${key}}}"
        $template = $template -replace [regex]::Escape($placeholder), $data[$key]
    }

    return $template
}



function Start-WebNotes {
    param (
        $path = $NotesPath
    )

    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:8080/")
    $listener.Start()
    Write-Host "Server started at http://localhost:8080/"
    Start-Website "http://localhost:8080/"

    function Receive-Request {
        param ($context)

        $request = $context.Request
        $response = $context.Response
        $route = $request.Url.AbsolutePath
        $method = $request.HttpMethod

        if  ($route -eq "/") {
            if ($method -eq "GET") {
                $notes = Get-Notes $path
                $notes = $notes | Where-Object { $_.id -ne -1 }
                $unorderedList = "<ul>"
                foreach ($note in $notes) {
                    $title = [System.Web.HttpUtility]::HtmlEncode($note.Title)
                    $content = $note.Content -replace "(\r\n|\n|\r)", "<br>"
                    $content = [System.Web.HttpUtility]::HtmlEncode($content) -replace "&lt;br&gt;", "<br>"
                    $user = [System.Web.HttpUtility]::HtmlEncode($note.User)
                    $timestamp = [System.Web.HttpUtility]::HtmlEncode($note.Timestamp)
                    $id = [System.Web.HttpUtility]::HtmlEncode($note.id)
                    $unorderedList += @"
<li class="note">
    <button type="button" onclick="remove($id)">✕</button>
    <div class="endo">
        <h3>$title</h3>
        <p>$content</p>
    </div>
    <div class="meta">
        <em>$user | $timestamp</em>
    </div>
</li>
"@
                }
                $unorderedList += "</ul>"

                $data = @{
                    notepath = $path
                    notes    = $unorderedList
                }

                $template = NoteRenderTemplate $data

                $buffer = [System.Text.Encoding]::UTF8.GetBytes($template)
                $response.StatusCode = 200
                $response.ContentType = "text/html"
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.OutputStream.Close()
                return
            }

            elseif ($method -eq "POST") {
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $body = $reader.ReadToEnd()
                try {
                    $noteData = $body | ConvertFrom-Json
                    New-Note -title $noteData.Title -content $noteData.Content -path $path
                    $responseString = @{ success = $true; message = "Note added successfully." } | ConvertTo-Json
                    $response.StatusCode = 201
                }
                catch {
                    $responseString = @{ success = $false; message = "Error: $_" } | ConvertTo-Json
                    $response.StatusCode = 400
                }
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
                $response.ContentType = "application/json"
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }

            elseif ($method -eq "DELETE") {
                $reader = New-Object System.IO.StreamReader($request.InputStream)
                $body = $reader.ReadToEnd()
                try {
                    $noteData = $body | ConvertFrom-Json
                    Remove-Note -id $noteData.id -path $path -askconfirm $false
                    $response.StatusCode = 204 # No Content
                    $responseString = ""
                }
                catch {
                    $responseString = @{ success = $false; message = "Error: $_" } | ConvertTo-Json
                    $response.StatusCode = 400 # Bad Request
                }
                $buffer = [System.Text.Encoding]::UTF8.GetBytes($responseString)
                $response.ContentType = "application/json"
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }

            else {
                $response.StatusCode = 405
                $response.AddHeader("Allow", "GET, POST, DELETE")
                $buffer = [System.Text.Encoding]::UTF8.GetBytes("<h1>405 Method Not Allowed</h1>")
                $response.ContentType = "text/html"
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
                $response.OutputStream.Close()
                return
            }

        } 
        else {
            $response.StatusCode = 404
            $buffer = [System.Text.Encoding]::UTF8.GetBytes("<h1>404 Not Found</h1>")
            $response.ContentType = "text/html"
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }

        Write-Host "Request: $method $route; Response: $($response.StatusCode) ($([System.Net.HttpStatusCode]$response.StatusCode))"


        $response.OutputStream.Close()
    }

    while ($listener.IsListening) {
        $context = $listener.GetContext()
        Receive-Request $context
    }


}
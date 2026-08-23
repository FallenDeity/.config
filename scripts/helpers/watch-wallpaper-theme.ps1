<#
.SYNOPSIS
    Real-time wallpaper theme synchronizer for GlazeWM & Zebar.
    Pure event-driven kernel watcher with zero CPU/disk polling overhead.
#>

$ErrorActionPreference = 'SilentlyContinue'

$helpersDir = $PSScriptRoot
$sRoot = Split-Path -Parent $helpersDir
$sPy = Join-Path $helpersDir 'sync-wallpaper-theme.py'
$sAssets = Join-Path $helpersDir 'install-config-assets.ps1'

$global:pendingSync = $false
$global:lastEventTime = [DateTime]::MinValue

$action = {
    $global:pendingSync = $true
    $global:lastEventTime = [DateTime]::UtcNow
}

# 1. Windows Wallpaper Watcher
$themesDir = Join-Path $env:APPDATA 'Microsoft\Windows\Themes'
if (Test-Path $themesDir) {
    $winWatcher = New-Object System.IO.FileSystemWatcher
    $winWatcher.Path = $themesDir
    $winWatcher.Filter = "TranscodedWallpaper"
    $winWatcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite, FileName, Size'
    $winWatcher.EnableRaisingEvents = $true
    Register-ObjectEvent $winWatcher 'Changed' -Action $action | Out-Null
    Register-ObjectEvent $winWatcher 'Created' -Action $action | Out-Null
    Register-ObjectEvent $winWatcher 'Renamed' -Action $action | Out-Null
    Write-Host "Watching Windows wallpaper: $themesDir" -ForegroundColor Cyan
}

# 2. Wallpaper Engine Watcher
$weDirs = @(
    "${env:ProgramFiles(x86)}\Steam\steamapps\common\wallpaper_engine",
    "$env:ProgramFiles\Steam\steamapps\common\wallpaper_engine"
)

foreach ($weDir in $weDirs) {
    if (Test-Path $weDir) {
        $weWatcher = New-Object System.IO.FileSystemWatcher
        $weWatcher.Path = $weDir
        $weWatcher.Filter = "*config.json*"
        $weWatcher.NotifyFilter = [System.IO.NotifyFilters]'LastWrite, FileName, Size'
        $weWatcher.EnableRaisingEvents = $true
        Register-ObjectEvent $weWatcher 'Changed' -Action $action | Out-Null
        Register-ObjectEvent $weWatcher 'Created' -Action $action | Out-Null
        Register-ObjectEvent $weWatcher 'Renamed' -Action $action | Out-Null
        Write-Host "Watching Wallpaper Engine: $weDir" -ForegroundColor Cyan
        break
    }
}

Write-Host "Dynamic wallpaper theme watcher is active." -ForegroundColor Green

while ($true) {
    Start-Sleep -Seconds 1

    # Execute exactly once only after file writes have fully settled for 1.4s
    if ($global:pendingSync) {
        $elapsed = ([DateTime]::UtcNow - $global:lastEventTime).TotalMilliseconds
        if ($elapsed -ge 1400) {
            $global:pendingSync = $false
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Wallpaper change settled. Syncing theme once..." -ForegroundColor Cyan
            
            if (Test-Path $sPy) { python $sPy }
            
            if (Get-Command glazewm -ErrorAction SilentlyContinue) {
                glazewm command wm-reload-config
            }
            Stop-Process -Name zebar -Force -ErrorAction SilentlyContinue
            if (Get-Command glazewm -ErrorAction SilentlyContinue) {
                glazewm command shell-exec zebar
            }
            Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Wallpaper sync complete!" -ForegroundColor Green
        }
    }
}

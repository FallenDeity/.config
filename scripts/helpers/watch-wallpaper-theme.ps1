<#
.SYNOPSIS
    Real-time wallpaper theme synchronizer for GlazeWM & Zebar.
    Monitors TranscodedWallpaper for changes and updates themes automatically.
#>

$ErrorActionPreference = 'SilentlyContinue'

$themesDir = Join-Path $env:APPDATA 'Microsoft\Windows\Themes'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$syncPy = Join-Path $scriptDir 'sync-wallpaper-theme.py'
$installAssets = Join-Path $scriptDir 'install-config-assets.ps1'

function Update-ThemeFromWallpaper {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Wallpaper changed! Updating theme colors..." -ForegroundColor Cyan
    try {
        if (Test-Path $syncPy) {
            python $syncPy
        }
        if (Test-Path $installAssets) {
            & $installAssets -ScriptsRoot (Split-Path -Parent $scriptDir)
        }
        
        # Reload GlazeWM & Zebar
        if (Get-Command glazewm -ErrorAction SilentlyContinue) {
            glazewm command reload-config
        }
        Stop-Process -Name zebar -Force -ErrorAction SilentlyContinue
        if (Get-Command glazewm -ErrorAction SilentlyContinue) {
            glazewm command shell-exec zebar
        }
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Theme synchronization complete!" -ForegroundColor Green
    } catch {
        Write-Host "Error updating theme: $_" -ForegroundColor Red
    }
}

if (-not (Test-Path $themesDir)) {
    Write-Host "Themes directory not found: $themesDir" -ForegroundColor Yellow
    exit 1
}

Write-Host "Watching for wallpaper changes in: $themesDir" -ForegroundColor Cyan

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $themesDir
$watcher.Filter = "TranscodedWallpaper"
$watcher.IncludeSubdirectories = $false
$watcher.EnableRaisingEvents = $true

$action = {
    Start-Sleep -Milliseconds 600
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Wallpaper changed! Syncing theme..." -ForegroundColor Cyan
    $sRoot = 'd:\projects\.config\scripts'
    $sPy = Join-Path $sRoot 'helpers\sync-wallpaper-theme.py'
    $sAssets = Join-Path $sRoot 'helpers\install-config-assets.ps1'
    if (Test-Path $sPy) { python $sPy }
    if (Test-Path $sAssets) { & $sAssets -ScriptsRoot $sRoot }
    if (Get-Command glazewm -ErrorAction SilentlyContinue) {
        glazewm command reload-config
    }
    Stop-Process -Name zebar -Force -ErrorAction SilentlyContinue
    if (Get-Command glazewm -ErrorAction SilentlyContinue) {
        glazewm command shell-exec zebar
    }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Wallpaper sync complete!" -ForegroundColor Green
}

Register-ObjectEvent $watcher 'Changed' -Action $action | Out-Null
Register-ObjectEvent $watcher 'Created' -Action $action | Out-Null

Write-Host "Dynamic wallpaper theme watcher is active." -ForegroundColor Green

while ($true) {
    Start-Sleep -Seconds 10
}

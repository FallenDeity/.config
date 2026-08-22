param(
    [string]$ScriptsRoot
)

$ErrorActionPreference = 'Stop'

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Sync-ConfigDirectory {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description = $null
    )

    if (-not (Test-Path $Source)) {
        Write-Host "$Description source not found: $Source" -ForegroundColor Yellow
        return
    }

    Ensure-Directory -Path $Destination

    $srcFull = [System.IO.Path]::GetFullPath($Source)
    $dstFull = [System.IO.Path]::GetFullPath($Destination)
    if ($srcFull -ieq $dstFull) {
        Write-Host "$Description source and destination are identical; skipping copy." -ForegroundColor DarkGreen
        return
    }

    Copy-Item -Path (Join-Path $Source '*') -Destination $Destination -Recurse -Force
    Write-Host "$Description synced to: $Destination" -ForegroundColor Green
}

function Install-WindowsTerminalProfileIcons {
    Write-Host "`n==> Setting up Windows Terminal profile icons" -ForegroundColor Cyan

    $repoIconsDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'windows-terminal\icons'
    if (-not (Test-Path $repoIconsDir)) {
        Write-Host "No repo icons directory found: $repoIconsDir" -ForegroundColor Yellow
        return
    }

    $stableRoaming = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\RoamingState\icons'
    $previewRoaming = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\RoamingState\icons'

    $targetDir = if (Test-Path (Split-Path -Parent $stableRoaming)) { $stableRoaming } elseif (Test-Path (Split-Path -Parent $previewRoaming)) { $previewRoaming } else { $stableRoaming }
    Ensure-Directory -Path $targetDir

    Copy-Item -Path (Join-Path $repoIconsDir '*') -Destination $targetDir -Force -ErrorAction SilentlyContinue
    Write-Host "Windows Terminal icons synced to: $targetDir" -ForegroundColor Green
}

function Install-WindowsTerminalSettings {
    Write-Host "`n==> Setting up Windows Terminal settings" -ForegroundColor Cyan

    $repoSettings = Join-Path (Split-Path -Parent $ScriptsRoot) 'windows-terminal\settings.json'
    if (-not (Test-Path $repoSettings)) {
        Write-Host "Windows Terminal settings file not found: $repoSettings" -ForegroundColor Yellow
        return
    }

    $stableDir = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
    $previewDir = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState'
    $targetDir = if (Test-Path $stableDir) { $stableDir } elseif (Test-Path $previewDir) { $previewDir } else { $stableDir }
    Ensure-Directory -Path $targetDir

    $targetFile = Join-Path $targetDir 'settings.json'
    if (Test-Path $targetFile) {
        $backupFile = Join-Path $targetDir ("settings.backup.{0}.json" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
        Copy-Item -Path $targetFile -Destination $backupFile -Force
        Write-Host "Backed up existing settings to: $backupFile" -ForegroundColor DarkGreen
    }

    Copy-Item -Path $repoSettings -Destination $targetFile -Force
    Write-Host "Windows Terminal settings synced: $targetFile" -ForegroundColor Green
}

function Install-WezTermConfig {
    Write-Host "`n==> Setting up WezTerm config" -ForegroundColor Cyan
    $repoWezTermDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'wezterm'
    $targetDir = Join-Path $HOME '.config\wezterm'
    Sync-ConfigDirectory -Source $repoWezTermDir -Destination $targetDir -Description 'WezTerm config'
}

function Install-GlazeWMConfig {
    Write-Host "`n==> Setting up GlazeWM config" -ForegroundColor Cyan
    $repoGlazeWMDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'glazewm'
    $targetDir = Join-Path $HOME '.glzr\glazewm'
    Sync-ConfigDirectory -Source $repoGlazeWMDir -Destination $targetDir -Description 'GlazeWM config'

    # Ensure GlazeWM starts automatically on Windows login (Userspace Startup)
    $glazewmExe = $null
    if (Get-Command glazewm -ErrorAction SilentlyContinue) {
        $glazewmExe = (Get-Command glazewm).Source
    } elseif (Test-Path "$HOME\scoop\shims\glazewm.exe") {
        $glazewmExe = "$HOME\scoop\shims\glazewm.exe"
    }

    if ($glazewmExe) {
        $startupDir = [Environment]::GetFolderPath('Startup')
        if ($startupDir -and (Test-Path $startupDir)) {
            $shortcutPath = Join-Path $startupDir 'GlazeWM.lnk'
            try {
                $wsh = New-Object -ComObject WScript.Shell
                $shortcut = $wsh.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $glazewmExe
                $shortcut.Description = 'GlazeWM Tiling Window Manager'
                $shortcut.Save()
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shortcut) | Out-Null
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($wsh) | Out-Null
                Write-Host "GlazeWM startup shortcut enabled: $shortcutPath" -ForegroundColor Green
            } catch {
                Write-Host "Failed to create GlazeWM startup shortcut: $_" -ForegroundColor Yellow
            }
        }
    }
}

function Install-Btop4winTheme {
    Write-Host "`n==> Setting up btop4win config" -ForegroundColor Cyan

    $repoRoot = Split-Path -Parent $ScriptsRoot
    $repoBtopDir = Join-Path $repoRoot 'btop'

    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host 'scoop not found; skipping btop4win theme setup.' -ForegroundColor Yellow
        return
    }

    $btopPrefix = (& scoop prefix btop 2>$null | Out-String).Trim()
    if ([string]::IsNullOrWhiteSpace($btopPrefix)) {
        $btopPrefix = (& scoop prefix btop-lhm 2>$null | Out-String).Trim()
    }

    if ([string]::IsNullOrWhiteSpace($btopPrefix) -or -not (Test-Path $btopPrefix)) {
        Write-Host 'btop4win is not installed via scoop yet; skipping theme setup.' -ForegroundColor Yellow
        return
    }

    Copy-Item -Path (Join-Path $repoBtopDir '*') -Destination $btopPrefix -Recurse -Force
    Write-Host "btop config synced to: $btopPrefix" -ForegroundColor Green
}

function Sync-WallpaperTheme {
    Write-Host "`n==> Syncing theme palette from current wallpaper" -ForegroundColor Cyan
    $syncScript = Join-Path $ScriptsRoot "helpers\sync-wallpaper-theme.py"
    if (Test-Path $syncScript) {
        python $syncScript
    }
}

function Install-ZebarConfig {
    Write-Host "`n==> Setting up Zebar config" -ForegroundColor Cyan
    $repoZebarDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'zebar'
    $targetDir = Join-Path $HOME '.glzr\zebar'
    Sync-ConfigDirectory -Source $repoZebarDir -Destination $targetDir -Description 'Zebar config'
}

function Install-WallpaperWatcherStartup {
    Write-Host "`n==> Setting up Wallpaper Theme Watcher startup shortcut" -ForegroundColor Cyan
    $watcherScript = Join-Path $ScriptsRoot "helpers\watch-wallpaper-theme.ps1"
    if (-not (Test-Path $watcherScript)) {
        return
    }

    $startupDir = [Environment]::GetFolderPath('Startup')
    if ($startupDir -and (Test-Path $startupDir)) {
        $shortcutPath = Join-Path $startupDir 'WallpaperThemeWatcher.lnk'
        $pwshExe = $null
        if (Get-Command pwsh -ErrorAction SilentlyContinue) {
            $pwshExe = (Get-Command pwsh).Source
        } elseif (Get-Command powershell -ErrorAction SilentlyContinue) {
            $pwshExe = (Get-Command powershell).Source
        }

        if ($pwshExe) {
            try {
                $wsh = New-Object -ComObject WScript.Shell
                $shortcut = $wsh.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $pwshExe
                $shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File `"$watcherScript`""
                $shortcut.Description = 'Dynamic Wallpaper Theme Watcher for GlazeWM and Zebar'
                $shortcut.Save()
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
                [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
                Write-Host "Wallpaper Watcher startup shortcut enabled: $shortcutPath" -ForegroundColor Green
            } catch {
                Write-Host "Failed to create Wallpaper Watcher startup shortcut: $_" -ForegroundColor Yellow
            }
        }
    }
}

Sync-WallpaperTheme
Install-WindowsTerminalProfileIcons
Install-WindowsTerminalSettings
Install-WezTermConfig
Install-GlazeWMConfig
Install-ZebarConfig
Install-Btop4winTheme
Install-WallpaperWatcherStartup
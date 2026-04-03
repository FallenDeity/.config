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

function Install-AlacrittyConfig {
    Write-Host "`n==> Setting up Alacritty config" -ForegroundColor Cyan
    $repoAlacrittyDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'alacritty'
    $targetDir = Join-Path $env:APPDATA 'alacritty'
    Sync-ConfigDirectory -Source $repoAlacrittyDir -Destination $targetDir -Description 'Alacritty config'
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

function Install-PsmuxPluginManager {
    Write-Host "`n==> Setting up psmux plugins from repo submodule" -ForegroundColor Cyan

    $repoRoot = Split-Path -Parent $ScriptsRoot
    $repoPluginsRoot = Join-Path $repoRoot 'psmux\plugins'
    $targetPluginsRoot = Join-Path $HOME '.psmux\plugins'

    $pluginsListFile = Join-Path $repoRoot 'psmux\plugins.list'
    if (-not (Test-Path $pluginsListFile)) {
        Write-Host "psmux plugins list not found: $pluginsListFile" -ForegroundColor Yellow
        return
    }

    $requiredPlugins = @(Get-Content -Path $pluginsListFile | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object { $_.Trim() })

    if (-not (Test-Path (Join-Path $repoPluginsRoot 'ppm\ppm.ps1'))) {
        Write-Host "psmux plugin submodule is missing or not initialized: $repoPluginsRoot" -ForegroundColor Yellow
        Write-Host 'Run: git submodule update --init --recursive' -ForegroundColor Yellow
        return
    }

    Ensure-Directory -Path $targetPluginsRoot

    foreach ($pluginName in $requiredPlugins) {
        $sourcePath = Join-Path $repoPluginsRoot $pluginName
        $targetPath = Join-Path $targetPluginsRoot $pluginName

        if (-not (Test-Path $sourcePath)) {
            Write-Host "Plugin not found in repo: $sourcePath" -ForegroundColor Yellow
            continue
        }

        if (Test-Path $targetPath) {
            Remove-Item -Path $targetPath -Recurse -Force
        }

        Copy-Item -Path $sourcePath -Destination $targetPath -Recurse -Force
        Write-Host "psmux plugin synced: $pluginName" -ForegroundColor Green
    }

    $userPsmuxConf = Join-Path $HOME '.psmux\psmux.conf'
    if (Test-Path $userPsmuxConf) {
        $confContent = Get-Content -Path $userPsmuxConf -Raw
        if ($confContent -notmatch 'run.*psmux-sensible\.ps1') {
            Write-Host "`n==> Appending dynamic plugin commands to psmux.conf" -ForegroundColor Cyan

            $pluginCommands = @()
            foreach ($pluginName in $requiredPlugins) {
                $pluginScriptPath = "~/.psmux/plugins/$pluginName"
                $mainScript = if ($pluginName -eq 'ppm') {
                    'ppm.ps1'
                }
                elseif ($pluginName -like 'psmux-*') {
                    "$pluginName.ps1"
                }
                else {
                    continue
                }

                $pluginCommands += "run '$pluginScriptPath/$mainScript'"
            }

            if ($pluginCommands.Count -gt 0) {
                Add-Content -Path $userPsmuxConf -Value $("`n" + ($pluginCommands -join "`n"))
            }
        }
    }
}

Install-WindowsTerminalProfileIcons
Install-WindowsTerminalSettings
Install-AlacrittyConfig
Install-Btop4winTheme
Install-PsmuxPluginManager
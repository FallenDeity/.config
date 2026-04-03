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
    $repoPsmuxDir = Join-Path $repoRoot 'psmux'
    $repoPsmuxConf = Join-Path $repoPsmuxDir 'psmux.conf'
    $repoPluginsRoot = Join-Path $repoPsmuxDir 'plugins'

    $userPsmuxDir = Join-Path (Join-Path $HOME '.config') 'psmux'
    $userPsmuxConf = Join-Path $userPsmuxDir 'psmux.conf'
    $targetPluginsRoot = Join-Path $userPsmuxDir 'plugins'

    $pluginsListFile = Join-Path $repoPsmuxDir 'plugins.list'
    if (-not (Test-Path $pluginsListFile)) {
        Write-Host "psmux plugins list not found: $pluginsListFile" -ForegroundColor Yellow
        return
    }

    $requiredPlugins = @(Get-Content -Path $pluginsListFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
    if ($requiredPlugins.Count -eq 0) {
        Write-Host 'psmux plugins list is empty; skipping plugin setup.' -ForegroundColor Yellow
        return
    }

    if (-not (Test-Path $repoPluginsRoot)) {
        Write-Host "psmux plugin submodule is missing or not initialized: $repoPluginsRoot" -ForegroundColor Yellow
        Write-Host 'Run: git submodule update --init --recursive' -ForegroundColor Yellow
        return
    }

    Ensure-Directory -Path $userPsmuxDir
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

    if (-not (Test-Path $userPsmuxConf)) {
        return
    }

    Write-Host "`n==> Appending dynamic plugin commands to psmux.conf" -ForegroundColor Cyan
    $pluginCommands = @()
    foreach ($pluginName in $requiredPlugins) {
        $mainScript = if ($pluginName -eq 'ppm') {
            'ppm.ps1'
        }
        elseif ($pluginName -like 'psmux-*') {
            "$pluginName.ps1"
        }
        else {
            continue
        }

        $pluginCommands += "run '~/.config/psmux/plugins/$pluginName/$mainScript'"
    }

    if ($pluginCommands.Count -eq 0) {
        return
    }

    $startMarker = '# BEGIN: managed psmux plugins'
    $endMarker = '# END: managed psmux plugins'
    $managedBlock = @($startMarker) + $pluginCommands + @($endMarker)

    $lines = @(Get-Content -Path $userPsmuxConf)
    $startIndex = [Array]::IndexOf($lines, $startMarker)
    $endIndex = [Array]::IndexOf($lines, $endMarker)

    if ($startIndex -ge 0 -and $endIndex -gt $startIndex) {
        $before = if ($startIndex -gt 0) { $lines[0..($startIndex - 1)] } else { @() }
        $after = if ($endIndex -lt ($lines.Count - 1)) { $lines[($endIndex + 1)..($lines.Count - 1)] } else { @() }
        $newLines = @($before + $managedBlock + $after)
        Set-Content -Path $userPsmuxConf -Value $newLines -Encoding UTF8
    }
    else {
        Add-Content -Path $userPsmuxConf -Value ("`n" + ($managedBlock -join "`n"))
    }
}

Install-WindowsTerminalProfileIcons
Install-WindowsTerminalSettings
Install-AlacrittyConfig
Install-Btop4winTheme
Install-PsmuxPluginManager
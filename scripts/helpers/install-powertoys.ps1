param(
    [string[]]$PluginRepos = @(
        'https://github.com/ruslanlap/PowerToysRun-VideoDownloader',
        'https://github.com/ruslanlap/PowerToysRun-SpeedTest',
        'https://github.com/ruslanlap/PowerToysRun-Hotkeys',
        'https://github.com/Darkdriller/PowerToys-Run-LocalLLm',
        'https://github.com/nathancartlidge/powertoys-run-unicode',
        'https://github.com/8LWXpg/PowerToysRun-ProcessKiller',
        'https://github.com/Quriz/PowerToysRunScoop',
        'https://github.com/dandn9/prun-lorem',
        'https://github.com/bostrot/PowerToysRunPluginWinget',
        'https://github.com/Advaith3600/PowerToys-Run-Currency-Converter',
        'https://github.com/lin-ycv/EverythingPowerToys'
    )
)

$ErrorActionPreference = 'Stop'

$PluginArchitecture = if ($env:PROCESSOR_ARCHITECTURE -match 'ARM64') { 'arm64' } else { 'x64' }
$PluginsRoot = Join-Path $HOME 'AppData\Local\Microsoft\PowerToys\PowerToys Run\Plugins'
$PluginDownloadCache = Join-Path $HOME '.cache\powertoys-plugin-cache'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Ensure-Directory {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Force -Path $Path | Out-Null
    }
}

function Get-RepoOwnerAndName {
    param([string]$RepoUrl)
    $trimmed = $RepoUrl.TrimEnd('/')
    if ($trimmed -notmatch 'github\.com/([^/]+)/([^/]+)$') {
        throw "Invalid GitHub repo URL: $RepoUrl"
    }
    return @($Matches[1], $Matches[2])
}

function Get-PreferredReleaseAsset {
    param(
        [object[]]$Assets,
        [string]$Architecture
    )

    if (-not $Assets -or $Assets.Count -eq 0) {
        return $null
    }

    $archiveAssets = $Assets | Where-Object {
        $_.name -match '\.(zip|nupkg|7z|rar)$'
    }

    if (-not $archiveAssets -or $archiveAssets.Count -eq 0) {
        return $null
    }

    $archMatches = $archiveAssets | Where-Object {
        $_.name -match "(?i)$Architecture"
    }
    if ($archMatches -and $archMatches.Count -gt 0) {
        return $archMatches | Select-Object -First 1
    }

    $x64Fallback = $archiveAssets | Where-Object { $_.name -match '(?i)x64|amd64' }
    if ($x64Fallback -and $x64Fallback.Count -gt 0) {
        return $x64Fallback | Select-Object -First 1
    }

    return $archiveAssets | Select-Object -First 1
}

function Expand-PluginArchive {
    param(
        [string]$ArchivePath,
        [string]$DestinationPath
    )

    if (Test-Path $DestinationPath) {
        Remove-Item -Recurse -Force $DestinationPath
    }
    Ensure-Directory -Path $DestinationPath

    if ($ArchivePath -match '\.(zip|nupkg)$') {
        Expand-Archive -Path $ArchivePath -DestinationPath $DestinationPath -Force
        return
    }

    if ($ArchivePath -match '\.7z$') {
        if (Get-Command 7z -ErrorAction SilentlyContinue) {
            & 7z x "$ArchivePath" "-o$DestinationPath" -y | Out-Null
            return
        }
        throw "7z archive detected but 7z is not installed: $ArchivePath"
    }

    if ($ArchivePath -match '\.rar$') {
        if (Get-Command 7z -ErrorAction SilentlyContinue) {
            & 7z x "$ArchivePath" "-o$DestinationPath" -y | Out-Null
            return
        }

        if (Get-Command unrar -ErrorAction SilentlyContinue) {
            & unrar x -o+ "$ArchivePath" "$DestinationPath\" | Out-Null
            return
        }

        throw "rar archive detected but neither 7z nor unrar is installed: $ArchivePath"
    }

    throw "Unsupported archive type: $ArchivePath"
}

function Get-PluginContentPath {
    param([string]$ExtractRoot)

    $pluginJson = Get-ChildItem -Path $ExtractRoot -Filter 'plugin.json' -Recurse -File -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pluginJson) {
        return Split-Path -Parent $pluginJson.FullName
    }

    $candidates = Get-ChildItem -Path $ExtractRoot -Directory -ErrorAction SilentlyContinue
    if ($candidates.Count -eq 1) {
        return $candidates[0].FullName
    }

    return $ExtractRoot
}

function Stop-PowerToysForPluginInstall {
    $running = @(Get-Process -Name 'PowerToys' -ErrorAction SilentlyContinue)
    if (-not $running -or $running.Count -eq 0) {
        return @{ WasRunning = $false; ExecutablePath = $null }
    }

    $executablePath = $null
    foreach ($proc in $running) {
        if ($proc.Path) {
            $executablePath = $proc.Path
            break
        }
    }

    if (-not $executablePath) {
        $knownPaths = @(
            (Join-Path $env:ProgramFiles 'PowerToys\PowerToys.exe'),
            (Join-Path $env:LOCALAPPDATA 'PowerToys\PowerToys.exe')
        )
        foreach ($path in $knownPaths) {
            if (Test-Path $path) {
                $executablePath = $path
                break
            }
        }
    }

    Write-Host 'PowerToys is running. Stopping it before plugin update...' -ForegroundColor Yellow
    $running | Stop-Process -Force
    Start-Sleep -Seconds 2

    return @{ WasRunning = $true; ExecutablePath = $executablePath }
}

function Start-PowerToysAfterPluginInstall {
    param([hashtable]$State)

    if (-not $State -or -not $State.WasRunning) {
        return
    }

    $executablePath = $State.ExecutablePath
    if (-not $executablePath -or -not (Test-Path $executablePath)) {
        $knownPaths = @(
            (Join-Path $env:ProgramFiles 'PowerToys\PowerToys.exe'),
            (Join-Path $env:LOCALAPPDATA 'PowerToys\PowerToys.exe')
        )
        foreach ($path in $knownPaths) {
            if (Test-Path $path) {
                $executablePath = $path
                break
            }
        }
    }

    if ($executablePath -and (Test-Path $executablePath)) {
        Start-Process -FilePath $executablePath
        Write-Host 'PowerToys restarted after plugin update.' -ForegroundColor Green
    }
    else {
        Write-Host 'PowerToys was stopped, but executable was not found for auto-restart.' -ForegroundColor Yellow
    }
}

function Install-PowerToysPluginsFromGitHub {
    param(
        [string[]]$Repos,
        [string]$Architecture,
        [string]$PluginsDestination,
        [string]$DownloadCache
    )

    Write-Step 'Installing PowerToys Run plugins from GitHub releases'

    Ensure-Directory -Path $PluginsDestination
    Ensure-Directory -Path $DownloadCache

    foreach ($repoUrl in $Repos) {
        try {
            $owner, $name = Get-RepoOwnerAndName -RepoUrl $repoUrl
            Write-Host "Processing: $owner/$name"

            $releaseApi = "https://api.github.com/repos/$owner/$name/releases/latest"
            $release = Invoke-RestMethod -Uri $releaseApi -Headers @{ 'User-Agent' = 'install-powertoys' }

            $asset = Get-PreferredReleaseAsset -Assets $release.assets -Architecture $Architecture
            if (-not $asset) {
                Write-Host "No archive asset found for $owner/$name (x64/arm64). Skipping." -ForegroundColor Yellow
                continue
            }

            $archivePath = Join-Path $DownloadCache $asset.name
            $extractPath = Join-Path $DownloadCache ("$name-extracted")
            $targetPath = Join-Path $PluginsDestination $name

            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $archivePath
            Expand-PluginArchive -ArchivePath $archivePath -DestinationPath $extractPath

            $contentPath = Get-PluginContentPath -ExtractRoot $extractPath

            if (Test-Path $targetPath) {
                Remove-Item -Recurse -Force $targetPath
            }
            Ensure-Directory -Path $targetPath
            Copy-Item -Path (Join-Path $contentPath '*') -Destination $targetPath -Recurse -Force

            Write-Host "Installed plugin to: $targetPath" -ForegroundColor Green
        }
        catch {
            $errorMessage = $_.Exception.Message
            Write-Host "Failed plugin install for $repoUrl - $errorMessage" -ForegroundColor Red
        }
    }
}

# Main execution
Write-Step "Plugin architecture: $PluginArchitecture"
Write-Step "Plugins root: $PluginsRoot"

$powerToysState = Stop-PowerToysForPluginInstall
try {
    Install-PowerToysPluginsFromGitHub -Repos $PluginRepos -Architecture $PluginArchitecture -PluginsDestination $PluginsRoot -DownloadCache $PluginDownloadCache
}
finally {
    Start-PowerToysAfterPluginInstall -State $powerToysState
}

Write-Step 'PowerToys Run plugin setup complete.'
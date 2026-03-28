$ErrorActionPreference = 'Stop'

$ScriptsRoot = Split-Path -Parent $PSCommandPath

$PluginArchitecture = if ($env:PROCESSOR_ARCHITECTURE -match 'ARM64') { 'arm64' } else { 'x64' }
$PluginsRoot = Join-Path $HOME 'AppData\Local\Microsoft\PowerToys\PowerToys Run\Plugins'
$PluginDownloadCache = Join-Path $HOME '.cache\powertoys-plugin-cache'

$LanguageSetupScript = Join-Path $ScriptsRoot 'languages\install-language-toolchains.ps1'
$PreferredWslDistro = 'Ubuntu'

$PluginRepos = @(
    'https://github.com/ruslanlap/PowerToysRun-VideoDownloader',
    'https://github.com/ruslanlap/PowerToysRun-SpeedTest',
    'https://github.com/ruslanlap/PowerToysRun-Hotkeys',
    'https://github.com/Darkdriller/PowerToys-Run-LocalLLm',
    'https://github.com/nathancartlidge/powertoys-run-unicode',
    'https://github.com/8LWXpg/PowerToysRun-ProcessKiller',
    'https://github.com/Quriz/PowerToysRunScoop',
    'https://github.com/dandn9/prun-lorem',
    'https://github.com/bostrot/PowerToysRunPluginWinget'
)

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

function Apply-GitConfigHardcoded {
    Write-Step 'Applying hardcoded git global config'
    git config --global user.name 'Triyan Mukherjee'
    git config --global user.email 'triyanmukherjee@gmail.com'
    Write-Host 'Set git config: user.name' -ForegroundColor Green
    Write-Host 'Set git config: user.email' -ForegroundColor Green

    $repoDeltaGitConfig = Join-Path (Split-Path -Parent $ScriptsRoot) 'delta\gitconfig'
    if (Test-Path $repoDeltaGitConfig) {
        $existingIncludes = @(git config --global --get-all include.path 2>$null)
        $repoDeltaGitConfigForward = $repoDeltaGitConfig.Replace('\', '/')

        if (-not ($existingIncludes -contains $repoDeltaGitConfig) -and -not ($existingIncludes -contains $repoDeltaGitConfigForward)) {
            git config --global --add include.path $repoDeltaGitConfig
            Write-Host "Added git include.path for delta config: $repoDeltaGitConfig" -ForegroundColor Green
        }
        else {
            Write-Host "Git include.path already present for delta config: $repoDeltaGitConfig" -ForegroundColor DarkGreen
        }
    }
    else {
        Write-Host "delta git config not found: $repoDeltaGitConfig" -ForegroundColor Yellow
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
        $_.name -match '\.(zip|nupkg|7z)$'
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

function Install-PowerShellProfile {
    Write-Step 'Setting up PowerShell profile'
    
    $RepoProfileScript = Join-Path (Split-Path -Parent $ScriptsRoot) 'PowerShell\profile.ps1'
    
    if (-not (Test-Path $RepoProfileScript)) {
        Write-Host "Profile source not found: $RepoProfileScript" -ForegroundColor Yellow
        return
    }
    
    # Ensure default PowerShell profile directory exists
    $ProfileDir = Split-Path -Parent $PROFILE
    Ensure-Directory -Path $ProfileDir
    
    # Copy profile to standard location
    Copy-Item -Path $RepoProfileScript -Destination $PROFILE -Force
    Write-Host "PowerShell profile updated: $PROFILE" -ForegroundColor Green
}

function Install-ClinkSetup {
    Write-Step 'Setting up Clink for cmd.exe'
    
    if (-not (Get-Command clink -ErrorAction SilentlyContinue)) {
        Write-Host 'clink not found; skipping setup.' -ForegroundColor Yellow
        return
    }
    
    try {
        clink autorun install 2>$null
        Write-Host 'Clink autorun enabled' -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to enable clink autorun: $($_.Exception.Message)" -ForegroundColor Yellow
    }
    
    $OhMyPoshTheme = Join-Path (Split-Path -Parent $ScriptsRoot) 'oh-my-posh\themes\night-owl.omp.json'
    
    if (-not (Test-Path $OhMyPoshTheme)) {
        Write-Host "Oh My Posh theme not found at: $OhMyPoshTheme" -ForegroundColor Yellow
        return
    }
    
    try {
        clink config prompt use oh-my-posh 2>$null
        clink set ohmyposh.theme $OhMyPoshTheme 2>$null
        Write-Host 'Clink Oh My Posh configured' -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to configure Oh My Posh for clink: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Install-OhMyPoshFonts {
    Write-Step 'Ensuring Oh My Posh fonts'

    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
        Write-Host 'oh-my-posh not found; skipping font install.' -ForegroundColor Yellow
        return
    }

    $fonts = @('meslo', 'jetbrainsmono')
    foreach ($font in $fonts) {
        try {
            oh-my-posh font install $font
            Write-Host "Font ensured: $font" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install font ${font}: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

function Ensure-WSLInstalled {
    Write-Step 'Ensuring WSL is available'

    $platformReady = $false

    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        $null = (& wsl --status 2>&1 | Out-String)
        if ($LASTEXITCODE -eq 0) {
            Write-Host 'WSL is already available.' -ForegroundColor DarkGreen
            $platformReady = $true
        }
        else {
            Write-Host 'WSL command exists but platform is not fully configured. Attempting install...' -ForegroundColor Yellow
        }
    }
    else {
        Write-Host 'WSL command not found. Attempting install...' -ForegroundColor Yellow
    }

    if (-not $platformReady) {
        try {
            Start-Process -FilePath powershell -Verb RunAs -Wait -ArgumentList '-NoProfile -Command "wsl --install --no-distribution"'
            Write-Host 'WSL platform install command executed. A reboot may be required.' -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to install WSL platform automatically: $($_.Exception.Message)" -ForegroundColor Yellow
            return
        }
    }

    try {
        $installedDistros = @(& wsl --list --quiet 2>$null | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        if ($installedDistros -contains $PreferredWslDistro) {
            Write-Host "WSL distro already installed: $PreferredWslDistro" -ForegroundColor DarkGreen
            return
        }

        Write-Host "Installing WSL distro: $PreferredWslDistro" -ForegroundColor Cyan
        & wsl --install -d $PreferredWslDistro
        Write-Host "WSL distro install command executed: $PreferredWslDistro" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install WSL distro ${PreferredWslDistro}: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Install-WindowsTerminalProfileIcons {
    Write-Step 'Setting up Windows Terminal profile icons'

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
    Write-Step 'Setting up Windows Terminal settings'

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
            $release = Invoke-RestMethod -Uri $releaseApi -Headers @{ 'User-Agent' = 'config-setup' }

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
            Write-Host ("Failed plugin install for " + $repoUrl + " - " + $errorMessage) -ForegroundColor Red
        }
    }
}

Write-Step 'Setting up PowerShell and cmd shell'
Install-OhMyPoshFonts
Install-PowerShellProfile

$repoBatConfig = Join-Path (Split-Path -Parent $ScriptsRoot) 'bat\config'
if (Test-Path $repoBatConfig) {
    [Environment]::SetEnvironmentVariable('BAT_CONFIG_PATH', $repoBatConfig, 'User')
    $env:BAT_CONFIG_PATH = $repoBatConfig
    Write-Host "BAT_CONFIG_PATH set (User): $repoBatConfig" -ForegroundColor Green
}
else {
    Write-Host "bat config not found: $repoBatConfig" -ForegroundColor Yellow
}

$repoEzaConfigDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'eza'
if (Test-Path $repoEzaConfigDir) {
    Ensure-Directory -Path $repoEzaConfigDir
    [Environment]::SetEnvironmentVariable('EZA_CONFIG_DIR', $repoEzaConfigDir, 'User')
    $env:EZA_CONFIG_DIR = $repoEzaConfigDir
    Write-Host "EZA_CONFIG_DIR set (User): $repoEzaConfigDir" -ForegroundColor Green

    $repoEzaTheme = Join-Path $repoEzaConfigDir 'theme.yml'
    if (-not (Test-Path $repoEzaTheme)) {
        Set-Content -Path $repoEzaTheme -Value "colourful: true`n" -Encoding UTF8
        Write-Host "Created default eza theme file: $repoEzaTheme" -ForegroundColor DarkGreen
    }
}
else {
    Write-Host "eza config directory not found: $repoEzaConfigDir" -ForegroundColor Yellow
}

$postingThemeDir = Join-Path $HOME '.config\posting\themes'
Ensure-Directory -Path $postingThemeDir
[Environment]::SetEnvironmentVariable('POSTING_THEME_DIRECTORY', $postingThemeDir, 'User')
$env:POSTING_THEME_DIRECTORY = $postingThemeDir
Write-Host "POSTING_THEME_DIRECTORY set (User): $postingThemeDir" -ForegroundColor Green

$repoYaziConfigDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'yazi'
if (Test-Path $repoYaziConfigDir) {
    Ensure-Directory -Path $repoYaziConfigDir
    [Environment]::SetEnvironmentVariable('YAZI_CONFIG_HOME', $repoYaziConfigDir, 'User')
    $env:YAZI_CONFIG_HOME = $repoYaziConfigDir
    Write-Host "YAZI_CONFIG_HOME set (User): $repoYaziConfigDir" -ForegroundColor Green
}
else {
    Write-Host "yazi config directory not found: $repoYaziConfigDir" -ForegroundColor Yellow
}

$repoRipgrepDir = Join-Path (Split-Path -Parent $ScriptsRoot) 'ripgrep'
$repoRipgrepTemplate = Join-Path $repoRipgrepDir 'ripgreprc.template'
$repoRipgrepIgnore = Join-Path $repoRipgrepDir 'ignore'
$userRipgrepConfig = Join-Path $HOME '.ripgreprc'
if ((Test-Path $repoRipgrepTemplate) -and (Test-Path $repoRipgrepIgnore)) {
    $ripgrepTemplateContent = Get-Content -Path $repoRipgrepTemplate -Raw
    $ripgrepConfigContent = $ripgrepTemplateContent.Replace('__RIPGREP_IGNORE_FILE__', $repoRipgrepIgnore.Replace('\', '/'))
    Set-Content -Path $userRipgrepConfig -Value $ripgrepConfigContent -Encoding UTF8

    [Environment]::SetEnvironmentVariable('RIPGREP_CONFIG_PATH', $userRipgrepConfig, 'User')
    $env:RIPGREP_CONFIG_PATH = $userRipgrepConfig
    Write-Host "RIPGREP_CONFIG_PATH set (User): $userRipgrepConfig" -ForegroundColor Green
}
else {
    Write-Host "ripgrep template/ignore missing in: $repoRipgrepDir" -ForegroundColor Yellow
}

# direnv setup - disabled (kept for future enablement)
# $direnvRootDir = Join-Path $HOME '.direnv'
# $direnvConfigDir = Join-Path $direnvRootDir 'config'
#
# Ensure-Directory -Path $direnvConfigDir
#
# [Environment]::SetEnvironmentVariable('DIRENV_CONFIG', $direnvConfigDir, 'User')
# $env:DIRENV_CONFIG = $direnvConfigDir
# Write-Host "DIRENV_CONFIG set (User): $direnvConfigDir" -ForegroundColor Green

Install-ClinkSetup
Ensure-WSLInstalled
Install-WindowsTerminalProfileIcons
Install-WindowsTerminalSettings

Write-Step 'Setting up git config'

if (Get-Command git -ErrorAction SilentlyContinue) {
    Apply-GitConfigHardcoded
    Write-Host 'Git config setup complete.' -ForegroundColor Green
}
else {
    Write-Host 'git not found; skipping git apply.' -ForegroundColor Yellow
}

Write-Step 'Setting up language toolchains'
if (Test-Path $LanguageSetupScript) {
    & $LanguageSetupScript
}
else {
    Write-Host "Language setup script not found: $LanguageSetupScript" -ForegroundColor Yellow
}

Write-Step 'Setting up PowerToys Run plugins from GitHub releases'

Write-Step "Plugin architecture: $PluginArchitecture"
Write-Step "Plugins root: $PluginsRoot"

Install-PowerToysPluginsFromGitHub -Repos $PluginRepos -Architecture $PluginArchitecture -PluginsDestination $PluginsRoot -DownloadCache $PluginDownloadCache

Write-Step 'PowerToys Run plugin setup complete.'
Write-Step 'All configuration setup complete.'

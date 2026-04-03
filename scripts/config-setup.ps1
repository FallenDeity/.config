param(
    [switch]$ConfigOnly
)

$ErrorActionPreference = 'Stop'

$ScriptsRoot = Split-Path -Parent $PSCommandPath
$LanguageSetupScript = Join-Path $ScriptsRoot 'languages\install-language-toolchains.ps1'
$PreferredWslDistro = 'Ubuntu'

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

function Convert-DircolorsFileToLsColors {
    param([string]$Path)
    if (-not (Test-Path $Path)) {
        return $null
    }

    $entries = New-Object System.Collections.Generic.List[string]
    $ignoredKeywords = @('TERM', 'COLOR', 'EIGHTBIT', 'OPTIONS')

    foreach ($line in Get-Content -Path $Path) {
        $trimmed = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($trimmed) -or $trimmed.StartsWith('#')) {
            continue
        }

        $content = $trimmed -replace '\s+#.*$', ''
        if ([string]::IsNullOrWhiteSpace($content)) {
            continue
        }

        $tokens = $content -split '\s+'
        if ($tokens.Count -lt 2) {
            continue
        }

        if ($ignoredKeywords -contains $tokens[0]) {
            continue
        }

        $value = ($tokens[1..($tokens.Count - 1)] -join ' ').Trim()
        if ([string]::IsNullOrWhiteSpace($value)) {
            continue
        }

        $entries.Add(('{0}={1}' -f $tokens[0], $value))
    }

    if ($entries.Count -eq 0) {
        return $null
    }

    return ($entries -join ':')
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

function Set-ConfigEnvironmentVariable {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Description = $null
    )

    if (-not (Test-Path $Path)) {
        Write-Host "$Name path not found: $Path" -ForegroundColor Yellow
        return
    }

    [Environment]::SetEnvironmentVariable($Name, $Path, 'User')
    Set-Item -Path "env:$Name" -Value $Path
    Write-Host "$Name set (User): $Path" -ForegroundColor Green
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

    $backupFile = Join-Path $Destination ("{0}.backup.{1}" -f (Split-Path -Leaf $Source), (Get-Date -Format 'yyyyMMdd-HHmmss'))
    if (Test-Path (Join-Path $Destination (Split-Path -Leaf $Source))) {
        Copy-Item -Path (Join-Path $Destination (Split-Path -Leaf $Source)) -Destination $backupFile -Force -ErrorAction SilentlyContinue
        Write-Host "Backed up existing to: $backupFile" -ForegroundColor DarkGreen
    }

    Copy-Item -Path (Join-Path $Source '*') -Destination $Destination -Recurse -Force
    Write-Host "$Description synced to: $Destination" -ForegroundColor Green
}

function Install-PowerShellProfile {
    Write-Step 'Setting up PowerShell profile'
    
    $RepoProfileScript = Join-Path (Split-Path -Parent $ScriptsRoot) 'PowerShell\profile.ps1'
    
    if (-not (Test-Path $RepoProfileScript)) {
        Write-Host "Profile source not found: $RepoProfileScript" -ForegroundColor Yellow
        return
    }
    
    $repoConfigRoot = Split-Path -Parent $ScriptsRoot
    $repoProfilePath = Join-Path $repoConfigRoot 'PowerShell\profile.ps1'

    $bootstrap = @"
`$RepoProfile = '$($repoProfilePath.Replace("'", "''"))'
if (Test-Path `$RepoProfile) {
    . `$RepoProfile
}
else {
    Write-Host "Repo profile not found: `$RepoProfile" -ForegroundColor Yellow
}
"@

    $primaryTarget = $PROFILE.CurrentUserCurrentHost
    $secondaryTarget = $PROFILE.CurrentUserAllHosts

    if ([string]::IsNullOrWhiteSpace($primaryTarget)) {
        $documentsPath = [Environment]::GetFolderPath('MyDocuments')
        $primaryTarget = Join-Path $documentsPath 'PowerShell\Microsoft.PowerShell_profile.ps1'
    }

    $profileDir = Split-Path -Parent $primaryTarget
    Ensure-Directory -Path $profileDir
    Set-Content -Path $primaryTarget -Value $bootstrap -Encoding UTF8
    Write-Host "PowerShell profile bootstrap updated: $primaryTarget" -ForegroundColor Green

    if (-not [string]::IsNullOrWhiteSpace($secondaryTarget) -and ($secondaryTarget -ne $primaryTarget) -and (Test-Path $secondaryTarget)) {
        $secondaryContent = Get-Content -Path $secondaryTarget -Raw
        if ($secondaryContent -match [regex]::Escape($repoProfilePath)) {
            Set-Content -Path $secondaryTarget -Value '# Disabled by config-setup: use CurrentUserCurrentHost profile bootstrap only.' -Encoding UTF8
            Write-Host "Disabled duplicate profile bootstrap: $secondaryTarget" -ForegroundColor DarkGreen
        }
    }
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

    $repoCmdStartupScript = Join-Path (Split-Path -Parent $ScriptsRoot) 'cmd\clink_start.cmd'
    if (Test-Path $repoCmdStartupScript) {
        try {
            clink set clink.autostart "call `"$repoCmdStartupScript`"" 2>$null
            Write-Host "Clink autostart set to: $repoCmdStartupScript" -ForegroundColor Green
        }
        catch {
            Write-Host "Failed to configure clink autostart: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    else {
        Write-Host "Cmd startup script not found: $repoCmdStartupScript" -ForegroundColor Yellow
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
        if ($installedDistros | Where-Object { $_ -ieq $PreferredWslDistro }) {
            Write-Host "WSL distro already installed: $PreferredWslDistro" -ForegroundColor DarkGreen
            return
        }

        if ($installedDistros.Count -gt 0) {
            Write-Host ("WSL distro(s) already present: {0}. Skipping install of preferred distro '{1}'." -f ($installedDistros -join ', '), $PreferredWslDistro) -ForegroundColor DarkGreen
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


function Initialize-GitSubmodules {
    Write-Step 'Initializing git submodules'
    
    $repoRoot = Split-Path -Parent $ScriptsRoot
    
    try {
        Push-Location $repoRoot
        $result = git submodule status 2>&1
        
        if ($result -match '^\-') {
            Write-Host 'Uninitialized submodules detected, running git submodule update --init --recursive' -ForegroundColor DarkGreen
            git submodule update --init --recursive
            Write-Host 'Git submodules initialized successfully.' -ForegroundColor Green
        }
        else {
            Write-Host 'Git submodules already initialized.' -ForegroundColor DarkGreen
        }
    }
    catch {
        Write-Host "Warning: Failed to initialize submodules: $_" -ForegroundColor Yellow
    }
    finally {
        Pop-Location
    }
}

Write-Step 'Setting up PowerShell and cmd shell'
if (-not $ConfigOnly) {
    Install-OhMyPoshFonts
}
else {
    Write-Host 'Config-only mode: skipping Oh My Posh font install.' -ForegroundColor DarkGreen
}
Install-PowerShellProfile

# Initialize git submodules early so repo-vendored plugins/configs are available
Initialize-GitSubmodules

$repoConfigRoot = Split-Path -Parent $ScriptsRoot
Write-Host "Config root: $repoConfigRoot" -ForegroundColor DarkGreen

# Set environment variables from repo config files
Set-ConfigEnvironmentVariable -Name 'PSMUX_CONFIG_FILE' -Path (Join-Path $repoConfigRoot 'psmux\psmux.conf')
Set-ConfigEnvironmentVariable -Name 'BAT_CONFIG_PATH' -Path (Join-Path $repoConfigRoot 'bat\config')
Set-ConfigEnvironmentVariable -Name 'EZA_CONFIG_DIR' -Path (Join-Path $repoConfigRoot 'eza')
Set-ConfigEnvironmentVariable -Name 'YAZI_CONFIG_HOME' -Path (Join-Path $repoConfigRoot 'yazi')

# Handle dir colors and derived LS_COLORS/EZA_COLORS
$repoDircolorsFile = Join-Path $repoConfigRoot 'dircolors\dircolors'
if (Test-Path $repoDircolorsFile) {
    Set-ConfigEnvironmentVariable -Name 'DIR_COLORS' -Path $repoDircolorsFile
    $lsColorsValue = Convert-DircolorsFileToLsColors -Path $repoDircolorsFile
    if (-not [string]::IsNullOrWhiteSpace($lsColorsValue)) {
        [Environment]::SetEnvironmentVariable('LS_COLORS', $lsColorsValue, 'User')
        $env:LS_COLORS = $lsColorsValue
        [Environment]::SetEnvironmentVariable('EZA_COLORS', $lsColorsValue, 'User')
        $env:EZA_COLORS = $lsColorsValue
        Write-Host 'LS_COLORS and EZA_COLORS generated from dircolors file and set (User).' -ForegroundColor Green
    }
}
else {
    Write-Host "dircolors config file not found: $repoDircolorsFile" -ForegroundColor Yellow
}

# Posting themes directory
$postingThemeDir = Join-Path $HOME '.config\posting\themes'
Ensure-Directory -Path $postingThemeDir
[Environment]::SetEnvironmentVariable('POSTING_THEME_DIRECTORY', $postingThemeDir, 'User')
$env:POSTING_THEME_DIRECTORY = $postingThemeDir
Write-Host "POSTING_THEME_DIRECTORY set (User): $postingThemeDir" -ForegroundColor Green

# Lazygit config sync
$repoLazygitDir = Join-Path $repoConfigRoot 'lazygit'
$homeLazygitDir = Join-Path $HOME '.config\lazygit'
if (Test-Path $repoLazygitDir) {
    Sync-ConfigDirectory -Source $repoLazygitDir -Destination $homeLazygitDir -Description 'Lazygit config'
    $lazygitBaseConfig = Join-Path $homeLazygitDir 'config.yml'
    $lazygitThemeFile = Join-Path $homeLazygitDir 'themes\mocha\blue.yml'
    if ((Test-Path $lazygitBaseConfig) -and (Test-Path $lazygitThemeFile)) {
        $lgConfigValue = "{0},{1}" -f ($lazygitBaseConfig.Replace('\', '/')), ($lazygitThemeFile.Replace('\', '/'))
        [Environment]::SetEnvironmentVariable('LG_CONFIG_FILE', $lgConfigValue, 'User')
        $env:LG_CONFIG_FILE = $lgConfigValue
        Write-Host "LG_CONFIG_FILE set (User): $lgConfigValue" -ForegroundColor Green
    }
}

# Ripgrep config generation
$repoRipgrepDir = Join-Path $repoConfigRoot 'ripgrep'
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
if (-not $ConfigOnly) {
    Ensure-WSLInstalled
}
else {
    Write-Host 'Config-only mode: skipping WSL install checks.' -ForegroundColor DarkGreen
}
$configAssetsScript = Join-Path $ScriptsRoot 'helpers\install-config-assets.ps1'
if (Test-Path $configAssetsScript) {
    & $configAssetsScript -ScriptsRoot $ScriptsRoot
}
else {
    Write-Host "Config assets installer script not found: $configAssetsScript" -ForegroundColor Yellow
}

Write-Step 'Setting up git config'

if (Get-Command git -ErrorAction SilentlyContinue) {
    Apply-GitConfigHardcoded
    Write-Host 'Git config setup complete.' -ForegroundColor Green
}
else {
    Write-Host 'git not found; skipping git apply.' -ForegroundColor Yellow
}

Write-Step 'Setting up language toolchains'
if ($ConfigOnly) {
    Write-Host 'Config-only mode: skipping language toolchain install.' -ForegroundColor DarkGreen
}
elseif (Test-Path $LanguageSetupScript) {
    & $LanguageSetupScript
}
else {
    Write-Host "Language setup script not found: $LanguageSetupScript" -ForegroundColor Yellow
}

# PowerToys plugin setup (delegated to separate script)
if ($ConfigOnly) {
    Write-Host 'Config-only mode: skipping PowerToys plugin install.' -ForegroundColor DarkGreen
}
else {
    $powerToysScript = Join-Path $ScriptsRoot 'helpers\install-powertoys.ps1'
    if (Test-Path $powerToysScript) {
        & $powerToysScript
    }
    else {
        Write-Host "PowerToys install script not found: $powerToysScript" -ForegroundColor Yellow
    }
}

Write-Step 'All configuration setup complete.'

param(
    [string]$ScriptsRoot
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

Write-Step "Configuring Spicetify & Spotify"

$spotifyExe = "$env:APPDATA\Spotify\Spotify.exe"
if (-not (Test-Path $spotifyExe)) {
    Write-Host "  [!] Spotify desktop client not found at $spotifyExe. Skipping Spicetify setup." -ForegroundColor Yellow
    return
}

# 1. Locate spicetify CLI binary via candidate loop
$spicetifyCandidates = @(
    (Get-Command spicetify -ErrorAction SilentlyContinue)?.Source,
    "$env:LOCALAPPDATA\spicetify\spicetify.exe",
    "$HOME\scoop\shims\spicetify.exe",
    "$HOME\scoop\apps\spicetify-cli\current\spicetify.exe"
)
$spicetifyExe = $spicetifyCandidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1

if (-not $spicetifyExe) {
    Write-Host "  [!] Spicetify CLI not found (install via 'scoop install spicetify-cli'). Skipping." -ForegroundColor Yellow
    return
}

Write-Host "  [=] Using Spicetify CLI: $spicetifyExe" -ForegroundColor DarkGray

# 2. Sync Spicetify dotfiles configuration, themes, and extensions
$repoRoot = if ($ScriptsRoot) { Split-Path -Parent $ScriptsRoot } else { (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) }
$repoSpicetifyDir = Join-Path $repoRoot 'spicetify'
$targetSpicetifyDir = "$env:APPDATA\spicetify"

if (Test-Path $repoSpicetifyDir) {
    Write-Host "  [+] Syncing Spicetify configuration from dotfiles..." -ForegroundColor Green
    if (-not (Test-Path $targetSpicetifyDir)) {
        New-Item -ItemType Directory -Path $targetSpicetifyDir -Force | Out-Null
    }

    # Copy Themes & Extensions folders if present in repo
    foreach ($folder in @('Themes', 'Extensions', 'CustomApps')) {
        $src = Join-Path $repoSpicetifyDir $folder
        if (Test-Path $src) {
            $dest = Join-Path $targetSpicetifyDir $folder
            Copy-Item -Path (Join-Path $src '*') -Destination $dest -Recurse -Force
        }
    }

    # Update config-xpui.ini with portable paths
    $repoConfigIni = Join-Path $repoSpicetifyDir 'config-xpui.ini'
    $targetConfigIni = Join-Path $targetSpicetifyDir 'config-xpui.ini'
    if (Test-Path $repoConfigIni) {
        $iniContent = Get-Content $repoConfigIni -Raw
        $iniContent = $iniContent -replace '(?m)^spotify_path\s*=.*$', "spotify_path           = $env:APPDATA\Spotify"
        $iniContent = $iniContent -replace '(?m)^prefs_path\s*=.*$', "prefs_path             = $env:APPDATA\Spotify\prefs"
        
        # Preserve existing [Backup] section if present on target machine
        if (Test-Path $targetConfigIni) {
            $existingIni = Get-Content $targetConfigIni -Raw
            if ($existingIni -match '(?s)(\[Backup\].*)$') {
                $backupSection = $matches[1]
                if ($iniContent -notmatch '\[Backup\]') {
                    $iniContent = $iniContent.TrimEnd() + "`r`n`r`n" + $backupSection
                }
            }
        }
        $iniContent | Set-Content -Path $targetConfigIni -Encoding UTF8
        Write-Host "  [+] Synced config-xpui.ini." -ForegroundColor Green
    }
}

# 3. Apply Spicetify configuration
$spotifyProcess = Get-Process -Name Spotify -ErrorAction SilentlyContinue
if ($spotifyProcess) {
    Write-Host "  [=] Spotify is currently running. Skipped 'spicetify apply' to avoid interrupting playback." -ForegroundColor DarkGray
} else {
    Write-Host "  [+] Applying Spicetify configuration..." -ForegroundColor Green
    try {
        $backupDir = "$env:APPDATA\spicetify\Backup"
        if (Test-Path $backupDir) {
            & $spicetifyExe -n apply
        } else {
            & $spicetifyExe -n backup apply
        }
        Write-Host "  [+] Spicetify configuration applied successfully." -ForegroundColor Green
    } catch {
        Write-Host "  [!] Spicetify apply error: $_" -ForegroundColor Yellow
    }
}

Write-Host "Spicetify setup complete." -ForegroundColor Green

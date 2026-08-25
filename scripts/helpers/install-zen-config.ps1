param(
    [string]$ScriptsRoot
)

$ErrorActionPreference = 'Stop'

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

Write-Step "Configuring Zen Browser"

$RepoRoot = if ($ScriptsRoot) { Split-Path -Parent $ScriptsRoot } else { Split-Path -Parent (Split-Path -Parent $PSCommandPath) }
$ZenConfigDir = Join-Path $RepoRoot "zen"

if (-not (Test-Path $ZenConfigDir)) {
    Write-Host "Zen config source directory not found at: $ZenConfigDir" -ForegroundColor Yellow
    return
}

$ZenBaseDir = Join-Path $env:APPDATA "zen"
$ZenProfilesDir = Join-Path $ZenBaseDir "Profiles"
Ensure-Directory -Path $ZenProfilesDir

$Profiles = Get-ChildItem -Path $ZenProfilesDir -Directory | Where-Object { $_.Name -like "*Default*" -or $_.Name -like "*release*" }
if (-not $Profiles) {
    $Profiles = Get-ChildItem -Path $ZenProfilesDir -Directory | Select-Object -First 1
}

# If fresh install with no profile yet, create standard default.release and profiles.ini
if (-not $Profiles) {
    $defaultProfileDir = Join-Path $ZenProfilesDir "default.release"
    Ensure-Directory -Path $defaultProfileDir

    $profilesIni = @"
[Profile0]
Name=default
IsRelative=1
Path=Profiles/default.release
Default=1

[General]
StartWithLastProfile=1
Version=2
"@
    Set-Content -Path (Join-Path $ZenBaseDir "profiles.ini") -Value $profilesIni -Encoding UTF8
    $Profiles = @(Get-Item $defaultProfileDir)
    Write-Host "Created initial Zen profile at: $defaultProfileDir" -ForegroundColor Cyan
}

foreach ($Profile in $Profiles) {
    $ProfilePath = $Profile.FullName
    Write-Host "Configuring Zen profile: $($Profile.Name)" -ForegroundColor Green

    # 1. Sync / Symlink chrome directory
    $SourceChrome = Join-Path $ZenConfigDir "chrome"
    $DestChrome = Join-Path $ProfilePath "chrome"
    if (Test-Path $SourceChrome) {
        Ensure-Directory -Path $DestChrome
        Copy-Item -Path (Join-Path $SourceChrome "*") -Destination $DestChrome -Recurse -Force
        Write-Host "  [+] Synced chrome styles to: $DestChrome" -ForegroundColor DarkGreen
    }

    # 2. Sync zen-themes.json
    $SourceThemes = Join-Path $ZenConfigDir "zen-themes.json"
    $DestThemes = Join-Path $ProfilePath "zen-themes.json"
    if (Test-Path $SourceThemes) {
        Copy-Item -Path $SourceThemes -Destination $DestThemes -Force
        Write-Host "  [+] Synced zen-themes.json to: $DestThemes" -ForegroundColor DarkGreen
    }

    # 3. Sync user.js
    $SourceUserJs = Join-Path $ZenConfigDir "user.js"
    $DestUserJs = Join-Path $ProfilePath "user.js"
    if (Test-Path $SourceUserJs) {
        Copy-Item -Path $SourceUserJs -Destination $DestUserJs -Force
        Write-Host "  [+] Synced user.js (preferences) to: $DestUserJs" -ForegroundColor DarkGreen
    }

    # 4. Sync Extensions (.xpi files)
    $SourceExts = Join-Path $ZenConfigDir "extensions"
    $DestExts = Join-Path $ProfilePath "extensions"
    if (Test-Path $SourceExts) {
        Ensure-Directory -Path $DestExts
        Copy-Item -Path (Join-Path $SourceExts "*.xpi") -Destination $DestExts -Force
        Write-Host "  [+] Synced browser extensions to: $DestExts" -ForegroundColor DarkGreen
    }
}

Write-Host "Zen Browser configuration complete." -ForegroundColor Green

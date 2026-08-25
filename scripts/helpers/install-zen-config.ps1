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
[General]
StartWithLastProfile=1
Version=2

[InstallF0DC299D809B9700]
Default=Profiles/default.release
Locked=1

[Profile0]
Name=default
IsRelative=1
Path=Profiles/default.release
Default=1
"@
    Set-Content -Path (Join-Path $ZenBaseDir "profiles.ini") -Value $profilesIni -Encoding UTF8
    $Profiles = @(Get-Item $defaultProfileDir)
    Write-Host "Created initial Zen profile at: $defaultProfileDir" -ForegroundColor Cyan
}

foreach ($Profile in $Profiles) {
    $ProfilePath = $Profile.FullName
    Write-Host "Configuring Zen profile: $($Profile.Name)" -ForegroundColor Green

    # Ensure profiles.ini points Install section directly to this profile
    $profilesIniPath = Join-Path $ZenBaseDir "profiles.ini"
    if (Test-Path $profilesIniPath) {
        $iniContent = Get-Content $profilesIniPath -Raw
        if ($iniContent -match '\[Install[^\]]+\]') {
            $relPath = "Profiles/" + $Profile.Name
            $iniContent = [regex]::Replace($iniContent, '(\[Install[^\]]+\][\r\n]+Default=)[^\r\n]+', "`$1$relPath")
            Set-Content -Path $profilesIniPath -Value $iniContent -Encoding UTF8
        }
    }

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
}

Write-Host "Zen Browser configuration complete." -ForegroundColor Green

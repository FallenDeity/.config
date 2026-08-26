param(
    [string]$ScriptsRoot,
    [switch]$Force
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

$RepoRoot = if ($ScriptsRoot) { Split-Path -Parent $ScriptsRoot } else { Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $PSCommandPath)) }
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

    # 1. Sync chrome directory (only copy files if missing, unless -Force)
    $SourceChrome = Join-Path $ZenConfigDir "chrome"
    $DestChrome = Join-Path $ProfilePath "chrome"
    if (Test-Path $SourceChrome) {
        Ensure-Directory -Path $DestChrome
        $filesToCopy = Get-ChildItem -Path $SourceChrome -Recurse -File
        $copiedCount = 0
        foreach ($file in $filesToCopy) {
            $rel = $file.FullName.Substring($SourceChrome.Length).TrimStart('\', '/')
            $destFilePath = Join-Path $DestChrome $rel
            $destFileDir = Split-Path -Parent $destFilePath
            Ensure-Directory -Path $destFileDir

            if (-not (Test-Path $destFilePath) -or $Force) {
                Copy-Item -Path $file.FullName -Destination $destFilePath -Force
                $copiedCount++
            }
        }
        if ($copiedCount -gt 0) {
            Write-Host "  [+] Synced $copiedCount chrome files to: $DestChrome" -ForegroundColor DarkGreen
        } else {
            Write-Host "  [=] Chrome files already exist; skipping overwrite (use -Force to override)." -ForegroundColor DarkGray
        }
    }

    # 2. Sync zen-themes.json (only if missing, unless -Force)
    $SourceThemes = Join-Path $ZenConfigDir "zen-themes.json"
    $DestThemes = Join-Path $ProfilePath "zen-themes.json"
    if (Test-Path $SourceThemes) {
        if (-not (Test-Path $DestThemes) -or $Force) {
            $themesContent = Get-Content -Path $SourceThemes -Raw
            $escapedProfile = $ProfilePath.Replace('\', '\\')
            $themesContent = $themesContent.Replace('__PROFILE_DIR__', $escapedProfile)
            Set-Content -Path $DestThemes -Value $themesContent -Encoding UTF8
            Write-Host "  [+] Synced zen-themes.json to: $DestThemes" -ForegroundColor DarkGreen
        } else {
            Write-Host "  [=] zen-themes.json already exists; skipping overwrite." -ForegroundColor DarkGray
        }
    }

    # 3. Sync user.js (only if missing, unless -Force)
    $SourceUserJs = Join-Path $ZenConfigDir "user.js"
    $DestUserJs = Join-Path $ProfilePath "user.js"
    if (Test-Path $SourceUserJs) {
        if (-not (Test-Path $DestUserJs) -or $Force) {
            Copy-Item -Path $SourceUserJs -Destination $DestUserJs -Force
            Write-Host "  [+] Synced user.js (preferences) to: $DestUserJs" -ForegroundColor DarkGreen
        } else {
            Write-Host "  [=] user.js already exists; skipping overwrite." -ForegroundColor DarkGray
        }
    }
}

Write-Host "Zen Browser configuration complete." -ForegroundColor Green

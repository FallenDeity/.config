param(
    [string]$ImportFile = (Join-Path $env:USERPROFILE '.config\winstall.json'),
    [switch]$IncludeVersions = $false,
    [switch]$SkipWingetImport = $false
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Ensure-WingetAvailable {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget is not available on this system.'
    }
}

function Ensure-ImportFile {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "winstall source file not found: $Path"
    }

    Write-Host "Using winstall source file: $Path" -ForegroundColor DarkGreen
}

function Import-WingetPackages {
    param(
        [string]$Path,
        [bool]$PinVersions
    )

    Write-Step 'Importing packages from winget export'

    if (-not $PinVersions) {
        winget import --import-file $Path --accept-package-agreements --accept-source-agreements --ignore-versions
        return
    }

    winget import --import-file $Path --accept-package-agreements --accept-source-agreements
}

Write-Step 'Phase 0: Winget bootstrap'
Ensure-WingetAvailable
Ensure-ImportFile -Path $ImportFile

if (-not $SkipWingetImport) {
    Import-WingetPackages -Path $ImportFile -PinVersions:$IncludeVersions
}
else {
    Write-Host 'Skipping winget import as requested.' -ForegroundColor Yellow
}

Write-Step 'Done'


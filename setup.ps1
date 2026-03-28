$ErrorActionPreference = 'Stop'

$Root = Split-Path -Parent $PSCommandPath
$WingetScript = Join-Path $Root 'scripts\install-applications-winget.ps1'
$ScoopScript = Join-Path $Root 'scripts\install-tools-scoop.ps1'
$ConfigScript = Join-Path $Root 'scripts\config-setup.ps1'
$ImportFile = Join-Path $Root 'winstall.json'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

Write-Step 'Phase 1: Winget install'
& $WingetScript -ImportFile $ImportFile

Write-Step 'Phase 2: Scoop install'
& $ScoopScript

Write-Step 'Phase 3: Config setup'
& $ConfigScript

Write-Step 'Setup complete'

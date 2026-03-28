param(
    [string]$ImportFile = (Join-Path $env:USERPROFILE '.config\winstall.json'),
    [switch]$IncludeVersions = $false,
    [switch]$SkipWingetImport = $false,
    [int]$RetryCount = 2,
    [int]$RetryDelaySeconds = 2
)

$ErrorActionPreference = 'Stop'

$PackageInstallerOverrides = @{
}

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

function Get-ManifestPackages {
    param([string]$Path)

    $manifest = Get-Content -Path $Path -Raw | ConvertFrom-Json
    $packages = @()

    foreach ($source in $manifest.Sources) {
        foreach ($package in $source.Packages) {
            if (-not $package.PackageIdentifier) {
                continue
            }

            $packages += [PSCustomObject]@{
                PackageIdentifier = $package.PackageIdentifier
                Version = $package.Version
            }
        }
    }

    return @($packages | Sort-Object PackageIdentifier -Unique)
}

function Install-WingetPackages {
    param(
        [object[]]$Packages,
        [bool]$PinVersions,
        [hashtable]$Overrides,
        [int]$MaxRetries,
        [int]$RetryDelay
    )

    Write-Step 'Installing packages from winget manifest'

    $results = @()

    foreach ($package in $Packages) {
        $packageId = $package.PackageIdentifier
        $packageVersion = $package.Version

        Write-Host "Processing package: $packageId" -ForegroundColor Cyan

        $attempt = 0
        $installed = $false
        $lastOutput = ''

        while ($attempt -le $MaxRetries -and -not $installed) {
            $attempt += 1

            $arguments = @(
                'install',
                '--id', $packageId,
                '-e',
                '--accept-package-agreements',
                '--accept-source-agreements',
                '--disable-interactivity',
                '--verbose-logs'
            )

            if ($PinVersions -and $packageVersion) {
                $arguments += @('--version', $packageVersion)
            }

            if ($Overrides.ContainsKey($packageId) -and $Overrides[$packageId]) {
                $arguments += @('--override', $Overrides[$packageId])
                Write-Host "Using installer override for $packageId" -ForegroundColor DarkGreen
            }

            $lastOutput = (& winget @arguments 2>&1 | Out-String)
            $exitCode = $LASTEXITCODE
            if (-not [string]::IsNullOrWhiteSpace($lastOutput)) {
                Write-Host $lastOutput
            }

            $alreadyInstalled = $lastOutput -match 'Package is already installed:'
            $noUpgrade = $lastOutput -match 'No available upgrade found\.'
            $manualUpgrade = $lastOutput -match 'cannot be upgraded using winget'

            if ($exitCode -eq 0 -or $alreadyInstalled -or $noUpgrade -or $manualUpgrade) {
                $installed = $true
                $status = if ($exitCode -eq 0) { 'installed-or-updated' } elseif ($alreadyInstalled -or $noUpgrade) { 'already-installed' } else { 'manual-upgrade-required' }
                $results += [PSCustomObject]@{
                    PackageIdentifier = $packageId
                    Status = $status
                    Attempts = $attempt
                }
                Write-Host "Status: $status ($packageId)" -ForegroundColor Green
                break
            }

            if ($attempt -le $MaxRetries) {
                Write-Host "Install failed for $packageId (attempt $attempt). Retrying in $RetryDelay second(s)..." -ForegroundColor Yellow
                Start-Sleep -Seconds $RetryDelay
            }
        }

        if (-not $installed) {
            $results += [PSCustomObject]@{
                PackageIdentifier = $packageId
                Status = 'failed'
                Attempts = $attempt
            }
            Write-Host "Status: failed ($packageId)" -ForegroundColor Red
        }
    }

    Write-Step 'Winget package install summary'
    $grouped = $results | Group-Object Status
    foreach ($group in $grouped) {
        Write-Host ("{0}: {1}" -f $group.Name, $group.Count) -ForegroundColor DarkGreen
    }

    $failed = @($results | Where-Object { $_.Status -eq 'failed' })
    if ($failed.Count -gt 0) {
        Write-Host 'Failed packages:' -ForegroundColor Yellow
        $failed | ForEach-Object { Write-Host (" - {0}" -f $_.PackageIdentifier) -ForegroundColor Yellow }
    }
}

Write-Step 'Phase 0: Winget bootstrap'
Ensure-WingetAvailable
Ensure-ImportFile -Path $ImportFile

if (-not $SkipWingetImport) {
    $manifestPackages = Get-ManifestPackages -Path $ImportFile
    Install-WingetPackages -Packages $manifestPackages -PinVersions:$IncludeVersions -Overrides $PackageInstallerOverrides -MaxRetries $RetryCount -RetryDelay $RetryDelaySeconds
}
else {
    Write-Host 'Skipping winget import as requested.' -ForegroundColor Yellow
}

Write-Step 'Done'


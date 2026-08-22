param()

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Ensure-ScoopInstalled {
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host 'Scoop already installed.' -ForegroundColor DarkGreen
        return
    }

    Write-Step 'Installing Scoop'
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

function Ensure-ScoopBuckets {
    param(
        [Parameter(Mandatory = $false)]
        [hashtable]$BucketsWithSources = @{}
    )

    $existingBuckets = @(scoop bucket list 2>$null | ForEach-Object {
        if ($_.Name) { $_.Name }
        elseif ($_ -match '(?i)^\s*([a-z0-9\-_]+)\s+') { $matches[1] }
    })

    foreach ($bucket in $BucketsWithSources.Keys) {
        if ($existingBuckets -contains $bucket) {
            Write-Host "Bucket exists: $bucket" -ForegroundColor DarkGreen
        }
        else {
            $source = $BucketsWithSources[$bucket]
            if ($source) {
                Write-Host "Adding bucket: $bucket ($source)"
                scoop bucket add $bucket $source
            }
            else {
                Write-Host "Adding bucket: $bucket"
                scoop bucket add $bucket
            }
        }
    }
}

function Ensure-ScoopPackages {
    param([string[]]$Packages)

    $installed = @((scoop export | ConvertFrom-Json).apps.name)
    $installedSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    $installed | ForEach-Object { if ($_) { [void]$installedSet.Add($_) } }

    foreach ($pkg in $Packages) {
        $normalized = ($pkg -split '/')[-1]
        if ($installedSet.Contains($pkg) -or $installedSet.Contains($normalized)) {
            Write-Host "Already installed: $pkg" -ForegroundColor DarkGreen
            continue
        }

        Write-Host "Installing: $pkg"
        Install-ScoopPackageSafely -Package $pkg
    }
}

function Remove-ScoopPartialAppDirectory {
    param([string]$Package)

    $scoopRoot = [Environment]::GetEnvironmentVariable('SCOOP', 'User')
    if ([string]::IsNullOrWhiteSpace($scoopRoot)) {
        $scoopRoot = [Environment]::GetEnvironmentVariable('SCOOP', 'Process')
    }

    if ([string]::IsNullOrWhiteSpace($scoopRoot)) {
        return
    }

    $normalized = ($Package -split '/')[-1]
    $appRoot = Join-Path $scoopRoot "apps\$normalized"

    if (Test-Path $appRoot) {
        Remove-Item -Path $appRoot -Recurse -Force
        Write-Host "Removed partial Scoop app directory: $appRoot" -ForegroundColor Yellow
    }
}

function Install-ScoopPackageSafely {
    param([string]$Package)

    $output = & scoop install $Package -u 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0) {
        return
    }

    $normalizedOutput = $output.Trim()
    $collisionDetected = ($normalizedOutput -match 'already exists') -and ($normalizedOutput -match 'pre_install|Running pre_install script')

    if ($collisionDetected) {
        Write-Host "Scoop install collision detected for $Package; retrying once after clearing partial install state." -ForegroundColor Yellow
        Remove-ScoopPartialAppDirectory -Package $Package

        $retryOutput = & scoop install $Package -u 2>&1 | Out-String
        if ($LASTEXITCODE -eq 0) {
            return
        }

        $normalizedOutput = $retryOutput.Trim()
    }

    throw ("Scoop install failed for {0}: {1}" -f $Package, $normalizedOutput)
}

function Ensure-GhExtensions {
    $requiredExtensions = @(
        'dlvhdr/gh-dash'
    )

    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Warning 'gh is not installed; skipping extension setup.'
        return
    }

    Write-Step 'Ensuring GitHub CLI extensions'
    $installedExt = @(gh extension list 2>$null | ForEach-Object {
        if ($_ -match '^([\w\-]+/[\w\-.]+)\s+') { $matches[1] }
    })

    foreach ($ext in $requiredExtensions) {
        if ($installedExt -contains $ext) {
            Write-Host "Extension exists: $ext" -ForegroundColor DarkGreen
        }
        else {
            Write-Host "Installing extension: $ext"
            gh extension install $ext
        }
    }

    $copilotVersion = gh copilot --version 2>$null | Out-String
    if (-not [string]::IsNullOrWhiteSpace($copilotVersion)) {
        Write-Host ("GitHub Copilot CLI ready: {0}" -f ($copilotVersion.Trim())) -ForegroundColor DarkGreen
    }
    else {
        Write-Host 'GitHub Copilot CLI not ready yet. Ensure GitHub.Copilot is installed and run `gh copilot -- --help` once.' -ForegroundColor Yellow
    }

}

function Ensure-UvAndTools {
    Write-Step 'Ensuring uv and uv-managed tools'

    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing uv (winget)'
        winget install --id astral-sh.uv -e --accept-package-agreements --accept-source-agreements
    }
    else {
        Write-Host 'uv already installed.' -ForegroundColor DarkGreen
    }

    $uvTools = @(
        @{ Name = 'posting' },
        @{ Name = 'poetry' },
        @{ Name = 'ruff' },
        @{ Name = 'black' },
        @{ Name = 'ipython'; With = 'catppuccin[pygments]' }
    )
    $listedTools = uv tool list --show-with 2>$null | Out-String

    foreach ($toolObj in $uvTools) {
        $tool = $toolObj.Name
        $withDep = $toolObj.With

        $hasTool = $false
        if ($withDep) {
            $depPattern = ($withDep -replace '\[.*\]', '')
            if ($listedTools -match "(?im)^$([regex]::Escape($tool))\b.*\[with:.*$([regex]::Escape($depPattern)).*\]") {
                $hasTool = $true
            }
        }
        else {
            if ($listedTools -match "(?im)^$([regex]::Escape($tool))\b") {
                $hasTool = $true
            }
        }

        if ($hasTool) {
            Write-Host "uv tool exists: $tool" -ForegroundColor DarkGreen
        }
        else {
            if ($withDep) {
                Write-Host "Installing uv tool: $tool --with $withDep"
                uv tool install $tool --with $withDep --force
            }
            else {
                Write-Host "Installing uv tool: $tool"
                uv tool install $tool
            }
        }
    }
}

function Ensure-CargoAndTools {
    Write-Step 'Ensuring Cargo and Cargo-managed tools'

    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        Write-Host 'Cargo not found; ensure Rust toolchain is installed.' -ForegroundColor Yellow
        return
    }

    $cargoTools = @(
        'matugen',
        'cargo-binstall',
        'cargo-update'
    )

    $installedList = @(cargo install --list 2>$null | Out-String)

    foreach ($tool in $cargoTools) {
        if ($installedList -match "(?im)^$([regex]::Escape($tool))\s+v") {
            Write-Host "Cargo tool exists: $tool" -ForegroundColor DarkGreen
        }
        else {
            Write-Host "Installing Cargo tool: $tool"
            if (Get-Command cargo-binstall -ErrorAction SilentlyContinue) {
                cargo binstall $tool --no-confirm 2>$null
                if ($LASTEXITCODE -ne 0) {
                    cargo install $tool
                }
            }
            else {
                cargo install $tool
            }
        }
    }
}

Ensure-ScoopInstalled

Write-Step 'Updating Scoop and bucket manifests'
scoop update

Write-Step 'Ensuring Scoop buckets'
Ensure-ScoopBuckets -BucketsWithSources @{
    'extras'       = $null
    'nerd-fonts'   = $null
    'sysinternals' = $null
}

$categoryCoreTools = @(
    'uutils-coreutils',
    'autohotkey',
    'bat',
    'btop',
    'bombardier',
    'clink',
    'curl',
    'delta',
    'difftastic',
    'diffutils',
    'direnv',
    'doggo',
    'dos2unix',
    'duf',
    'dust',
    'eza',
    'fastfetch',
    'fd',
    'ffmpeg',
    'file',
    'findutils',
    'fzf',
    'fx',
    'gh',
    'git-crypt',
    'glow',
    'grep',
    'hyperfine',
    'ImageMagick',
    'ghostscript',
    'iperf3',
    'jq',
    'just',
    'kubectl',
    'lazygit',
    'less',
    'make',
    'mediainfo',
    'navi',
    'neovim',
    'ngrok',
    'procs',
    'rclone',
    'ripgrep',
    'scoop-search',
    'sed',
    'sysinternals/autoruns',
    'sysinternals/psexec',
    'sysinternals/psshutdown',
    'sysinternals/regjump',
    'sysinternals/sdelete',
    'tealdeer',
    'tokei',
    'trippy',
    'ttyd',
    'unzip',
    'vhs',
    'watchexec',
    'wget',
    'whois',
    'xh',
    'yazi',
    'yq',
    'zellij',
    'zoxide',
    'pipx',
    'poppler',
    'PSFzf',
    'extras/wezterm',
    'extras/glazewm',
    'extras/zebar',
    'extras/shawl',
    'extras/vcredist2022'
)

$categoryFonts = @(
    'FiraCode',
    'FiraCode-NF-Mono',
    'JetBrains-Mono'
)

Write-Step 'Installing category: Core Tools'
Ensure-ScoopPackages -Packages $categoryCoreTools

Write-Step 'Installing category: Fonts'
Ensure-ScoopPackages -Packages $categoryFonts

Ensure-GhExtensions
Ensure-UvAndTools
Ensure-CargoAndTools

Write-Step 'Ensuring PowerShell modules from PSGallery'
$psModules = @(
    'Terminal-Icons'
    'ZLocation'
    'PsFzf'
    'PSTools'
    'posh-git'
)

foreach ($moduleName in $psModules) {
    if (-not (Get-Module -Name $moduleName -ListAvailable)) {
        Write-Host "Installing module: $moduleName"
        Install-Module -Name $moduleName -Repository PSGallery -Scope CurrentUser -Force -AllowClobber
    }
    else {
        Write-Host "Module already installed: $moduleName" -ForegroundColor DarkGreen
    }
}

Write-Step 'Done'
Write-Host 'Scoop/tool bootstrap complete.' -ForegroundColor Green

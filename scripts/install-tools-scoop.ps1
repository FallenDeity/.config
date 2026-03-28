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
    param([string[]]$Buckets)

    $existingBuckets = @(scoop bucket list | ForEach-Object {
        if ($_ -match '^([\w\-]+)\s+') { $matches[1] }
    })

    foreach ($bucket in $Buckets) {
        if ($existingBuckets -contains $bucket) {
            Write-Host "Bucket exists: $bucket" -ForegroundColor DarkGreen
        }
        else {
            Write-Host "Adding bucket: $bucket"
            scoop bucket add $bucket
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
        scoop install $pkg -u
    }
}

function Ensure-GhExtensions {
    $requiredExtensions = @(
        'github/gh-copilot',
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

    $uvTools = @('posting', 'poetry', 'ruff', 'black')
    $listedTools = uv tool list 2>$null | Out-String

    foreach ($tool in $uvTools) {
        if ($listedTools -match "(?im)^$([regex]::Escape($tool))\b") {
            Write-Host "uv tool exists: $tool" -ForegroundColor DarkGreen
        }
        else {
            Write-Host "Installing uv tool: $tool"
            uv tool install $tool
        }
    }
}

Ensure-ScoopInstalled

Write-Step 'Ensuring Scoop buckets'
Ensure-ScoopBuckets -Buckets @('extras', 'nerd-fonts', 'sysinternals')

$categoryCoreTools = @(
    'uutils-coreutils',
    'autohotkey',
    'bat',
    'bind',
    'broot',
    'clink',
    'curl',
    'delta',
    'diffutils',
    'direnv',
    'dos2unix',
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
    'ImageMagick',
    'ghostscript',
    'iperf3',
    'jq',
    'just',
    'kubectl',
    'lazygit',
    'less',
    'lf',
    'mediainfo',
    'neovim',
    'ngrok',
    'rclone',
    'ripgrep',
    'scoop-search',
    'sed',
    'sysinternals/autoruns',
    'sysinternals/psexec',
    'sysinternals/psshutdown',
    'sysinternals/regjump',
    'sysinternals/sdelete',
    'touch',
    'tre-command',
    'ttyd',
    'unzip',
    'vhs',
    'wget',
    'whois',
    'yazi',
    'zoxide',
    'pipx',
    'poppler',
    'PSFzf',
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

Write-Step 'Ensuring PowerShell modules from PSGallery'
$psModules = @(
    'Terminal-Icons'
    'ZLocation'
    'PsFzf'
    'PSTools'
    'TabExpansionPlusPlus'
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

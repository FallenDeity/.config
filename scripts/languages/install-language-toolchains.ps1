param(
    [string]$NodeVersion = 'lts',
    [int]$JavaLtsVersion = 21,
    [string]$JavaPackageIdOverride = '',
    [string]$RustToolchain = 'stable'
)

$ErrorActionPreference = 'Stop'

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Test-WingetAvailable {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw 'winget is not available on this system.'
    }
}

function Install-NvmIfMissing {
    if (Get-Command nvm -ErrorAction SilentlyContinue) {
        Write-Host 'nvm already installed.' -ForegroundColor DarkGreen
        return
    }

    Write-Step 'Installing nvm (NVM for Windows)'
    winget install --id CoreyButler.NVMforWindows -e --accept-package-agreements --accept-source-agreements
}

function Install-UvIfMissing {
    if (Get-Command uv -ErrorAction SilentlyContinue) {
        Write-Host 'uv already installed.' -ForegroundColor DarkGreen
        return
    }

    Write-Step 'Installing uv'
    winget install --id astral-sh.uv -e --accept-package-agreements --accept-source-agreements
}

function Install-RustupIfMissing {
    if (Get-Command rustup -ErrorAction SilentlyContinue) {
        Write-Host 'rustup already installed.' -ForegroundColor DarkGreen
        return
    }

    Write-Step 'Installing rustup'
    winget install --id Rustlang.Rustup -e --accept-package-agreements --accept-source-agreements
}

function Install-RustToolchainIfMissing {
    if (-not (Get-Command rustup -ErrorAction SilentlyContinue)) {
        throw 'rustup is not available after installation attempt.'
    }

    Write-Step "Ensuring Rust toolchain ($RustToolchain)"
    rustup toolchain install $RustToolchain
    rustup default $RustToolchain
    rustup component add rustfmt clippy

    if (Get-Command rustc -ErrorAction SilentlyContinue) {
        Write-Host ("Rust available: " + (rustc --version)) -ForegroundColor Green
    }
    else {
        Write-Host 'Rust setup completed, but this shell may need to be restarted for PATH changes.' -ForegroundColor Yellow
    }
}

function Install-LatestPythonViaUv {
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw 'uv is not available after installation attempt.'
    }

    Write-Step 'Ensuring latest Python via uv'
    uv python install

    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-Host ("Python available: " + (python --version)) -ForegroundColor Green
    }
    else {
        Write-Host 'Python install completed via uv, but this shell may need to be restarted for PATH changes.' -ForegroundColor Yellow
    }
}

function Install-NodeIfMissing {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        $nodeVersion = node --version
        Write-Host "Node.js already installed: $nodeVersion" -ForegroundColor DarkGreen
        return
    }

    if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) {
        throw 'nvm is not available after installation attempt.'
    }

    Write-Step "Installing and activating Node.js via nvm ($NodeVersion)"
    nvm install $NodeVersion
    nvm use $NodeVersion

    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Host ("Node.js active: " + (node --version)) -ForegroundColor Green
    }
    else {
        Write-Host 'Node.js installation completed, but this shell may need to be restarted for PATH changes.' -ForegroundColor Yellow
    }
}

function Install-TypescriptIfMissing {
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host 'npm not available; skipping TypeScript install in this shell.' -ForegroundColor Yellow
        return
    }

    $npmGlobal = npm list -g --depth=0 2>$null | Out-String
    if ($npmGlobal -match '(?m)\stypescript@') {
        Write-Host 'TypeScript already installed globally.' -ForegroundColor DarkGreen
        return
    }

    Write-Step 'Installing global TypeScript compiler'
    npm install -g typescript
}

function Install-JavaLtsIfMissing {
    $javaPackageId = if ([string]::IsNullOrWhiteSpace($JavaPackageIdOverride)) {
        "EclipseAdoptium.Temurin.$JavaLtsVersion.JDK"
    }
    else {
        $JavaPackageIdOverride
    }

    if (Get-Command java -ErrorAction SilentlyContinue) {
        $javaVersionOutput = java -version 2>&1 | Select-Object -First 1
        Write-Host ("Java already installed: " + $javaVersionOutput) -ForegroundColor DarkGreen
        return
    }

    Write-Step "Installing Java LTS JDK ($javaPackageId)"
    winget install --id $javaPackageId -e --accept-package-agreements --accept-source-agreements
}

Write-Step 'Language toolchain setup'
Test-WingetAvailable
Install-NvmIfMissing
Install-UvIfMissing
Install-RustupIfMissing
Install-RustToolchainIfMissing
Install-LatestPythonViaUv
Install-NodeIfMissing
Install-TypescriptIfMissing
Install-JavaLtsIfMissing
Write-Step 'Language toolchain setup complete'

# PowerShell Profile - Central Configuration
# Optimized for fast startup + multi-machine consistency

$ConfigRoot = Split-Path -Parent $PSScriptRoot
$OhMyPoshTheme = Join-Path $ConfigRoot 'oh-my-posh\themes\night-owl.omp.json'

# ============================================================
# Environment
# ============================================================

$env:VIRTUAL_ENV_DISABLE_PROMPT = '1'
$env:PIP_REQUIRE_VIRTUALENV = 'true'
$env:DFT_THEME = 'dark'

# Catppuccin Mocha theme for fzf
$env:FZF_DEFAULT_OPTS = @(
    '--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8'
    '--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc'
    '--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8'
    '--color=selected-bg:#45475a'
    '--multi'
) -join ' '

# ============================================================
# PSReadLine
# ============================================================

$historyDirectory = Join-Path $env:APPDATA 'PowerShell'

if (-not (Test-Path $historyDirectory)) {
    New-Item -ItemType Directory -Path $historyDirectory -Force | Out-Null
}

$PSReadLineParams = @{
    PredictionSource      = 'History'
    PredictionViewStyle   = 'ListView'
    EditMode              = 'Windows'
    HistoryNoDuplicates   = $true
    HistorySavePath       = Join-Path $historyDirectory 'PSReadline_history.txt'
    MaximumHistoryCount   = 10000
    MaximumKillRingCount  = 50
    BellStyle             = 'None'
}

try {
    Set-PSReadLineOption @PSReadLineParams -ErrorAction Stop
}
catch {
    # Prediction fails under redirected / non-VT hosts (pwsh -Command, CI).
    $PSReadLineParams.Remove('PredictionSource')
    $PSReadLineParams.Remove('PredictionViewStyle')
    Set-PSReadLineOption @PSReadLineParams
}

# PsFzf will be auto-loaded by PowerShell if installed.
if (Get-Command Set-PsFzfOption -ErrorAction SilentlyContinue) {
    Set-PsFzfOption `
        -PSReadlineChordReverseHistory 'Ctrl+r' `
        -PSReadlineChordSetLocation 'Ctrl+t' `
        -TabExpansion
}
else {
    Set-PSReadLineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
}

Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ============================================================
# Oh My Posh
# ============================================================
$OhMyPoshCacheDir = Join-Path $env:LOCALAPPDATA 'PowerShell\cache'
$OhMyPoshCache = Join-Path $OhMyPoshCacheDir 'oh-my-posh-init.ps1'

if (-not (Test-Path $OhMyPoshCacheDir)) {
    New-Item -ItemType Directory -Path $OhMyPoshCacheDir -Force | Out-Null
}

if (-not (Test-Path $OhMyPoshCache)) {
    if (
        (Test-Path $OhMyPoshTheme) -and
        (Get-Command oh-my-posh -CommandType Application -ErrorAction SilentlyContinue)
    ) {
        $ohMyPoshInit = oh-my-posh init pwsh --config $OhMyPoshTheme | Out-String

        # Don't cache empty output or a failed run.
        if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($ohMyPoshInit)) {
            Set-Content -Path $OhMyPoshCache -Value $ohMyPoshInit -Encoding utf8
        }
    }
}

if (Test-Path $OhMyPoshCache) {
    try {
        . $OhMyPoshCache
    }
    catch {
        Write-Warning "Oh My Posh cache was broken and has been removed: $_"
        Remove-Item -Path $OhMyPoshCache -Force -ErrorAction SilentlyContinue
    }
}
# ============================================================
# Cached Shell Integration / Completions
# ============================================================
#
# Previously every PowerShell startup executed:
#
#   gh
#   kubectl
#   uv
#   zoxide
#   rclone
#   zellij
#   rg
#   fd
#   ...
#
# just to generate completion scripts.
#
# Now generated scripts are cached under LOCALAPPDATA and loaded
# directly on subsequent shells.
#

$CompletionCache = Join-Path $env:LOCALAPPDATA 'PowerShell\completion-cache'

if (-not (Test-Path $CompletionCache)) {
    New-Item -ItemType Directory -Path $CompletionCache -Force | Out-Null
}

function Get-CachedInitScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$CommandName,

        [Parameter(Mandatory)]
        [scriptblock]$Generator
    )

    $cacheFile = Join-Path $CompletionCache "$Name.ps1"

    # Fast path: never launch the executable when cache exists.
    if (Test-Path $cacheFile) {
        return $cacheFile
    }

    # Only search PATH / generate when no cache exists.
    $command = Get-Command `
        $CommandName `
        -CommandType Application `
        -ErrorAction SilentlyContinue

    if (-not $command) {
        return $null
    }

    try {
        $global:LASTEXITCODE = 0
        $content = & $Generator | Out-String

        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($content)) {
            return $null
        }

        # Never cache output that isn't valid PowerShell (e.g. usage text
        # from an older tool version) — it would fail on every startup.
        $parseErrors = $null
        [void][System.Management.Automation.Language.Parser]::ParseInput(
            $content, [ref]$null, [ref]$parseErrors
        )

        if ($parseErrors) {
            return $null
        }

        Set-Content `
            -Path $cacheFile `
            -Value $content `
            -Encoding utf8

        return $cacheFile
    }
    catch {
        Write-Verbose "Unable to generate $Name shell integration: $_"
        return $null
    }
}

$ShellIntegrations = @(

    @{
        Name        = 'zoxide'
        CommandName = 'zoxide'
        Generator   = {
            zoxide init powershell
        }
    }

    @{
        Name        = 'gh'
        CommandName = 'gh'
        Generator   = {
            gh completion -s powershell 2>$null
        }
    }

    @{
        Name        = 'uv'
        CommandName = 'uv'
        Generator   = {
            uv generate-shell-completion powershell
        }
    }

    @{
        Name        = 'kubectl'
        CommandName = 'kubectl'
        Generator   = {
            kubectl completion powershell
        }
    }

    @{
        Name        = 'just'
        CommandName = 'just'
        Generator   = {
            just --completions powershell
        }
    }

    @{
        Name        = 'rclone'
        CommandName = 'rclone'
        Generator   = {
            rclone completion powershell
        }
    }

    @{
        Name        = 'ruff'
        CommandName = 'ruff'
        Generator   = {
            ruff generate-shell-completion powershell
        }
    }

    @{
        Name        = 'vhs'
        CommandName = 'vhs'
        Generator   = {
            vhs completion powershell
        }
    }

    @{
        Name        = 'fd'
        CommandName = 'fd'
        Generator   = {
            fd --gen-completions powershell
        }
    }

    @{
        Name        = 'rg'
        CommandName = 'rg'
        Generator   = {
            rg --generate complete-powershell
        }
    }

    @{
        Name        = 'delta'
        CommandName = 'delta'
        Generator   = {
            delta --generate-completion powershell
        }
    }

    @{
        Name        = 'tailscale'
        CommandName = 'tailscale'
        Generator   = {
            tailscale completion powershell 2>$null
        }
    }

    @{
        Name        = 'zellij'
        CommandName = 'zellij'
        Generator   = {
            zellij setup --generate-completion powershell
        }
    }
)

foreach ($integration in $ShellIntegrations) {

    $cacheFile = Get-CachedInitScript @integration

    if ($cacheFile) {
        # IMPORTANT:
        # Dot-source at profile scope so functions / argument completers
        # survive after this loop finishes.
        try {
            . $cacheFile
        }
        catch {
            Write-Warning "$($integration.Name) cache was broken and has been removed: $_"
            Remove-Item -Path $cacheFile -Force -ErrorAction SilentlyContinue
        }
    }
}

# Remove cached scripts after updating CLI tools or the Oh My Posh theme.
function Clear-ShellCompletionCache {
    if (Test-Path $CompletionCache) {
        Remove-Item `
            -Path "$CompletionCache\*.ps1" `
            -Force `
            -ErrorAction SilentlyContinue
    }

    Remove-Item -Path $OhMyPoshCache -Force -ErrorAction SilentlyContinue

    Write-Host 'Shell completion cache cleared. Open a new PowerShell session to regenerate it.' `
        -ForegroundColor Green
}

# ============================================================
# Optional / Heavy Modules
# ============================================================
#
# These used to cost several seconds because they were imported
# eagerly during every startup.
#
# Load manually only when necessary.
#

function Enable-TerminalIcons {
    Import-Module Terminal-Icons -ErrorAction Stop
}

function Enable-PoshGit {
    Import-Module posh-git -ErrorAction Stop
}

function Enable-PSTools {
    Import-Module PSTools -ErrorAction Stop
}

# One-time migration from ZLocation -> zoxide.
#
# Run manually if you still need the old ZLocation history:
#
#   Import-ZLocationToZoxide
#
function Import-ZLocationToZoxide {

    if (-not (Get-Command zoxide -CommandType Application -ErrorAction SilentlyContinue)) {
        Write-Host 'zoxide is not installed.' -ForegroundColor Yellow
        return
    }

    try {
        Import-Module ZLocation -ErrorAction Stop
    }
    catch {
        Write-Host 'ZLocation module is not installed.' -ForegroundColor Yellow
        return
    }

    $locations = Get-ZLocation

    if (-not $locations) {
        Write-Host 'No ZLocation entries found.' -ForegroundColor Yellow
        return
    }

    $importFile = New-TemporaryFile

    try {
        $locations.GetEnumerator() |
            ForEach-Object {
                "$($_.Name)|$($_.Value)|0"
            } |
            Out-File `
                -FilePath $importFile `
                -Encoding utf8

        zoxide import --from=z $importFile --merge

        Write-Host 'ZLocation history imported into zoxide.' `
            -ForegroundColor Green
    }
    finally {
        Remove-Item `
            -Path $importFile `
            -Force `
            -ErrorAction SilentlyContinue
    }
}

# ============================================================
# Cached Native Commands
# ============================================================

$global:EzaCommand = @(
    (Get-Command eza -CommandType Application -ErrorAction SilentlyContinue).Source
)[0]

$global:WslCommand = @(
    (Get-Command wsl -CommandType Application -ErrorAction SilentlyContinue).Source
)[0]

$global:GitCommand = @(
    (Get-Command git -CommandType Application -ErrorAction SilentlyContinue).Source
)[0]

$global:OnefetchCommand = @(
    (Get-Command onefetch -CommandType Application -ErrorAction SilentlyContinue).Source
)[0]

# ============================================================
# Helper Functions
# ============================================================

function explain {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string]$text
    )

    if ([string]::IsNullOrWhiteSpace($text)) {
        Write-Host 'Usage: explain <text>' -ForegroundColor Yellow
        return
    }

    gh copilot -p "explain $text"
}

function custom-ls {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = '.'
    )

    if (-not $global:EzaCommand) {
        Get-ChildItem -Path $Path
        return
    }

    & $global:EzaCommand `
        -lab `
        --group-directories-first `
        --group `
        --git `
        --color=always `
        --icons=always `
        --color-scale=all `
        --sort=time `
        --hyperlink `
        $Path
}

Remove-Alias -Name ls -ErrorAction SilentlyContinue
Set-Alias -Name ls -Value custom-ls -Scope Global

function task {
    if ($global:WslCommand) {
        & $global:WslCommand task @args
    }
    else {
        Write-Host 'WSL not available' -ForegroundColor Yellow
    }
}

function timew {
    if ($global:WslCommand) {
        & $global:WslCommand timew @args
    }
    else {
        Write-Host 'WSL not available' -ForegroundColor Yellow
    }
}

# ============================================================
# Repository Detection
# ============================================================

$global:lastRepository = $null

function Update-RepositoryInfo {

    if (-not $global:GitCommand) {
        return
    }

    # Runs on every cd: don't let git's exit code (128 outside a repo)
    # leak into $LASTEXITCODE, or the prompt shows an error state.
    $savedExitCode = $global:LASTEXITCODE

    $currentRepository = & $global:GitCommand `
        rev-parse `
        --show-toplevel `
        2>$null

    $global:LASTEXITCODE = $savedExitCode

    if (
        $currentRepository -and
        ($currentRepository -ne $global:lastRepository)
    ) {

        if ([Console]::OutputEncoding -ne [System.Text.Encoding]::UTF8) {
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        }

        if ($global:OnefetchCommand) {
            & $global:OnefetchCommand | Write-Host
            $global:LASTEXITCODE = $savedExitCode
        }
    }

    $global:lastRepository = $currentRepository
}

# Append (not assign) so zoxide's own location hook, registered above,
# keeps working. Remove our old handler first so `. $PROFILE` doesn't
# register it twice.
if ($global:RepositoryLocationHandler) {
    $ExecutionContext.InvokeCommand.LocationChangedAction = [Delegate]::Remove(
        $ExecutionContext.InvokeCommand.LocationChangedAction,
        $global:RepositoryLocationHandler
    )
}

$global:RepositoryLocationHandler =
    [EventHandler[System.Management.Automation.LocationChangedEventArgs]] {
        Update-RepositoryInfo
    }

$ExecutionContext.InvokeCommand.LocationChangedAction = [Delegate]::Combine(
    $ExecutionContext.InvokeCommand.LocationChangedAction,
    $global:RepositoryLocationHandler
)

Update-RepositoryInfo
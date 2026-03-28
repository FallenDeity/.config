# PowerShell Profile - Central Configuration
# Centrally managed for multi-machine consistency

$ConfigRoot = if ($env:DOTFILES_CONFIG_ROOT -and (Test-Path $env:DOTFILES_CONFIG_ROOT)) {
    $env:DOTFILES_CONFIG_ROOT
}
elseif (Test-Path (Join-Path $HOME '.config')) {
    Join-Path $HOME '.config'
}
else {
    Split-Path -Parent (Split-Path -Parent $PSCommandPath)
}
$OhMyPoshTheme = Join-Path $ConfigRoot 'oh-my-posh\themes\night-owl.omp.json'

# ============ Modules ============
$requiredModules = @(
    'Terminal-Icons',
    'PSReadLine',
    'ZLocation',
    'PsFzf',
    'PSTools',
    'TabExpansionPlusPlus'
)

foreach ($module in $requiredModules) {
    if (-not (Get-Module -Name $module)) {
        if (Get-Module -Name $module -ListAvailable) {
            Import-Module $module
        }
        else {
            Write-Host "Module not installed: $module" -ForegroundColor Yellow
        }
    }
}

# ============ PSReadLine Configuration ============
$PSReadLineParams = @{
    PredictionSource         = 'History'
    PredictionViewStyle      = 'ListView'
    EditMode                 = 'Windows'
    HistoryNoDuplicates      = $true
    HistorySavePath          = (Join-Path $env:APPDATA 'PowerShell\PSReadline_history.txt')
    MaximumHistoryCount      = 10000
    MaximumKillRingCount     = 50
    BellStyle                = 'None'
}

Set-PSReadLineOption @PSReadLineParams

# ============ PSReadLine Key Bindings ============
# Tab completion
Set-PSReadLineKeyHandler -Key Tab -ScriptBlock { Invoke-FzfTabCompletion }
# Ctrl+R for history
Set-PSReadLineKeyHandler -Key Ctrl+r -ScriptBlock { Invoke-FzfReverseHistory }
# Arrow keys for history prefix search
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# ============ Oh My Posh - Prompt Customization ============
if (Test-Path $OhMyPoshTheme) {
    oh-my-posh init pwsh --config $OhMyPoshTheme | Invoke-Expression
}
else {
    Write-Host "Oh-my-posh theme not found at: $OhMyPoshTheme" -ForegroundColor Yellow
}

# ============ Environment Setup ============
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
$env:PIP_REQUIRE_VIRTUALENV = 'true'

# ============ Shell Integration ============
# direnv - disabled (kept for future enablement)
# if (Get-Command direnv -ErrorAction SilentlyContinue) {
#     Invoke-Expression "$(direnv hook pwsh)"
# }

# Zoxide - Directory jumper
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    if (Get-Command Get-ZLocation -ErrorAction SilentlyContinue) {
        $zLocationImportFile = New-TemporaryFile
        try {
            (Get-ZLocation).GetEnumerator() |
                ForEach-Object { "$($_.Name)|$($_.Value)|0" } |
                Out-File -FilePath $zLocationImportFile -Encoding utf8
            zoxide import --from=z $zLocationImportFile --merge 2>$null
        }
        finally {
            Remove-Item -Path $zLocationImportFile -Force -ErrorAction SilentlyContinue
        }
    }

    Invoke-Expression (& { (zoxide init powershell | Out-String) })
}

# GitHub CLI completion
if (Get-Command gh -ErrorAction SilentlyContinue) {
    $ghCompletion = gh completion -s powershell 2>$null | Out-String
    if (-not [string]::IsNullOrWhiteSpace($ghCompletion)) {
        Invoke-Expression -Command $ghCompletion
    }
}

# Tailscale completion
if (Get-Command tailscale -ErrorAction SilentlyContinue) {
    tailscale completion powershell 2>$null | Out-String | Invoke-Expression
}

# ============ Helper Functions ============
function explain {
    param(
        [Parameter(Position = 0, ValueFromRemainingArguments = $true)]
        [string]$text
    )
    gh copilot explain $text
}

function custom-ls {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$Path = '.'
    )
    
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path $Path
        return
    }
    
    eza -lab --group-directories-first --git --icons --hyperlink $Path
}

# Set ls alias to custom-ls
Remove-Alias -Name ls -ErrorAction SilentlyContinue
Set-Alias -Name ls -Value custom-ls -Scope Global

function task {
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl task $args
    }
    else {
        Write-Host 'WSL not available' -ForegroundColor Yellow
    }
}

function timew {
    if (Get-Command wsl -ErrorAction SilentlyContinue) {
        wsl timew $args
    }
    else {
        Write-Host 'WSL not available' -ForegroundColor Yellow
    }
}

# ============ Repository Detection ============
$global:lastRepository = $null

function Update-RepositoryInfo {
    $currentRepository = git rev-parse --show-toplevel 2>$null
    if ($currentRepository -and ($currentRepository -ne $global:lastRepository)) {
        if ([Console]::OutputEncoding -ne [System.Text.Encoding]::UTF8) {
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        }
        if (Get-Command onefetch -ErrorAction SilentlyContinue) {
            onefetch | Write-Host
        }
    }
    $global:lastRepository = $currentRepository
}

# Override Set-Location to trigger repository detection
$ExecutionContext.InvokeCommand.LocationChangedAction = {
    Update-RepositoryInfo
}

Update-RepositoryInfo

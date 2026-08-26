# Windows Dotfiles

An automated dotfiles configuration and setup orchestrator for Windows 11. It provides a tiling window management environment, dynamic wallpaper theme synchronization, multi-shell configurations, package management, and curated developer toolchains.

## Screenshots

| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/5fc194bc-ab42-43f8-a846-5dc23332e6f5" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/8d6ab98e-1332-49d0-85e6-22d97e759b5a" /> |
| ------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------ |
| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/24595de2-0b07-473d-a88c-24cf3362a5e5" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/d35cafaa-71b3-449c-8cba-504e7b1b2d4b" /> |
| -                                                                                                                                    | -                                                                                                                                    |
| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/2007f4e5-859f-456e-93af-68893dd76cfb" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/15ebd5be-a2cb-446f-a4b3-5d15602f4a00" /> |
| -                                                                                                                                    | -                                                                                                                                    |
| <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/704d2640-cd06-4a6a-b4fe-e7d3a4fa7c08" /> | <img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/ddd2fa6b-ff12-4613-98f5-db3f352c20cf" /> |

## System Overview

* Window Management: GlazeWM (tiling window manager) and Zebar (status bar with custom widgets).
* Terminals: WezTerm (primary emulator with custom QuickSelect regex matching) and Windows Terminal.
* Shells: PowerShell 7 with custom profile, PSReadLine keybindings, and Oh My Posh prompt. Clink integration for CMD.
* Dynamic Theming: Real-time wallpaper watcher extracting color palettes from Windows desktop and Wallpaper Engine to dynamically update Zebar, terminal themes, and UI accents.
* Package Management: Dual-layer management using Winget for GUI applications and Scoop for portable command-line tools.
* Developer Tooling: Zellij, Yazi, Lazygit, Posting, Cava, Delta, Bat, Eza, Ripgrep, Btop, Doggo, Navi, Tealdeer, and Procs.
* Application Configurations: Zen Browser (userChrome customizations and profile automation), Spicetify (Spotify client theme and extensions), Windhawk mods, and VS Code.

## Directory Structure

```
.config/
├── PowerShell/          # PowerShell profile and utility functions
├── bat/                 # Bat syntax highlighter configuration
├── btop/                # btop4win system monitor theme and config
├── cava/                # Cava audio visualizer configuration
├── cmd/                 # Clink autostart and CMD shell configuration
├── delta/               # Git delta syntax theme and settings
├── dircolors/           # Custom dircolors file for LS_COLORS/EZA_COLORS
├── doggo/               # Doggo DNS client configuration
├── eza/                 # Eza file listing configurations
├── fastfetch/           # System information fetch configuration
├── files/               # Files App settings
├── gh-dash/             # GitHub CLI dashboard configuration
├── git/                 # Global gitconfig and ignore rules
├── glazewm/             # GlazeWM keybindings and workspace rules
├── glow/                # Glow terminal markdown viewer settings
├── ipython/             # IPython shell configuration
├── lazygit/             # Lazygit configuration and Catppuccin theme
├── navi/                # Navi interactive cheatsheets and settings
├── oh-my-posh/          # Custom Oh My Posh shell prompt themes
├── posting/             # Posting TUI API client configuration and themes
├── procs/               # Procs process viewer configuration
├── rainmeter/           # Rainmeter layouts and skin settings
├── ripgrep/             # Ripgrep global config and ignore rules
├── scoop/               # Scoop package buckets and manifest references
├── scripts/             # Setup and configuration automation scripts
│   ├── helpers/
│   │   ├── applications/# App setup helpers (Zen, Spicetify, PowerToys)
│   │   └── glzr/        # GlazeWM/Zebar wallpaper theme sync scripts
│   └── languages/       # Language toolchain installers (uv, nvm, rustup)
├── spicetify/           # Spicetify CLI configuration, themes, and extensions
├── tealdeer/            # Tealdeer tldr cache configuration
├── trippy/              # Trippy network diagnostic configuration
├── vscode/              # VS Code settings, extensions list, and documentation
├── wezterm/             # WezTerm Lua configuration and keybindings
├── windhawk/            # Windhawk Windows customization mods
├── windows-terminal/    # Windows Terminal settings and custom icons
├── winstall.json        # Winget package bundle manifest
├── yazi/                # Yazi terminal file manager configuration
├── zebar/               # Zebar status bar HTML, CSS, and widget scripts
└── zellij/              # Zellij terminal multiplexer configuration
```

## Installation & Setup

### Prerequisites

* Windows 11 (build 22000 or later recommended).
* PowerShell 7 (pwsh).
* Winget (App Installer from Microsoft Store).

### Pre-Installation Configuration

Before running the setup script, customize the following settings:

* Git Identity:
  Open `scripts/config-setup.ps1` and update lines 70 and 71 with your name and email:
  ```powershell
  git config --global user.name 'Your Name'
  git config --global user.email 'your.email@example.com'
  ```
  The setup script will link the included global configurations (`git/gitconfig` and `delta/gitconfig`) via `include.path`.
* Windows Accent Color:
  1. Open Windows Settings > Personalization > Colors.
  2. Under Accent color, select Automatic to allow the dynamic wallpaper theme engine to set Windows accents.

### Quick Start

Clone this repository into your user directory or dedicated project path, then run `setup.ps1`:

```pwsh
git clone https://github.com/FallenDeity/.config
cd .config
.\setup.ps1
```

### Execution Modes

The setup orchestrator supports custom parameters for selective installs:

```pwsh
# Full installation: runs Winget installs, Scoop setup, and config syncing
.\setup.ps1

# Config-only mode: skips package installations and only applies dotfile configurations
.\setup.ps1 -ConfigOnly
```

### Post-Install Notes

* Windhawk: Follow setup instructions documented in windhawk/README.md.
* Spicetify: Run `spicetify apply` in terminal after initial Spotify setup if Spotify was active during installation or if you hadn't logged into Spotify yet.

## Terminal Entertainment & Aesthetics

A curated collection of CLI toys, screensavers, and terminal visualizers:

| Tool             | Description                                                                       | Install Command                                                      |
| :--------------- | :-------------------------------------------------------------------------------- | :------------------------------------------------------------------- |
| **`pipes-rs`**   | Animated over-crossing colorful pipes growing across the screen.                  | `scoop install pipes-rs`                                             |
| **`genact`**     | Nonsense activity generator simulating crypto mining, compilation, and downloads. | `scoop install genact`                                               |
| **`rusty-rain`** | High-performance Matrix digital rain with shaders and custom colors.              | `winget install cowboy8625.rusty-rain` or `cargo install rusty-rain` |
| **`clock-rs`**   | Responsive ASCII digital terminal clock with color controls.                      | `cargo install clock-rs`                                             |
| **`rbonsai`**    | Generates a zen, animated ASCII bonsai tree with live growth.                     | `cargo install rbonsai`                                              |
| **`gitlogue`**   | Creates a cinematic visual replay of your Git commit history.                     | `cargo install gitlogue`                                             |
| **`lolcat`**     | Colorizes any terminal output or piping with vibrant rainbow gradients.           | `cargo install lolcat` or `uv tool install lolcat`                   |
| **`wttr.in`**    | Graphical ASCII weather forecast for any city in the world.                       | `curl wttr.in` *(e.g. `curl wttr.in/London`)*                        |

### Batch Install and Uninstall

Install all:
```pwsh
scoop install pipes-rs genact; winget install --id cowboy8625.rusty-rain -e --accept-source-agreements --accept-package-agreements; cargo install rbonsai gitlogue lolcat clock-rs
```

Uninstall all:
```pwsh
scoop uninstall pipes-rs genact; winget uninstall --id cowboy8625.rusty-rain; cargo uninstall rbonsai gitlogue lolcat clock-rs
```

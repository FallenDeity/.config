# GlazeWM Cheat Sheet

GlazeWM is a tiling window manager for Windows inspired by i3 and bspwm.

---

## Application & Window Control

| Keybinding                                           | Action                | Description                                                     |
| :--------------------------------------------------- | :-------------------- | :-------------------------------------------------------------- |
| <kbd>Alt</kbd> + <kbd>Enter</kbd>                    | **Launch Terminal**   | Opens WezTerm (`wezterm-gui`)                                   |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>Q</kbd>     | **Close Window**      | Closes the currently focused window                             |
| <kbd>Alt</kbd> + <kbd>Ctrl</kbd> + <kbd>Q</kbd>      | **Force Kill Window** | Instantly terminates hung / Not Responding processes            |
| <kbd>Alt</kbd> + <kbd>F</kbd>                        | **Toggle Fullscreen** | Expands window across the active monitor                        |
| <kbd>Alt</kbd> + <kbd>M</kbd>                        | **Toggle Minimized**  | Minimizes the active window                                     |
| <kbd>Alt</kbd> + <kbd>T</kbd>                        | **Set Tiling**        | Re-integrates floating window back into tiling layout           |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>Space</kbd> | **Toggle Floating**   | Detaches window into centered floating mode                     |
| <kbd>Alt</kbd> + <kbd>`</kbd>                        | **Cycle Focus**       | Cycles focus between tiling, floating, and fullscreen           |
| <kbd>Alt</kbd> + <kbd>V</kbd>                        | **Toggle Direction**  | Toggles horizontal / vertical split orientation for new windows |

---

## Focus & Window Movement

| Action          | Direction                | Vim-Style                                                                               | Arrow Keys                                                                              |
| :-------------- | :----------------------- | :-------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------- |
| **Shift Focus** | Left / Down / Up / Right | <kbd>Alt</kbd> + <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd>                    | <kbd>Alt</kbd> + <kbd>←</kbd>/<kbd>↓</kbd>/<kbd>↑</kbd>/<kbd>→</kbd>                    |
| **Move Window** | Left / Down / Up / Right | <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd> | <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd>/<kbd>↓</kbd>/<kbd>↑</kbd>/<kbd>→</kbd> |

---

## Resizing Windows

### Quick Resize
| Keybinding                                   | Action                                  |
| :------------------------------------------- | :-------------------------------------- |
| <kbd>Alt</kbd> + <kbd>U</kbd> / <kbd>P</kbd> | Decrease / Increase window width by 2%  |
| <kbd>Alt</kbd> + <kbd>I</kbd> / <kbd>O</kbd> | Decrease / Increase window height by 2% |

### Interactive Resize Mode
1. Press <kbd>Alt</kbd> + <kbd>E</kbd> to enter **Resize Mode**.
2. Use <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd> or **Arrow Keys** to adjust dimensions.
3. Press <kbd>Esc</kbd>, <kbd>Enter</kbd>, or <kbd>Alt</kbd> + <kbd>E</kbd> to exit.

---

## Workspaces (1 – 9)

| Action                                        | Keybinding                                                                              |
| :-------------------------------------------- | :-------------------------------------------------------------------------------------- |
| **Focus Workspace $N$**                       | <kbd>Alt</kbd> + <kbd>1</kbd> ... <kbd>9</kbd>                                          |
| **Move Window to Workspace $N$ & Follow**     | <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>1</kbd> ... <kbd>9</kbd>                       |
| **Next / Prev Active Workspace**              | <kbd>Alt</kbd> + <kbd>S</kbd> / <kbd>Alt</kbd> + <kbd>A</kbd>                           |
| **Switch to Most Recent Workspace**           | <kbd>Alt</kbd> + <kbd>D</kbd>                                                           |
| **Move Workspace to Monitor (L / R / U / D)** | <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>A</kbd>/<kbd>F</kbd>/<kbd>D</kbd>/<kbd>S</kbd> |

---

## GlazeWM Operations

| Keybinding                                       | Action                                                      |
| :----------------------------------------------- | :---------------------------------------------------------- |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | **Reload Config** (Applies `config.yaml` changes instantly) |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd> | **Redraw Windows** (Re-tiles all managed windows)           |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> | **Toggle Pause** (Temporarily suspends all WM keybindings)  |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | **Exit GlazeWM**                                            |

---

## Instant Startup (Task Scheduler Setup)

Windows Startup folder apps run with delayed priority during user login. To start GlazeWM immediately at logon without the Windows startup queue delay:

```powershell
# 1. Register Task Scheduler trigger for instant launch at logon
$glazeExe = (Get-Command glazewm -ErrorAction SilentlyContinue)?.Source
if (-not $glazeExe) { $glazeExe = "$HOME\scoop\apps\glazewm\current\glazewm.exe" }

$action = New-ScheduledTaskAction -Execute $glazeExe
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit 0

Register-ScheduledTask -TaskName "GlazeWM-Instant" -Action $action -Trigger $trigger -Settings $settings -Force

# 2. Remove standard startup shortcut to prevent double-launching
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\GlazeWM.lnk" -ErrorAction SilentlyContinue
```


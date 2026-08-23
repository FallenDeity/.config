# Windows Terminal Cheat Sheet

Windows Terminal is configured with Catppuccin Mocha, acrylic transparency, and profiles for PowerShell 7, WSL, Git Bash, cmd, and MSYS2.

---

## Panes & Splits

| Keybinding                                                                             | Action                                      | Description                                 |
| :------------------------------------------------------------------------------------- | :------------------------------------------ | :------------------------------------------ |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>\</kbd>                                      | **Split Horizontally** (Side-by-side)       | Splits pane vertically side-by-side         |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>-</kbd>                                      | **Split Vertically** (Top-to-bottom)        | Splits pane horizontally top-to-bottom      |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd>/<kbd>↓</kbd>/<kbd>↑</kbd>/<kbd>→</kbd>| **Move Focus between Panes**                | Shifts cursor focus to adjacent pane        |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Z</kbd>                                        | **Toggle Pane Zoom**                        | Maximizes / restores active pane            |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>X</kbd>                                      | **Close Pane**                              | Closes active pane                          |

---

## Tabs & Profiles

| Keybinding                                                                             | Action                                       |
| :------------------------------------------------------------------------------------- | :------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>                                      | Open New Tab (Default Profile: PowerShell 7) |
| <kbd>Ctrl</kbd> + <kbd>Tab</kbd> / <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> | Switch to Next / Previous Tab                |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>1</kbd> ... <kbd>9</kbd>                       | Open specific profile tab                    |

---

## Search & Clipboard

| Keybinding                                        | Action                   |
| :------------------------------------------------ | :----------------------- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>F</kbd> | **Find Text** in buffer  |
| <kbd>Ctrl</kbd> + <kbd>C</kbd>                    | **Copy** selected text   |
| <kbd>Ctrl</kbd> + <kbd>V</kbd>                    | **Paste** from clipboard |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> | **Command Palette**      |

---

## Available Profiles in Windows Terminal

* **PowerShell 7 (`pwsh`)** — *Default*
* **Windows PowerShell**
* **Command Prompt (`cmd`)**
* **Git Bash**
* **Ubuntu (WSL)**
* **MSYS2 (UCRT64)**
* **MSYS2 (MINGW64)**
* **MSYS2 (CLANG64)**
* **MSYS2 (MSYS)**

# Windows Terminal Cheat Sheet

Windows Terminal is configured with Catppuccin Mocha, acrylic transparency, and profiles for PowerShell 7, WSL, Git Bash, cmd, and MSYS2.

---

## Panes & Splits

| Keybinding                                                                              | Action                       | Description                                 |
| :-------------------------------------------------------------------------------------- | :--------------------------- | :------------------------------------------ |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>D</kbd>                                        | **Duplicate Pane Auto**      | Splits active pane in automatic orientation |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>+</kbd>                                        | **Split Horizontally**       | Splits pane side-by-side                    |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>-</kbd>                                        | **Split Vertically**         | Splits pane top-to-bottom                   |
| <kbd>Alt</kbd> + <kbd>←</kbd>/<kbd>↓</kbd>/<kbd>↑</kbd>/<kbd>→</kbd>                    | **Move Focus between Panes** | Shifts cursor focus to adjacent pane        |
| <kbd>Alt</kbd> + <kbd>Shift</kbd> + <kbd>←</kbd>/<kbd>↓</kbd>/<kbd>↑</kbd>/<kbd>→</kbd> | **Resize Pane**              | Adjusts pane size in direction              |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd>                                       | **Close Pane / Tab**         | Closes active pane or tab                   |

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

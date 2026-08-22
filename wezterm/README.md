# WezTerm Cheat Sheet

WezTerm is a GPU-accelerated terminal emulator configured with Catppuccin Mocha, native Windows 11 rounded corners, and custom QuickSelect hints.

---

## Command Palette & Launcher

| Keybinding                                                             | Action              | Description                                        |
| :--------------------------------------------------------------------- | :------------------ | :------------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>P</kbd> *(or <kbd>F2</kbd>)* | **Command Palette** | Searchable modal to execute any action or shortcut |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>L</kbd> *(or <kbd>F1</kbd>)* | **Launcher Menu**   | Open pwsh, WSL, Command Prompt, Git Bash, or MSYS2 |

---

## Panes & Splits

| Keybinding                                                                 | Action                                      |
| :------------------------------------------------------------------------- | :------------------------------------------ |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>\</kbd> *(or <kbd>\|</kbd>)*     | **Split Horizontally** (Side-by-side)       |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>-</kbd> *(or <kbd>_</kbd>)*      | **Split Vertically** (Top-to-bottom)        |
| <kbd>Alt</kbd> + <kbd>←</kbd> / <kbd>↓</kbd> / <kbd>↑</kbd> / <kbd>→</kbd> | **Navigate between Panes**                  |
| <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>Z</kbd>                            | **Toggle Pane Zoom** (Maximize active pane) |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>W</kbd>                          | **Close Current Pane**                      |

---

## Tabs

| Keybinding                                          | Action           |
| :-------------------------------------------------- | :--------------- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>T</kbd>   | **New Tab**      |
| <kbd>Ctrl</kbd> + <kbd>Tab</kbd>                    | **Next Tab**     |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> | **Previous Tab** |

---

## QuickSelect Hints (Regex Match & Action)

QuickSelect highlights matching patterns in your terminal and gives each a single keystroke jump key:

| Keybinding                                        | Target Pattern                                 | Action                                    |
| :------------------------------------------------ | :--------------------------------------------- | :---------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>O</kbd> | **URLs & Links**                               | Opens directly in your default browser    |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | **File Paths** (`C:\...`, `~/...`, `foo:12:3`) | Opens directly in **VS Code** at line/col |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> | **Hex Color Codes** (`#cba6f7`)                | Copies hex color to clipboard             |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>I</kbd> | **IPv4 Addresses**                             | Copies IP address to clipboard            |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>G</kbd> | **Git Hashes** (`7–40 chars`)                  | Copies commit hash to clipboard           |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Z</kbd> | **Quoted Strings** (`"..."` / `'...'`)         | Searches string on DuckDuckGo             |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>Y</kbd> | **GitHub PRs** (`owner/repo#123`)              | Opens PR in browser                       |
| <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>R</kbd> | **GitHub Repos** (`owner/repo`)                | Opens repo in browser                     |
| <kbd>Ctrl</kbd> + <kbd>Win</kbd> + <kbd>B</kbd>   | **Search Clipboard**                           | Searches clipboard contents on DuckDuckGo |

---

## Mouse & Window Controls

| Action                          | Control                                                                  |
| :------------------------------ | :----------------------------------------------------------------------- |
| **Move Borderless Window**      | Hold <kbd>Ctrl</kbd> + <kbd>Shift</kbd> and **Left-Click Drag** anywhere |
| **Paste from Clipboard**        | Right Click                                                              |
| **Copy Selection to Clipboard** | Middle Click *(or standard text selection)*                              |
| **Open Hyperlinks**             | <kbd>Ctrl</kbd> + Left Click                                             |

---

## Font Size

| Keybinding                                    | Action                     |
| :-------------------------------------------- | :------------------------- |
| <kbd>Ctrl</kbd> + <kbd>+</kbd> / <kbd>=</kbd> | Increase Font Size         |
| <kbd>Ctrl</kbd> + <kbd>-</kbd>                | Decrease Font Size         |
| <kbd>Ctrl</kbd> + <kbd>0</kbd>                | Reset Font Size to Default |

# PowerShell & CLI Shell Cheat Sheet

PowerShell environment configured with PSReadLine, PSFzf, Zoxide, and Git integrations.

---

## Interactive Fuzzy Searching (PSFzf & FZF)

| Keybinding                     | Action                   | Description                                           |
| :----------------------------- | :----------------------- | :---------------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>R</kbd> | **Fuzzy History Search** | Search through past PowerShell command history        |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> | **Fuzzy File Search**    | Interactively fuzzy search files in current directory |
| <kbd>Alt</kbd> + <kbd>C</kbd>  | **Fuzzy CD**             | Search directories and `cd` directly into the match   |

---

## PSReadLine & Editing Shortcuts

| Keybinding                                                      | Action                                                            |
| :-------------------------------------------------------------- | :---------------------------------------------------------------- |
| <kbd>→</kbd> *(Right Arrow)*                                    | **Accept Prediction** (Inline Fish-style autocomplete suggestion) |
| <kbd>Ctrl</kbd> + <kbd>Space</kbd>                              | **Menu Complete** (Interactive dropdown argument completion)      |
| <kbd>Tab</kbd> / <kbd>Shift</kbd> + <kbd>Tab</kbd>              | Next / Previous completion match                                  |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> / <kbd>Ctrl</kbd> + <kbd>E</kbd> | Jump to Beginning / End of line                                   |
| <kbd>Ctrl</kbd> + <kbd>W</kbd>                                  | Delete word backwards                                             |
| <kbd>Ctrl</kbd> + <kbd>K</kbd>                                  | Delete to end of line                                             |
| <kbd>Ctrl</kbd> + <kbd>U</kbd>                                  | Delete entire line                                                |
| <kbd>Ctrl</kbd> + <kbd>L</kbd>                                  | Clear screen                                                      |

---

## Navigation & CLI Fast Commands

| Command     | Action                                                          |
| :---------- | :-------------------------------------------------------------- |
| `z <dir>`   | Smart directory jump using **zoxide** (e.g. `z conf`, `z proj`) |
| `zi`        | Interactive fuzzy directory picker with zoxide                  |
| `y`         | Launch **Yazi** file manager                                    |
| `lg`        | Launch **Lazygit** UI                                           |
| `btop`      | Launch **btop** resource monitor                                |
| `fastfetch` | Display system and dotfiles stats                               |

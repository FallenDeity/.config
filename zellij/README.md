# Zellij Cheat Sheet

Zellij is a terminal workspace and multiplexer configured with Catppuccin Mocha and rounded pane borders.

---

## Navigation & Modes Overview

Zellij uses modal keybindings. The prefix modifier triggers each mode:

| Shortcut                          | Mode             | Purpose                                                    |
| :-------------------------------- | :--------------- | :--------------------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>P</kbd>    | **Pane Mode**    | Create, split, close, and navigate panes                   |
| <kbd>Ctrl</kbd> + <kbd>T</kbd>    | **Tab Mode**     | Create, rename, close, and switch tabs                     |
| <kbd>Ctrl</kbd> + <kbd>N</kbd>    | **Resize Mode**  | Shrink or expand active pane                               |
| <kbd>Ctrl</kbd> + <kbd>S</kbd>    | **Scroll Mode**  | Scroll history and search buffer                           |
| <kbd>Ctrl</kbd> + <kbd>O</kbd>    | **Session Mode** | Detach, manage sessions, and layouts                       |
| <kbd>Ctrl</kbd> + <kbd>G</kbd>    | **Locked Mode**  | Locks Zellij keys (passes all keystrokes to terminal apps) |
| <kbd>Esc</kbd> / <kbd>Enter</kbd> | **Normal Mode**  | Return to standard terminal input                          |

---

## Panes (<kbd>Ctrl</kbd> + <kbd>P</kbd>)

| Keybinding                                                                                       | Action                                           |
| :----------------------------------------------------------------------------------------------- | :----------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> $\rightarrow$ <kbd>D</kbd> / <kbd>N</kbd>                         | Split Down (Horizontal) / Split Right (Vertical) |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> $\rightarrow$ <kbd>X</kbd>                                        | Close active pane                                |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> $\rightarrow$ <kbd>F</kbd>                                        | Toggle Fullscreen pane                           |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> $\rightarrow$ <kbd>W</kbd>                                        | Toggle Floating pane                             |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> $\rightarrow$ <kbd>E</kbd>                                        | Embed floating pane                              |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> $\rightarrow$ <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd> | Focus pane left / down / up / right              |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> $\rightarrow$ <kbd>R</kbd>                                        | Rename active pane                               |

---

## Tabs (<kbd>Ctrl</kbd> + <kbd>T</kbd>)

| Keybinding                                                                 | Action                                         |
| :------------------------------------------------------------------------- | :--------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> $\rightarrow$ <kbd>N</kbd>                  | New Tab                                        |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> $\rightarrow$ <kbd>X</kbd>                  | Close current tab                              |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> $\rightarrow$ <kbd>H</kbd> / <kbd>L</kbd>   | Switch to Left / Right tab                     |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> $\rightarrow$ <kbd>1</kbd> ... <kbd>9</kbd> | Jump to Tab $N$                                |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> $\rightarrow$ <kbd>R</kbd>                  | Rename active tab                              |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> $\rightarrow$ <kbd>S</kbd>                  | Toggle tab synchronization (type in all panes) |

---

## Resize (<kbd>Ctrl</kbd> + <kbd>N</kbd>)

| Keybinding                                                               | Action                           |
| :----------------------------------------------------------------------- | :------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>N</kbd> $\rightarrow$ <kbd>H</kbd> / <kbd>L</kbd> | Resize width left / right        |
| <kbd>Ctrl</kbd> + <kbd>N</kbd> $\rightarrow$ <kbd>J</kbd> / <kbd>K</kbd> | Resize height down / up          |
| <kbd>Ctrl</kbd> + <kbd>N</kbd> $\rightarrow$ <kbd>+</kbd> / <kbd>-</kbd> | Increase / Decrease overall size |

---

## Scroll & Search (<kbd>Ctrl</kbd> + <kbd>S</kbd>)

| Keybinding                                                               | Action                                      |
| :----------------------------------------------------------------------- | :------------------------------------------ |
| <kbd>Ctrl</kbd> + <kbd>S</kbd> $\rightarrow$ <kbd>S</kbd>                | Enter search pattern                        |
| <kbd>Ctrl</kbd> + <kbd>S</kbd> $\rightarrow$ <kbd>N</kbd> / <kbd>P</kbd> | Next / Previous search match                |
| <kbd>Ctrl</kbd> + <kbd>S</kbd> $\rightarrow$ <kbd>J</kbd> / <kbd>K</kbd> | Scroll half-page down / up                  |
| <kbd>Ctrl</kbd> + <kbd>S</kbd> $\rightarrow$ <kbd>D</kbd> / <kbd>U</kbd> | Scroll half-page down / up                  |
| <kbd>Ctrl</kbd> + <kbd>S</kbd> $\rightarrow$ <kbd>E</kbd>                | Open scrollback in default editor ($EDITOR) |

---

## Sessions & Detach (<kbd>Ctrl</kbd> + <kbd>O</kbd>)

| Keybinding                                                | Action                                           |
| :-------------------------------------------------------- | :----------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>O</kbd> $\rightarrow$ <kbd>D</kbd> | **Detach session** (keeps running in background) |
| <kbd>Ctrl</kbd> + <kbd>O</kbd> $\rightarrow$ <kbd>W</kbd> | Session manager / switcher                       |
| <kbd>Ctrl</kbd> + <kbd>Q</kbd>                            | **Quit Zellij** (closes session)                 |

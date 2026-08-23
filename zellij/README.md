# Zellij Cheat Sheet

Zellij is a terminal workspace and multiplexer configured with Catppuccin Mocha and rounded pane borders.

---

## Navigation & Modes Overview

Zellij is configured with a **Leader Key** (<kbd>Ctrl</kbd> + <kbd>A</kbd>) to prevent any collisions with terminal applications (like PSFzf, Lazygit, and Posting):

| Shortcut                                                     | Mode             | Purpose                                                    |
| :----------------------------------------------------------- | :--------------- | :--------------------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>P</kbd>    | **Pane Mode**    | Create, split, close, and navigate panes                   |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>T</kbd>    | **Tab Mode**     | Create, rename, close, and switch tabs                     |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>N</kbd>    | **Resize Mode**  | Shrink or expand active pane                               |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>S</kbd>    | **Scroll Mode**  | Scroll history and search buffer                           |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>O</kbd>    | **Session Mode** | Detach, manage sessions, and layouts                       |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>G</kbd>    | **Locked Mode**  | Locks Zellij keys (passes all keystrokes to terminal apps) |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>D</kbd>    | **Detach**       | Detaches session into background                           |
| <kbd>Esc</kbd> / <kbd>Enter</kbd>                            | **Normal Mode**  | Return to standard terminal input                          |

---

## Direct Leader Shortcuts (<kbd>Ctrl</kbd> + <kbd>A</kbd>)

| Keybinding                                                                                       | Action                                           |
| :----------------------------------------------------------------------------------------------- | :----------------------------------------------- |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>\</kbd> / <kbd>-</kbd>                         | Split Right (Vertical) / Split Down (Horizontal) |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>X</kbd>                                        | Close active pane                                |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>Z</kbd>                                        | Toggle Fullscreen zoom                           |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd> | Focus pane left / down / up / right              |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>D</kbd>                                        | Detach active session                            |
| <kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>Q</kbd>                                        | Quit Zellij                                      |

---

## Panes Mode (<kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>P</kbd>)

| Keybinding                                         | Action                               |
| :------------------------------------------------- | :----------------------------------- |
| <kbd>D</kbd> / <kbd>R</kbd>                        | Split Down / Split Right             |
| <kbd>X</kbd>                                       | Close active pane                    |
| <kbd>F</kbd> / <kbd>Z</kbd>                        | Toggle Fullscreen / Toggle Frames    |
| <kbd>W</kbd> / <kbd>E</kbd>                        | Toggle Floating / Embed              |
| <kbd>H</kbd>/<kbd>J</kbd>/<kbd>K</kbd>/<kbd>L</kbd>| Focus pane left / down / up / right  |
| <kbd>C</kbd>                                       | Rename active pane                   |

---

## Tabs Mode (<kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>T</kbd>)

| Keybinding                     | Action                                         |
| :----------------------------- | :--------------------------------------------- |
| <kbd>N</kbd>                   | New Tab                                        |
| <kbd>X</kbd>                   | Close current tab                              |
| <kbd>H</kbd> / <kbd>L</kbd>    | Switch to Left / Right tab                     |
| <kbd>1</kbd> ... <kbd>9</kbd>  | Jump to Tab $N$                                |
| <kbd>R</kbd>                   | Rename active tab                              |
| <kbd>S</kbd>                   | Toggle tab synchronization (type in all panes) |

---

## Resize Mode (<kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>N</kbd>)

| Keybinding                                         | Action                           |
| :------------------------------------------------- | :------------------------------- |
| <kbd>H</kbd> / <kbd>L</kbd>                        | Resize width left / right        |
| <kbd>J</kbd> / <kbd>K</kbd>                        | Resize height down / up          |
| <kbd>+</kbd> / <kbd>-</kbd>                        | Increase / Decrease overall size |

---

## Scroll & Search Mode (<kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>S</kbd>)

| Keybinding                                         | Action                                      |
| :------------------------------------------------- | :------------------------------------------ |
| <kbd>S</kbd>                                       | Enter search pattern                        |
| <kbd>N</kbd> / <kbd>P</kbd>                        | Next / Previous search match                |
| <kbd>J</kbd> / <kbd>K</kbd>                        | Scroll line down / up                       |
| <kbd>D</kbd> / <kbd>U</kbd>                        | Scroll half-page down / up                  |
| <kbd>E</kbd>                                       | Open scrollback in default editor ($EDITOR) |

---

## Sessions Mode (<kbd>Ctrl</kbd> + <kbd>A</kbd> $\rightarrow$ <kbd>O</kbd>)

| Keybinding       | Action                                           |
| :--------------- | :----------------------------------------------- |
| <kbd>D</kbd>     | **Detach session** (keeps running in background) |
| <kbd>W</kbd>     | Session manager / switcher                       |
| <kbd>Q</kbd>     | **Quit Zellij** (closes session)                 |

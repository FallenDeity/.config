# Yazi Cheat Sheet

Yazi is a blazing-fast terminal file manager written in Rust with asynchronous I/O and image preview support.

---

## Navigation

| Keybinding                                                              | Action                             |
| :---------------------------------------------------------------------- | :--------------------------------- |
| <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> *(or Arrows)* | Parent dir / Down / Up / Enter dir |
| <kbd>G</kbd> / <kbd>Shift</kbd> + <kbd>G</kbd>                          | Jump to Top / Bottom of directory  |
| <kbd>Ctrl</kbd> + <kbd>U</kbd> / <kbd>Ctrl</kbd> + <kbd>D</kbd>         | Scroll half page up / down         |
| <kbd>Ctrl</kbd> + <kbd>B</kbd> / <kbd>Ctrl</kbd> + <kbd>F</kbd>         | Scroll full page up / down         |
| <kbd>~</kbd> / <kbd>Shift</kbd> + <kbd>H</kbd>                          | Jump to Home directory             |

---

## File Operations

| Keybinding                      | Action                                         |
| :------------------------------ | :--------------------------------------------- |
| <kbd>O</kbd> / <kbd>Enter</kbd> | Open file with default application             |
| <kbd>A</kbd>                    | Create file (end with `/` to create directory) |
| <kbd>R</kbd>                    | Rename file or directory                       |
| <kbd>Y</kbd> / <kbd>X</kbd>     | Yank (Copy) / Cut selected files               |
| <kbd>P</kbd>                    | Paste copied / cut files                       |
| <kbd>D</kbd>                    | Move to Trash                                  |
| <kbd>Shift</kbd> + <kbd>D</kbd> | Permanently Delete                             |
| <kbd>.</kbd>                    | Toggle hidden files visibility                 |

---

## Selection & Visual Mode

| Keybinding                      | Action                                       |
| :------------------------------ | :------------------------------------------- |
| <kbd>Space</kbd>                | Toggle selection on current item & move down |
| <kbd>V</kbd>                    | Enter Visual Selection mode                  |
| <kbd>Shift</kbd> + <kbd>V</kbd> | Enter Unset Visual Selection mode            |
| <kbd>Ctrl</kbd> + <kbd>A</kbd>  | Select all files                             |
| <kbd>Ctrl</kbd> + <kbd>R</kbd>  | Invert selection                             |
| <kbd>Esc</kbd>                  | Clear selection / Cancel mode                |

---

## Search & Filtering

| Keybinding                                     | Action                                |
| :--------------------------------------------- | :------------------------------------ |
| <kbd>/</kbd>                                   | Incremental Find in current directory |
| <kbd>F</kbd>                                   | Filter directory entries in-place     |
| <kbd>Z</kbd>                                   | Jump using `zoxide` integration       |
| <kbd>N</kbd> / <kbd>Shift</kbd> + <kbd>N</kbd> | Next / Previous search match          |

---

## Tabs

| Keybinding                    | Action                        |
| :---------------------------- | :---------------------------- |
| <kbd>T</kbd>                  | Open new tab                  |
| <kbd>W</kbd>                  | Close current tab             |
| <kbd>1</kbd> ... <kbd>9</kbd> | Switch to Tab $N$             |
| <kbd>[</kbd> / <kbd>]</kbd>   | Switch to Previous / Next Tab |

---

## Shell & Tasks

| Keybinding   | Action                               |
| :----------- | :----------------------------------- |
| <kbd>:</kbd> | Open shell command prompt            |
| <kbd>;</kbd> | Shell command with interactive block |
| <kbd>W</kbd> | Open task manager popup              |
| <kbd>Q</kbd> | Quit Yazi                            |

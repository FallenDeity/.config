# Lazygit Cheat Sheet

Lazygit is a simple terminal UI for git commands.

---

## Panel Navigation

| Keybinding                                         | Action                           |
| :------------------------------------------------- | :------------------------------- |
| <kbd>1</kbd>                                       | Focus **Status** panel           |
| <kbd>2</kbd>                                       | Focus **Files** panel            |
| <kbd>3</kbd>                                       | Focus **Branches** panel         |
| <kbd>4</kbd>                                       | Focus **Commits** panel          |
| <kbd>5</kbd>                                       | Focus **Stash** panel            |
| <kbd>Tab</kbd> / <kbd>Shift</kbd> + <kbd>Tab</kbd> | Next / Previous panel            |
| <kbd>]</kbd> / <kbd>[</kbd>                        | Next / Previous sub-tab in panel |
| <kbd>Enter</kbd>                                   | Focus into list item / diff      |
| <kbd>Esc</kbd>                                     | Focus out / return to panels     |

---

## Files & Staging (Panel 2)

| Keybinding                      | Action                               |
| :------------------------------ | :----------------------------------- |
| <kbd>Space</kbd>                | Stage / Unstage current file or line |
| <kbd>A</kbd>                    | Stage / Unstage ALL files            |
| <kbd>C</kbd>                    | Commit staged changes                |
| <kbd>Shift</kbd> + <kbd>C</kbd> | Commit with message template         |
| <kbd>D</kbd>                    | Discard changes in file              |
| <kbd>I</kbd>                    | Add file to `.gitignore`             |
| <kbd>E</kbd>                    | Edit file in default editor          |
| <kbd>O</kbd>                    | Open file in system default program  |

---

## Branches & Remotes (Panel 3)

| Keybinding                      | Action                           |
| :------------------------------ | :------------------------------- |
| <kbd>Space</kbd>                | Checkout branch                  |
| <kbd>N</kbd>                    | Create new branch                |
| <kbd>D</kbd>                    | Delete branch                    |
| <kbd>F</kbd>                    | Fast-forward / pull from remote  |
| <kbd>P</kbd>                    | Push to remote                   |
| <kbd>Shift</kbd> + <kbd>P</kbd> | Force push options               |
| <kbd>R</kbd>                    | Rebase branch onto active branch |
| <kbd>M</kbd>                    | Merge branch into active branch  |

---

## Commits & History (Panel 4)

| Keybinding                                                      | Action                                     |
| :-------------------------------------------------------------- | :----------------------------------------- |
| <kbd>S</kbd>                                                    | Squash commit down into previous commit    |
| <kbd>R</kbd>                                                    | Reword / rename commit message             |
| <kbd>D</kbd>                                                    | Drop (delete) commit                       |
| <kbd>F</kbd>                                                    | Fixup commit                               |
| <kbd>C</kbd>                                                    | Cherry-pick commit                         |
| <kbd>T</kbd>                                                    | Revert commit                              |
| <kbd>Ctrl</kbd> + <kbd>J</kbd> / <kbd>Ctrl</kbd> + <kbd>K</kbd> | Move commit down / up (interactive rebase) |

---

## Stash (Panel 5)

| Keybinding       | Action            |
| :--------------- | :---------------- |
| <kbd>Space</kbd> | Apply stash entry |
| <kbd>G</kbd>     | Pop stash entry   |
| <kbd>D</kbd>     | Drop stash entry  |

---

## Global Operations

| Keybinding                     | Action                                         |
| :----------------------------- | :--------------------------------------------- |
| <kbd>?</kbd>                   | Open built-in interactive keybinding help menu |
| <kbd><</kbd> / <kbd>></kbd>    | Scroll left / right in diff view               |
| <kbd>+</kbd> / <kbd>_</kbd>    | Zoom diff panel / reset zoom                   |
| <kbd>Ctrl</kbd> + <kbd>P</kbd> | Custom command prompt                          |
| <kbd>Q</kbd>                   | Quit Lazygit                                   |

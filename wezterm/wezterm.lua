local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

--------------------------------------------------------------------------------
-- 1. Shell, Environment & Launch Menu
--------------------------------------------------------------------------------
config.default_prog = { 'pwsh.exe', '-NoLogo' }
config.default_cwd = wezterm.home_dir
config.set_environment_variables = {
  TERM = 'xterm-256color',
}

-- Launcher Profiles (Accessible via F1 or Ctrl+Shift+L)
config.launch_menu = {
  {
    label = 'PowerShell 7 (pwsh)',
    args = { 'pwsh.exe', '-NoLogo' },
  },
  {
    label = 'WSL: Ubuntu-24.04',
    args = { 'wsl.exe', '-d', 'Ubuntu-24.04' },
  },
  {
    label = 'Command Prompt (cmd)',
    args = { 'cmd.exe' },
  },
  {
    label = 'Git Bash',
    args = { 'C:\\Program Files\\Git\\bin\\bash.exe', '--login', '-i' },
  },
  {
    label = 'MSYS2: UCRT64',
    args = { 'cmd.exe', '/c', 'C:\\msys64\\msys2_shell.cmd', '-defterm', '-here', '-no-start', '-ucrt64' },
  },
  {
    label = 'MSYS2: MINGW64',
    args = { 'cmd.exe', '/c', 'C:\\msys64\\msys2_shell.cmd', '-defterm', '-here', '-no-start', '-mingw64' },
  },
  {
    label = 'MSYS2: CLANG64',
    args = { 'cmd.exe', '/c', 'C:\\msys64\\msys2_shell.cmd', '-defterm', '-here', '-no-start', '-clang64' },
  },
  {
    label = 'MSYS2: MSYS',
    args = { 'cmd.exe', '/c', 'C:\\msys64\\msys2_shell.cmd', '-defterm', '-here', '-no-start', '-msys' },
  },
}

--------------------------------------------------------------------------------
-- 2. Window Styling (Windows 11 Rounded Corners + Clean Borderless)
--------------------------------------------------------------------------------
config.window_decorations = 'RESIZE'
config.win32_system_backdrop = 'Disable'
config.enable_tab_bar = false
config.window_background_opacity = 0.92
config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 6,
}
config.initial_cols = 120
config.initial_rows = 30
config.adjust_window_size_when_changing_font_size = false

--------------------------------------------------------------------------------
-- 3. Performance & Rendering
--------------------------------------------------------------------------------
config.front_end = 'WebGpu'
config.webgpu_power_preference = 'HighPerformance'
config.max_fps = 120
config.animation_fps = 1 -- Saves GPU/CPU power when idle
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.audible_bell = 'Disabled'

--------------------------------------------------------------------------------
-- 4. Colors, Font & Cursor
--------------------------------------------------------------------------------
config.color_scheme = 'Catppuccin Mocha'
config.font = wezterm.font('MesloLGM Nerd Font')
config.font_size = 10.0

-- Crisp cursor & paste sanitation
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.canonicalize_pasted_newlines = 'LineFeed'

--------------------------------------------------------------------------------
-- 5. Mouse Bindings & Selection
--------------------------------------------------------------------------------
config.hide_mouse_cursor_when_typing = true

config.mouse_bindings = {
  -- Right click: Paste from Clipboard
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'SHIFT',
    action = act.PasteFrom 'PrimarySelection',
  },
  -- Middle click: Copy to Clipboard
  {
    event = { Down = { streak = 1, button = 'Middle' } },
    mods = 'NONE',
    action = act.CopyTo 'Clipboard',
  },
}

--------------------------------------------------------------------------------
-- 6. Hyperlink Rules (Hover & Ctrl+Click)
--------------------------------------------------------------------------------
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Match GitHub PRs (e.g. owner/repo#123)
table.insert(config.hyperlink_rules, {
  regex = [[[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#\d+]],
  format = 'https://github.com/$1/pull/$2',
})

--------------------------------------------------------------------------------
-- 7. Keybindings & QuickSelect (Launcher, Panes, Hints)
--------------------------------------------------------------------------------
config.quick_select_alphabet = 'jfkdls;ahgurieowpq'

config.keys = {
  -- Command Palette (Searchable modal with all actions - Standard Ctrl+Shift+P and F2)
  { key = 'P', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  { key = 'F2', mods = 'NONE', action = act.ActivateCommandPalette },

  -- Launcher Menu (PowerShell, WSL, cmd, Git Bash - F1 and Ctrl+Shift+L)
  { key = 'F1', mods = 'NONE', action = act.ShowLauncher },
  { key = 'L', mods = 'CTRL|SHIFT', action = act.ShowLauncher },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ShowLauncher },

  -- Splits (Horizontal & Vertical)
  { key = '\\', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '|', mods = 'CTRL|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = '_', mods = 'CTRL|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Pane Navigation & Management
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane { confirm = false } },
  { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'z', mods = 'CTRL|ALT', action = act.TogglePaneZoomState },

  -- Tabs
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },

  -- Font Size adjustments
  { key = '=', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
  { key = '+', mods = 'CTRL|SHIFT', action = act.IncreaseFontSize },
  { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
  { key = '0', mods = 'CTRL', action = act.ResetFontSize },

  -- Ctrl+Super+B: Search Clipboard contents on DuckDuckGo
  {
    key = 'b',
    mods = 'CTRL|SUPER',
    action = wezterm.action_callback(function(window, pane)
      local clip = window:get_clipboard_text()
      if clip and #clip > 0 then
        local query = clip:gsub('^%s+', ''):gsub('%s+$', '')
        wezterm.open_with('https://duckduckgo.com/?q=' .. wezterm.url_encode(query))
      end
    end),
  },

  -- Ctrl+Shift+O: QuickSelect URLs -> Open in browser
  {
    key = 'O',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?:ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh:|ftp://)[^\s<>'"^`]+]=],
      },
      action = wezterm.action_callback(function(window, pane)
        local url = window:get_selection_text_for_pane(pane)
        if url and #url > 0 then
          wezterm.open_with(url)
        end
      end),
    },
  },

  -- Ctrl+Shift+E: QuickSelect File paths -> Open in VS Code with line/column
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?i)\b(?:[A-Za-z]:\\[^\s:"<>|?*]+|(?:\.{1,2}/|~/|/)[^\s:]+)(?::\d+(?::\d+)?)?\b]=],
      },
      action = wezterm.action_callback(function(window, pane)
        local selection = window:get_selection_text_for_pane(pane)
        if selection and #selection > 0 then
          wezterm.run_child_process { 'cmd.exe', '/c', 'code', '-g', selection }
        end
      end),
    },
  },

  -- Ctrl+Shift+H: QuickSelect Hex color codes -> Copy to clipboard
  {
    key = 'H',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?i)#(?:[0-9a-f]{8}|[0-9a-f]{6}|[0-9a-f]{4}|[0-9a-f]{3})]=],
      },
      action = act.CopyTo 'Clipboard',
    },
  },

  -- Ctrl+Shift+I: QuickSelect IPv4 -> Copy to clipboard
  {
    key = 'I',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?:\b(?:25[0-5]|2[0-4]\d|1?\d?\d)\.){3}(?:25[0-5]|2[0-4]\d|1?\d?\d)\b]=],
      },
      action = act.CopyTo 'Clipboard',
    },
  },

  -- Ctrl+Shift+G: QuickSelect Git Commit Hashes -> Copy to clipboard
  {
    key = 'G',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?i)\b[0-9a-f]{7,40}\b]=],
      },
      action = act.CopyTo 'Clipboard',
    },
  },

  -- Ctrl+Shift+Z: QuickSelect Quoted Strings -> Search on DuckDuckGo
  {
    key = 'Z',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?:"[^"\r\n]{3,}"|'[^'\r\n]{3,}')]=],
      },
      action = wezterm.action_callback(function(window, pane)
        local text = window:get_selection_text_for_pane(pane)
        if text and #text > 0 then
          local cleaned = text:gsub('^["\']', ''):gsub('["\']$', '')
          wezterm.open_with('https://duckduckgo.com/?q=' .. wezterm.url_encode(cleaned))
        end
      end),
    },
  },

  -- Ctrl+Shift+Y: QuickSelect GitHub PRs (owner/repo#123) -> Open in browser
  {
    key = 'Y',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?i)\b[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+#[0-9]+\b]=],
      },
      action = wezterm.action_callback(function(window, pane)
        local text = window:get_selection_text_for_pane(pane)
        if text and #text > 0 then
          local repo, pr = text:match('^([%w%-_.]+/[%w%-_.]+)#(%d+)$')
          if repo and pr then
            wezterm.open_with('https://github.com/' .. repo .. '/pull/' .. pr)
          end
        end
      end),
    },
  },

  -- Ctrl+Shift+R: QuickSelect GitHub Repos (owner/repo) -> Open in browser
  {
    key = 'R',
    mods = 'CTRL|SHIFT',
    action = act.QuickSelectArgs {
      patterns = {
        [=[(?i)\b[A-Za-z0-9_-]+/[A-Za-z0-9_.-]+\b]=],
      },
      action = wezterm.action_callback(function(window, pane)
        local text = window:get_selection_text_for_pane(pane)
        if text and #text > 0 then
          wezterm.open_with('https://github.com/' .. text)
        end
      end),
    },
  },
}

return config

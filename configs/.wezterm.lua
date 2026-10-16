local wezterm = require 'wezterm'
local mux = wezterm.mux

local config = wezterm.config_builder()

-- Font and appearance
config.font = wezterm.font({
  family = "JetBrains Mono NF",
  weight = "Regular",
  italic = false,
})

config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.92
config.line_height = 1.0
config.font_size = 14.0

-- Window size
config.initial_cols = 100
config.initial_rows = 24

-- Cursor
config.default_cursor_style = "BlinkingUnderline"
config.cursor_blink_rate = 500

-- Tabs
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- Scrollback and scrollbar
config.scrollback_lines = 10000
config.enable_scroll_bar = true

-- Mouse and selection
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"
config.mouse_wheel_scrolls_tabs = false

-- Padding
config.window_padding = {
  bottom = 8,
  right = 8,
  left = 8,
  top = 8,
}

config.keys = {
  {
    key = '=',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.IncreaseFontSize,
  },
  {
    key = '-',
    mods = 'CTRL',
    action = wezterm.action.DecreaseFontSize,
  },
  {
    key = '0',
    mods = 'CTRL',
    action = wezterm.action.ResetFontSize,
  },
  {
    key = 'UpArrow',
    mods = 'CTRL',
    action = wezterm.action.ScrollByLine(-2),
  },
  {
    key = 'DownArrow',
    mods = 'CTRL',
    action = wezterm.action.ScrollByLine(2),
  },
  {
    key = 'f',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'O',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'W',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.CloseCurrentPane { confirm = true },
  },
  {
    key = 'LeftArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'ALT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
  {
    key = 'LeftArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Left', 5 },
  },
  {
    key = 'RightArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Right', 5 },
  },
  {
    key = 'UpArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Up', 5 },
  },
  {
    key = 'DownArrow',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.AdjustPaneSize { 'Down', 5 },
  },
  {
    key = 'T',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SpawnTab 'CurrentPaneDomain',
  },
  {
    key = 'PageUp',
    mods = 'CTRL',
    action = wezterm.action.ActivateTabRelative(-1),
  },
  {
    key = 'PageDown',
    mods = 'CTRL',
    action = wezterm.action.ActivateTabRelative(1),
  },
  {
    key = 'X',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.TogglePaneZoomState,
  },
}

-- Center window on startup
wezterm.on('gui-startup', function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()

  local screen = wezterm.gui.screens().active
  local dimensions = gui_window:get_dimensions()

  local x = screen.x + math.floor((screen.width - dimensions.pixel_width) / 2)
  local y = screen.y + math.floor((screen.height - dimensions.pixel_height) / 2)

  gui_window:set_position(x, y)
end)

return config

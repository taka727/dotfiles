local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font
config.font = wezterm.font('JetBrains Mono', { weight = 'Regular' })
config.font_size = 14.0

-- Color scheme
config.color_scheme = 'Tokyo Night'

-- Window
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20
config.window_padding = {
  left = 10,
  right = 10,
  top = 10,
  bottom = 10,
}
config.window_decorations = 'RESIZE'
config.initial_cols = 220
config.initial_rows = 50

-- Tab bar
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- Scrollback
config.scrollback_lines = 10000

-- Bell
config.audible_bell = 'Disabled'

return config

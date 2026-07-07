local wezterm = require("wezterm")
local module = {}

local appearance = {
  color_scheme = "Tokyo Night",

  window_decorations = "RESIZE",
  window_close_confirmation = "NeverPrompt",
  window_padding = { left = 10, right = 10, top = 10, bottom = 10 },

  inactive_pane_hsb = {
    hue = 1.0,
    saturation = 0.85,
    brightness = 0.75,
  },

  -- Tab bar
  show_tabs_in_tab_bar = true,
  hide_tab_bar_if_only_one_tab = false,
  tab_bar_at_bottom = true,
  show_new_tab_button_in_tab_bar = false,
  tab_max_width = 30,
  use_fancy_tab_bar = true,
  window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
  },
  colors = {
    tab_bar = {
      background = "none",
      inactive_tab_edge = "none",
    },
    cursor_bg = "#7aa2f7",
    cursor_fg = "#1a1b26",
    cursor_border = "#7aa2f7",
    selection_bg = "#33467c",
    selection_fg = "#c0caf5",
  },

  -- Cursor
  default_cursor_style = "BlinkingBar",
  cursor_blink_rate = 500,
}

function module.apply_to_config(config)
  for k, v in pairs(appearance) do
    config[k] = v
  end
end

return module

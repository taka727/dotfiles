---@type Wezterm
local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.automatically_reload_config = true

-- IME: 修飾なし・SHIFT のみ転送（CTRL を含めると誤爆が増える）
---@diagnostic disable-next-line: assign-type-mismatch
config.macos_forward_to_ime_modifier_mask = "SHIFT"

config.font_size = 14.0
config.font = wezterm.font("JetBrainsMono Nerd Font")

config.window_background_opacity = 0.50
config.macos_window_background_blur = 2

config.status_update_interval = 1500

config.scrollback_lines = 10000
config.audible_bell = "Disabled"

-- QuickSelect: URL・ファイルパス・Git hash など
config.disable_default_quick_select_patterns = true
config.quick_select_patterns = {
  "\\bhttps?://[\\w\\-._~:/?#@!$&'()*+,;=%]+",
  "(?<=[\\s:=(\"'`])(?:~|/)[/\\w\\-.@~]+",
  "(?m)^(?:~|/)[/\\w\\-.@~]+(?=\\s*$)",
  "\\b[0-9a-f]{7,40}\\b",
  "\\b(?:[0-9]{1,3}\\.){3}[0-9]{1,3}\\b",
  "\\b[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\\b",
  "\\b[\\w.+-]+@[\\w.-]+\\.[a-zA-Z]{2,}\\b",
}

require("appearance").apply_to_config(config)
require("keymaps").apply_to_config(config)
require("tab").apply_to_config(config)
require("statusbar").apply_to_config(config)
require("workspace").apply_to_config(config)
require("background").apply_to_config(config)

wezterm.on("gui-startup", function()
  wezterm.run_child_process({ "aerospace", "enable", "on" })
end)

wezterm.on("gui-shutdown", function()
  wezterm.run_child_process({ "aerospace", "enable", "off" })
end)

wezterm.on("window-close-requested", function(window, _pane)
  local wins = wezterm.gui.gui_windows()
  if #wins <= 1 then
    wezterm.run_child_process({ "aerospace", "enable", "off" })
  end
  return false
end)

return config

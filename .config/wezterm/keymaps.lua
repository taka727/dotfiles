local wezterm = require("wezterm")
local act = wezterm.action

local module = {}

local keys = {}

local key_tables = {}

function module.apply_to_config(config)
  config.disable_default_key_bindings = false
  config.keys = keys
  config.key_tables = key_tables
end

return module

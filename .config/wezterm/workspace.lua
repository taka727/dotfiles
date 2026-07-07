local wezterm = require("wezterm")
local act = wezterm.action

local module = {}

local previous_workspace = nil

-- scratch ワークスペースをトグル
local function toggle_scratch_workspace()
  return wezterm.action_callback(function(window, pane)
    local current = wezterm.mux.get_active_workspace()
    if current == "scratch" then
      local target = previous_workspace or "default"
      window:perform_action(act.SwitchToWorkspace({ name = target }), pane)
    else
      previous_workspace = current
      window:perform_action(act.SwitchToWorkspace({ name = "scratch" }), pane)
    end
  end)
end

local keys = {
  -- CTRL+CMD+s で scratch ワークスペースをトグル
  { key = "s", mods = "CTRL|CMD", action = toggle_scratch_workspace() },
}

function module.apply_to_config(config)
  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return module

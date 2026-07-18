local wezterm = require("wezterm")

local module = {}

-- 表示ループは nvim(toggleterm)と共用のスクリプトに切り出してある
local calendar_args = {
  "/bin/zsh",
  "-lc",
  wezterm.home_dir .. "/.config/bin/gcal-watch",
}

-- 右側にカレンダーペインを開き、フォーカスは元のペインに残す
function module.open(pane)
  local cal_pane = pane:split({
    direction = "Right",
    size = 0.28,
    args = calendar_args,
  })
  pane:activate()
  return cal_pane
end

local keys = {
  -- LEADER+g でカレンダーペインを開き直す（閉じるのは通常どおり LEADER+x）
  {
    key = "g",
    mods = "LEADER",
    action = wezterm.action_callback(function(_, pane)
      module.open(pane)
    end),
  },
}

function module.apply_to_config(config)
  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return module

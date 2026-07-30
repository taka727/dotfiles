local colors = require("colors")

local spaces = {}

local function highlight(sid, selected)
  sbar.set("space." .. sid, {
    background = {
      color = selected and colors.space.active_bg or colors.space.inactive_bg,
      border_color = selected and colors.space.active_border or colors.space.inactive_border,
    },
    icon = {
      color = selected and colors.space.active_label or colors.space.inactive_label,
    },
  })
end

-- aerospace.toml の exec-on-workspace-change が発火するカスタムイベント
local function workspace_change(env)
  for sid in pairs(spaces) do
    highlight(sid, tostring(sid) == env.FOCUSED_WORKSPACE)
  end
end

for sid = 1, 9 do
  local space = sbar.add("item", "space." .. sid, {
    position = "left",
    icon = {
      string = tostring(sid),
      padding_left = 8,
      padding_right = 8,
      color = colors.space.inactive_label,
    },
    label = { drawing = false },
    background = {
      color = colors.space.inactive_bg,
      border_width = 1,
      border_color = colors.space.inactive_border,
    },
  })

  spaces[sid] = space

  space:subscribe("aerospace_workspace_change", workspace_change)
  space:subscribe("mouse.clicked", function()
    sbar.exec("aerospace workspace " .. sid)
  end)
end

-- 起動直後は上のイベントがまだ発火していないので、現在のフォーカスを問い合わせて初期表示に反映する
sbar.exec("aerospace list-workspaces --focused", function(focused)
  workspace_change({ FOCUSED_WORKSPACE = focused:match("%d+") })
end)

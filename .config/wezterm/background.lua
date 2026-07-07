local wezterm = require("wezterm")
local module = {}

local CHEATSHEET_DIR = wezterm.config_dir .. "/cheatsheets/"

-- プロセス名(部分一致) -> チートシート画像のマッピング
local PROCESS_CHEATSHEETS = {
  nvim = CHEATSHEET_DIR .. "nvim.png",
  vim  = CHEATSHEET_DIR .. "nvim.png",
}

local DEFAULT_CHEATSHEET = CHEATSHEET_DIR .. "wezterm.png"

local function basename(path)
  return path and path:match("([^/]+)$") or ""
end

local function cheatsheet_for_pane(pane)
  local proc = basename(pane:get_foreground_process_name())
  for pattern, path in pairs(PROCESS_CHEATSHEETS) do
    if proc:find(pattern) then
      return path
    end
  end
  return DEFAULT_CHEATSHEET
end

local function make_background(image_path)
  return {
    -- ターミナルの背景色レイヤー（既存の opacity / blur はウィンドウ全体に効く）
    {
      source = { Color = "transparent" },
    },
    -- チートシート画像レイヤー
    {
      source = { File = image_path },
      width = "100%",
      height = "100%",
      vertical_align = "Middle",
      horizontal_align = "Center",
      opacity = 0.12,
      hsb = { brightness = 0.9, saturation = 0.8 },
    },
  }
end

function module.apply_to_config(_)
  wezterm.on("update-status", function(window, pane)
    local image_path = cheatsheet_for_pane(pane)
    window:set_config_overrides({
      background = make_background(image_path),
    })
  end)
end

return module

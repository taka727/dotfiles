local wezterm = require("wezterm")
local act = wezterm.action

local module = {}

-- リーダーキー（必要になったら有効化）
local leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

-- フォーカス中の macOS ウィンドウ（AeroSpace視点）に対してコマンドを実行
local function aerospace(args)
  return wezterm.action_callback(function()
    wezterm.run_child_process({ "/bin/zsh", "-lc", "aerospace " .. args })
  end)
end

-- 透過率: ALT+SHIFT+Z を押すたびに透過⇔通常をトグルする
-- 透過時はブラーもなくし、文字も foreground_text_hsb の brightness を下げて薄くする
-- （WezTerm は colors.foreground の alpha を無視するため、真の透過ではなく減光で近似）
local TRANSPARENT_OPACITY = 0.15
local TRANSPARENT_BLUR = 0
local TRANSPARENT_TEXT_HSB = { hue = 1.0, saturation = 1.0, brightness = 0.35 }
local NORMAL_TEXT_HSB = { hue = 1.0, saturation = 1.0, brightness = 1.0 }
local is_transparent = {} -- window_id -> bool
local normal_opacity -- apply_to_config で config.window_background_opacity から設定される
local normal_blur -- apply_to_config で config.macos_window_background_blur から設定される

local transparency_toggle = wezterm.action_callback(function(window, _pane)
  local id = window:window_id()
  local overrides = window:get_config_overrides() or {}
  is_transparent[id] = not is_transparent[id]
  overrides.window_background_opacity = is_transparent[id] and TRANSPARENT_OPACITY or normal_opacity
  overrides.macos_window_background_blur = is_transparent[id] and TRANSPARENT_BLUR or normal_blur
  overrides.foreground_text_hsb = is_transparent[id] and TRANSPARENT_TEXT_HSB or NORMAL_TEXT_HSB
  window:set_config_overrides(overrides)
end)

local keys = {
  -- ウィンドウ
  { key = "n", mods = "LEADER", action = act.SpawnWindow },
  { key = "N", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

  -- タブ
  { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "T", mods = "LEADER|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },

  -- ペイン移動（各ペインにアルファベットを表示し、押すとジャンプ）
  { key = ";", mods = "CTRL", action = act.PaneSelect({ alphabet = "asdfghjklqwertyuiopzxcvbnm", mode = "Activate" }) },

  -- ペイン分割
  { key = "r", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },

  -- ペインを閉じる
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

  -- ペインリサイズ（リサイズモードに入り、h/j/k/l で連続調整。Esc か q で抜ける）
  { key = "e", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false, timeout_milliseconds = 3000 }) },

  -- AeroSpace のオン/オフ切り替え
  { key = "a", mods = "LEADER", action = aerospace("enable toggle") },

  -- ペインズーム

  -- 透過率（押すたびに透過⇔通常をトグル）
  { key = "Z", mods = "ALT|SHIFT", action = transparency_toggle },

  -- コピー・ペースト

  -- スクロール

  -- 検索

  -- コピーモード

  -- その他
}

local key_tables = {
  resize_pane = {
    { key = "h", action = act.AdjustPaneSize({ "Left", 3 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down", 3 }) },
    { key = "k", action = act.AdjustPaneSize({ "Up", 3 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 3 }) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "q", action = "PopKeyTable" },
  },
}

function module.apply_to_config(config)
  normal_opacity = config.window_background_opacity
  normal_blur = config.macos_window_background_blur
  config.leader = leader
  config.disable_default_key_bindings = false
  config.keys = keys
  config.key_tables = key_tables
end

return module

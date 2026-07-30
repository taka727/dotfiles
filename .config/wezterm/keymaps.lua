local wezterm = require("wezterm")
local act = wezterm.action

local module = {}

-- リーダーキー（必要になったら有効化）
local leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

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
  {
    key = "a",
    mods = "LEADER",
    action = wezterm.action_callback(function()
      wezterm.run_child_process({ "/bin/zsh", "-lc", "aerospace enable toggle" })
    end),
  },

  -- ペインズーム

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
  config.leader = leader
  config.disable_default_key_bindings = false
  config.keys = keys
  config.key_tables = key_tables
end

return module

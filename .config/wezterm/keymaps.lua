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

-- 透過率: ALT+SHIFT+Z を長押しすると一時的に透けさせる
-- WezTerm はキーの離上イベントを取得できないため、OS のキーリピートを利用する。
-- 押すたびにカウントを更新し、一定時間（RELEASE_DELAY）後に押下回数が変化していなければ
-- 「離された」とみなして元の透過率に戻す。
local HOLD_OPACITY = 0.15
local RELEASE_DELAY = 0.15 -- 秒
local hold_press_count = {}
local normal_opacity -- apply_to_config で config.window_background_opacity から設定される

local transparency_hold = wezterm.action_callback(function(window, _pane)
  local id = window:window_id()
  hold_press_count[id] = (hold_press_count[id] or 0) + 1
  local count = hold_press_count[id]

  local overrides = window:get_config_overrides() or {}
  if overrides.window_background_opacity ~= HOLD_OPACITY then
    overrides.window_background_opacity = HOLD_OPACITY
    window:set_config_overrides(overrides)
  end

  wezterm.time.call_after(RELEASE_DELAY, function()
    if hold_press_count[id] ~= count then
      return -- その間に再度押されている＝まだ押しっぱなし
    end
    local released_overrides = window:get_config_overrides() or {}
    released_overrides.window_background_opacity = normal_opacity
    window:set_config_overrides(released_overrides)
  end)
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

  -- 透過率（長押しで透ける、離すと戻る）
  { key = "Z", mods = "ALT|SHIFT", action = transparency_hold },

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
  config.leader = leader
  config.disable_default_key_bindings = false
  config.keys = keys
  config.key_tables = key_tables
end

return module

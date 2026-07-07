local wezterm = require("wezterm")
local act = wezterm.action

local module = {}

-- Ctrl+; をリーダーキーに（TUIアプリと競合しにくい）
local leader = { key = ";", mods = "CTRL", timeout_milliseconds = 2000 }

-- ペインの高さを指定パーセンテージに設定
local function apply_pane_height_percent(window, pane, percent)
  local tab = pane:tab()
  local tab_size = tab:get_size()
  local pane_dims = pane:get_dimensions()
  local pane_id = pane:pane_id()

  local is_top_pane = false
  for _, info in ipairs(tab:panes_with_info()) do
    if info.pane:pane_id() == pane_id then
      is_top_pane = (info.top == 0)
      break
    end
  end

  local target_rows = math.floor(tab_size.rows * percent)
  local current_rows = pane_dims.viewport_rows
  local diff = current_rows - target_rows

  if is_top_pane then
    if diff > 0 then
      window:perform_action(act.AdjustPaneSize({ "Up", diff }), pane)
    elseif diff < 0 then
      window:perform_action(act.AdjustPaneSize({ "Down", -diff }), pane)
    end
  else
    if diff > 0 then
      window:perform_action(act.AdjustPaneSize({ "Down", diff }), pane)
    elseif diff < 0 then
      window:perform_action(act.AdjustPaneSize({ "Up", -diff }), pane)
    end
  end
end

local function set_pane_height_percent(percent)
  return wezterm.action_callback(function(window, pane)
    apply_pane_height_percent(window, pane, percent)
  end)
end

local keys = {
  -- Alt+¥ → バックスラッシュ
  { key = "¥", mods = "ALT", action = wezterm.action.SendString("\\") },

  -- ウィンドウ
  { key = "Enter", mods = "ALT", action = act.ToggleFullScreen },
  { key = "n", mods = "SUPER", action = act.SpawnWindow },

  -- タブ
  { key = "t", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = "LEADER", action = act.CloseCurrentTab({ confirm = true }) },
  { key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },

  -- タブリネーム
  {
    key = ",",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local tab = pane:tab()
      local tab_module = require("tab")
      local current = tab_module.custom_title[tab:tab_id()] or ""
      window:perform_action(
        act.PromptInputLine({
          description = "(wezterm) Rename tab (empty to reset):",
          initial_value = current,
          action = wezterm.action_callback(function(_, inner_pane, line)
            if line == nil then return end
            local t = inner_pane:tab()
            if line == "" then
              tab_module.custom_title[t:tab_id()] = nil
            else
              tab_module.custom_title[t:tab_id()] = line
            end
          end),
        }),
        pane
      )
    end),
  },

  -- ペイン移動
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },

  -- ペイン分割
  { key = "r", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "d", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "x", mods = "LEADER", action = act({ CloseCurrentPane = { confirm = true } }) },
  { key = ":", mods = "CTRL", action = act.PaneSelect },

  -- ペインズーム
  {
    key = "Z",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local tab = pane:tab()
      if #tab:panes() > 1 then
        window:perform_action(act.TogglePaneZoomState, pane)
      end
    end),
  },

  -- フォントサイズ
  { key = "+", mods = "SUPER", action = act.IncreaseFontSize },
  { key = "-", mods = "SUPER", action = act.DecreaseFontSize },
  { key = "0", mods = "SUPER", action = act.ResetFontSize },

  -- コピー・ペースト
  { key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
  { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
  { key = "Copy", mods = "NONE", action = act.CopyTo("Clipboard") },
  { key = "Paste", mods = "NONE", action = act.PasteFrom("Clipboard") },

  -- Shift+Enter → 改行（Claude Code などで使用）
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },

  -- スクロール
  { key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
  { key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
  { key = "p", mods = "ALT|CTRL", action = act.ScrollByPage(-0.5) },
  { key = "n", mods = "ALT|CTRL", action = act.ScrollByPage(0.5) },

  -- ScrollToPrompt（シェル統合が必要）
  { key = "[", mods = "ALT", action = act.ScrollToPrompt(-1) },
  { key = "]", mods = "ALT", action = act.ScrollToPrompt(1) },

  -- QuickSelect
  { key = " ", mods = "SUPER", action = act.QuickSelect },

  -- 検索
  {
    key = "f",
    mods = "SUPER",
    action = act.Multiple({
      act.Search("CurrentSelectionOrEmptyString"),
      act.CopyMode("ClearPattern"),
      act.CopyMode("ClearSelectionMode"),
    }),
  },

  -- コピーモード
  {
    key = "X",
    mods = "CTRL",
    action = act.Multiple({
      act.ActivateCopyMode,
      act.CopyMode("ClearPattern"),
      act.CopyMode("ClearSelectionMode"),
      act.CopyMode("MoveToViewportMiddle"),
    }),
  },

  -- Ctrl+[ → Escape
  {
    key = "[",
    mods = "CTRL",
    action = wezterm.action_callback(function(window, pane)
      local proc = pane:get_foreground_process_name() or ""
      if proc:match("nvim") then
        window:perform_action(act.SendString("\x1b[27u"), pane)
      else
        window:perform_action(act.SendKey({ key = "Escape" }), pane)
      end
    end),
  },

  -- コマンドパレット
  { key = "P", mods = "CTRL", action = act.ActivateCommandPalette },

  -- 文字選択パレット
  { key = "U", mods = "CTRL", action = act.CharSelect({ copy_on_select = true, copy_to = "ClipboardAndPrimarySelection" }) },

  -- デバッグ
  { key = "l", mods = "SUPER", action = act.ShowDebugOverlay },
  { key = "R", mods = "CTRL", action = act.ReloadConfiguration },
  { key = "r", mods = "SUPER", action = act.ReloadConfiguration },

  -- サイズ調整モード
  { key = "s", mods = "LEADER", action = act.ActivateKeyTable({ name = "setting_mode", one_shot = false }) },
}

local key_tables = {
  copy_mode = {
    { key = "c", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
    { key = "q", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
    { key = "Escape", mods = "NONE", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },
    { key = "[", mods = "CTRL", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" } }) },

    -- Vim風移動
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
    { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
    { key = "G", mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
    { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    { key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
    { key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
    { key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
    { key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
    { key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
    { key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
    { key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
    { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
    { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },

    -- 選択
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },
    { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "z", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "SemanticZone" }) },
    { key = "y", mods = "NONE", action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" } }) },

    -- 検索
    { key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
    { key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
    { key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },

    -- ScrollToPrompt
    { key = "[", mods = "ALT", action = act.ScrollToPrompt(-1) },
    { key = "]", mods = "ALT", action = act.ScrollToPrompt(1) },
    { key = "]", mods = "NONE", action = act.CopyMode({ MoveForwardZoneOfType = "Input" }) },
    { key = "[", mods = "NONE", action = act.CopyMode({ MoveBackwardZoneOfType = "Input" }) },

    { key = "v", mods = "SUPER", action = act.Multiple({ "ScrollToBottom", { CopyMode = "Close" }, act.PasteFrom("Clipboard") }) },
    { key = "p", mods = "ALT|CTRL", action = act.CopyMode("PageUp") },
    { key = "n", mods = "ALT|CTRL", action = act.CopyMode("PageDown") },
  },

  search_mode = {
    { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
    { key = "[", mods = "CTRL", action = act.CopyMode("Close") },
    { key = "n", mods = "CTRL", action = act.Multiple({ act.CopyMode("NextMatch"), act.ActivateCopyMode }) },
    { key = "p", mods = "CTRL", action = act.Multiple({ act.CopyMode("PriorMatch"), act.ActivateCopyMode }) },
    { key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
    { key = "u", mods = "CTRL", action = act.CopyMode("ClearPattern") },
    { key = "X", mods = "CTRL", action = act.ActivateCopyMode },
  },

  setting_mode = {
    { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "1", action = set_pane_height_percent(0.1) },
    { key = "2", action = set_pane_height_percent(0.2) },
    { key = "3", action = set_pane_height_percent(0.3) },
    { key = "4", action = set_pane_height_percent(0.4) },
    { key = "5", action = set_pane_height_percent(0.5) },
    { key = "6", action = set_pane_height_percent(0.6) },
    { key = "7", action = set_pane_height_percent(0.7) },
    { key = "8", action = set_pane_height_percent(0.8) },
    { key = "9", action = set_pane_height_percent(0.9) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "[", mods = "CTRL", action = "PopKeyTable" },
    { key = "q", action = "PopKeyTable" },
    { key = "c", mods = "CTRL", action = "PopKeyTable" },
  },
}

function module.apply_to_config(config)
  config.disable_default_key_bindings = true
  config.leader = leader
  config.keys = keys
  config.key_tables = key_tables
end

return module

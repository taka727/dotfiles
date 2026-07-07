local wezterm = require("wezterm")
local module = {}

module.custom_title = {}

local ICONS = {
  neovim  = wezterm.nerdfonts.linux_neovim,
  ssh     = wezterm.nerdfonts.md_lan,
  claude  = "✳",
  fallback = wezterm.nerdfonts.dev_terminal,
  zoom    = wezterm.nerdfonts.md_magnify,
}

local ICON_COLORS = {
  neovim = "#57A143",
  ssh    = "#ff6b6b",
  claude = "#D97757",
}

local TAB_COLORS = {
  foreground_inactive   = "#a9b1d6",
  background_inactive   = "none",
  foreground_active     = "#1a1b26",
  background_active     = "#7aa2f7",
  background_ssh_active = "#ff6b6b",
  foreground_ssh_active = "#ffffff",
}

local DECORATIONS = {
  left_circle  = wezterm.nerdfonts.ple_left_half_circle_thick,
  right_circle = wezterm.nerdfonts.ple_right_half_circle_thick,
}

local function basename(path)
  return string.gsub(path or "", "(.*[/\\])(.*)", "%2")
end

local function is_ssh_process(process_name, cmdline, user_vars)
  if user_vars.ssh_host and user_vars.ssh_host ~= "" then
    return true, user_vars.ssh_host
  end
  if process_name:find("ssh") or (cmdline and cmdline:find("ssh")) then
    local host = cmdline and cmdline:match("ssh%s+([%w_%-%.]+)")
    return true, host
  end
  return false, nil
end

local function is_claude_process(process_name, pane_title)
  return process_name == "claude"
    or (pane_title and (pane_title:find("^✳") or pane_title:lower():find("claude")))
end

local function extract_project_name(cwd)
  if not cwd then return "-" end
  local home = os.getenv("HOME")
  if home and cwd:find("^" .. home) then
    cwd = cwd:gsub("^" .. home, "~")
  end
  local _, project = cwd:match(".*/src/github.com/([^/]+)/([^/]+)")
  if project then return project end
  cwd = cwd:gsub("/$", "")
  return cwd:match("([^/]+)$") or cwd
end

local function get_tab_colors(is_active, is_ssh)
  if is_active and is_ssh then
    return TAB_COLORS.background_ssh_active, TAB_COLORS.foreground_ssh_active
  elseif is_active then
    return TAB_COLORS.background_active, TAB_COLORS.foreground_active
  end
  return TAB_COLORS.background_inactive, TAB_COLORS.foreground_inactive
end

local function has_zoomed_pane(panes)
  for _, pane_info in ipairs(panes) do
    if pane_info.is_zoomed then return true end
  end
  return false
end

function module.apply_to_config(config)
  local title_cache = {}
  local raw_cwd_cache = {}
  local claude_cache = {}

  wezterm.on("update-status", function(_, pane)
    local pane_id = pane:pane_id()
    local user_vars = pane.user_vars or {}

    if not (user_vars.ssh_host and user_vars.ssh_host ~= "") then
      local cwd_url = pane:get_current_working_dir()
      local cwd = cwd_url and cwd_url.file_path
      if cwd ~= raw_cwd_cache[pane_id] then
        raw_cwd_cache[pane_id] = cwd
        title_cache[pane_id] = extract_project_name(cwd)
      end
    end

    local process_name = basename(pane:get_foreground_process_name() or "")
    local pane_title = pane:get_title() or ""
    if is_claude_process(process_name, pane_title) then
      claude_cache[pane_id] = true
    elseif (process_name == "zsh" or process_name == "bash" or process_name == "fish")
      and not (pane_title:find("^✳") or pane_title:lower():find("claude")) then
      claude_cache[pane_id] = nil
    end
  end)

  wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
    local pane = tab.active_pane
    local pane_id = pane.pane_id
    local process_name = basename(pane.foreground_process_name)
    local pane_title = pane.title or ""
    local cmdline = pane.foreground_process_name or ""
    local user_vars = pane.user_vars or {}

    local is_ssh, _ = is_ssh_process(process_name, cmdline, user_vars)
    local is_claude = claude_cache[pane_id] or false

    local background, foreground = get_tab_colors(tab.is_active, is_ssh)
    local edge_foreground = background

    -- タイトルテキスト
    local title_text
    local custom = module.custom_title[tab.tab_id]
      or (tab.tab_title ~= "" and tab.tab_title or nil)
    if custom then
      title_text = custom
    elseif is_ssh then
      local host = user_vars.ssh_host or cmdline:match("ssh%s+([%w_%-%.]+)") or "ssh"
      title_text = host
    else
      title_text = title_cache[pane_id] or "-"
    end

    -- アイコン
    local icon, icon_color
    if is_ssh then
      icon = ICONS.ssh
      icon_color = tab.is_active and "#ffffff" or ICON_COLORS.ssh
    elseif pane_title == "nvim" or process_name == "nvim" then
      icon = ICONS.neovim
      icon_color = ICON_COLORS.neovim
    elseif is_claude then
      icon = ICONS.claude
      icon_color = ICON_COLORS.claude
    else
      icon = ICONS.fallback
      icon_color = TAB_COLORS.foreground_inactive
    end

    local zoom_indicator = has_zoomed_pane(tab.panes) and (ICONS.zoom .. " ") or ""
    local left_circle  = tab.is_active and DECORATIONS.left_circle or ""
    local right_circle = tab.is_active and DECORATIONS.right_circle or ""

    local claude_suffix = ""
    if not custom and is_claude and pane_title ~= "" then
      claude_suffix = " " .. pane_title
    end

    local title = " " .. wezterm.truncate_right(title_text, max_width)
    local claude_title = wezterm.truncate_right(claude_suffix, max_width) .. " "

    return {
      { Background = { Color = "transparent" } },
      { Text = " " },
      { Foreground = { Color = edge_foreground } },
      { Text = left_circle },
      { Background = { Color = background } },
      { Foreground = { Color = icon_color } },
      { Text = icon },
      { Foreground = { Color = foreground } },
      { Text = zoom_indicator },
      { Attribute = { Intensity = "Bold" } },
      { Text = title },
      { Attribute = { Intensity = "Normal" } },
      { Text = claude_title },
      { Background = { Color = "transparent" } },
      { Foreground = { Color = edge_foreground } },
      { Text = right_circle },
    }
  end)
end

return module

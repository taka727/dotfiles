local icons = {
  _0 = "󰖁",
  _33 = "󰕿",
  _66 = "󰖀",
  _100 = "󰕾",
}

local volume = sbar.add("item", "volume", {
  position = "right",
})

local function set_icon(pct)
  local icon = icons._100
  if pct == 0 then
    icon = icons._0
  elseif pct < 34 then
    icon = icons._33
  elseif pct < 67 then
    icon = icons._66
  end
  volume:set({ icon = icon })
end

volume:subscribe("volume_change", function(env)
  local pct = tonumber(env.INFO)
  set_icon(pct)
  volume:set({ label = pct .. "%" })
end)

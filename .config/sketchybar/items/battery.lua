local battery = sbar.add("item", "battery", {
  position = "right",
  update_freq = 60,
  icon = { drawing = false },
})

local function update()
  sbar.exec("pmset -g batt", function(batt_info)
    local percentage = batt_info:match("(%d+)%%")
    battery:set({ label = percentage .. "%" })
  end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, update)

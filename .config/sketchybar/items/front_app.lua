local front_app = sbar.add("item", "front_app", {
  position = "center",
  icon = { drawing = false },
  label = {
    font = { style = "SemiBold", size = 10.0 },
  },
})

front_app:subscribe("front_app_switched", function(env)
  front_app:set({ label = { string = env.INFO } })
end)

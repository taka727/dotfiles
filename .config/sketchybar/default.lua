local settings = require("settings")
local colors = require("colors")

sbar.default({
  updates = "when_shown",
  icon = {
    font = {
      family = settings.font,
      style = "Regular",
      size = 10.0,
    },
    color = colors.icon,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font,
      style = "Regular",
      size = 10.0,
    },
    color = colors.label,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  background = {
    height = 20,
    corner_radius = 5,
    border_width = 1,
    padding_left = 4,
    padding_right = 4,
  },
  padding_left = 4,
  padding_right = 4,
})

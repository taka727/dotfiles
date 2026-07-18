local calendar_term

return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      { "<C-\\>", desc = "Toggle terminal" },
      {
        "<leader>gc",
        function()
          if not calendar_term then
            calendar_term = require("toggleterm.terminal").Terminal:new({
              cmd = vim.fn.expand("~/.config/bin/gcal-watch"),
              direction = "float",
              hidden = true,
              close_on_exit = true,
            })
          end
          calendar_term:toggle()
        end,
        desc = "Google Calendar",
      },
    },
    opts = {
      open_mapping = [[<C-\>]],
      direction = "float",
      float_opts = {
        border = "curved",
      },
    },
  },
}

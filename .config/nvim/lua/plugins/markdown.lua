return {
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    init = function()
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
      vim.g.bullets_enable_in_empty_buffers = 0
      vim.g.bullets_set_mappings = 1
      vim.g.bullets_outline_levels = { "ROM", "ABC", "num", "abc", "rom", "std-" }
    end,
  },
  {
    "toppair/peek.nvim",
    ft = "markdown",
    build = "deno task --quiet build:fast",
    keys = {
      {
        "<Leader>mp",
        function()
          local peek = require("peek")
          if peek.is_open() then
            peek.close()
          else
            peek.open()
          end
        end,
        ft = "markdown",
        desc = "Markdown プレビューをトグル (peek)",
      },
    },
    opts = {
      app = "browser",
    },
    config = function(_, opts)
      require("peek").setup(opts)
      vim.api.nvim_create_user_command("PeekOpen", function() require("peek").open() end, {})
      vim.api.nvim_create_user_command("PeekClose", function() require("peek").close() end, {})
    end,
  },
}

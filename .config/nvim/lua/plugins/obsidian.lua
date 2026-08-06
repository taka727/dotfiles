return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "life",
          path = "~/project/life/life",
        },
      },
      picker = {
        name = "telescope.nvim",
      },
      checkbox = {
        order = { " ", "x" },
      },
      templates = {
        folder = "_templates",
      },
    },
    keys = {
      { "<Leader>oo", "<cmd>Obsidian quick_switch<cr>",    desc = "Obsidian: ノートを開く" },
      { "<Leader>os", "<cmd>Obsidian search<cr>",          desc = "Obsidian: 全文検索" },
      { "<Leader>ot", "<cmd>Obsidian toggle_checkbox<cr>", desc = "Obsidian: チェックボックス切替" },
      { "<Leader>ob", "<cmd>Obsidian backlinks<cr>",       desc = "Obsidian: バックリンク一覧" },
      { "<Leader>on", "<cmd>Obsidian new<cr>",             desc = "Obsidian: 新規ノート作成" },
    },
    init = function()
      -- obsidian.nvimのチェックボックス・リンク装飾にはconceallevel 1/2が必要
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.conceallevel = 2
        end,
      })
    end,
  },
}

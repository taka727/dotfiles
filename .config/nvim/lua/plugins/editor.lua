return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Recent files" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",     desc = "Keymaps" },
    },
    config = function()
      require("telescope").setup({
        extensions = { fzf = {} },
      })
      require("telescope").load_extension("fzf")
    end,
  },

  {
    "stevearc/oil.nvim",
    -- `nvim .` でディレクトリを開いた時点で oil を起動させるため遅延読み込みしない
    lazy = false,
    keys = {
      { "<leader>fo", "<cmd>Oil<cr>", desc = "Open parent directory (oil)" },
    },
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      local parsers = {
        "lua", "javascript", "typescript", "tsx",
        "python", "go", "html", "css", "json", "yaml", "markdown", "bash",
      }

      require("nvim-treesitter").install(parsers)

      -- tsconfig.json / biome.json などの jsonc は json パーサーで扱う
      vim.treesitter.language.register("json", "jsonc")

      -- FileType の pattern にはパーサー名ではなく filetype を指定する
      -- （例: .tsx の filetype は typescriptreact、.sh は sh）
      local filetypes = {
        "lua", "javascript", "javascriptreact", "typescript", "typescriptreact",
        "python", "go", "html", "css", "json", "jsonc", "yaml", "markdown", "sh", "bash",
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = filetypes,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}

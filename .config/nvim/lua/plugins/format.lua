return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = { "stylua", "prettier", "ruff" },
    },
  },

  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>fm",
        function() require("conform").format({ lsp_fallback = true }) end,
        mode = { "n", "v" },
        desc = "Format buffer",
      },
    },
    opts = function()
      -- Biome の設定ファイルがあるプロジェクトでは Biome、それ以外は Prettier で整形する
      -- biome-check = 整形 + 安全な lint 自動修正 + import 並べ替え（`biome check --write` 相当）
      -- コマンドはプロジェクトの node_modules/.bin/biome を使うため Mason でのインストールは不要
      local biome_config_files = { "biome.json", "biome.jsonc", ".biome.json", ".biome.jsonc" }
      local function biome_or_prettier(bufnr)
        if vim.fs.root(bufnr, biome_config_files) then
          return { "biome-check" }
        end
        return { "prettier" }
      end

      return {
        formatters_by_ft = {
          lua = { "stylua" },
          javascript = biome_or_prettier,
          typescript = biome_or_prettier,
          javascriptreact = biome_or_prettier,
          typescriptreact = biome_or_prettier,
          json = biome_or_prettier,
          jsonc = biome_or_prettier,
          css = biome_or_prettier,
          yaml = { "prettier" },
          html = { "prettier" },
          markdown = { "prettier" },
          python = { "ruff_format" },
        },
        format_on_save = {
          timeout_ms = 1000,
          lsp_fallback = true,
        },
      }
    end,
  },
}

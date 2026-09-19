return {
  {
    "tadmccorkle/markdown.nvim",
    ft = "markdown",
    config = true,
    -- デフォルトキーマップ: gs+モーション+b/i/s/c で太字/斜体/取り消し線/コードをトグル
    -- (例: gsiwb で単語を太字化、ビジュアル選択中は gsb)
    -- ]] / [[ / ]c / ]p で見出し間を移動
    init = function()
      -- <Leader>ma/s/d/f/g/h で現在行を見出しレベル1〜6にして挿入モードに入る
      -- 既存の見出し記号は付け替え、行にテキストがあればそのまま見出し文になる
      -- 数字キーはレイヤー切り替えが必要なため、ホームポジションの文字を左から順に割り当てている
      local heading_keys = { "a", "s", "d", "f", "g", "h" }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(args)
          for level, key in ipairs(heading_keys) do
            vim.keymap.set("n", "<Leader>m" .. key, function()
              local text = vim.api.nvim_get_current_line():gsub("^%s*#*%s*", "")
              vim.api.nvim_set_current_line(string.rep("#", level) .. " " .. text)
              vim.cmd("startinsert!")
            end, {
              buffer = args.buf,
              desc = "Markdown: 見出しレベル" .. level .. "にして入力",
            })
          end
        end,
      })
    end,
  },
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown", "text", "gitcommit" },
    init = function()
      vim.g.bullets_enabled_file_types = { "markdown", "text", "gitcommit" }
      vim.g.bullets_enable_in_empty_buffers = 0
      vim.g.bullets_outline_levels = { "ROM", "ABC", "num", "abc", "rom", "std-" }
      -- チェックボックスのトグルは obsidian.nvim の <Leader>ot に統一するため、
      -- bullets.vim のデフォルトキーマップを切り、<Leader>x 以外を手動で定義する
      vim.g.bullets_set_mappings = 0
      vim.g.bullets_custom_mappings = {
        { "imap", "<cr>", "<Plug>(bullets-newline)" },
        { "inoremap", "<C-cr>", "<cr>" },
        { "nmap", "o", "<Plug>(bullets-newline)" },
        { "vmap", "gN", "<Plug>(bullets-renumber)" },
        { "nmap", "gN", "<Plug>(bullets-renumber)" },
        { "imap", "<C-t>", "<Plug>(bullets-demote)" },
        { "nmap", ">>", "<Plug>(bullets-demote)" },
        { "vmap", ">", "<Plug>(bullets-demote)" },
        { "imap", "<C-d>", "<Plug>(bullets-promote)" },
        { "nmap", "<<", "<Plug>(bullets-promote)" },
        { "vmap", "<", "<Plug>(bullets-promote)" },
      }
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

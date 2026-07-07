-- =====================================================================
-- 🛠️ Neovim 基本設定 (仕事・プライベート共通)
-- =====================================================================

vim.opt.number = true         -- 行番号を表示
vim.opt.relativenumber = false -- 絶対行番号を表示
vim.opt.smartindent = true    -- 自動インデント
vim.opt.tabstop = 2           -- Tab幅
vim.opt.shiftwidth = 2        -- インデント幅
vim.opt.expandtab = true      -- Tabをスペースに

-- クリップボード同期
vim.opt.clipboard = "unnamed,unnamedplus"

vim.opt.mouse = "a"           -- マウス操作有効
vim.opt.ignorecase = true     -- 検索時に大文字小文字無視
vim.opt.smartcase = true      -- 大文字が含まれる場合は区別
vim.opt.hlsearch = true       -- 検索結果ハイライト

-- =====================================================================
-- 🪟 背景透過 (WezTermの背景・チートシート画像を透過させる)
-- =====================================================================
-- ColorScheme適用後に上書きするためautocmdで登録
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local transparent = { bg = "NONE", ctermbg = "NONE" }
    for _, hl in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer" }) do
      vim.api.nvim_set_hl(0, hl, transparent)
    end
  end,
})
-- 初回起動時にも適用
vim.cmd("doautocmd ColorScheme")

-- =====================================================================
-- ⌨️ 快適キーマッピング (Keymaps)
-- =====================================================================
-- レジスタ・モードの割り当て用ショートカット関数
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- 1. リーダーキーの設定 (色々なショートカットの起点になるキー。スペースが押しやすくておすすめ)
vim.g.mapleader = " "

-- 2. 画面分割 (スペース + s で横分割、スペース + v で縦分割)
keymap("n", "<Leader>s", ":split<CR>", opts)
keymap("n", "<Leader>v", ":vsplit<CR>", opts)

-- 3. 分割画面の移動 (Ctrl + h/j/k/l で上下左右の画面へ一瞬でジャンプ)
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- 4. 検索ハイライトの解除 (Escキーを2回連打で、検索で光った文字を消灯)
keymap("n", "<Esc><Esc>", ":nohlsearch<CR>", opts)


keymap("v", "J", ":m '>+1<CR>gv=gv", opts)
keymap("v", "K", ":m '<-2<CR>gv=gv", opts)

-- 6. ビジュアルモード時：インデント調整後も選択状態をキープ
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)       

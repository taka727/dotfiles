vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.smartindent = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.mouse = "a"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- 外部（Claude Codeなど）によるファイル変更を検知して自動再読込する
vim.opt.autoread = true
vim.opt.updatetime = 1000
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "checktime",
})

-- WezTermの背景・チートシート画像を透過させる
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local transparent = { bg = "NONE", ctermbg = "NONE" }
    for _, hl in ipairs({ "Normal", "NormalNC", "NormalFloat", "SignColumn", "EndOfBuffer" }) do
      vim.api.nvim_set_hl(0, hl, transparent)
    end
  end,
})

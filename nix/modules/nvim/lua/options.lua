local options = {
  is_transparent = false
}

-- [기본 옵션]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.g.mapleader = " "         
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.laststatus = 3        -- 전역 상태줄 (Global Statusline)
vim.opt.cmdheight = 1         -- 커맨드 라인 높이 유지
vim.opt.conceallevel = 2      -- 必须设置为 2 才能让 markview 隐藏 Markdown 标记并显示美化 UI

-- [YAML 전용 설정 (DevOps 추천)]
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"yaml", "yml"},
  callback = function()
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.number = true
  end,
})

return options

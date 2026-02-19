{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;
    # wrapRc = true;  <-- 이 줄을 삭제하거나 주석 처리하세요.

    # 1. 플러그인 목록
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
      vim-tmux-navigator 
      which-key-nvim 
      nvim-web-devicons
      lualine-nvim
      neo-tree-nvim
      nui-nvim 
      plenary-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars 
      gitsigns-nvim
      indent-blankline-nvim
      bufferline-nvim
      sg-nvim           # ast-grep
      oil-nvim          # 파일 관리
      comment-nvim      # 주석
      nvim-autopairs    # 괄호 자동완성
      trouble-nvim      # 에러 목록
      
      # LSP & Completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
    ];

    # 2. Lua 설정
    initLua = ''
      -- 안전한 설정을 위한 헬퍼 함수
      local function safe_require(module, config_fn)
        local ok, mod = pcall(require, module)
        if ok then config_fn(mod) end
      end

      -- [기본 옵션]
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
      vim.g.mapleader = " "         
      vim.opt.clipboard = "unnamedplus"
      vim.opt.termguicolors = true

      -- [Vim Tmux Navigator]
      vim.g.tmux_navigator_no_mappings = 1
      vim.keymap.set('n', '<M-h>', '<cmd>TmuxNavigateLeft<cr>')
      vim.keymap.set('n', '<M-j>', '<cmd>TmuxNavigateDown<cr>')
      vim.keymap.set('n', '<M-k>', '<cmd>TmuxNavigateUp<cr>')
      vim.keymap.set('n', '<M-l>', '<cmd>TmuxNavigateRight<cr>')

      -- [테마 설정]
      safe_require("tokyonight", function(tokyonight)
        tokyonight.setup({
          style = "moon", -- storm, night, moon, day
          transparent = true,
          styles = {
            sidebars = "transparent",
            floats = "transparent",
          },
        })
        vim.cmd.colorscheme "tokyonight"
      end)

      -- [Lualine 설정]
      safe_require("lualine", function(lualine)
        lualine.setup { options = { theme = 'tokyonight' } }
      end)

      -- [Bufferline 설정]
      safe_require("bufferline", function(bufferline)
        bufferline.setup{}
      end)

      -- [Gitsigns 설정]
      safe_require("gitsigns", function(gitsigns)
        gitsigns.setup()
      end)

      -- [Indent Blankline 설정]
      safe_require("ibl", function(ibl)
        ibl.setup()
      end)

      -- [Oil.nvim 설정]
      safe_require("oil", function(oil)
        oil.setup()
        vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      end)

      -- [Comment.nvim 설정]
      safe_require("Comment", function(comment)
        comment.setup()
      end)

      -- [nvim-autopairs 설정]
      safe_require("nvim-autopairs", function(autopairs)
        autopairs.setup()
      end)

      -- [Trouble 설정]
      safe_require("trouble", function(trouble)
        vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>")
      end)

      -- [ast-grep (sg.nvim) 설정]
      safe_require("sg", function(sg)
        sg.setup()
      end)

      -- [Neo-tree 키맵]
      vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })

      -- [Telescope 키맵]
      safe_require("telescope.builtin", function(builtin)
        vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>ss', builtin.spell_suggest, {})
      end)

      -- [Treesitter 설정]
      safe_require("nvim-treesitter.configs", function(configs)
        configs.setup {
          highlight = { enable = true },
          indent = { enable = true },
        }
      end)

      -- [LSP & Autocomplete 설정]
      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        cmp.setup({
          snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
          mapping = cmp.mapping.preset.insert({
            ['<C-b>'] = cmp.mapping.scroll_docs(-4),
            ['<C-f>'] = cmp.mapping.scroll_docs(4),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<CR>'] = cmp.mapping.confirm({ select = true }),
          }),
          sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          }, {
            { name = 'buffer' },
            { name = 'path' },
          })
        })
      end

      local lsp_ok, lspconfig = pcall(require, "lspconfig")
      if lsp_ok then
        local capabilities = {}
        local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
        if cmp_lsp_ok then
          capabilities = cmp_nvim_lsp.default_capabilities()
        end
        
        -- 사용 중인 언어 서버들 활성화
        local servers = { 'gopls', 'clangd', 'nil_ls' }
        for _, lsp in ipairs(servers) do
          lspconfig[lsp].setup { capabilities = capabilities }
        end
      end
    '';
  };
}

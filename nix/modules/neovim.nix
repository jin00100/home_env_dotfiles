{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;
    # wrapRc = true;  <-- 이 줄을 삭제하거나 주석 처리하세요.

    # Lua 라이브러리 추가 (jsregexp 등)
    extraLuaPackages = ps: [ ps.jsregexp ];

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
      mini-nvim         # mini.icons 등
      oil-nvim          # 파일 관리
      comment-nvim      # 주석
      nvim-autopairs    # 괄호 자동완성
      trouble-nvim      # 에러 목록
      toggleterm-nvim   # 터미널 관리 (Ctrl+/)
      lazygit-nvim      # Lazygit 통합
      
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
      vim.opt.laststatus = 3        -- 전역 상태줄 (Global Statusline)
      vim.opt.cmdheight = 1         -- 커맨드 라인 높이 유지

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

      -- [ToggleTerm 설정]
      safe_require("toggleterm", function(toggleterm)
        toggleterm.setup({
          open_mapping = [[<C-/>]], -- Ctrl+/ (일부 터미널에서는 <C-_>)
          direction = 'float',      -- float, horizontal, vertical 중 선택 가능
          float_opts = {
            border = 'curved',
          }
        })
        -- Ctrl+/ 와 Ctrl+_ 모두 매핑 (터미널 호환성)
        vim.keymap.set({'n', 't'}, '<C-/>', '<cmd>ToggleTerm<cr>', {desc = "Toggle terminal"})
        vim.keymap.set({'n', 't'}, '<C-_>', '<cmd>ToggleTerm<cr>', {desc = "Toggle terminal"})
        
        -- 터미널 모드 전용 키맵
        function _G.set_terminal_keymaps()
          -- 터미널 모드에서 Esc를 눌렀을 때 노멀 모드로 전환하고 싶다면 아래 주석을 해제하세요.
          -- 하지만 lazygit 등에서 Esc를 써야 할 경우가 많으므로 기본적으로는 매핑하지 않습니다.
          -- local opts = {buffer = 0}
          -- vim.keymap.set('t', '<Esc><Esc>', [[<C-\><C-n>]], opts)
        end
        vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
      end)

      -- [Lazygit 설정]
      safe_require("lazygit", function(lazygit)
        vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Open LazyGit" })
      end)

      -- [Mini.icons 설정]
      safe_require("mini.icons", function(icons)
        icons.setup()
        icons.mock_nvim_web_devicons()
      end)

      -- [Luasnip 경고 무시 및 jsregexp 설정]
      -- Nix에서 라이브러리를 직접 빌드하기 힘드므로 특정 기능에 대한 경고를 우회합니다.
      safe_require("luasnip", function(luasnip)
        luasnip.config.set_config({
          history = true,
          updateevents = "TextChanged,TextChangedI",
          delete_check_events = "TextChanged",
        })
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

      -- [LSP & Autocomplete 설정 (Modern 0.11+)]
      local capabilities = {}
      local cmp_lsp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
      if cmp_lsp_ok then
        capabilities = cmp_nvim_lsp.default_capabilities()
      end

      -- 사용 중인 언어 서버들 목록 (packages.nix에 설치된 것들)
      local servers = { 'gopls', 'nil_ls' }

      -- Neovim 0.11+ 방식 (vim.lsp.config)
      if vim.lsp.config then
        for _, lsp in ipairs(servers) do
          vim.lsp.config(lsp, { capabilities = capabilities })
          vim.lsp.enable(lsp)
        end
        -- clangd 전용 안전 설정
        vim.lsp.config('clangd', {
          capabilities = capabilities,
          cmd = {
            "clangd",
            "--offset-encoding=utf-16",
          }
        })
        vim.lsp.enable('clangd')
      else
        -- Fallback: Neovim 0.10.x 이하 (nvim-lspconfig)
        local lsp_ok, lspconfig = pcall(require, "lspconfig")
        if lsp_ok then
          for _, lsp in ipairs(servers) do
            lspconfig[lsp].setup { capabilities = capabilities }
          end
        end
      end
    '';
  };
}

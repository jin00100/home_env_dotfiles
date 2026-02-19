{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;
    wrapRc = true; # (New) 기존 로컬 설정 파일과의 충돌을 원천 차단합니다.

    # 1. 플러그인 목록 (기존의 모든 플러그인을 그대로 유지합니다)
    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      vim-tmux-navigator 
      which-key-nvim 
      nvim-web-devicons
      lualine-nvim
      neo-tree-nvim
      nui-nvim 
      plenary-nvim
      telescope-nvim
      nvim-treesitter.withAllGrammars # (Update) 모든 문법을 포함하여 에러를 방지합니다.
    ];

    # 2. Lua 설정 (기존 설정을 모두 포함하되, 더 안전하게 배치했습니다)
    initLua = ''
      -- 안전한 설정을 위한 헬퍼 함수
      local function safe_require(module, config_fn)
        local ok, mod = pcall(require, module)
        if ok then config_fn(mod) end
      end

      -- [기본 옵션] (기존 설정 그대로 유지)
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
      vim.g.mapleader = " "         
      vim.opt.clipboard = "unnamedplus"
      vim.opt.termguicolors = true

      -- [테마 설정] (Catppuccin 설정 그대로 유지)
      safe_require("catppuccin", function(catppuccin)
        catppuccin.setup({
          flavour = "mocha",
          transparent_background = true,
        })
        vim.cmd.colorscheme "catppuccin"
      end)

      -- [Lualine 설정]
      safe_require("lualine", function(lualine)
        lualine.setup { options = { theme = 'catppuccin' } }
      end)

      -- [Neo-tree 키맵]
      vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })

      -- [Telescope 키맵]
      safe_require("telescope.builtin", function(builtin)
        vim.keymap.set('n', '<leader>f', builtin.find_files, {})
        vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
      end)

      -- [Treesitter 설정] (에러 방지용 최적화 설정)
      safe_require("nvim-treesitter.configs", function(configs)
        configs.setup {
          highlight = { enable = true },
          indent = { enable = true },
        }
      end)
    '';
  };
}

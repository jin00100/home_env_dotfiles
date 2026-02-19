{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; vimAlias = true;

    # 1. 플러그인 목록 (설정 코드 제거하고 순수하게 목록만 유지)
    plugins = with pkgs.vimPlugins; [
      # UI 및 편의 기능
      vim-tmux-navigator 
      which-key-nvim 
      nvim-web-devicons
      lualine-nvim
      neo-tree-nvim
      nui-nvim 
      plenary-nvim
      telescope-nvim
      
      # 구문 강조 (에러 원인이었던 녀석)
      nvim-treesitter.withAllGrammars
    ];

    # 2. Lua 설정 통합 (여기서 플러그인 설정을 안전하게 실행)
    initLua = ''
      -- [기본 설정]
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.tabstop = 4
      vim.opt.shiftwidth = 4
      vim.opt.expandtab = true
      vim.g.mapleader = " "         
      vim.opt.clipboard = "unnamedplus"

      -- [플러그인 설정]
      -- pcall(protected call)로 감싸서, 플러그인 로드 실패 시에도 Neovim이 죽지 않게 함

      -- 1. Lualine (상태바)
      local status_ok, lualine = pcall(require, "lualine")
      if status_ok then
        lualine.setup { options = { theme = 'auto' } }
      end

      -- 2. Neo-tree (파일 탐색기)
      -- Ctrl+n 키맵핑
      vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })

      -- 3. Telescope (파일 찾기)
      local status_ok, telescope_builtin = pcall(require, "telescope.builtin")
      if status_ok then
        vim.keymap.set('n', '<leader>f', telescope_builtin.find_files, {})
        vim.keymap.set('n', '<leader>g', telescope_builtin.live_grep, {})
      end

      -- 4. Treesitter (구문 강조) - 에러 수정 핵심!
      local status_ok, configs = pcall(require, "nvim-treesitter.configs")
      if status_ok then
        configs.setup {
          highlight = { enable = true },
          indent = { enable = true },  -- 들여쓰기도 개선됨
        }
      end
    '';
  };
}

{ config, pkgs, inputs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withRuby = false;
    withPython3 = false;

    # Lua 라이브러리 추가 (jsregexp 등)
    extraLuaPackages = ps: [ ps.jsregexp ];

    # 1. 플러그인 목록
    plugins = with pkgs.vimPlugins; [
      tokyonight-nvim
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
      nvim-osc52        # SSH 클립보드 (OSC 52) 지원
      
      # Modern UI / Notification
      noice-nvim
      nvim-notify
      
      # LSP & Completion
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      friendly-snippets # 사전 정의된 스니펫 모음
      
      # Colorscheme
      catppuccin-nvim

      # Markdown Rendering
      markview-nvim

      # Smooth Cursor
      (pkgs.vimUtils.buildVimPlugin {
        name = "smoothcursor-nvim";
        src = inputs.smoothcursor;
      })
    ];

    # 2. Lua 설정
    initLua = ''
      require('utils')
      require('options')
      require('keymaps')
      require('plugins')
    '';
  };

  # 3. Lua 모듈들을 ~/.config/nvim/lua/ 경로에 배치
  xdg.configFile = {
    "nvim/lua/utils.lua".source = ./nvim/lua/utils.lua;
    "nvim/lua/options.lua".source = ./nvim/lua/options.lua;
    "nvim/lua/keymaps.lua".source = ./nvim/lua/keymaps.lua;
    "nvim/lua/plugins.lua".source = ./nvim/lua/plugins.lua;
  };
}

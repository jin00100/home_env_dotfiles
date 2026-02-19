# Nix Home Manager Ultimate Setup (Jetpack Edition)

## 1. 개요

이 문서는 Nix Home Manager를 사용하여 리눅스 개발 환경을 구축하는 최종 가이드이다.
Native Linux(Ubuntu)와 WSL 환경을 하나의 코드베이스로 관리하며, Starship(Jetpack) 테마와 Tmux/Neovim 생산성 도구가 완벽하게 통합되어 있다.

**주요 기능:**
- **Core:** Nix Flakes + Home Manager (Modular Structure)
- **Shell:** Zsh + Starship (Jetpack) + Eza + Zoxide + Bat + FZF
- **Editor:** Neovim (LSP, Treesitter, Telescope, Neo-tree)
- **Terminal:** Tmux (Prefix Ctrl+g, Vim-Navigator, Auto-start)
- **Auto-Install:** Node.js (LTS), Gemini CLI, Ghostty (Native Only)

## 2. 디렉토리 구조

설정 파일은 기능별로 모듈화되어 `nix/modules` 내부에 위치한다.

```text
~/dotfiles
├── flake.nix             # [Entry] OS 환경(Native/WSL) 구분
├── nix
│   ├── home.nix          # [Main] 모듈 로더 및 기본 설정
│   └── modules
│       ├── git.nix       # Git 사용자 설정
│       ├── neovim.nix    # Neovim 플러그인 및 설정
│       ├── packages.nix  # 시스템 패키지 & 설치 스크립트
│       ├── shell.nix     # Zsh, Starship, Alias, Tmux 실행 로직
│       ├── starship.toml # Starship 테마 설정 (Jetpack)
│       └── tmux.nix      # Tmux 옵션 및 키바인딩
└── .gitignore
```

## 3. 파일별 상세 코드

### 3.1 ~/dotfiles/flake.nix

```nix
{
  description = "Home Manager configuration for yongminari";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations = {
        # 1. Native Linux
        "yongminari" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./nix/home.nix ];
          extraSpecialArgs = { isWSL = false; };
        };
        # 2. WSL
        "yongminari-wsl" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./nix/home.nix ];
          extraSpecialArgs = { isWSL = true; };
        };
      };
    };
}
```

### 3.2 ~/dotfiles/nix/home.nix

```nix
{ config, pkgs, ... }:

{
  home.username = "yongminari";
  home.homeDirectory = "/home/yongminari";
  home.stateVersion = "25.11"; 

  # 모듈 로드
  imports = [
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/tmux.nix
    ./modules/git.nix
  ];

  programs.home-manager.enable = true;
}
```

### 3.3 ~/dotfiles/nix/modules/packages.nix

```nix
{ config, pkgs, lib, isWSL, ... }:

{
  home.sessionVariables = {
    NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  };
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.packages = with pkgs; [
    # 유틸
    neofetch htop ripgrep fd unzip xclip lsb-release
    
    # 개발 도구
    nodejs          # Node.js LTS
    clang-tools cmake gnumake go gopls

    # 폰트
    maple-mono.NF nerd-fonts.ubuntu-mono 

  ] ++ (lib.optionals (!isWSL) [
    ghostty # WSL이 아닐 때만 설치
  ]);

  # Gemini CLI 자동 설치 스크립트
  home.activation.installGeminiCli = lib.hm.dag.entryAfter ["writeBoundary"] ''
    npm_global_dir="${config.home.homeDirectory}/.npm-global"
    mkdir -p "$npm_global_dir"
    export PATH="${pkgs.nodejs}/bin:$npm_global_dir/bin:$PATH"

    if ! command -v gemini &> /dev/null; then
      echo "Installing @google/gemini-cli..."
      npm install -g --prefix "$npm_global_dir" @google/gemini-cli
    fi
  '';
}
```

### 3.4 ~/dotfiles/nix/modules/shell.nix

```nix
{ config, pkgs, lib, ... }:

{
  # Starship (테마 파일 로드)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ./starship.toml;
  };

  # Modern Tools
  programs.eza = { enable = true; enableZshIntegration = true; icons = "auto"; git = true; };
  programs.zoxide = { enable = true; enableZshIntegration = true; options = [ "--cmd cd" ]; };
  programs.bat = { enable = true; config = { theme = "Dracula"; }; };
  programs.fzf = { enable = true; enableZshIntegration = true; };

  # Zsh 설정
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "virtualenv" "history-substring-search" ];
    };

    shellAliases = {
      ls = "eza";
      ll = "eza -l --icons --git -a";
      lt = "eza --tree --level=2 --long --icons --git";
      cat = "bat";
      tocb = "xclip -selection clipboard";
      
      hms = "home-manager switch --flake ~/dotfiles/#yongminari";
      hms-wsl = "home-manager switch --flake ~/dotfiles/#yongminari-wsl";
      vi = "nvim"; vim = "nvim";
    };

    initContent = ''
      export PATH=$HOME/.local/bin:$PATH
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # Pyenv 초기화 (설치된 경우만)
      if command -v pyenv &>/dev/null; then
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
      fi

      # ---------------------------------------------------------
      # Welcome Message (Tmux 내부일 때만)
      # ---------------------------------------------------------
      if [[ -n "$TMUX" ]]; then
        echo "\x1b[40;1;31m
      __      __        .__                       ._. \x1b[40;1;31m $(lsb_release -d 2>/dev/null || echo "Linux")
     /  \    /  \ ____ |  |    ____  ____   _____    ____| | \x1b[40;1;33m HOST       :      $(uname -n)
     \   \/\/   // __ \|  | _/ ___\/  _ \ /     \_/ __ \ | \x1b[40;1;34m Kernel     :      $(uname -r)
      \        /\  ___/|  |_\  \__(  <_> )  Y Y  \  ___/\| \x1b[40;1;35m Date       :      $(date)
       \__/\  /  \___  >____/\___  >____/|__|_|  /\___  >_ \x1b[40;1;36m Shell      :      $(zsh --version | awk '{print $1, $2}')
            \/        \/           \/            \/      \/\/ \x1b[40;1;37m Who        :      $(whoami)
    \x1b[0m"
        echo "Welcome to \x1b[94mZsh\x1b[94m, \x1b[1m$USER!\x1b[0m"
        echo "Current directory: \x1b[1m$(pwd)\x1b[0m"
      fi

      # ---------------------------------------------------------
      # Tmux 자동 실행 (VS Code 및 중복 실행 방지)
      # ---------------------------------------------------------
      function is_vscode() {
        if [[ -n "$VSCODE_IPC_HOOK_CLI" || -n "$VSCODE_PID" || "$TERM_PROGRAM" == "vscode" ]]; then
          return 0
        else
          return 1
        fi
      }

      if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && ! is_vscode; then
        exec tmux
      fi
    '';
  };
}
```

### 3.5 ~/dotfiles/nix/modules/neovim.nix

```nix
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; vimAlias = true;

    plugins = with pkgs.vimPlugins; [
      vim-tmux-navigator which-key-nvim nvim-web-devicons
      { plugin = lualine-nvim; config = "require('lualine').setup { options = { theme = 'auto' } }"; type = "lua"; }
      { plugin = neo-tree-nvim; config = "vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })"; type = "lua"; }
      nui-nvim plenary-nvim
      { plugin = telescope-nvim; config = "local b=require('telescope.builtin'); vim.keymap.set('n','<leader>f',b.find_files,{}); vim.keymap.set('n','<leader>g',b.live_grep,{})"; type = "lua"; }
      { plugin = nvim-treesitter.withAllGrammars; config = "require('nvim-treesitter.configs').setup { highlight = { enable = true } }"; type = "lua"; }
    ];

    initLua = ''
      vim.opt.number = true; vim.opt.relativenumber = true
      vim.opt.tabstop = 4; vim.opt.shiftwidth = 4; vim.opt.expandtab = true
      vim.g.mapleader = " "; vim.opt.clipboard = "unnamedplus"
    '';
  };
}
```

### 3.6 ~/dotfiles/nix/modules/tmux.nix

```nix
{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-g";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    customPaneNavigationAndResize = true;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      { plugin = tmuxPlugins.power-theme; extraConfig = "set -g @tmux_power_theme 'coral'"; }
    ];
    extraConfig = ''
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}
```

### 3.7 ~/dotfiles/nix/modules/git.nix

```nix
{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    settings = {
      user = { name = "yongminari"; email = "easyid21c@gmail.com"; };
      init.defaultBranch = "master";
    };
  };
}
```

## 4. 설치 및 적용 방법
... (기존 내용) ...

## 5. 핵심 이슈 해결 (Troubleshooting)

### 5.1 Experimental Features 활성화 에러
`home-manager switch` 명령 시 `error: experimental Nix feature 'nix-command' is disabled` 에러가 발생하면, Nix 설정 파일에 Flakes 기능을 명시적으로 허용해야 한다.

- **해결법:**
  ```bash
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  # 멀티 유저 설치인 경우 sudo 필요할 수 있음
  # sudo vi /etc/nix/nix.conf
  ```

### 5.2 기본 셸 전환 (chsh) 및 경로 문제
Nix를 통해 설치한 Zsh는 `/usr/bin/zsh`가 아닌 사용자 프로필 경로(`~/.nix-profile/bin/zsh`)에 위치한다. 이 경로를 `/etc/shells`에 등록해야 `chsh` 명령이 정상 작동한다.

- **해결법:**
  ```bash
  # 1. Nix Zsh 경로 추출
  NIX_ZSH_PATH=$(which zsh)

  # 2. 시스템 허용 셸 목록에 등록
  sudo sh -c "echo $NIX_ZSH_PATH >> /etc/shells"

  # 3. 기본 셸 변경
  chsh -s $NIX_ZSH_PATH
  ```
  *참고: WSL의 경우 설치된 배포판에 따라 `/etc/shells` 수동 수정이 필수적일 수 있다.*


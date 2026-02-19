# Nix Home Manager Ultimate Setup (Jetpack Edition)

## 1. 개요

이 문서는 Nix Home Manager를 사용하여 리눅스 개발 환경을 구축하는 최종 가이드이다.
Native Linux(Ubuntu 등)와 WSL 환경을 하나의 코드베이스로 관리하며, Starship(Jetpack) 테마와 Tmux/Neovim 생산성 도구가 완벽하게 통합되어 있다.

**주요 기능:**
- **Core:** Nix Flakes + Home Manager (Modular Structure)
- **Shell:** Zsh + Starship (Jetpack) + Eza + Zoxide + Bat + FZF
- **Editor:** Neovim (LSP, Treesitter, Telescope, Neo-tree)
- **Terminal:** Tmux (Prefix Ctrl+g, Vim-Navigator, Auto-start)
- **Auto-Install:** Node.js (LTS), Gemini CLI, Tree-sitter CLI
- **Dev Tools:** gcc, clang, make, cmake, go, gopls

## 2. 필수 사전 준비 (Manual Steps)

### 2.1 Ghostty 터미널 설치 (수동)
Ghostty는 최신 터미널 에뮬레이터로, 아직 패키지 매니저에 안정적으로 포함되지 않은 경우가 많아 직접 설치를 권장한다.

1.  **다운로드:** [Ghostty 공식 웹사이트](https://ghostty.org/download) 또는 GitHub Release 페이지에서 자신의 OS에 맞는 버전을 다운로드한다.
2.  **설치 (Ubuntu/Debian 예시):**
    ```bash
    # 다운로드 받은 .deb 파일이 있는 경로로 이동
    sudo dpkg -i ghostty_*.deb
    sudo apt-get install -f # 의존성 문제 발생 시 해결
    ```
3.  **설정 파일:**
    Home Manager가 `~/.config/ghostty/config` 파일을 자동으로 생성 관리하므로, 별도의 설정 파일을 수동으로 만들 필요는 없다. (설정 내용은 `nix/home.nix` 참조)

### 2.2 Nix 설치 (Multi-user)
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### 2.3 Experimental Features 활성화
Flakes 기능을 사용하기 위해 필수적이다.
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

## 3. 디렉토리 구조

설정 파일은 기능별로 모듈화되어 `nix/modules` 내부에 위치한다.

```text
~/home_env_dotfiles
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

## 4. 파일별 상세 코드

### 4.1 ~/home_env_dotfiles/flake.nix
Native Linux와 WSL 환경을 구분하여 Home Manager 설정을 로드한다.

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

### 4.2 ~/home_env_dotfiles/nix/home.nix
모든 모듈을 임포트하고 공통 설정을 관리한다. Ghostty 설정도 여기서 관리된다.

```nix
{ config, pkgs, ... }:

{
  home.username = "yongminari";
  home.homeDirectory = "/home/yongminari";
  home.stateVersion = "25.11"; 

  imports = [
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/tmux.nix
    ./modules/git.nix
  ];

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  # Ghostty 설정
  xdg.configFile."ghostty/config".text = ''
    font-family = "Maple Mono NF"
    font-size = 12
    window-width = 120
    window-height = 60
    window-decoration = auto
    background-opacity = 0.85
    theme = Dracula
  '';

  programs.home-manager.enable = true;
}
```

### 4.3 ~/home_env_dotfiles/nix/modules/packages.nix
필수 패키지와 개발 도구를 설치한다. `gemini-cli`와 `tree-sitter-cli` 자동 설치 스크립트가 포함되어 있다.

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
    # [시스템 유틸]
    neofetch htop ripgrep fd unzip lazygit
    lsb-release
    xclip xsel wl-clipboard 
    
    # [개발 도구]
    nodejs
    gcc clang binutils pkg-config # Essential Build Tools
    clang-tools cmake gnumake go gopls
    
    # 폰트
    maple-mono.NF nerd-fonts.ubuntu-mono 
  ];

  # [Gemini CLI & Tree-sitter CLI 자동 설치]
  home.activation.installGeminiCli = lib.hm.dag.entryAfter ["writeBoundary"] ''
    npm_global_dir="${config.home.homeDirectory}/.npm-global"
    mkdir -p "$npm_global_dir"
    export PATH="${pkgs.nodejs}/bin:$npm_global_dir/bin:$PATH"

    if ! command -v gemini &> /dev/null; then
      echo "Installing @google/gemini-cli..."
      npm install -g --prefix "$npm_global_dir" @google/gemini-cli
    fi

    if ! command -v tree-sitter &> /dev/null; then
      echo "Installing tree-sitter-cli..."
      npm install -g --prefix "$npm_global_dir" tree-sitter-cli
    fi
  '';
}
```

### 4.4 ~/home_env_dotfiles/nix/modules/neovim.nix
Neovim 설정. `tree-sitter-cli` 에러 해결을 위해 `packages.nix`에서 CLI 도구를 설치하고, 여기서는 플러그인과 Lua 설정을 관리한다.

```nix
{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true; 
    vimAlias = true;

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
      nvim-treesitter.withAllGrammars 
    ];

    initLua = ''
      -- (생략: Lua 설정 코드, GitHub 레포지토리 참조)
      -- 핵심: Treesitter, Telescope, Neo-tree, Catppuccin 테마 설정
    '';
  };
}
```

### 4.5 ~/home_env_dotfiles/nix/modules/shell.nix
Zsh, Starship, Eza, Bat, FZF 등 쉘 환경 설정. Tmux 자동 실행 로직이 포함됨.

```nix
{ config, pkgs, lib, ... }:

{
  # ... Starship, Eza, Zoxide, Bat, FZF 설정 ...

  programs.zsh = {
    enable = true;
    # ... Oh-My-Zsh 및 플러그인 설정 ...
    shellAliases = {
      ls = "eza";
      ll = "eza -l --icons --git -a";
      lt = "eza --tree --level=2 --long --icons --git";
      cat = "bat";
      tocb = "xclip -selection clipboard"; # 클립보드 복사
      hms = "home-manager switch --flake ~/home_env_dotfiles/#yongminari";
      hms-wsl = "home-manager switch --flake ~/home_env_dotfiles/#yongminari-wsl";
      vi = "nvim"; vim = "nvim";
    };
    initContent = ''
      # ... Tmux 자동 실행 및 Welcome Message 스크립트 ...
    '';
  };
}
```

### 4.6 ~/home_env_dotfiles/nix/modules/tmux.nix
Tmux 설정. 클립보드 연동(OSC 52) 및 Vim Navigator 설정 포함.

```nix
{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-g";
    # ... 마우스, vi 모드, 플러그인 설정 ...
    extraConfig = ''
      # 클립보드 연동 (xclip/wl-copy)
      # Vim-Tmux Navigator 키바인딩
    '';
  };
}
```

## 5. 설치 및 적용

```bash
# 1. 레포지토리 클론 (또는 다운로드)
git clone <YOUR_REPO_URL> ~/home_env_dotfiles
cd ~/home_env_dotfiles

# 2. Home Manager 적용
# Native Linux
home-manager switch --flake .#yongminari

# WSL
home-manager switch --flake .#yongminari-wsl
```

## 6. 트러블슈팅

- **`tree-sitter-cli` 버전 에러:** Neovim 구동 시 에러가 발생하면 `home-manager switch`를 다시 실행하여 최신 `tree-sitter-cli`가 NPM을 통해 설치되도록 한다.
- **GPU Warning:** "Non-NixOS system..." 경고는 무시해도 되며, 필요 시 경고 메시지에 나온 명령어를 `sudo`로 실행한다.
- **폰트 깨짐:** 터미널(Ghostty 등) 폰트를 `Maple Mono NF` 또는 `UbuntuMono Nerd Font`로 설정했는지 확인한다.

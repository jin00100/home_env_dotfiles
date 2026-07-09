{ config, pkgs, lib, ... }:

{
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
  ];

  home.packages = with pkgs; [
    # [시스템 유틸 및 CLI 도구]
    wget
    curl
    gum
    jq
    btop
    ripgrep
    fd
    unzip
    rsync
    inotify-tools
    xclip
    wl-clipboard
    eza
    bat
    fastfetch
    figlet
    htop
    fzf
    libnotify

    # [Ported & Modern Rust Utils]
    lazygit
    lolcat
    lsb-release
    xsel
    ncdu
    duf
    tldr
    yq-go

    # [DevOps & Nix Native Tools]
    procs
    gping
    dust
    nix-output-monitor
    nix-index
    nix-tree
    rclone
    # [Neovim 보조 도구 (LSP/Parsers)]
    # 에디터 경험을 위해 가벼운 서버들만 유지
    tree-sitter   # Tree-sitter CLI (Fix checkhealth error)
    nil           # Nix Language Server
    ast-grep      # ast-grep CLI
    lua51Packages.jsregexp # Luasnip dependency
    gopls         # Go LSP
    clang-tools   # clangd 등 (헤더 검색 등 에디터용)
    yaml-language-server              # YAML LSP
    nodePackages.bash-language-server # Bash LSP
    dockerfile-language-server        # Dockerfile LSP

    # 폰트
    maple-mono.NF
    nerd-fonts.ubuntu-mono 
    monaspace
    nerd-fonts.jetbrains-mono
    fnm
  ];
}

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
    lsb-release   # (New) 웰컴 메시지에서 OS 정보 출력용
    xclip xsel wl-clipboard 
    
    # [개발 도구]
    nodejs
    gcc
    clang
    binutils
    pkg-config
    clang-tools cmake gnumake go gopls
    
    # (선택) Pyenv가 꼭 필요하다면 추가 (Nix에서는 보통 shell.nix로 대체함)
    # pyenv 

    # 폰트
    maple-mono.NF nerd-fonts.ubuntu-mono 

  ];

  # [Gemini CLI 자동 설치]
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

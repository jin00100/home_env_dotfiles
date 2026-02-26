{ config, pkgs, ... }:

{
  # [사용자 정보]
  home.username = "yongminari";
  home.homeDirectory = "/home/yongminari";
  home.stateVersion = "25.11"; 

  # [모듈 로드] 기능별 파일들을 여기서 불러옴
  imports = [
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/tmux.nix
    ./modules/zellij.nix
    ./modules/git.nix
  ];

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  # [Ghostty 설정 관리]
  # 직접 설치하신 Ghostty가 이 파일을 읽게 됩니다.
  xdg.configFile."ghostty/config".text = ''
    # Fonts
    font-family = "Maple Mono NF"
    font-size = 12

    # Window
    window-width = 150
    window-height = 60
    window-decoration = auto
    background-opacity = 0.85

    # Theme
    theme = Dracula
  '';

  programs.home-manager.enable = true;
}

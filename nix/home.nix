{ config, pkgs, ... }:

{
  # [사용자 정보]
  home.username = "jin";
  home.homeDirectory = "/home/jin";
  home.stateVersion = "25.11"; 

  # [모듈 로드] 기능별 파일들을 여기서 불러옴
  imports = [
    ./modules/shell.nix
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/zellij.nix
    ./modules/git.nix
    ./modules/ghostty.nix
  ];

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;
}

{ config, pkgs, lib, ... }:

{
  # 1. Starship 프롬프트 (테마 파일 로드)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # 같은 폴더의 starship.toml 파일을 읽어서 적용
    settings = lib.importTOML ./starship.toml;
  };

  # 2. Zsh 설정
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "virtualenv" "history-substring-search" ];
    };

    initContent = ''
      export PATH=$HOME/.local/bin:$PATH
      
      # Alias
      alias ll="ls -al"
      alias hms="home-manager switch --flake ~/dotfiles/#yongminari" 
      alias hms-wsl="home-manager switch --flake ~/dotfiles/#yongminari-wsl"
      alias vi="nvim"
      alias vim="nvim"

      # History Search 키바인딩
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down
    '';
  };
}

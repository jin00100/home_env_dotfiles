{ config, pkgs, lib, ... }:

{
  # 1. Starship 프롬프트
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
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

    # [여기가 핵심입니다]
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

      # ---------------------------------------------------------
      # [Tmux 자동 실행 설정]
      # ---------------------------------------------------------
      # 1. 대화형 쉘인지 확인 ($- string에 i가 포함되어 있는지)
      # 2. 이미 Tmux 안이 아닌지 확인 ($TMUX 변수가 비어있어야 함)
      # 3. VS Code 터미널이 아닌지 확인 ($TERM_PROGRAM != "vscode")
      # ---------------------------------------------------------
      if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ "$TERM_PROGRAM" != "vscode" ]]; then
        # exec: 현재 쉘을 tmux로 '교체'합니다. (tmux 끄면 터미널도 꺼짐)
        exec tmux
      fi
    '';
  };
}

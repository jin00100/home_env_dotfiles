{ config, pkgs, lib, ... }:

{
  # 1. Starship 프롬프트
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ./starship.toml;
  };

  # 2. Eza (ls 대체)
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # 3. Zoxide (cd 대체)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  # 4. [New] Bat (cat 대체 - Syntax Highlight)
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula"; # 원하는 테마 설정 가능
    };
  };

  # 5. [New] FZF (Fuzzy Finder)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Ctrl+R(히스토리), Ctrl+T(파일찾기) 활성화
  };

  # 6. Zsh 설정
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
      
      # [New] cat -> bat 매핑
      cat = "bat";
      
      # [New] 클립보드 복사 Alias
      tocb = "xclip -selection clipboard";

      hms = "home-manager switch --flake ~/home_env_dotfiles/#yongminari";
      hms-wsl = "home-manager switch --flake ~/home_env_dotfiles/#yongminari-wsl";
      vi = "nvim";
      vim = "nvim";
    };

    initContent = ''
      export PATH=$HOME/.local/bin:$PATH

      # History Search 키바인딩
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # [New] Pyenv 초기화 (설치되어 있을 경우에만)
      if command -v pyenv &>/dev/null; then
        eval "$(pyenv init -)"
        eval "$(pyenv virtualenv-init -)"
      fi

      # ---------------------------------------------------------
      # [New] Welcome Message for Tmux Sessions
      # ---------------------------------------------------------
      if [[ -n "$TMUX" ]]; then
        echo "\x1b[40;1;31m
      __      __        .__                              ._. \x1b[40;1;31m $(lsb_release -d 2>/dev/null || echo "Linux")
     /  \    /  \ ____ |  |    ____  ____   _____    ____| | \x1b[40;1;33m HOST       :      $(uname -n)
     \   \/\/   // __ \|  | _/ ___\/  _ \ /     \_/ __ \ | \x1b[40;1;34m   Kernel     :      $(uname -r)
      \        /\  ___/|  |_\  \__(  <_> )  Y Y  \  ___/\| \x1b[40;1;35m   Date       :      $(date)
       \__/\  /  \___  >____/\___  >____/|__|_|  /\___  >_ \x1b[40;1;36m   Shell      :      $(zsh --version | awk '{print $1, $2}')
            \/       \/          \/            \/     \/\/ \x1b[40;1;37m   Who        :      $(whoami)
    \x1b[0m"
        echo "Welcome to \x1b[94mZsh\x1b[94m, \x1b[1m$USER!\x1b[0m You are on $HOSTNAME."
        echo "Current directory: \x1b[1m$(pwd)\x1b[0m"
      fi

      # ---------------------------------------------------------
      # [New] Tmux 자동 실행 (VS Code 감지 강화)
      # ---------------------------------------------------------
      # VS Code 내부인지 확인하는 함수
      function is_vscode() {
        if [[ -n "$VSCODE_IPC_HOOK_CLI" || -n "$VSCODE_PID" || "$TERM_PROGRAM" == "vscode" ]]; then
          return 0
        else
          return 1
        fi
      }

      # 대화형 쉘 + Tmux 밖 + VSCode 아님 -> Tmux 실행
      if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && ! is_vscode; then
        exec tmux
      fi
    '';
  };
}

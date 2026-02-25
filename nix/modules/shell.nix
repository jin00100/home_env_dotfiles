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

  # 6. [New] Direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # 7. Zsh 설정
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
      vi = "nvim";
      vim = "nvim";
    };

    initContent = ''
      # [추가] fnm 초기화 코드 (fnm이 설치되어 있다면 실행)
      if command -v fnm &>/dev/null; then
        eval "$(fnm env --use-on-cd --shell zsh)"
      fi

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
        # 줄바꿈 비활성화 (너비 넘어가면 자름)
        printf "\e[?7l"

        # 아스키 아트 본체 (lolcat 옵션 조절로 파스텔 톤 느낌 구현)
        # -F: 빈도(낮을수록 완만함), -p: 퍼짐(클수록 부드러움)
        cat << 'EOF' | lolcat #-f -F 0.15 -p 1.5
                                                                                                               
 ███        █████ █████   █████    █████   ████   ████████  █████   █████ ████ █████   ████   ██████   ████████   ████
░░░███     ░░███ ░░███  ███░░░███ ░░█████ ░░██   ███░░░░███░░█████ █████ ░░██ ░░█████ ░░██   ██░░░░██ ░░██░░░░██ ░░██ 
  ░░░███    ░░███ ███  ███   ░░███ ░██░███ ░██  ███    ░░░  ░██░█████░██  ░██  ░██░███ ░██  ░██   ░██  ░██   ░██  ░██ 
    ░░░███   ░░█████  ░███    ░███ ░██░░███░██ ░███         ░██░░███ ░██  ░██  ░██░░███░██  ░████████  ░███████   ░██ 
     ███░     ░░███   ░███    ░███ ░██ ░░█████ ░███   █████ ░██ ░░░  ░██  ░██  ░██ ░░█████  ░██░░░░██  ░██░░░░██  ░██ 
   ███░        ░███   ░░███   ███  ░██  ░░████ ░░███ ░░███  ░██      ░██  ░██  ░██  ░░████  ░██   ░██  ░██   ░██  ░██ 
 ███░          █████   ░░░█████░   ████  ░░████ ░░████████  ████     ████ ████ ████  ░░████ ████  ████ ████  ████ ████
░░░           ░░░░░      ░░░░░    ░░░░    ░░░░   ░░░░░░░░░  ░░░░     ░░░░ ░░░░ ░░░░    ░░░░ ░░░░  ░░░░ ░░░░  ░░░░ ░░░░ 
                                                                                                                                        
EOF

        # 시스템 정보 출력 (ANSI 색상 적용)
        echo "\x1b[1;31m $(lsb_release -d 2>/dev/null | cut -f2 || echo "Linux")"
        echo "\x1b[1;33m HOST      : $(uname -n)"
        echo "\x1b[1;34m Kernel    : $(uname -r)"
        echo "\x1b[1;35m Date      : $(date +'%Y-%m-%d %H:%M:%S')"
        echo "\x1b[1;36m Shell     : $(zsh --version | awk '{print $1, $2}')"
        echo "\x1b[1;37m Who       : $(whoami)\x1b[0m"

        echo "\nWelcome to \x1b[94mZsh\x1b[94m, \x1b[1m$USER!\x1b[0m You are on $HOSTNAME."
        echo "Current directory: \x1b[1m$(pwd)\x1b[0m"

        # 줄바꿈 다시 활성화
        printf "\e[?7h"
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

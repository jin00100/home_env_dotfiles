{ config, pkgs, lib, ... }:

{
  # 1. Starship Prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = lib.importTOML ./starship.toml;
  };

  # 2. Eza (ls alternative)
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  # 3. Zoxide (cd alternative)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  # 4. [New] Bat (cat alternative - Syntax Highlight)
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula"; # You can set your preferred theme here
    };
  };

  # 5. [New] FZF (Fuzzy Finder)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # Enables Ctrl+R (History) and Ctrl+T (File Search)
  };

  # 6. [New] Direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # 7. Zsh Configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # [.zshenv] Loaded first (Terminal compatibility fallbacks)
    envExtra = ''
      # [Terminal Compatibility] Fallback to standard if xterm-ghostty terminfo is missing
      if [[ "$TERM" == "xterm-ghostty" ]] && ! command -v infocmp &>/dev/null; then
        export TERM=xterm-256color
      elif [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
        export TERM=xterm-256color
      fi
    '';

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # [Ghostty] Shell Integration (ONLY if running INSIDE Ghostty)
        if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
          if [[ -f "/usr/share/ghostty/shell-integration/zsh/ghostty-integration" ]]; then
            source "/usr/share/ghostty/shell-integration/zsh/ghostty-integration"
          elif [[ -f "$HOME/.nix-profile/share/ghostty/shell-integration/zsh/ghostty-integration" ]]; then
            source "$HOME/.nix-profile/share/ghostty/shell-integration/zsh/ghostty-integration"
          fi
        fi

        if [[ "$TERM" == "zellij" ]]; then
          export TERM=xterm-256color
          export ZELLIJ_SKIP_AUTOSTART=true
        fi

        # [SSH Detection] More robust check
        function is_ssh() {
          [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" || -n "$SSH_CONNECTION" ]] || \
          [[ "$(ps -o comm= -p $PPID 2>/dev/null)" == "sshd" ]]
        }
      '')
      ''
        # [Added] fnm initialization code
        if command -v fnm &>/dev/null; then
          eval "$(fnm env --use-on-cd --shell zsh)"
        fi

        export PATH=$HOME/.local/bin:$PATH

        # [Key Bindings] Enhancing bindings for broader terminal compatibility
        bindkey '^[[A' history-substring-search-up    # Arrow Up
        bindkey '^[[B' history-substring-search-down  # Arrow Down
        bindkey '^[OA' history-substring-search-up    # Arrow Up (Application Mode)
        bindkey '^[OB' history-substring-search-down  # Arrow Down (Application Mode)

        # [New] Pyenv initialization
        if command -v pyenv &>/dev/null; then
          eval "$(pyenv init -)"
          eval "$(pyenv virtualenv-init -)"
        fi

        # ---------------------------------------------------------
        # [New] Welcome Message for Zellij Sessions or SSH
        # ---------------------------------------------------------
        if [[ -n "$ZELLIJ" ]] || is_ssh; then
          # Disable line wrapping
          printf "\e[?7l"

          # Fast OS detection
          local os_name="Linux"
          if [[ -f /etc/os-release ]]; then
            os_name=$(grep PRETTY_NAME /etc/os-release | cut -d '"' -f2)
          fi

          # Determine which ASCII art to show
          if is_ssh; then
            # SSH: Always show the small version
            cat << 'EOF'
 █████   ███   █████          ████  ████    █████████                                             █████  ███            
░░███   ░███  ░░███          ░░███ ░░███   ███░░░░░███                                           ░░███  ░░░             
 ░███   ░███   ░███   ██████  ░███  ░███  ███     ░░░   ██████  █████████████    ██████           ░███  ████  ████████  
 ░███   ░███   ░███  ███░░███ ░███  ░███ ░███          ███░░███░░███░░███░░███  ███░░███          ░███ ░░███ ░░███░░███ 
 ░░███  █████  ███  ░███████  ░███  ░███ ░███         ░███ ░███ ░███ ░███ ░███ ░███████           ░███  ░███  ░███ ░███ 
  ░░░█████░█████░   ░███░░░   ░███  ░███ ░░███     ███░███ ░███ ░███ ░███ ░███ ░███░░░      ███   ░███  ░███  ░███ ░███ 
    ░░███ ░░███     ░░██████  █████ █████ ░░█████████ ░░██████  █████░███ █████░░██████    ░░████████   █████ ████ █████
     ░░░   ░░░       ░░░░░░  ░░░░░ ░░░░░   ░░░░░░░░░   ░░░░░░  ░░░░░ ░░░ ░░░░░  ░░░░░░      ░░░░░░░░   ░░░░░ ░░░░ ░░░░░ 
EOF
          elif command -v lolcat &>/dev/null; then
            # Local Zellij: Show large version with lolcat
            cat << 'EOF' | lolcat 
                                                                                                                 

 █████   ███   █████          ████  ████    █████████                                             █████  ███            
░░███   ░███  ░░███          ░░███ ░░███   ███░░░░░███                                           ░░███  ░░░             
 ░███   ░███   ░███   ██████  ░███  ░███  ███     ░░░   ██████  █████████████    ██████           ░███  ████  ████████  
 ░███   ░███   ░███  ███░░███ ░███  ░███ ░███          ███░░███░░███░░███░░███  ███░░███          ░███ ░░███ ░░███░░███ 
 ░░███  █████  ███  ░███████  ░███  ░███ ░███         ░███ ░███ ░███ ░███ ░███ ░███████           ░███  ░███  ░███ ░███ 
  ░░░█████░█████░   ░███░░░   ░███  ░███ ░░███     ███░███ ░███ ░███ ░███ ░███ ░███░░░      ███   ░███  ░███  ░███ ░███ 
    ░░███ ░░███     ░░██████  █████ █████ ░░█████████ ░░██████  █████░███ █████░░██████    ░░████████   █████ ████ █████
     ░░░   ░░░       ░░░░░░  ░░░░░ ░░░░░   ░░░░░░░░░   ░░░░░░  ░░░░░ ░░░ ░░░░░  ░░░░░░      ░░░░░░░░   ░░░░░ ░░░░ ░░░░░ 
EOF
          else
            # Local Zellij (no lolcat): Show small version
            cat << 'EOF'
 █████   ███   █████          ████  ████    █████████                                             █████  ███            
░░███   ░███  ░░███          ░░███ ░░███   ███░░░░░███                                           ░░███  ░░░             
 ░███   ░███   ░███   ██████  ░███  ░███  ███     ░░░   ██████  █████████████    ██████           ░███  ████  ████████  
 ░███   ░███   ░███  ███░░███ ░███  ░███ ░███          ███░░███░░███░░███░░███  ███░░███          ░███ ░░███ ░░███░░███ 
 ░░███  █████  ███  ░███████  ░███  ░███ ░███         ░███ ░███ ░███ ░███ ░███ ░███████           ░███  ░███  ░███ ░███ 
  ░░░█████░█████░   ░███░░░   ░███  ░███ ░░███     ███░███ ░███ ░███ ░███ ░███ ░███░░░      ███   ░███  ░███  ░███ ░███ 
    ░░███ ░░███     ░░██████  █████ █████ ░░█████████ ░░██████  █████░███ █████░░██████    ░░████████   █████ ████ █████
     ░░░   ░░░       ░░░░░░  ░░░░░ ░░░░░   ░░░░░░░░░   ░░░░░░  ░░░░░ ░░░ ░░░░░  ░░░░░░      ░░░░░░░░   ░░░░░ ░░░░ ░░░░░ 

EOF
          fi

          echo "\x1b[1;31m $os_name"
          echo "\x1b[1;33m HOST      : $(uname -n)"
          echo "\x1b[1;32m SESSION   : Zellij (Modern Terminal Workspace)"
          echo "\x1b[1;34m Kernel    : $(uname -r)"
          echo "\x1b[1;35m Date      : $(date +'%Y-%m-%d %H:%M:%S')"
          echo "\x1b[1;36m Shell     : $(zsh --version | awk '{print $1, $2}')"
          echo "\x1b[1;37m Who       : $(whoami)\x1b[0m"

          echo "\nWelcome to \x1b[94mZsh\x1b[94m, \x1b[1m$USER!\x1b[0m"

          # Re-enable line wrapping
          printf "\e[?7h"
        fi      

        # ---------------------------------------------------------
        # [New] Zellij Autostart
        # ---------------------------------------------------------
        function is_vscode() {
          [[ -n "$VSCODE_IPC_HOOK_CLI" || -n "$VSCODE_PID" || "$TERM_PROGRAM" == "vscode" ]]
        }

        # Interactive Shell + Outside Zellij + Not VSCode + Not SSH -> Autostart
        if [[ $- == *i* ]] && [[ -z "$ZELLIJ" ]] && [[ -z "$ZELLIJ_SKIP_AUTOSTART" ]] && ! is_vscode && ! is_ssh; then
          # Start a new session (prevents duplication)
          exec zellij
        fi
      ''
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "virtualenv" "history-substring-search" ];
    };

    shellAliases = {
      ls = "eza";
      ll = "eza -l --icons --git -a";
      lt = "eza --tree --level=2 --long --icons --git";
      
      # [New] cat -> bat mapping
      cat = "bat";
      
      # [New] Clipboard copy alias
      tocb = "xclip -selection clipboard";

      hms = "home-manager switch --flake ~/home_env_dotfiles/#default --impure";
      vi = "nvim";
      vim = "nvim";
      zj = "zellij";
      
      zj_shortcuts = ''echo -e "\033[1;34m=== Zellij Custom Shortcuts (Tmux Style) ===\033[0m" && \
                        echo -e "\033[1;33m[ Quick Actions (Alt Key) ]\033[0m" && \
                        echo "  Alt + n       : New Pane (Right)" && \
                        echo "  Alt + h/j/k/l : Move focus (Left/Down/Up/Right)" && \
                        echo "  Alt + i/o     : Move Tab (Prev/Next)" && \
                        echo "  Alt + =/-     : Resize Pane (Increase/Decrease)" && \
                        echo -e "\033[1;33m[ Core Modes (Prefix) ]\033[0m" && \
                        echo "  Ctrl + g      : LOCKED Mode (Essential for NeoVim!)" && \
                        echo "  Ctrl + s      : SCROLL/COPY Mode (Like tmux prefix + [)" && \
                        echo "                  -> v: Select, y/Enter: Copy" && \
                        echo "  Ctrl + p      : PANE Mode (Split, Resize, etc.)" && \
                        echo "  Ctrl + t      : TAB Mode (New, Rename, etc.)" && \
                        echo "  Ctrl + n      : RESIZE Mode" && \
                        echo "  Ctrl + o      : SESSION Mode" && \
                        echo "  Ctrl + q      : QUIT Zellij" && \
                        echo -e "\033[1;32mTip: Bottom bar changes based on these modes!\033[0m" '';
    };
  };
}

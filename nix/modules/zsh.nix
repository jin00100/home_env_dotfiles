{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # 사용자가 드롭다운 메뉴(zsh-autocomplete)의 버벅임에 불만을 표시하여 클래식 인라인 고스트 텍스트 자동완성으로 복구합니다.
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # [Zsh Performance Tuning]
    localVariables = {
      ZSH_AUTOSUGGEST_USE_ASYNC = "1";

      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#5c6370,italic"; # 强制真彩色灰字，无视主题引擎
      ZSH_DISABLE_COMPFIX = "true"; # Distrobox/Nix 권한 경고 방지
    };

    envExtra = ''
      export PATH=$HOME/.local/bin:$PATH
      export ZSH_DISABLE_COMPFIX="true" 
    '';

    # [Zsh Initialization]
    # NOTE: 'initContent' is used as it is the modern/preferred option in this setup.
    initContent = ''
      source ${./shell-common.sh}

      # [SSH/Zellij Specific Fixes]
      if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        bindkey "^?" backward-delete-char
        bindkey "^H" backward-delete-char
      fi

      # [Welcome Message]
      if [[ $- == *i* ]] && command -v welcome-msg &>/dev/null; then welcome-msg; fi

      # [External Tools (fnm)]
      if command -v fnm &>/dev/null; then eval "$(fnm env --use-on-cd --shell zsh)"; fi

      # [Kubernetes & Helm Autocompletion (Cached)]
      mkdir -p ~/.zsh_cache
      if command -v helm &>/dev/null; then
        if [[ ! -f ~/.zsh_cache/helm_completion ]]; then
          helm completion zsh > ~/.zsh_cache/helm_completion 2>/dev/null
        fi
        source ~/.zsh_cache/helm_completion
      fi

      if command -v kubectl &>/dev/null; then
        if [[ ! -f ~/.zsh_cache/kubectl_completion ]]; then
          kubectl completion zsh > ~/.zsh_cache/kubectl_completion 2>/dev/null
        fi
        source ~/.zsh_cache/kubectl_completion
      fi

      # [Keybindings]
      bindkey '^[[A' history-substring-search-up
      bindkey '^[[B' history-substring-search-down

      # [Fix Text Color]
      # 强制普通输入（如 jin@jin）渲染为明亮的纯白色，覆盖终端自带的灰暗默认色
      typeset -gA ZSH_HIGHLIGHT_STYLES
      ZSH_HIGHLIGHT_STYLES[default]="fg=white,bold"


      # [Final Cleanup for Containers]
      # 모든 자동 통합(zoxide, atuin 등)이 끝난 후 컨테이너라면 한 번 더 청소합니다.
      # zoxide가 'cd'를 함수나 별칭으로 가로채는 것을 방지하기 위해 cd도 목록에 추가합니다.
      if is_container; then
        # 1. Zsh 훅 제거 (디렉토리 이동 시 에러 방지)
        if [[ -n "$chpwd_functions" ]]; then
          chpwd_functions=(''${chpwd_functions:#__zoxide_hook})
        fi
        if [[ -n "$precmd_functions" ]]; then
          precmd_functions=(''${precmd_functions:#_atuin_precmd})
        fi

        # 2. 별칭 및 함수 제거
        unalias ls ll lt cat v vi vim g z cd 2>/dev/null
        unset -f z zi cd __zoxide_hook _atuin_precmd 2>/dev/null
      fi
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "history-substring-search" ];
    };

    shellAliases = {
      # Custom Keyboard Guide
      keymap = "bat ~/nixos-home-manager/docs/keyboard-layout.md";

      # WireGuard Aliases
      vpn-on = "sudo systemctl start wg-quick-wg0";
      vpn-off = "sudo systemctl stop wg-quick-wg0";
      vpn-stat = "sudo wg";
    };
  };
}

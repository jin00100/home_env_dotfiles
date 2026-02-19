{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-g";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    customPaneNavigationAndResize = true;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.yank
      {
        plugin = tmuxPlugins.power-theme;
        extraConfig = "set -g @tmux_power_theme 'coral'";
      }
    ];
    extraConfig = ''
      # 1. Vim-Tmux Navigator Alt (Meta) Key Bindings
      # Ctrl+j 충돌 방지를 위해 Alt(M-) 키로 변경합니다.
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'M-h' if-shell "$is_vim" 'send-keys M-h'  'select-pane -L'
      bind-key -n 'M-j' if-shell "$is_vim" 'send-keys M-j'  'select-pane -D'
      bind-key -n 'M-k' if-shell "$is_vim" 'send-keys M-k'  'select-pane -U'
      bind-key -n 'M-l' if-shell "$is_vim" 'send-keys M-l'  'select-pane -R'

      # 기존 Ctrl 매핑 해제 (Vim-Tmux Navigator 플러그인 기본값 무시)
      unbind-key -n C-h
      unbind-key -n C-j
      unbind-key -n C-k
      unbind-key -n C-l

      # 2. 터미널 클립보드 프로토콜(OSC 52) 설정
      set -s set-clipboard off
      set -as terminal-features ',xterm-256color:clipboard'

      # 2. 복사 모드(vi) 키 바인딩
      bind-key -T copy-mode-vi v send-keys -X begin-selection

      # 3. 복사 명령어 (Wayland와 X11 모두 지원)
      # Nix 패키지의 실행 파일 경로를 직접 사용하여 '명령어를 찾을 수 없음' 에러를 방지합니다.
      # Wayland일 경우 wl-copy를, X11일 경우 xclip을 사용합니다.
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "if [ -n \"$WAYLAND_DISPLAY\" ]; then ${pkgs.wl-clipboard}/bin/wl-copy; else ${pkgs.xclip}/bin/xclip -sel clip -i; fi"
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "if [ -n \"$WAYLAND_DISPLAY\" ]; then ${pkgs.wl-clipboard}/bin/wl-copy; else ${pkgs.xclip}/bin/xclip -sel clip -i; fi"

      # 4. tmux-yank 플러그인 설정 (보조용)
      set -g @yank_selection 'clipboard'
      set -g @yank_selection_mouse 'clipboard'
      set -g @yank_action 'copy-pipe'
    '';
  };
}

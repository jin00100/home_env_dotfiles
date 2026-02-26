{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    
    settings = {
      theme = "dracula";
      default_layout = "compact";
      pane_frames = false;
      
      # [Keybindings] tmux(C-g)와 유사한 경험 제공
      keybinds = {
        unbind = [ "Ctrl b" "Ctrl h" ]; # 기본 바인딩 해제
        
        # Tmux와 동일하게 Ctrl-g를 메인 단축키로 사용 
        # Zellij에서는 'locked' 모드를 통해 Neovim과 키 충돌을 방지합니다.
        normal = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Locked"; };
        };
        locked = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Normal"; };
        };

        # 어느 모드에서나 작동하는 공통 단축키 (Alt 사용)
        shared_except = {
          _args = [ "locked" ];
          "bind \"Alt h\"" = { MoveFocusOrTab = "Left"; };
          "bind \"Alt l\"" = { MoveFocusOrTab = "Right"; };
          "bind \"Alt j\"" = { MoveFocus = "Down"; };
          "bind \"Alt k\"" = { MoveFocus = "Up"; };
          "bind \"Alt =\"" = { Resize = "Increase"; };
          "bind \"Alt -\"" = { Resize = "Decrease"; };
          "bind \"Alt n\"" = { NewPane = "Right"; };
          "bind \"Alt i\"" = { MoveTab = "Left"; };
          "bind \"Alt o\"" = { MoveTab = "Right"; };
        };
      };

      # 테마 설정 (Dracula)
      themes = {
        dracula = {
          fg = [ 248 248 242 ];
          bg = [ 40 42 54 ];
          black = [ 0 0 0 ];
          red = [ 255 85 85 ];
          green = [ 80 250 123 ];
          yellow = [ 241 250 140 ];
          blue = [ 189 147 249 ];
          magenta = [ 255 121 198 ];
          cyan = [ 139 233 253 ];
          white = [ 255 255 255 ];
          orange = [ 255 184 108 ];
        };
      };

      # 마우스 지원 및 복사 설정
      mouse_mode = true;
      copy_on_select = true;
      copy_command = if config.targets.genericLinux.enable then "wl-copy" else "";
    };
  };
}

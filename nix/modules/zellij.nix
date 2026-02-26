{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    
    settings = {
      theme = "dracula";
      # [변경] 처음 배우실 때는 'default' 레이아웃이 도움말이 잘 나와서 훨씬 좋습니다.
      default_layout = "default";
      # [변경] 패널 테두리를 켜면 각 패널의 상태(Locked 등)를 확인하기 쉽습니다.
      pane_frames = true;
      
      keybinds = {
        unbind = [ "Ctrl b" "Ctrl h" ];
        
        normal = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Locked"; };
        };
        locked = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Normal"; };
        };

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

      mouse_mode = true;
      copy_on_select = true;
      copy_command = if config.targets.genericLinux.enable then "wl-copy" else "";
    };
  };
}

{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    
    settings = {
      theme = "modern-gruvbox";
      default_layout = "default";
      pane_frames = true;
      simplified_ui = false;
      mirror_session_to_terminal_title = true;

      keybinds = {
        unbind = [ "Ctrl b" "Ctrl h" ];
        
        normal = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Locked"; };
        };
        locked = {
          "bind \"Ctrl g\"" = { SwitchToMode = "Normal"; };
        };

        tab = {
          unbind = [ "x" ];
          "bind \"Ctrl x\"" = {
            CloseTab = { };
            SwitchToMode = "Normal";
          };
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
        modern-gruvbox = {
          fg = [ 235 219 178 ];
          bg = [ 40 40 40 ];
          black = [ 29 32 33 ];
          red = [ 251 73 52 ];
          green = [ 184 187 38 ];
          yellow = [ 250 189 47 ];
          blue = [ 131 165 152 ];
          magenta = [ 211 134 155 ];
          cyan = [ 142 192 124 ];
          white = [ 168 153 132 ];
          orange = [ 254 128 25 ];
        };
      };

      mouse_mode = true;
      copy_on_select = true;
      copy_command = if config.targets.genericLinux.enable then "wl-copy" else "";
    };
  };
}

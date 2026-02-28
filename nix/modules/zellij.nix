{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
    
    settings = {
      theme = "cyber-blue";
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
        cyber-blue = {
          fg = [ 192 202 245 ];
          bg = [ 26 27 38 ];       # 차분한 남색/검정 배경
          black = [ 21 22 30 ];
          red = [ 247 118 142 ];
          
          # Zellij는 'green' 속성을 평상시 화면(Normal Mode)의 🟢외곽선 색상으로 씁니다.
          # 노란색/초록색이 싫으시다고 했으므로 이를 시원한 🔵파란색 느낌으로 교체합니다.
          green = [ 122 162 247 ]; 
          
          # 하단의 단축키 배열이나 다른 모드(보통 yellow/orange)도 
          # 청록색(Cyan)이나 보라색(Magenta)으로 매핑하여 이질적인 노란색을 완전히 제거합니다.
          yellow = [ 125 207 255 ];
          blue = [ 122 162 247 ];
          magenta = [ 187 154 247 ];
          cyan = [ 125 207 255 ];
          white = [ 169 177 214 ];
          orange = [ 187 154 247 ];
        };
      };

      mouse_mode = true;
      copy_on_select = true;
      copy_command = if config.targets.genericLinux.enable then "wl-copy" else "";
    };
  };
}

{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    
    # 强制修改 Kitty 终端类型，解决在 CLI/SSH 等环境下的冲突问题
    environment = {
      "TERM" = "xterm-256color";
    };

    font = {
      name = "Maple Mono NF";
      size = 12;
    };

    settings = {
      # 视觉效果
      background_opacity = "0.65";
      window_padding_width = 15;
      hide_window_decorations = "yes";

      # 解决 CLI 冲突的备用方案（确保内部也强制使用 xterm-256color）
      term = "xterm-256color";

      # ----------------------------------------------------
      # 核心黑科技：光标彗星拖影特效 (OSYX 独占视觉体验)
      # ----------------------------------------------------
      cursor_trail = 1;
      cursor_trail_decay = "0.1 0.3";
      
      # 光标样式 (保持与 Ghostty 相似)
      cursor_shape = "block";
      cursor_blink_interval = "0.5";

      # 兼容性修复：强制使用 XWayland 解决 NVIDIA 显卡在 Wayland 下的 EGL 闪退问题
      linux_display_server = "x11";
    };
  };
}

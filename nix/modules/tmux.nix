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
      set -g set-clipboard on
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
    '';
  };
}

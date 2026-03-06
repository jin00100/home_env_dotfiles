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

  # 4. Bat (cat alternative - Syntax Highlight)
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
    };
  };

  # 5. FZF (Fuzzy Finder)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  # 6. Direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # 7. fnm (Fast Node Manager)
  programs.fnm = {
    enable = true;
    enableZshIntegration = true;
  };

  # 8. Pyenv
  programs.pyenv = {
    enable = true;
    enableZshIntegration = true;
  };
}

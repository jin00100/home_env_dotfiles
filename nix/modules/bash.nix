{ config, pkgs, lib, ... }:

{
  programs.bash = {
    enable = true;
    initExtra = ''
      ${builtins.readFile ./shell-common.sh}
      
      # If this is an interactive bash shell, drop directly into zsh
      if [[ $- == *i* ]]; then
        export SHELL=$(which zsh)
        exec zsh -l
      fi

      if command -v fnm &>/dev/null; then eval "$(fnm env --use-on-cd --shell bash)"; fi
    '';
  };
}

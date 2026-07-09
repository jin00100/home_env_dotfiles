{ config, pkgs, username, homeDirectory, inputs, ... }:

{
  # [User Info - Dynamically passing from flake.nix]
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "25.11"; 

  # [Module Loader] Load feature-specific files
  imports = [
    ./modules/zsh.nix
    ./modules/bash.nix
    ./modules/nushell.nix
    ./modules/welcome.nix
    ./modules/packages.nix
    ./modules/neovim.nix
    ./modules/zellij.nix
    ./modules/git.nix
    ./modules/ghostty.nix
    ./modules/kitty.nix
  ];

  targets.genericLinux.enable = true;
  fonts.fontconfig.enable = true;

  # [Auto GC] Automatically clean up unused Nix histories weekly
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  home.shellAliases = {
    # Kubernetes & Helm Shortcuts
    k = "kubectl";
    h = "helm";

    ls = "eza";
    ll = "eza -l --icons --git -a";
    lt = "eza --tree --level=2 --long --icons --git";
    
    # cat -> bat mapping
    cat = "bat";
    
    # Git & short commands
    la = "ls -a";
    g = "git";
    v = "nvim";
    vi = "nvim";
    vim = "nvim";
    
    # Clipboard copy alias
    tocb = "xclip -selection clipboard";

    # Home Manager alias for fast rebuilds in CLI repo
    hms = "home-manager switch --flake ~/home_env_dotfiles/#default --impure -b backup";
    
    # Zellij aliases
    zj = "zellij";
    
    # Nix cleanup alias
    nix-clean = "home-manager expire-generations \"-7 days\" && nix-env --delete-generations old && nix-store --gc";
  };

  programs.home-manager.enable = true;
}

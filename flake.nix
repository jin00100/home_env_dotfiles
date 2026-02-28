{
  description = "Dynamic Home Manager configuration";

  inputs = {
    # Nixpkgs (Unstable - latest packages)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager (Master - tracks nixpkgs)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Use --impure flag to interpret system environment at runtime
      system = builtins.currentSystem;
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Dynamically extract Username and Home Directory
      userEnv = builtins.getEnv "USER";
      username = if userEnv != "" then userEnv else builtins.getEnv "LOGNAME";
      homeDirectory = builtins.getEnv "HOME";
    in {
      # Using a universal "default" identifier to run consistently across any machine
      homeConfigurations."default" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        
        # Pass dynamic variables into Home Manager modules (e.g., home.nix)
        extraSpecialArgs = { inherit username homeDirectory; };
        
        modules = [ ./nix/home.nix ];
      };
    };
}

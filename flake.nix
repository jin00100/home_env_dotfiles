{
  description = "Home Manager configuration for yongminari";

  inputs = {
    # Nixpkgs (Unstable - 최신 패키지)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager (Master - Nixpkgs 버전과 맞춤)
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations = {
        # 1. Native Linux & WSL (Unified)
        "yongminari" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./nix/home.nix ];
        };
      };
    };
}

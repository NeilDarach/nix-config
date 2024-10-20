{
  description = "Yet another general nixos setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hardware.url = "github:nixos/nixos-hardware";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:/nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixNvim.url = "github:NeilDarach/nixNvim";
    msgQ.url = "github:NeilDarach/msg_q";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, sops-nix
    , hardware, impermanence, msgQ, nixNvim, ... }@inputs:
    let
      neil = {
        userId = "neil";
        email = "neil.darach@gmail.com";
        name = "Neil Darach";
      };
      inherit (self) outputs;
      #systems = [ "aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" ];
      #forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      #overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        gregor = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; user = neil; };
          modules = [
            ./hosts/gregor
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs; };
                users.${neil.userId}.imports = [ ];
              };
            }
          ];
        };
      };
    };
}

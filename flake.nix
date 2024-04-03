{ 
  description = "Flake to set up standard Linux servers";

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ... } @ inputs: let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
	];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays {inherit inputs; };
      nixosModules = import ./modules/nixos;  
      homeManagerModules = import ./modules/home-manager;

      nixosConfigurations = {
        hayellow = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
	  modules = [
	    ./nixos/configuration.nix
	    ];
	  };
	};

    homeConfigurations = {
      "neil@hayellow" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
	extraSpecialArgs = { inherit inputs outputs; };
	modules = [
	  ./home-manager/home.nix
	];
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix/master";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    };
  };
}


{ 
  description = "Flake to set up standard Linux servers";

  nixConfig = { };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    impermanence.url = "github:nix-community/impermanence";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    raspberry-pi-nix,
    sops-nix,
    ... } @ inputs: let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      systems = [
        "aarch64-linux"
	];

      forEachSystem = f: lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = lib.genAttrs systems ( system:
        import nixpkgs { inherit system; config.allowUnfree = true; });
    in {
      inherit lib;
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      overlays = import ./overlays {inherit inputs outputs; };
      nixosModules = import ./modules/nixos;  
      homeManagerModules = import ./modules/home-manager;


      nixosConfigurations = {
        pi400 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
	  modules = [
	    ./hosts/pi400
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
      "neil@pi400" = lib.homeManagerConfiguration {
        modules = [ ./home/neil/pi400.nix ];
        pkgs = pkgsFor.aarch64-linux;
	extraSpecialArgs = { inherit inputs outputs; };
      };
    };
  };

}


{ 
  # References at  https://github.com/EmergentMind/nix-config
  #                https://github.com/Misterio77/nix-starter-configs

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
    neovim-flake = { 
      url = "github:notashelf/neovim-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      };
    };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    raspberry-pi-nix,
    sops-nix,
    neovim-flake,
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
      packages = forEachSystem (pkgs: import ./pkgs { 
         inherit pkgs; 
         });
      overlays = import ./overlays {inherit inputs outputs; };
      nixosModules = import ./modules/nixos;  
      homeManagerModules = import ./modules/home-manager;


      devShells = forEachSystem (pkgs: {
        default = pkgs.mkShell {
          NIX_CONFIG = "extra-experimental-features = nix-command flakes repl-flake";
          nativeBuildInputs = builtins.attrValues {
            inherit (pkgs)
              # Required for pre-commit hook 'nixpkgs-fmt' only on Darwin
              # REF: <https://discourse.nixos.org/t/nix-shell-rust-hello-world-ld-linkage-issue/17381/4>
              libiconv
              nix home-manager git just pre-commit
              age ssh-to-age sops;
            };
          };
        });

      nixosConfigurations = {
        pi400 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
	  modules = [
	    ./hosts/pi400
	    ];
	  };
        yellow = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
	  modules = [
	    ./hosts/yellow
	    ];
	  };
	};

    homeConfigurations = {
      "neil@yellow" = lib.homeManagerConfiguration {
        modules = [
                    ./home/neil/yellow.nix ];
        pkgs = pkgsFor;
	      extraSpecialArgs = { inherit inputs outputs; };
        };
      "neil@pi400" = lib.homeManagerConfiguration {
        modules = [
                    ./home/neil/pi400.nix ];
        pkgs = pkgsFor;
	      extraSpecialArgs = { inherit inputs outputs; };
        };
      "guest@pi400" = lib.homeManagerConfiguration {
        modules = [ ./home/guest/pi400.nix ];
        pkgs = pkgsFor.aarch64-linux;
	      extraSpecialArgs = { inherit inputs outputs; };
        };
      };
    };
  }


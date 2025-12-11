{
  description = "Yet another general nixos setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
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
    #nixNvim.url = "github:NeilDarach/nix-config/gregor?dir=nixNvim";
    nixNvim.url = "github:NeilDarach/nixNvim";
    msg_q.url = "github:NeilDarach/msg_q";
    #msg_q.url = "git+file:/home/neil/msg_q";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
    secrets = {
      url = "git+ssh://git@github.com/NeilDarach/secrets.git?shallow=1";
      flake = false;
    };
    systems.url = "github:nix-systems/default-linux";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, sops-nix
    , hardware, impermanence, msg_q, nixNvim, raspberry-pi-nix, systems, ...
    }@inputs:
    let
      inherit (self) outputs;
      forEachSystem = f:
        nixpkgs.lib.genAttrs (import systems) (system: f pkgsFor.${system});
      pkgsFor = nixpkgs.lib.genAttrs (import systems) (system:
        import nixpkgs {
          inherit system;
          overlays = builtins.attrValues outputs.overlays;
          config.allowUnfree = true;
        });
      users = {
        neil = {
          userId = "neil";
          email = "neil.darach@gmail.com";
          name = "Neil Darach";
        };
      };
    in {
      packages = forEachSystem (pkgs: import ./packages { inherit pkgs; });
      nixosModules = import ./modules/nixos;
      overlays = import ./overlays { inherit inputs outputs; };
      devShells = forEachSystem
        (pkgs: import ./shells { inherit pkgs inputs outputs; });
      nixosConfigurations = {
        yellow = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs users; };
          modules = [
            ./hosts/yellow
            { nixpkgs.overlays = builtins.attrValues outputs.overlays; }
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs users; };
                users.neil.imports = [ ];
              };
            }
          ] ++ builtins.attrValues outputs.nixosModules;
        };
        gregor = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs users; };
          modules = [
            ./hosts/gregor
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            msg_q.nixosModules.msg_q
            { nixpkgs.overlays = builtins.attrValues outputs.overlays; }

            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs users; };
                users.neil.imports = [ ];
              };
            }
          ] ++ builtins.attrValues outputs.nixosModules;
        };
      };
    };
}

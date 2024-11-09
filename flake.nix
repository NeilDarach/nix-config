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
    nixNvim.url = "github:NeilDarach/nix-config/gregor?dir=nixNvim";
    msg_q.url = "github:NeilDarach/msg_q";
    #msg_q.url = "git+file:/home/neil/msg_q";
    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, sops-nix
    , hardware, impermanence, msg_q, nixNvim, raspberry-pi-nix, ... }@inputs:
    let
      inherit (self) outputs;
      systems =
        [ "aarch64-linux" "i686-linux" "x86_64-linux" "aarch64-darwin" ];
      forEachSystem = f:
        nixpkgs.lib.genAttrs systems (system: f pkgsFor.${system});
      pkgsFor = nixpkgs.lib.genAttrs systems (system:
        import nixpkgs {
          inherit system;
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
      #overlays = import ./overlays { inherit inputs; };

      nixosConfigurations = {
        yellow = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs users; };
          modules = [
            ./hosts/yellow
            disko.nixosModules.disko
            sops-nix.nixosModules.sops
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            {
              nixpkgs.overlays = [
                (f: p: {
                  networkmanager-vpnc =
                    p.networkmanager-vpnc.override { withGnome = false; };
                  networkmanager-iodine =
                    p.networkmanager-iodine.override { withGnome = false; };
                  networkmanager-openvpn =
                    p.networkmanager-openvpn.override { withGnome = false; };
                  networkmanager-libnma =
                    p.networkmanager-libnma.override { withGnome = false; };
                  networkmanager-fortislvpn =
                    p.networkmanager-fortislvpn.override { withGnome = false; };
                  networkmanager-sstp =
                    p.networkmanager-sstp.override { withGnome = false; };
                  networkmanager-l2tp =
                    p.networkmanager-l2tp.override { withGnome = false; };
                  networkmanager-openconnect =
                    p.networkmanager-openconnect.override {
                      withGnome = false;
                    };
                })
              ];
            }
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs users; };
                users.neil.imports = [ ];
              };
            }
          ];
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

            {
              nixpkgs.overlays = [
                (f: p: {
                  networkmanager-l2tp =
                    p.networkmanager-l2tp.override { withGnome = false; };
                  networkmanager-openconnect =
                    p.networkmanager-openconnect.override {
                      withGnome = false;
                    };
                })

                (f: p: { msg_q = msg_q.packages.${p.system}.default; })
              ];
            }
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = { inherit inputs users; };
                users.neil.imports = [ ];
              };
            }
          ];
        };
      };
    };
}

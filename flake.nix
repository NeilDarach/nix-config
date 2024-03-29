{ 
  description = "Flake to set up the HA Yellow";
  nixConfig = { 
    extra-substituters = [ "https://raspberry-pi-nix.cachix.org" ];
    extra-trusted-public-keys = [
      "raspberry-pi-nix.cachix.org-1:WmV2rdSangxW0rZjY/tBvBDSaNFQ3DyEQsVw8EvHn90="
      ];
    };
  outputs = inputs@{self, nixpkgs, nixos-hardware, home-manager, raspberry-pi-nix, ... }:
  let
  # --- System Settings ---
  systemSettings = {
    system = "aarch64-linux";
    hostname = "hayellow";
    profile = "standard";
    timezone = "Europe/London";
    locale = "en_GB.UTF-8";
    };

  userSettings = {
    username = "neil";
    name = "Neil Darach";
    email = "neil.darach@gmail.com";
    dotfilesDir = "~/.dotfiles";
    editor = "nvim";
    };

  pkgs = import nixpkgs {
    system = systemSettings.system;
    config = { allowUnfree = true;
               allowUnfreePredicate = ( _: true ); };
    };

  lib = nixpkgs.lib;

  nix.distributedBuilds = false;
  nix.buildMachines = [
    { hostName = "nixos-build";
      systems = [ "aarch64-linux" ];
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
      ];
  programs.ssh.extraConfig = ''
    Host nixos-build
    HostName nixos-build.darach.org.uk
    port 22
    user neil
    IdentitiesOnly yes
    IdentityFile /root/.ssh/id_nixos-build
    '';

  supportedSystems = [
    "aarch64-linux"
    ];

  forAllSystems = inputs.nixpkgs.lib.genAttrs supportedSystems;

  nixpkgsFor = forAllSystems (system:
    import inputs.nixpkgs { inherit system; });

  in {
    homeConfigurations = {
      user = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
	modules = [ (./. + "/profiles" + ("/"+systemSettings.profile)+"/home.nix") ];
	extraSpecialArgs =  {
	  inherit systemSettings;
	  inherit userSettings;
	  };
	};
      };
    nixosConfigurations = {
      system = lib.nixosSystem {
        system = systemSettings.system;
	modules = [ nixos-hardware.nixosModules.raspberry-pi-4
	            raspberry-pi-nix.nixosModules.raspberry-pi
	            (./. + "/profiles"+("/"+systemSettings.profile)+"/configuration.nix") ];
	specialArgs = {
	  inherit systemSettings;
	  inherit userSettings;
	  inherit nixos-hardware;
	  inherit raspberry-pi-nix;
	  };
	};
      };

    packages = forAllSystems (system:
      let pkgs = nixpkgsFor.${system}; in
      {
        default = self.packages.${system}.install;
	install = pkgs.writeScriptBin "install" ./install.sh;
	});

    apps = forAllSystems (system: {
      default = self.apps.${system}.install;
      install = {
        type = "app";
	program = "${self.packages.${system}.install}/bin/install";
	};
      });
    };
    
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    raspberry-pi-nix.url = "github:tstat/raspberry-pi-nix/master";
    };
  }





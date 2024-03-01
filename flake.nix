{ 
  description = "Flake to set up the HA Yellow";

  outputs = inputs@{self, nixpkgs, home-manager, ... }:
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

  pkgs = {
    system = systemSettings.system;
    config = { allowUnfree = true;
               allowUnfreePredicate = ( _: true ); };
    };

  lib = nixpkgs.lib;

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
	modules = [ (./. + "/profiles" + ("/"+systemSettings.profile)+"/home/nix") ];
	extraSpecialArgs =  {
	  inherit systemSettings;
	  inherit userSettings;
	  };
	};
      };
    nixosConfigurations = {
      system = lib.nixosSystem {
        system = systemSettings.system;
	modules = [ (./. + "/profiles"+("/"+systemSettings.profile)+"/configuration.nix") ];
	specialArgs = {
	  inherit systemSettings;
	  inherit userSettings;
	  };
	};
      };
    apps = forAllSystems (system: {
      default = self.apps.${system}.install;
      install = {
        type = "app";
	program = "${self.packages.${system}.install}/bin/install";
	};
      });
    };
    
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    };
  }





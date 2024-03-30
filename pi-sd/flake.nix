{ 
  description = "Raspberry Pi 4 Image";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    };
  outputs = { self, nixpkgs }: let
    system = "aarch64-linux";
    pkgs = import nixpkgs {
             inherit system;

    overlays = [
      (final: prev: {
        ubootRaspberryPi4_64bit = (prev.ubootRaspberryPi4_64bit.override  {
           extraPatches =  [ (./. + "/u-boot-nvme.patch") ];
        }).overrideAttrs (o: {
           postInstall = '' 
	   '';
        });
      })
    ];
	     };

    nixosConfigurations.rpi4 = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
	({ ... }: {
	  config = {
	    time.timeZone = "Europe/London";
	    i18n.defaultLocale = "en_GB.UTF-8";
	    sdImage.compressImage = false;
	    sdImage.expandOnBoot = false;
	    sdImage.firmwareSize = 500;
	    sdImage.populateFirmwareCommands = ''
	    cp "${pkgs.ubootRaspberryPi4_64bit}"/u-boot.bin firmware/u-boot-rpi4.bin.nvme
	    '';
	    console.keyMap = "uk";

	    users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
	      ];

	    services.openssh = {
	      enable = true;
	      };

	    system = {
	      stateVersion = "23.05";
	      };
	    networking = {
	      wireless.enable = false;
	      useDHCP = true;
	      };
	    environment.systemPackages = [ pkgs.neovim pkgs.git pkgs.curl ];
	    };
	  })
	];
      };
    in {
      image.rpi4 = nixosConfigurations.rpi4.config.system.build.sdImage;
      };
  }

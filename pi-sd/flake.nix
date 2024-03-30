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


  nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "nixos-build";
      systems = [ "aarch64-linux" ];
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
      ];


  services.openssh.knownHosts.nixos-build.hostNames = [ "nixos-build.darach.org.uk" ];
  services.openssh.knownHosts.nixos-build.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9qKrfo5/UkLCIU9kYNvzHkfVPpajZtvie7FHqMain1"; 

  programs.ssh.extraConfig = ''
Host nixos-build
    HostName nixos-build.darach.org.uk
    port 22
    user neil
    IdentitiesOnly yes
    IdentityFile /root/.ssh/id_nixos-build
    '';



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

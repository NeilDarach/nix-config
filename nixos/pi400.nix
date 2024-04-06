{ 
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
  }: {
  imports = [ 
    ./pi400-hardware.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
    inputs.home-manager.nixosModules.home-manager
    ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      ];
    config = {
      allowUnfree = true;
      };
    };

  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = 
    lib.mapAttrs'
    (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
      })
    config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    #auto-optimize-store = true;
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

  networking.hostName = "pi400";

  users.users = {
    neil = {
      isNormalUser = true;
      home = "/home/neil";
      description = "Neil Darach";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com" ];
      extraGroups = [ "wheel" ];
      };
    root = {
      isNormalUser = false;
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com" ];
      };
    };

  home-manager.users.root = {
      home.stateVersion = "23.11";
      programs.bash = {
        enable = true;
	sessionVariables = {
	  EDITOR = "nvim";
	  };
	};
      programs.git = {
        enable = true;
	extraConfig = {
	  user = {
	    name = "Neil Darach";
	    email = "neil.darach@gmail.com";
	  };
	};
      };
    };

  services.openssh = {
    knownHosts = {
      githubed.hostNames = [ "github.com" ];
      githubed.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      githubrsa.hostNames = [ "github.com" ];
      githubrsa.publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      githubecdsa.hostNames = [ "github.com" ];
      githubecdsa.publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=";

      nixos-build.hostNames = [ "nixos-build.darach.org.uk" ];
      nixos-build.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9qKrfo5/UkLCIU9kYNvzHkfVPpajZtvie7FHqMain1";
      };

    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      };
    };

    programs.bash.shellAliases = {
      vi = "nvim";
      vim = "nvim";
      };

    programs.ssh.extraConfig = ''
Host nixos-build
    HostName nixos-build.darach.org.uk
    port 22
    user neil
    IdentitiesOnly yes
    IdentityFile /root/.ssh/id_nixos-build
    AddressFamily inet
    '';
    
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
    };




  boot = {
    loader = {
      # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
      grub.enable = false;
      # Enables the generation of /boot/extlinux/extlinux.conf
      generic-extlinux-compatible.enable = true;
      };
    supportedFilesystems = [ "vfat" "zfs" "ext4" ];
    };

  hardware = {
    #raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    #deviceTree = {
    #  enable = true;
    #  filter = "*rpi-4-*.dtb";
    #};
    bluetooth.enable = false;
    #raspberry-pi = {
      #config = {
        #all = {
	  #base-dt-params = {
	    #krnbt = {
	      #enable = true;
	      #value = "on";
	      #};
	    #};
          #};
	#};
      #};
  };

  console.enable = true;

  networking.hostId = "95849595";

  environment.systemPackages = with pkgs; [
    binutils
    neovim
    tmux
    wget
    curl
    git
    ];

  system.stateVersion = "23.11";
  }

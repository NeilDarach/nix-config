# default server settings
{ hostname }:
{ inputs, outputs, lib, config, pkgs, users, ... }: {
  imports = [ ];
  nixpkgs = {
    overlays = [ ];
    config = { allowUnfree = true; };
  };

  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "eu.nixbuild.net";
      system = "aarch64-linux";
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [ "benchmark" "big-parallel" ];
    }
        #{
        #hostName = "eu.nixbuild.net";
        #system = "x86_64-linux";
        #maxJobs = 4;
        #speedFactor = 2;
        #supportedFeatures = [ "benchmark" "big-parallel" ];
        #}
  ];
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; }))
    ((lib.filterAttrs (_: lib.isType "flake")) inputs);
  nix.nixPath = [ "/etc/nix/path" ];
  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  networking.firewall.enable = true;
  programs.mtr.enable = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
    timeout = 3;
  };

  time.timeZone = "Europe/London";
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
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
  };

  security.sudo.wheelNeedsPassword = false;
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
  users.defaultUserShell = pkgs.fish;
  users.groups = { plugdev = { }; };
  users.users = {
    root = {
      hashedPasswordFile = config.sops.secrets.root_password_hashed.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
      ];
    };
    ${users.neil.userId} = {
      hashedPasswordFile = config.sops.secrets.user_password_hashed.path;
      isNormalUser = true;
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
      ];
      extraGroups =
        [ "wheel" "docker" "transmission" "plex" "plugdev" "dialout" ];
      packages = with pkgs; [ neovim docker ];
    };
  };

  sops.secrets."ssh_privatekey_nixbuild" = {
    path = "/root/.ssh/id_nixbuild";
    mode = "0400";
    owner = "root";
    group = "root";
  };
  systemd.tmpfiles.rules = [ "d /root/.ssh 0700 root root" ];
  programs.htop.enable = true;
  programs.fish.enable = true;
  environment = {
    defaultPackages = [ ];
    systemPackages = with pkgs; [
      curl
      dig
      dnsutils
      git
      gnutar
      htop
      iputils
      jq
      mtr
      netcat
      openssl
      tree
      unzip
      wget
      fish
    ];
  };

  services.udev = {
    enable = true;
    extraRules = ''
      # Detect a home-assistant yellow being plugged in recovery mode and allow members of plugdev to control it
      SUBSYSTEM=="usb", ATTRS{idVendor}=="1d6b", ATTRS{idProduct}=="0002", GROUP="plugdev", MODE="0660"
      # Detect the result of rpiboot creating new block devices, set the group and create a symlink
      SUBSYSTEM=="block", ENV{ID_VENDOR}=="RPi-MSD-", GROUP="plugdev", MODE="0660", SYMLINK+="pi-msd%n"
      SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="0a5c", ENV{ID_USB_MODEL_ID}=="0104", ENV{ID_USB_VENDOR}=="mmcblk0", GROUP="plugdev", MODE="0660", SYMLINK+="pi-emmc%n"
      SUBSYSTEM=="block", ENV{ID_VENDOR_ID}=="0a5c", ENV{ID_USB_MODEL_ID}=="0104", ENV{ID_USB_VENDOR}=="nvme0n1", GROUP="plugdev", MODE="0660", SYMLINK+="pi-nvme%n"
      SUBSYSTEM=="tty",   ENV{ID_VENDOR_ID}=="0403", ENV{ID_USB_MODEL_ID}=="6001", GROUP="plugdev", MODE="0660"
    '';
  };
  programs.ssh = {
    extraConfig = ''
      Host eu.nixbuild.net
      PubKeyAcceptedKeyTypes ssh-ed25519
      ServerAliveInterval 60
      IPQos throughput
      IdentityFile ~/.ssh/id_nixbuild
    '';
    knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      StreamLocalBindUnlink = "yes";
      GatewayPorts = "clientspecified";
    };
    hostKeys = [
      {
        path = "/run/secrets/sshd_hostkey_${hostname}_rsa";
        type = "rsa";
      }
      {
        path = "/run/secrets/sshd_hostkey_${hostname}_ed25519";
        type = "ed25519";
      }
    ];
  };

  system = {
    stateVersion = "24.05";
    autoUpgrade.enable = true;
    autoUpgrade.allowReboot = false;
  };
}

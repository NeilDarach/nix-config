# default server settings
{ inputs, outputs, lib, config, pkgs, user,  ... }: {
  imports = [ ];
  nixpkgs = {
    overlays = [ ];
    config = { allowUnfree = true; };
  };
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

    security.sudo.extraConfig = ''
        Defaults lecture = never
    '';
  users.defaultUserShell = pkgs.fish;
  users.users = {
    root = {
      hashedPasswordFile = config.sops.secrets.root_password_hashed.path;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
      ];
    };
    ${user.userId} = {
      hashedPasswordFile = config.sops.secrets.user_password_hashed.path;
      isNormalUser = true;
      shell = pkgs.fish;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
      ];
      extraGroups = [ "wheel" "docker" "transmission" "plex" ];
      packages = with pkgs; [ neovim docker ];
    };
  };

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
        path = "/run/secrets/sshd_hostkey_gregor_rsa";
        type = "rsa";
      }
      {
        path = "/run/secrets/sshd_hostkey_gregor_ed25519";
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

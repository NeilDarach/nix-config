{ self, config, inputs, ... }:
let inherit (config.flake.modules) nixos;
in {
  configurations.nixos.r5s.module = args@{ pkgs, lib, config, ... }: {
    imports = [
      nixos.hardware-r5s
      inputs.disko.nixosModules.disko
      nixos.overlays
      nixos.sops
      nixos.user-neil
      inputs.sops-nix.nixosModules.sops
    ];
    nixpkgs.hostPlatform = "aarch64-linux";
    inherit (self.diskoConfigurations.r5s) disko;
    boot.supportedFilesystems = [ "zfs" ];
    networking = {
      hostName = "r5s";
      useDHCP = true;
      hostId = "d9165aff";
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    time.timeZone = "Europe/London";

    sops = {
      secrets = {
        "sshd_hostkey_r5s_rsa" = { path = "/etc/ssh/sshd_hostkey_rsa"; };
        "sshd_hostkey_r5s_ed25519" = {
          path = "/etc/ssh/sshd_hostkey_ed25519";
        };
        "root_password_hashed" = { neededForUsers = true; };
      };
    };

    environment.systemPackages = with pkgs; [
      git
      python3
      mc
      psmisc
      curl
      wget
      dig
      file
      nvd
      ethtool
      sysstat
      zfs
      nixNvim
      dnsutils
      jq
      unzip
      usbutils
      lsof
    ];

    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = [ "root" "@wheel" ];
    users.users = {
      root = {
        hashedPasswordFile = config.sops.secrets.root_password_hashed.path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
        ];
      };
    };
    services.openssh.enable = true;
    i18n = { defaultLocale = "en_GB.UTF-8"; };
    environment.etc = {
      "systemd/journald.conf.d/99-storage.conf".text = ''
        [Journal]
        Storage=volatile
      '';
    };
    system.stateVersion = lib.mkDefault "25.11";

  };
}


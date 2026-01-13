{ self, config, inputs, ... }:
let inherit (config.flake.modules) nixos home-manager;
in {
  configurations.nixos.r5s.module = args@{ pkgs, lib, config, ... }: {
    imports = [
      nixos.hardware-r5s
      nixos.impermanence
      nixos.home-manager
      inputs.disko.nixosModules.disko
      nixos.overlays
      nixos.sops
      inputs.sops-nix.nixosModules.sops
      nixos.common
      nixos.user-neil
      inputs.home-manager.nixosModules.home-manager
      self.diskoConfigurations.r5s
    ];
    nixpkgs.hostPlatform = "aarch64-linux";
    boot.supportedFilesystems = [ "vfat" "zfs" ];
    boot.initrd.kernelModules = [ "zfs" ];
    boot.kernelModules = [ "zfs" ];
    networking = {
      hostName = "r5s";
      useDHCP = true;
      hostId = "d9165aff";
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    time.timeZone = "Europe/London";

    sops = {
      secrets = {
        "sshd_hostkey_${config.networking.hostName}_rsa" = { path = "/etc/ssh/ssh_host_rsa_key"; };
        "sshd_hostkey_${config.networking.hostName}_ed25519" = {
          path = "/etc/ssh/ssh_host_ed25519_key";
        };
        "root_password_hashed" = { neededForUsers = true; };
      };
    };

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

{ config, inputs, ... }:
let inherit (config.flake.modules) nixos;
in {
  configurations.nixos.r5s.module = args@{ pkgs, lib, ... }: {
    imports = [ nixos.hardware-r5s nixos.r5s-disko nixos.overlays ];
    nixpkgs.hostPlatform = "aarch64-linux";
    boot.supportedFilesystems = [ "zfs" ];
    networking = {
      hostName = "r5s";
      useDHCP = true;
      hostId = "d9165aff";
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    time.timeZone = "Europe/London";

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
    users.users.nix = {
      isNormalUser = true;
      description = "nix";
      extraGroups = [ "networkmanager" "wheel" ];
      password = "nix";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
      ];
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


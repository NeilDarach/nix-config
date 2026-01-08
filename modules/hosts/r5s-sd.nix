{ config, inputs, ... }:
let inherit (config.flake.modules) nixos;
in {
  configurations.nixos.r5s-sd.module = args@{ pkgs, lib, ... }: {
    imports = [ nixos.hardware-r5s nixos.r5s-sd-firstboot nixos.overlays-nvim ];
    nixpkgs.hostPlatform = "aarch64-linux";
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/NIXOS";
        fsType = "ext4";
      };
      "/var/log" = { fsType = "tmpfs"; };
    };
    boot.tmp.useTmpfs = true;
    boot.supportedFilesystems = [ "zfs" ];
    networking = {
      hostName = "nixos";
      useDHCP = true;
    };
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
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
    ];

    security.sudo.wheelNeedsPassword = false;
    nix.settings.trusted-users = [ "root" "@wheel" ];
    users.users.nix = {
      isNormalUser = true;
      description = "nix";
      extraGroups = [ "networkmanager" "wheel" ];
      password = "nix";
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


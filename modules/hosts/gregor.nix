{ self, config, inputs, ... }:
let inherit (config.flake.modules) nixos home-manager;
in {
  configurations.nixos.gregor.module = args@{ pkgs, lib, config, ... }: {
    imports = [
      nixos.hardware-intel
      nixos.impermanence
      nixos.home-manager
      inputs.disko.nixosModules.disko
      nixos.overlays
      nixos.sops
      inputs.sops-nix.nixosModules.sops
      nixos.common
      nixos.user-neil
      nixos.user-root
      nixos.udev
      inputs.home-manager.nixosModules.home-manager
      self.diskoConfigurations.gregor
      inputs.msg_q.nixosModules.msg_q
    ];
    boot.supportedFilesystems = [ "vfat" ];
    local = {
      useZfs = true;
      useDistributedBuilds = true;
      plex.enable = true;
      appdaemon.enable = true;
      esphome.enable = true;
      espresense.enable = true;
      gitea.enable = true;
      grafana.enable = true;
      homeassistant.enable = true;
      influxdb2.enable = true;
      nginx.enable = true;
      transmission.enable = true;
      zigbee2mqtt.enable = true;
    };
    boot.zfs.extraPools = [ "linstore" "silent" ];
    fileSystems."/home" = {
      device = "silent/home";
      fsType = "zfs";
      neededForBoot = true;
    };

    networking = {
      hostName = "gregor";
      useDHCP = lib.mkForce true;
      hostId = "42231481";
    };

    boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
    boot.initrd.systemd.emergencyAccess = true;
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
      timeout = 3;
    };
    system.stateVersion = lib.mkDefault "25.11";
    nix.settings.extra-platforms = config.boot.binfmt.emulatedSystems;
    environment = { systemPackages = [ pkgs.bluez ]; };
    hardware.bluetooth.enable = true;
    services.dbus = {
      implementation = "broker";
      enable = true;
    };
    services.msg_q = {
      enable = false;
      port = 9000;
      openFirewall = true;
    };
  };
}

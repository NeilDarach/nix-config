{
  self,
  config,
  inputs,
  ...
}:
let
  inherit (config.flake.modules) nixos home-manager;
in
{
  configurations.nixos.goip.module =
    args@{
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [
        nixos.hardware-amd64
        nixos.impermanence
        nixos.home-manager
        inputs.disko.nixosModules.disko
        nixos.overlays
        nixos.sops
        inputs.sops-nix.nixosModules.sops
        nixos.common
        nixos.user-neil
        nixos.user-root
        inputs.home-manager.nixosModules.home-manager
        self.diskoConfigurations.goip
      ];
      boot.supportedFilesystems = [
        "vfat"
      ];
      local = {
        useZfs = true;
        useDistributedBuilds = true;
      };
      boot.loader = {
        systemd-boot.enable = false;
        grub.enable = true;
        grub.useOSProber = false;
        grub.efiSupport = false;
        efi.canTouchEfiVariables = false;
        timeout = 3;
      };
      networking = {
        hostName = "goip";
        useDHCP = lib.mkForce false;
      };

      networking.interfaces.ens3.useDHCP = true;

      boot.initrd.systemd.emergencyAccess = true;
      boot.loader = {
      };
      system.stateVersion = lib.mkDefault "25.11";
      hardware.firmware = [ pkgs.linux-firmware ];
      services.dbus = {
        implementation = "broker";
        enable = true;
      };
    };
}

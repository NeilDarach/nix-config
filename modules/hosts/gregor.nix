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
  configurations.nixos.gregor.module =
    args@{
      pkgs,
      lib,
      config,
      ...
    }:
    {
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
        inputs.home-manager.nixosModules.home-manager
        self.diskoConfigurations.gregor
        nixos.svc-jellyfin
      ];
      boot.supportedFilesystems = [ "vfat" ];
      local = {
        useZfs = true;
        useDistributedBuilds = true;
      };
      boot.zfs.extraPools = [ "linstore" ];

      networking = {
        hostName = "gregor";
        useDHCP = true;
        hostId = "42231481";
      };
      system.stateVersion = lib.mkDefault "25.11";

    };
}

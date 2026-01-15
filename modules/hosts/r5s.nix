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
  configurations.nixos.r5s.module =
    args@{
      pkgs,
      lib,
      config,
      ...
    }:
    {
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
        nixos.user-root
        inputs.home-manager.nixosModules.home-manager
        self.diskoConfigurations.r5s
      ];
      boot.supportedFilesystems = [ "vfat" ];
      local = {
        useZfs = true;
        useDistributedBuilds = true;
        jellyfin.enable = true;
      };

      networking = {
        hostName = "r5s";
        useDHCP = lib.mkForce true;
        hostId = "d9165aff";
      };
      system.stateVersion = lib.mkDefault "25.11";

    };
}

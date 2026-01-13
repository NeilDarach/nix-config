{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.common-zfs =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local = {
          useZfs = lib.mkEnableOption "ZFS support on this host";
        };
        config = lib.mkIf config.local.useZfs {
        boot.supportedFilesystems = [ "zfs" ];
        boot.initrd.kernelModules = [ "zfs" ];
        boot.kernelModules = [ "zfs" ];
        environment.systemPackages = [ pkgs.zfs ];
        };
      };
  };
}

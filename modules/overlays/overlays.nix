{ inputs, config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.overlays =
    nixosArgs@{ pkgs, config, ... }:
    {
      imports = [
        nixos.overlays-nvim
        nixos.overlays-zfs-backup
        nixos.overlays-strongStateDir
        nixos.overlays-transcode
      ];
    };
}

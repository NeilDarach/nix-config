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
      ];

      nixpkgs.overlays = [
        (final: prev: {
          inherit (inputs.self.packages.${final.system})
            zfs-backup
            strongStateDir
            registration
            transcode
            ;
        })
      ];
    };
}

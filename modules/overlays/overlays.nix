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
        nixos.overlays-plex
        nixos.overlays-disableGnome
      ];

      nixpkgs.overlays = [
        (final: previous: {
          inherit (inputs.self.packages.${final.system})
            zfs-backup
            strongStateDir
            registration
            http-tarpit
            transcode;


            msg_q = inputs.msg_q.packages.${final.stdenv.hostPlatform.system}.default;
        })
      ];
    };
}

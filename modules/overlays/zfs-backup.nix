{ inputs, ... }: {
  flake.modules.nixos.overlays-zfs-backup = nixosArgs@{ pkgs, config, ... }: {

    nixpkgs.overlays = [
      (final: prev: {
        inherit (inputs.self.packages.${final.system}) zfs-backup;
      })
    ];
  };
}

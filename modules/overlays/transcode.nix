{ inputs, ... }: {
  flake.modules.nixos.overlays-transcode = nixosArgs@{ pkgs, config, ... }: {

    nixpkgs.overlays = [
      (final: prev: {
        inherit (inputs.self.packages.${final.system}) transcode;
      })
    ];
  };
}

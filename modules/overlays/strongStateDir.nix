{ inputs, ... }: {
  flake.modules.nixos.overlays-strongStateDir = nixosArgs@{ pkgs, config, ... }: {

    nixpkgs.overlays = [
      (final: prev: {
        inherit (inputs.self.packages.${final.system}) strongStateDir;
      })
    ];
  };
}

{ inputs, ... }: {
  flake.modules.nixos.overlays-nvim = nixosArgs@{ pkgs, config, ... }: {

    nixpkgs.overlays = [
      (final: prev: { nixNvim = inputs.nixNvim.packages.${final.system}.nvim; })
    ];
  };
}

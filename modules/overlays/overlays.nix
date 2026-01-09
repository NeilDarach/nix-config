{ inputs, ... }: let inherit (config.flake.modules) nixos;
{
  flake.modules.nixos.overlays = nixosArgs@{ pkgs, config, ... }: {
    imports = [ nixos.overlays-nvim ];
  };
}

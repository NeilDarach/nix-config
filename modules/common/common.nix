{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.common =
      nixosArgs@{ pkgs, config, ... }:
      {
        home-manager = {
          extraSpecialArgs = { inherit inputs; };
          useGlobalPkgs = true;
          useUserPackages = true;
        };
        programs = {
          fish.enable = true;
          git.enable = true;
        };
      };
    homeManager.common =
      nixosArgs@{ pkgs, config, ... }:
      {
        config = {
          programs.home-manager.enable = lib.mkDefault true;
          xdg.enable = lib.mkDefault true;
          systemd.user.startServices = lib.mkIf config.programs.home-manager.enable "sd-switch";
        };
      };
  };
}

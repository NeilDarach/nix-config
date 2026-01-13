{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    homeManager.neil-fish =
      nixosArgs@{ pkgs, config, ... }:
      {
        programs.fish = {
          shellAliases = lib.mkIf config.programs.fish.enable {
          };
          shellInit = ''
            fish_vi_key_bindings
          '';
        };
      };
  };

}

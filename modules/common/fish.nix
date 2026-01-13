{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.fish =
      nixosArgs@{ pkgs, config, ... }:
      {
        config = lib.mkIf config.programs.fish.enable {
          programs.fish = {
            shellInit = '''';
          };
        };
      };
  };
}

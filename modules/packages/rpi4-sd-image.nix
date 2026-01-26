{
  config,
  nixpkgs,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  perSystem =
    per@{ inputs', pkgs, ... }:
    let
      image = config.flake.nixosConfigurations.rpi4-sd;
    in
    {
      packages = {
        rpi4-sd-image = image.config.system.build.image;
      };
    };
}

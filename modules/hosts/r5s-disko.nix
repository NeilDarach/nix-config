{ config, lib, ... }: {
  flake.modules = {
    nixos.r5s-disko = nixosArgs@{ pkgs, config, ... }: import ./_r5s-disko.nix;
  };
}

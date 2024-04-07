{
  pkgs ? import <nixpkgs> { },
} : rec {
  bootstrap = pkgs.callPackage ./bootstrap.nix { };
  default = bootstrap;
  }

{
  pkgs ? import <nixpkgs> { },
} : rec {
  bootstrap = pkgs.callPackage ./bootstrap { };
  default = bootstrap;
  }

{
  description = "A modified Nixos SD/EMMC image generator";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
    nanopi-img.url = "github:bdew/nixos-nanopi";
  };

  outputs = { self, nixpkgs, flake-utils, nanopi-img, }: {
    packages = nanopi-img.packages;
    nixosModules = nanopi-img.nixosModules;
  };
}

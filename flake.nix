{
  description = "Build an sd image to boot an r5s with zfs support";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nanopi = {
      url = "github:bdew/nixos-nanopi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nanopi, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ];
      };
      modelDef = import "${nanopi}/models/r5s.nix";
      mynixpkgs = nixpkgs;
      image = import "${nanopi}/utils/image.nix" {
        inherit pkgs modelDef;
        nixpkgs = mynixpkgs;
      };
    in { packages."${system}".default = image; };
}

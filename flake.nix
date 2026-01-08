{
  description =
    "Nanopi R5S nix config for bootable SD image and a running config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    secrets = {
      url = "git+ssh://git@github.com/NeilDarach/secrets.git?shallow=1";
      flake = false;
    };
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
    (inputs.import-tree ./modules);
}


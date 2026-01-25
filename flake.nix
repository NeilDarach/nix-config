{
  description = "All systems config.  x86, rpi4, r5s";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    gff = {
      url = "github:NeilDarach/gff";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixnvim.follows = "nixNvim";
      inputs.secrets.follows = "secrets";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nixNvim = {
      url = "github:NeilDarach/nixNvim/updated";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    msg_q = {
      url = "github:NeilDarach/msg_q";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    secrets = {
      url = "git+ssh://git@github.com/NeilDarach/secrets.git?shallow=1";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}

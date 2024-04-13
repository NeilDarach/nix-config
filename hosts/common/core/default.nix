{ 
  inputs,
  outputs,
  pkgs,
  ...
  } : {
  imports = [ 
    inputs.home-manager.nixosModules.home-manager
    ./fish.nix
    ./sops.nix
    ./distributed-build.nix
    ./optin-persistence.nix
    ./openssh.nix
    ./security.nix
    ./locale.nix
    ./nix.nix
    ] ++ (builtins.attrValues outputs.nixosModules);

 environment.systemPackages = builtins.attrValues {
    inherit (pkgs)
      just; };

  home-manager.extraSpecialArgs = {
    inherit inputs outputs;
    };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      };
    };

  networking.domain = "darach.org.uk";
  }


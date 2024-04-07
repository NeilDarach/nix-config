{ 
  inputs,
  outputs,
  ...
  } : {
  imports = [ 
    inputs.home-manager.nixosModules.home-manager
    ./fish.nix
    ./sops.nix
    ./distributed-build.nix
    ./optin-persistence.nix
    ./openssh.nix
    ./locale.nix
    ] ++ (builtins.attrValues outputs.nixosModules);

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


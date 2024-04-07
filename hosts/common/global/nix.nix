{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  nix = {
    # TODO
    # https://github.com/NixOS/nix/issues/9579
    # https://github.com/NixOS/nix/pull/9547
    package = pkgs.nixVersions.nix_2_18;

    settings = {
      auto-optimise-store = lib.mkDefault true;
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # Keep the last 3 generations
      options = "--delete-older-than +3";
    };

    # Add each flake input as a registry
    # To make nix3 commands consistent with the flake
    registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ] ++ (lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry);

  };
}

{ 
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ... }: {
  import = [ ];

  nixpkgs = {
    overlays = [
      outputs.overlays.additions;
      outputs.overlays.modifications;
      ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      };
    };

    home = {
      username = "neil";
      homeDirector = "/home/neil";
      };

    programs.home-manager.enable = true;
    programs.git.enable = true;

    home.stateVersion = "23.11";
  }

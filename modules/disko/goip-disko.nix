{ config, lib, inputs, ... }: {
  imports = [ inputs.disko.flakeModules.disko ];
  flake.diskoConfigurations = { goip = import ./_goip-disko.nix; };
}

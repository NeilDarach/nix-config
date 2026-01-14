{ config, lib, inputs, ... }: {
  imports = [ inputs.disko.flakeModules.disko ];
  flake.diskoConfigurations = { gregor = import ./_gregor-disko.nix; };
}

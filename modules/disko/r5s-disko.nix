{ config, lib, inputs, ... }: {
  imports = [ inputs.disko.flakeModules.disko ];
  flake.diskoConfigurations = { r5s = import ./_r5s-disko.nix; };
}

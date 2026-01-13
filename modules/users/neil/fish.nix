{ config, lib, inputs, ... }: {
  flake.modules = {
    homeManager.neil-fish = nixosArgs@{ pkgs, config, ... }: {
      programs.fish = { shellAliases = { isFish = "echo yes"; }; };
    };
  };

}

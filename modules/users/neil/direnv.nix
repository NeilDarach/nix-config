{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    homeManager.neil-direnv =
      nixosArgs@{ pkgs, config, ... }:
      {
        programs.direnv = lib.mkIf config.programs.direnv.enable {
          nix-direnv.enable = true;
          config = {
            global = {
              hide_env_diff = true;
            };
          };
        };

      };
  };

}

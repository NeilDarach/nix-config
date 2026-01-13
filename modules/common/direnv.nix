{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.direnv = nixosArgs@{ pkgs, config, ... }: {
      config = lib.mkIf config.programs.direnv.enable {
        programs.direnv = {
          enableBashIntegration = true;
          enableFishIntegration = true;
          nix-direnv.enable = true;
          settings = { global = { hide_env_diff = true; }; };
        };
      };
    };
  };
}

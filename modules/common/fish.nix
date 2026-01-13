{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.fish = nixosArgs@{ pkgs, config, ... }: {
      config = lib.mkIf config.programs.fish.enable {
        programs.fish = {
          shellInit = ''
            fish_vi_key_bindings
          '';
        };
      };
    };
  };
}

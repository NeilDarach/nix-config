{ config, lib, inputs, ... }: {
  flake.modules = {
    home-manager.git = { config, ... }: {
      config = lib.mkIf config.programs.git.enable {
        programs.git = { ignore = [ "*~" "*.swp" ".direnv" "result" ]; };
      };

      nixos.git = nixosArgs@{ pkgs, config, ... }: { };
    };
  };
}

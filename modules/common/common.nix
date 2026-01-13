{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.common = nixosArgs@{ pkgs, config, ... }: {
      home-manager.extraSpecialArgs = { inherit inputs; };
      programs = {
        fish.enable = true;
        direnv.enable = true;
        git.enable = true;
      };
    };
    homeManager.common = nixosArgs@{ pkgs, config, ... }: {
      config = {
        programs.home-manager.enable = lib.mkDefault true;
        xdg.enable = lib.mkDefault true;
        systemd.user.startServices =
          lib.mkIf config.programs.home-manager.enable "sd-switch";
      };
    };
  };
}

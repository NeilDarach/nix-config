{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.common = nixosArgs@{ pkgs, config, ... }: {
      programs.fish.enable = true;
    };
    home-manager.common = nixosArgs@{ pkgs, config, ... }: {
      imports = with inputs.self.modules.nixos; [ direnv fish ];
      config = {
        programs.home-manager.enable = true;
        xdg.enable = true;
        systemd.user.startServices = "sd-switch";
      };
    };
  };
}

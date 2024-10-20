{ config, inputs, outputs, pkgs, user, lib, ... }: {
programs.direnv = lib.mkIf config.programs.direnv.enable {
      enableBashIntegration = true;
      nix-direnv.enable = true;
      config = builtins.fromTOML ''
        [global]
        hide_env_diff = true
      '';
    };
}

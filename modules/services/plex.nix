{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-plex =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.plex = {
          enable = lib.mkEnableOption "plex on this host";
        };
        config = lib.mkIf config.local.plex.enable {
          environment.persistence."/persist".directories = [
            {
              directory = "/var/lib/plex";
              user = "plex";
              group = "plex";
              mode = "u=rwx,g=rx,o=rx";
            }
          ];
          registration.service.plex = {
            description = "Plex Media Server";
            port = 32400;
          };

          services.plex = {
            enable = true;
            dataDir = "/var/lib/plex";
            openFirewall = true;
            user = "plex";
            group = "plex";
          };
        };
      };
  };
}

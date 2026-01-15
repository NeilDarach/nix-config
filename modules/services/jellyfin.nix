{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-jellyfin =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.jellyfin = {
          enable = lib.mkEnableOption "Jellyfin media server on this host";
        };
        config = lib.mkIf config.local.jellyfin.enable 
        {
          strongStateDir.service.jellyfin.enable = true;
          registration.service.jellyfin = {
            port = 8096;
            description = "Jellyfin Media Server";
          };

          services.jellyfin = {
            enable = true;
            dataDir = "/strongStateDir/jellyfin";
            openFirewall = true;
            user = "jellyfin";
            group = "jellyfin";
          };
        };
      };
  };
}

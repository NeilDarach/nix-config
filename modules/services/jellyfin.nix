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
        config = {
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

{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-gitea =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.gitea = {
          enable = lib.mkEnableOption "gitea on this host";
        };
        config = lib.mkIf config.local.gitea.enable {
          strongStateDir.service.gitea.enable = true;
          registration.service.gitea = {
            port = 3000;
            description = "Local git server";
          };
          networking.firewall.allowedTCPPorts = [ 3000 ];

          services.gitea = {
            enable = true;
            user = "gitea";
            group = "gitea";
            stateDir = "/strongStateDir/gitea";
          };
        };
      };
  };
}

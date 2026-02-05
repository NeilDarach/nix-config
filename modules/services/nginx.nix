{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-nginx =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.nginx = {
          enable = lib.mkEnableOption "nginx on this host";
        };
        config = lib.mkIf config.local.nginx.enable {
          services.nginx = {
            enable = true;
            defaultHTTPListenPort = 81;
            virtualHosts."gregor.darach.org.uk" = {
              locations."/" = {
                root = "/var/lib/nginx/www";
              };
            };
          };

          networking.firewall.allowedTCPPorts = [ 81 ];

          environment.persistence."/persist".directories = [
            {
              directory = "/var/lib/nginx";
              user = "nginx";
              group = "wheel";
              mode = "u=rwx,g=rwx,o=rx";
            }
          ];
        };
      };
  };
}

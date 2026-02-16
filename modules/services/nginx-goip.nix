{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-nginx-goip =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.nginx-goip = {
          enable = lib.mkEnableOption "nginx on the vps host";
        };
        config = lib.mkIf config.local.nginx-goip.enable {
          services.nginx = {
            enable = true;
            defaultHTTPListenPort = 80;
            virtualHosts = {
              "goip.org.uk" = {
                enableACME = true;
                forceSSL = true;
                extraConfig = ''
                  autoindex on;
                '';
                locations = {
                  "/" = {
                    root = "/strongStateDir/nginx";
                  };
                  "/charlie" = {
                    root = "/strongStateDir/nginx";
                    basicAuthFile = "/strongStateDir/nginx/charlie/.htpasswd";
                    extraConfig = ''
                      autoindex on;
                    '';
                  };
                  "/gff" = {
                    proxyPass = "http://darach.org.uk:3020/";
                  };
                };
              };
              "garageofinfiniteplenitude.org.uk" = {
                enableACME = true;
                forceSSL = true;
                locations = {
                  "/" = {
                    root = "/strongStateDir/nginx";
                  };
                  "/charlie" = {
                    basicAuthFile = "/strongStateDir/nginx/charlie/.htpasswd";
                    tryFiles = "$uri $uri/ $uri/index.html =404";
                    extraConfig = ''
                      autoindex on;
                    '';
                  };
                  "/gff" = {
                    proxyPass = "http://darach.org.uk:3020/";
                  };
                };
              };
            };
          };

          networking.firewall.allowedTCPPorts = [ 443 ];
          strongStateDir.service.nginx.enable = true;

        };
      };
  };
}

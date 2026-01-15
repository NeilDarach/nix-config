{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-grafana =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.grafana = {
          enable = lib.mkEnableOption "grafana on this host";
        };
        config = lib.mkIf config.local.grafana.enable {
          sops.secrets."grafana/admin_pw" = {
            owner = "grafana";
          };
          sops.secrets."grafana/secret_key" = {
            owner = "grafana";
          };
          strongStateDir.service.grafana.enable = true;
          services.grafana = {
            enable = true;
            dataDir = "/strongStateDir/grafana";
            openFirewall = true;
            settings = {
              server = {
                http_addr = "192.168.4.5";
                # gitea is using 3000
                http_port = 3001;
                domain = "grafana.darach.org.uk";
              };
              security = {
                admin_password = "$__file{${config.sops.secrets."grafana/admin_pw".path}}";
                admin_email = "neil.darach@gmail.com";
                secret_key = "$__file{${config.sops.secrets."grafana/secret_key".path}}";
              };
            };
          };

          registration.service.grafana = {
            port = 3001;
            description = "Grafana graphing engine";
          };
        };
      };
  };

}

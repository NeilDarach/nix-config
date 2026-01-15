{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-influxdb2 =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.influxdb2 = {
          enable = lib.mkEnableOption "influxdb2 on this host";
        };
        config = lib.mkIf config.local.influxdb2.enable {
          services.influxdb2 = {
            enable = true;
            provision = {
              enable = true;
              initialSetup = {
                organization = "Darach";
                bucket = "default";
                username = "admin";
                passwordFile = config.sops.secrets.influx-admin-pw.path;
                tokenFile = config.sops.secrets.influx-admin-token.path;
              };
              users = {
                homeassistant.passwordFile = config.sops.secrets.influx-ha-pw.path;
              };
              organizations = {
                "Darach" = {
                  buckets."homeassistant" = {
                    description = "HomeAssistant data";
                    retention = 0;
                  };
                  auths."ha" = {
                    description = "Token for Homeassistant authentication";
                    tokenFile = config.sops.secrets.influx-ha-token.path;
                    allAccess = true;
                  };
                };
              };
            };
          };

          networking.firewall.allowedTCPPorts = [ 8086 ];
          systemd.mounts = [
            {
              description = "Re-route the StateDirectory into /strongStateDir";
              where = "/var/lib/influxdb2";
              what = "/strongStateDir/influxdb";
              type = "none";
              options = "bind,noauto,nofail";
              requires = [ "strongStateDir-influxdb.mount" ];
            }
          ];
          sops.secrets.influx-ha-pw = {
            owner = "influxdb2";
          };
          sops.secrets.influx-admin-pw = {
            owner = "influxdb2";
          };
          sops.secrets.influx-ha-token = {
            owner = "influxdb2";
          };
          sops.secrets.influx-admin-token = {
            owner = "influxdb2";
          };

          strongStateDir.service.influxdb2 = {
            enable = true;
            datasetName = "influxdb";
            dataDir = "influxdb";
          };
          registration.service.influxdb2 = {
            description = "Influx time series database";
            port = 8086;
            alias = "influxdb";
          };

          systemd.services.influxdb2.requires = [ "var-lib-influxdb2.mount" ];
        };
      };
  };
}

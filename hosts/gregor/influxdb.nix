{ pkgs, config, outputs, ... }:
let utils = import ../../lib/svcUtils.nix;
in {
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
  systemd.mounts = [{
    description = "Re-route the StateDirectory into /strongStateDir";
    where = "/var/lib/influxdb2";
    what = "/strongStateDir/influxdb2";
    type = "none";
    options = "bind";
  }];
  sops.secrets.influx-ha-pw = { owner = "influxdb2"; };
  sops.secrets.influx-admin-pw = { owner = "influxdb2"; };
  sops.secrets.influx-ha-token = { owner = "influxdb2"; };
  sops.secrets.influx-admin-token = { owner = "influxdb2"; };

  systemd.timers.strongStateDir-backup-influxdb2 =
    (utils.zfsBackup "influxdb2" "influxdb2");
  services.strongStateDir.enable = true;
  systemd.services.influxdb2 = {

    serviceConfig = {
      ExecStartPost = [''
        +${pkgs.registration}/bin/registration influxdb 192.168.4.5 8086 "Influxdb Time Series Database"
      ''];
      ExecStop =
        [ "+${pkgs.coreutils}/bin/rm /var/run/registration-leases/influxdb2" ];
      wants = [
        "strongStateDir@influxdb2:influxdb2:infuxdb2:influxdb2.service"
        "var-lib-influxdb2.mount"
        "registration.timer"
      ];
    };
  };
}


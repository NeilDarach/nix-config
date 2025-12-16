{ pkgs, config, outputs, ... }:
let utils = import ../../lib/svcUtils.nix;
in {
  sops.secrets."grafana/admin_pw" = { owner = "grafana"; };
  sops.secrets."grafana/secret_key" = { owner = "grafana"; };
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
        admin_password =
          "$__file{${config.sops.secrets."grafana/admin_pw".path}}";
        admin_email = "neil.darach@gmail.com";
        secret_key =
          "$__file{${config.sops.secrets."grafana/secret_key".path}}";
      };
    };
  };

  systemd.timers.strongStateDir-backup-grafana =
    (utils.zfsBackup "grafana" "grafana");
  services.strongStateDir.enable = true;
  systemd.services.grafana = {

    serviceConfig = {
      ExecStartPost = [''
        +${pkgs.registration}/bin/registration grafana 192.168.4.5 3001 "Grafana graphing system"
      ''];
      ExecStop =
        [ "+${pkgs.coreutils}/bin/rm /var/run/registration-leases/grafana" ];
    };
    unitConfig = {
      requires = [ "registration.timer" "strongStateDir-grafana.mount" ];
      after = [ "strongStateDir-grafana.mount" ];
    };
  };
  systemd.mounts = [{
    requires = [ "strongStateDir@grafana:grafana:grafana:grafana.service" ];
    after = [ "strongStateDir@grafana:grafana:grafana:grafana.service" ];
    description = "Mount the zfs filesystem for grafana";
    what = "zroot/strong/strongStateDir/grafana";
    where = "/strongStateDir/grafana";
    type = "zfs";
    options = "noauto,nofail";
  }];

}


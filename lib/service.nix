# Wants
# serviceName
# user
# group
# srcDataset
# dstDataset
# port
# serviceDescription

# users systemd services

{ pkgs, details, ... }: {
  users.users.neil.extraGroups = [ "${details.group or details.serviceName}" ];
  users.users."${details.user or details.serviceName}".homeMode = "0770";
  systemd.timers."strongStateDir-backup-${details.serviceName}" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 20:03:00";
      RandomizedDelaySec = "1200";
      Unit = "zfs-backup@${details.srcDataset or details.serviceName}:${
          details.dstDataset or details.serviceName
        }.service";
    };
  };
  services.strongStateDir.enable = true;
  #  services."${details.serviceName}" = {
  #enable = true;
  #dataDir = "/strongStateDir/${details.serviceName}";
  #};
  systemd.services."${details.serviceName}" = {
    enable = true;
    serviceConfig = {
      LogsDirectory = "${details.serviceName}";
      LogsDirectoryMode = "0770";
      UMask = pkgs.lib.mkForce "0007";
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration ${details.serviceName} 192.168.4.5 ${
            toString details.port
          } "${details.serviceDescription}"''
      ];
      ExecStop = [
        "+${pkgs.coreutils}/bin/rm /var/run/registration-leases/${details.serviceName}"
      ];
    };
    wants = [
      "registration.timer"
      "strongStateDir@${details.srcDataset or details.serviceName}:${
        details.user or details.serviceName
      }:${details.group or details.serviceName}:${
        details.dstDataset or details.serviceName
      }.service"
    ];
  };
}

{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.registration;
in {
  options.services.registration = {
    enable = mkEnableOption "Register services with the proxy";

    package = mkOption {
      type = types.package;
      default = pkgs.registration;
      defaultText = "pkgs.registration";
      description = "The package to use to implement lease re-registration";
    };

    leaseDir = mkOption {
      type = types.path;
      description = "Diretory where lease files will be written";
      default = "/var/run/registration-leases";
    };
  };
  config = mkIf cfg.enable {
    systemd.timers."registration" = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "registration.service";
      };
    };
    systemd.services."registration" = {
      description = "Renew ETCD leases for running services";
      script = ''
        ${pkgs.registration}/bin/registration -r
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };

    };
  };
}

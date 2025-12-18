{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.registration;
  registrationType = lib.types.submodule ({ name, ... }: {
    options = {
      serviceName = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
      };
      port = lib.mkOption { type = lib.types.int; };
      alias = lib.mkOption {
        type = lib.types.str;
        default = name;
      };
      description = lib.mkOption { type = lib.types.str; };
    };
  });
in {
  options.registration = lib.mkOption {
    type = lib.types.attrsOf registrationType;
    default = { };
  };
  config = {
    systemd.services = (lib.attrsets.mapAttrs' (k: v: {
      name = v.serviceName;
      value = {
        serviceConfig = {
          ExecStartPost = [''
            +${pkgs.registration}/bin/registration ${v.alias} ${v.host} ${
              toString v.port
            }" "${v.description}"
          ''];
          ExecStop = [
            "+${pkgs.coreutils}/bin/rm /var/run/registration-leases/${v.alias}"
          ];
        };
        requires = [ "registration.timer" ];
        after = [ "registration.timer" ];
      };
    }) cfg) // lib.optionals (0 != length (attrNames cfg)) {
      registration = {
        description = "Renew ETCD leases for running services";
        script = ''
          ${pkgs.registration}/bin/registration -r
        '';
        serviceConfig = {
          type = "oneshot";
          User = "root";
        };
      };
    };

    systemd.timers.registration = lib.optionals (0 != length (attrNames cfg)) {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1m";
        OnUnitActiveSec = "1m";
        Unit = "registration.service";
      };
    };
  };
}

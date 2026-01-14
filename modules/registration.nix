{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.registration =
      nixosArgs@{ pkgs, config, ... }:

      let
        cfg = config.registration;
        registrationType = lib.types.submodule (
          { name, ... }:
          {
            options = {
              serviceName = lib.mkOption {
                type = lib.types.str;
                default = name;
              };
              serviceHost = lib.mkOption {
                type = lib.types.str;
                default = cfg.serviceHost;
              };
              etcdHost = lib.mkOption {
                type = lib.types.str;
                default = cfg.etcdHost;
              };
              port = lib.mkOption { type = lib.types.int; };
              alias = lib.mkOption {
                type = lib.types.str;
                default = name;
              };
              description = lib.mkOption { type = lib.types.str; };
            };
          }
        );
      in
      {
        options.registration = {
          serviceHost = lib.mkOption {
            type = lib.types.str;
            default = config.networking.hostName;
          };
          etcdHost = lib.mkOption {
            type = lib.types.str;
            default = "localhost:2379";
          };
          service = lib.mkOption {
            type = lib.types.attrsOf registrationType;
            default = { };
          };
        };
        config = {
          systemd.services =
            (lib.attrsets.mapAttrs' (k: v: {
              name = v.serviceName;
              value = {
                environment = {
                  ETCDCTL_ENDPOINTS = v.etcdHost;
                };
                serviceConfig = {
                  ExecStartPost = [
                    ''
                      +${pkgs.registration}/bin/registration ${v.alias} ${v.serviceHost} "${toString v.port}" "${v.description}"
                    ''
                  ];
                  ExecStop = [
                    "+${pkgs.coreutils}/bin/rm /var/run/registration-leases/${v.alias}"
                  ];
                };
                requires = [ "registration.timer" ];
                after = [ "registration.timer" ];
              };
            }) cfg.service)
            // lib.optionals (0 != lib.length (lib.attrNames cfg.service)) {
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

          systemd.timers.registration = lib.optionals (0 != lib.length (lib.attrNames cfg.service)) {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "1m";
              OnUnitActiveSec = "1m";
              Unit = "registration.service";
            };
          };
        };
      };
  };
}

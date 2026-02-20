{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.strongStateDir =
      nixosArgs@{ pkgs, config, ... }:

      let
        zfsBackup = src: dest: {
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = "Sun 20:03:000";
            RandomizedDelaySec = "1200";
            Unit = "zfs-backup@${src}:${dest}.service";
          };
        };
        cfg = config.strongStateDir;
        strongStateDirType = lib.types.submodule (
          { name, ... }:
          let
            svc = config.systemd.services."${config.strongStateDir.service."${name}".serviceName}";
          in
          {
            options = {
              enable = lib.mkEnableOption "Enable strongStateDir for this service";
              serviceName = lib.mkOption {
                type = lib.types.str;
                default = name;
              };
              dataDir = lib.mkOption {
                type = lib.types.str;
                default = name;
              };
              datasetName = lib.mkOption {
                type = lib.types.str;
                default = name;
              };
              localUser = lib.mkOption {
                type = lib.types.str;
                default = svc.serviceConfig.User;
              };
              localGroup = lib.mkOption {
                type = lib.types.str;
                default = config.users.users.${svc.serviceConfig.User}.group;
              };
            };
          }
        );
      in
      {
        options.strongStateDir = {
          package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.strongStateDir;
            defaultText = "pkgs.strongStateDir";
            description = "The packages used to implement stongStateDir creation";
          };
          service = lib.mkOption {
            type = lib.types.attrsOf strongStateDirType;
            default = { };
          };
        };
        config =
          let
            enabled = lib.attrsets.filterAttrs (k: v: v.enable) cfg.service;
            anyEnabled = 0 != lib.length (lib.attrValues enabled);
          in
          lib.mkIf anyEnabled {
            programs.ssh = {
              extraConfig = ''
                Host backup
                  HostName vps.goip.org.uk
                  User backup
                  IdentityFile ~/.ssh/id_backup
                  AddressFamily inet
              '';
              knownHosts = {
                "backup" = {
                  hostNames = [ "vps.goip.org.uk" ];
                  publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOEvCdE2EkfumIXKKY9lixReNsKh9rL+1dhGjrMemXWk neil@gregor";
                };
              };
            };
            systemd.timers = lib.attrsets.mapAttrs' (k: v: {
              name = "strongStateDir-backup-${v.serviceName}";
              value = zfsBackup "${v.dataDir}" "${v.dataDir}";
            }) enabled;

            systemd.mounts = builtins.map (v: {
              requires = [
                "strongStateDir@${v.datasetName}:${v.localUser}:${v.localGroup}:${v.datasetName}.service"
              ];
              after = [
                "strongStateDir@${v.datasetName}:${v.localUser}:${v.localGroup}:${v.datasetName}.service"
              ];
              description = "Mount the zfs filesystem for ${v.serviceName}";
              what = "zroot/strong/strongStateDir/${v.datasetName}";
              where = "/strongStateDir/${v.dataDir}";
              type = "zfs";
              options = "noauto,nofail";
            }) (lib.attrValues enabled);

            systemd.services =
              (lib.attrsets.mapAttrs' (k: v: {
                name = v.serviceName;
                value = {
                  requires = [ "strongStateDir-${v.datasetName}.mount" ];
                  after = [ "strongStateDir-${v.datasetName}.mount" ];
                };
              }) enabled)
              // {
                "strongStateDir@" = {
                  description = "Set up the state dir";
                  requires = [ "network-online.target" ];
                  after = [ "network-online.target" ];

                  serviceConfig = {
                    Type = "oneshot";
                    User = "root";
                    ExecStart = "${pkgs.strongStateDir}/bin/strongStateDir %i";
                  };
                };

                "zfs-backup@" = {
                  description = "Backup a strongStateDir";
                  serviceConfig = {
                    Type = "oneshot";
                    User = "root";
                    ExecStart = "${pkgs.zfs-backup}/bin/zfs-backup %i";
                  };
                };
              };
          };
      };
  };
}

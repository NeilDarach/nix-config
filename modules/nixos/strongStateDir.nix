{ config, lib, pkgs, ... }:
with lib;
let
  utils = import ../../lib/svcUtils.nix;
  cfg = config.strongStateDir;
  strongStateDirType = lib.types.submodule ({ name, ... }:
    let
      svc =
        config.systemd.services."${config.strongStateDir.service."${name}".serviceName}";
    in {
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
    });
in {
  options.strongStateDir = {
    package = mkOption {
      type = types.package;
      default = pkgs.strongStateDir;
      defaultText = "pkgs.strongStateDir";
      description = "The packages used to implemnt stongStateDir creation";
    };
    service = lib.mkOption {
      type = lib.types.attrsOf strongStateDirType;
      default = { };
    };
  };
  config = let
    enabled = lib.attrsets.filterAttrs (k: v: v.enable) cfg.service;
    anyEnabled = 0 != length (attrValues enabled);
  in lib.mkIf anyEnabled {
    systemd.timers = lib.attrsets.mapAttrs' (k: v: {
      name = "strongStateDir-backup-${v.serviceName}";
      value = utils.zfsBackup "${v.dataDir}" "${v.dataDir}";
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

    systemd.services = (lib.attrsets.mapAttrs' (k: v: {
      name = v.serviceName;
      value = {
        requires = [ "strongStateDir-${v.datasetName}.mount" ];
        after = [ "strongStateDir-${v.datasetName}.mount" ];
      };
    }) enabled) // {
      "strongStateDir@" = {
        description = "Set up the state dir";
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
}

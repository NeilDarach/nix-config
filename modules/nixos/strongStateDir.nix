{ config, lib, pkgs, ... }:
with lib;
let cfg = config.services.strongStateDir;
in {
  options.services.strongStateDir = {
    enable = mkEnableOption "Ensure that a zfs backed state dir is present";
    package = mkOption {
      type = types.package;
      default = pkgs.strongStateDir;
      defaultText = "pkgs.strongStateDir";
      description = "The packages used to implemnt stongStateDir creation";
    };
  };
  config = mkIf cfg.enable {
    systemd.services."strongStateDir@" = {
      description = "Set up the state dir";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${pkgs.strongStateDir}/bin/strongStateDir %i";
      };
    };

    systemd.services."zfs-backup@" = {
      description = "Backup a strongStateDir";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${pkgs.zfs-backup}/bin/zfs-backup %i";
      };
    };
  };

}

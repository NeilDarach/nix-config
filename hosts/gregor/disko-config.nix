{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sdx";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "";
        # Workaround: cannot import 'zroot': I/O error in disko tests
        options.cachefile = "none";
        rootFsOptions = {
          canmount = "off";
          acltype = "posix";
          listsnapshots = "on";
          atime = "off";
          relatime = "on";
          recordsize = "64k";
          dnodesize = "auto";
          xattr = "sa";
          normalization = "formD";
          secondarycache = "none";
          ashift = "12";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          local = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "false";
            options.mountpoint = "none";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook =
              "zfs list -t snapshot -H -o name | grep -E '^local/root@blank$' || zfs snapshot local/root@blank";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          stored = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "true";
            options.mountpoint = "none";
          };
          "stored/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
          "stored/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
          };
          reserved = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "true";
            options.mountpoint = "none";
            options.refreservation = "2G";
          };
        };
      };
    };
  };
  fileSystems = {
    "/".neededForBoot = true;
    "/nix".neededForBoot = true;
    "/home".neededForBoot = true;
    "/persist".neededForBoot = true;
    "/boot".neededForBoot = true;
  };
}

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WD_Blue_SN570_500GB_2239CA452011";
        content = {
          type = "gpt";
          partitions = {
            BOOT = {
              size = "1G";
              type = "0700";
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
          atime = "off";
          relatime = "on";
          recordsize = "64k";
          dnodesize = "auto";
          xattr = "sa";
          normalization = "formD";
          secondarycache = "none";
          "com.sun:auto-snapshot" = "false";
        };

        datasets = {
          weak = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "false";
            options.mountpoint = "none";
          };
          "weak/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook =
              "zfs list -t snapshot -H -o name | grep -E '^weak/root@blank$' || zfs snapshot zroot/weak/root@blank";
          };
          "weak/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
          strong = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "true";
            options.mountpoint = "none";
          };
          "strong/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
          };
          "strong/home" = {
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
    "/persist".neededForBoot = true;
    "/boot".neededForBoot = true;
  };
}

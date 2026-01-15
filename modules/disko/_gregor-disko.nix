let
  main = "/dev/disk/by-id/ata-KINGSTON_SV300S37A240G_50026B7762013410";
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = main;
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
          "com.sun:autosnapshot" = "false";
        };
        datasets = {
          week = {
            type = "zfs_fs";
            options."com.sun:auto-snapshot" = "false";
            options.mountpoint = "none";
          };
          "weak/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^weak/root@blank' || zfs snapshot zroot/weak/root@blank";
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
          "strong/keys" = {
            type = "zfs_fs";
            mountpoint = "/keys";
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
    "/keys".neededForBoot = true;
    "/persist".neededForBoot = true;
    "/boot".neededForBoot = true;
  };
}

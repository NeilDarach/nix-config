{ config, lib, ... }: {
  flake.modules = {
    nixos.r5s-disko = nixosArgs@{ pkgs, config, ... }:
      let
        emmc = "/dev/disk/by-id/mmc-AJTD4R_0xd9bdb60e";
        nvme = "/dev/disk/by-id/nvme-KINGSTON_SNV2S250G_50026B7785183EEF";
        bootloader = pkgs.stdenvNcCC.mkDerivation {
          name = "nanopi-r5s-loader";
          src = pkgs.fetchurl {
            url =
              "https://github.com/inindev/u-boot-build/releases/download/2025.01/rk3568-nanopi-r5s.zip";
            hash = "sha256-ZJYM1sjaS0wCQPqKuP8HxmqXpy+eaSyjvMnWakTvZ80=";
          };
        };
      in {
        options = { };
        config = {
          disko.devices = {
            disk = {
              emmc = {
                type = "disk";
                device = emmc;
                content = {
                  type = "gpt";
                  partitions = {
                    ESP = {
                      start = "32M";
                      size = "100%";
                      type = "EF00";
                      content = {
                        type = "filesystem";
                        format = "vfat";
                        mountpoint = "/boot";
                        mountOptions = [ "umask=0077" ];
                      };
                      postCreateHook = ''
                        echo "[*] installing the bootloader"
                        dd of=${emmc} if=${bootloader}/idbloader.img seek=8
                        dd of=${emmc} if=${bootloader}/u-boot.itb seek=2048
                      '';
                    };
                  };
                };
              };
              nvme = {
                type = "disk";
                device = nvme;
                content = {
                  type = "gpt";
                  partitions = {
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
                    postCreateHook =
                      "zfs list -t snapshot -H -o name | grep -E '^weak/root@blank' || zfs snapshot zroot/weak/root@blank";
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
            "/keys".neededForBoot = true;
            "/persist".neededForBoot = true;
            "/boot".neededForBoot = true;
            "/home".neededForBoot = true;
          };
        };
      };
  };
}


{ 
  lib, 
  config, 
  ... 
  } : 
  let
    hostname = config.networking.hostName;
  in {
    boot.initrd = {
      supportedFilesystems = [ "vfat" "zfs" ];
      availableKernelModules = [ "xhci_pci" "usbhid" "uas" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      postDeviceCommands = lib.mkAfter ''
        zpool import -f ${hostname}
        zfs rollback -r ${hostname}/local/root@blank
        '';
      };
    boot.kernelPackages = lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;

  fileSystems."/" =
    { device = lib.mkForce "${hostname}/local/root";
      fsType = lib.mkForce "zfs";
      neededForBoot = true;
    };

  fileSystems."/nix" =
    { device = "${hostname}/local/nix";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/persist" =
    { device = "${hostname}/safe/persist";
      fsType = "zfs";
      neededForBoot = true;
    };

  fileSystems."/home" =
    { device = "${hostname}/safe/home";
      fsType = "zfs";
    };

  fileSystems."/etc/nixos" =
    { device = "/persist/etc/nixos";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/persist" ];
      neededForBoot = true;
    };

  fileSystems."/var/log" =
    { device = "/persist/var/log";
      fsType = "none";
      options = [ "bind" ];
      depends = [ "/persist" ];
      neededForBoot = true;
    };

  fileSystems."/boot" =
    { device = lib.mkForce "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };

  swapDevices = [ ];

}

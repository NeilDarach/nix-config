{ lib, inputs, outputs, ... }: {
  imports = [
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
  ];

  boot.zfs.devNodes = "/dev/disk/by-id/nvme-WD_Blue_SN570_500GB_2239CA452011";
  boot.initrd.availableKernelModules =
    [ "xhci_pci" "usbhid" "uas" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

  boot = {
    loader = {
      systemd-boot.enable = lib.mkForce false;
      grub.enable = lib.mkForce false;
      grub.devices = [ "/dev/disk/by-label/SD_BOOT" ];
      generic-extlinux-compatible.enable = lib.mkForce false;
    };
    supportedFilesystems = [ "vfat" "zfs" "ext4" ];
  };

  raspberry-pi-nix = {
    board = "bcm2711";
    uboot.enable = true;
    #uboot.package = inputs.nixpkgs.u-boot-rpi4;
    firmware-migration-service.enable = true;
  };
    sdImage.firmwarePartitionName = "disk-emmc-FIRMWARE";
  hardware = {
    raspberry-pi."4".apply-overlays-dtmerge.enable = true;
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
    bluetooth.enable = true;
    raspberry-pi = {
      config = {
        all = {
          options = {
            kernel = {
              enable = true;
              value = lib.mkForce "u-boot-rpi4.bin";
            };
          };
          dt-overlays = { vc4-kms-v3d = { enable = false; }; };
          base-dt-params = {
            krnbt = {
              enable = true;
              value = "on";
            };
          };
        };
      };
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  fileSystems."/".fsType = lib.mkForce "zfs";
  fileSystems."/".device = lib.mkForce "zroot/weak/root";
}

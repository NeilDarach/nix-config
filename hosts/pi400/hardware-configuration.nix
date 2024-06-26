{
  lib,
  inputs,
  outputs,
  ...} : {
  imports =
    [ 
    inputs.raspberry-pi-nix.nixosModules.raspberry-pi
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ../common/optional/ephemeral-zfs.nix 
    ];

  boot.zfs.devNodes = "/dev/disk/by-id/usb-Micron_Crucial_X8_SSD_2152E480EFD6-0:0";
  boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "uas" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
      };
    supportedFilesystems = [ "vfat" "zfs" "ext4" ];
    };

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
	  dt-overlays = {
	    vc4-kms-v3d = {
	      enable = false;
	      };
	    };
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
}

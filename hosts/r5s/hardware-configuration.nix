{
  lib,
  inputs,
  config,
  outputs,
  ...
}: {
  imports = [
    inputs.nixos-hardware.nixosModules.friendlyarm-nanopi-r5s
    ../common/optional/ephemeral-zfs.nix
  ];

  fileSystems."/boot" = lib.mkForce {
    device = lib.mkForce "/dev/disk/by-id/mmc-AJTD4R_0xd9bdb60e-part1";
    fsType = "ext4";
  };

  boot = {
    #zfs.devNodes = "/dev/disk/by-id/nvme-KINGSTON_SNV2S250G_50026B7785183EEF";
    initrd.availableKernelModules = [
      "xhci_pci"
      "usbhid"
      "uas"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
      ## Rockchip
      ## Storage
      "sdhci_of_dwcmshc"
      "dw_mmc_rockchip"
      "analogix_dp"
      "io-domain"
      "rockchip_saradc"
      "rockchip_thermal"
      "rockchipdrm"
      "rockchip-rga"
      "pcie_rockchip_host"
      "phy-rockchip-pcie"
      "phy_rockchip_snps_pcie3"
      "phy_rockchip_naneng_combphy"
      "phy_rockchip_inno_usb2"
      "dwmac_rk"
      "dw_wdt"
      "dw_hdmi"
      "dw_hdmi_cec"
      "dw_hdmi_i2s_audio"
      "dw_mipi_dsi"
    ];
    kernelParams = [
      "console=tty1"
      "console=ttyS2,1500000"
      "earlycon=uart8250,mmio32,0xfe660000"
    ];
    blacklistedKernelModules = ["rtc_rk808"];
    loader = {
      timeout = 3;
      grub.enable = false;

      generic-extlinux-compatible = {
        enable = true;
        useGenerationDeviceTree = true;
      };
    };
    supportedFilesystems = ["vfat" "zfs" "ext4" "f2fs" "exfat"];
  };

  hardware = {
    deviceTree = {
      name = "../../rk3568-nanopi-r5s.dtb";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
}

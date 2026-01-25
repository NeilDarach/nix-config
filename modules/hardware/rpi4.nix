{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.hardware-rpi4 =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
          inputs.nixos-hardware.nixosModules.raspberry-pi-4
        ];
        options.rpi4 = {
        };
        config = {
          nixpkgs.hostPlatform = "aarch64-linux";
          nixpkgs.config.allowUnfree = lib.mkDefault true;
          hardware.raspberry-pi."4".apply-overlays-dtmerge.enable = true;
          hardware.deviceTree = {
            enable = true;
            filter = "*rpi-4-*.dtb";
          };
          console.enable = false;
          environment.systemPackages = with pkgs; [
            libraspberrypi
            raspberrypi-eeprom
          ];

          hardware.firmware = [ pkgs.linux-firmware ];
          hardware.enableRedistributableFirmware = true;
          boot.loader = {
            grub.enable = false;
            generic-extlinux-compatible = {
              enable = true;
              useGenerationDeviceTree = true;
            };
            timeout = 1;
          };
          boot.kernelParams = [
            "console=tty0"
            "earlycon=uart8250,mmio32,0xfe660000"
          ];
          boot.initrd.kernelModules = [
          ];
          boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
          powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

        };
      };
  };
}

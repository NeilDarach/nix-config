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
          configTxt = lib.mkOption {
            type = lib.types.str;
            description = "The config.txt file to be written to the firmware partition";
            default = ''
              [pi4]
              kernel=u-boot.bin
              enable_gic=1
              armstub=armstub8-gic.bin
              disable_overscan=1
              arm_boost=1

              [all]
              arm_64bit=1
              enable_uart=1
              avoid_warnings=1
            '';
          };
        };
        config = {
          nixpkgs.hostPlatform = "aarch64-linux";
          nixpkgs.config.allowUnfree = lib.mkDefault true;
          hardware = {
            #raspberry-pi."4".apply-overlays-dtmerge.enable = true;
            firmware = [ pkgs.linux-firmware ];
            enableRedistributableFirmware = true;
            deviceTree = {
              enable = true;
              name = "broadcom/bcm2711-rpi-4-b.dtb";
            };
          };
          console.enable = false;
          environment.systemPackages = with pkgs; [
            libraspberrypi
            raspberrypi-eeprom
          ];

          boot = {
            loader = {
              grub.enable = false;
              generic-extlinux-compatible.enable = lib.mkForce false;
              timeout = 1;
            };
            initrd = {
              systemd.enable = true;
              systemd.root = "gpt-auto";
              supportedFilesystems.ext4 = true;
            };
            kernelParams = [
              "console=tty0"
              "earlycon=uart8250,mmio32,0xfe660000"
            ];
            initrd.kernelModules = [
            ];
            kernelPackages = pkgs.linuxPackages_latest;
          };
          powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

        };
      };
  };
}

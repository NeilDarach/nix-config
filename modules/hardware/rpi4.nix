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
            description = "contents of the config.txt of the pi's firmware partiion";
          };
        };
        config = {
          nixpkgs.hostPlatform = "aarch64-linux";
          hardware.deviceTree = {
            enable = true;
            name = "broadcom/bcm2711-rpi-4-b.dtb";
          };
          boot = {
            initrd = {
              systemd.enable = true;
              systemd.root = "gpt-auto";
              supportedFilesystems.ext4 = true;
            };
            loader = {
              generic-extlinux-compatible.enable = lib.mkForce false;
              grub.enable = false;
            };
          };
        };
      };
  };
}

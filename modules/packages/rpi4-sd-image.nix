{
  config,
  nixpkgs,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  configurations.nixos.rpi4-sd.module =
    args@{ pkgs, lib, ... }:
    let
      efiArch = pkgs.stdenv.hostPlatform.efiArch;
      configTxt = pkgs.writeText "config.txt" thisConfig.rpi4.configTxt;
      thisConfig = config.flake.nixosConfigurations.rpi4-sd.config;
    in
    {
      imports = [ "${inputs.nixpkgs}/nixos/modules/image/repart.nix" ];

      systemd.repart.enable = true;
      systemd.repart.partitions."01-root".Type = "root";

      image.repart = {
        name = "rpi4-sd";
        compression = {
          enable = true;
          algorithm = "xz";
        };
        partitions = {
          "01-esp" = {
            contents = {
              "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
                "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
              "/EFI/Linux/${thisConfig.system.boot.loader.ukiFile}".source =
                "${thisConfig.system.build.uki}/${thisConfig.system.boot.loader.ukiFile}";
              "/u-boot.bin".source = "${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin";
              "/armstub8-gic.bin".source = "${pkgs.raspberrypi-armstubs}/armstub8-gic.bin";
              "/config.txt".source = configTxt;
              "/".source = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
            };
            repartConfig = {
              Type = "esp";
              Format = "vfat";
              LABEL = "ESP";
              SizeMinBytes = "512M";
            };
          };
          "02-root" = {
            storePaths = [ thisConfig.system.build.toplevel ];
            repartConfig = {
              Type = "root";
              Format = "ext4";
              Label = "nixos";
              Minimize = "guess";
              GrowFileSystem = true;
            };
          };
        };
      };
    };
  perSystem =
    per@{ inputs', pkgs, ... }:
    let
      image = config.flake.nixosConfigurations.rpi4-sd;
    in
    {
      packages = {
        rpi4-sd-image = image.config.system.build.image;
      };
    };
}

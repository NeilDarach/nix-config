{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.rpi4-repart =
      nixosArgs@{ pkgs, config, ... }:
      {
        options = { };
        config =
          let
            efiArch = pkgs.stdenv.hostPlatform.efiArch;
            configTxt = pkgs.writeText "config.txt" config.rpi4.configTxt;
          in
          {

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
                    "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
                      "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
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
                  storePaths = [ config.system.build.toplevel ];
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
      };
  };
}

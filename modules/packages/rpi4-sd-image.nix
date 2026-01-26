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
    args@{
      pkgs,
      lib,
      config,
      ...
    }:
    let
      efiArch = pkgs.stdenv.hostPlatform.efiArch;
      configTxt = pkgs.writeText "config.txt" ''
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
      #thisConfig = config.flake.nixosConfigurations.rpi4-sd.config;
    in
    {
      imports = [
        "${inputs.nixpkgs}/nixos/modules/profiles/minimal.nix"
        inputs.nixos-hardware.nixosModules.raspberry-pi-4
        "${inputs.nixpkgs}/nixos/modules/image/repart.nix"
      ];

      nixpkgs.hostPlatform = "aarch64-linux";
      # configuration.nix
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      environment.systemPackages = with pkgs; [
        vim
        git
      ];

      services.openssh.enable = true;
      networking.hostName = "nixos";
      users.users.nix = {
        password = "nix";
        isNormalUser = true;
        description = "nix";
        extraGroups = [
          "wheel"
        ];
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
        ];
      };
      networking = {
        useDHCP = lib.mkForce true;
        hostId = "d9165afe";
      };

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
      };

      ### repart.nix
      systemd.repart.enable = true;
      systemd.repart.partitions."01-root".Type = "root";
      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.root = "gpt-auto";
      boot.initrd.supportedFilesystems.ext4 = true;

      boot.loader = {
        generic-extlinux-compatible.enable = lib.mkForce false;
        grub.enable = false;
      };
      hardware.deviceTree.enable = true;
      hardware.deviceTree.name = "broadcom/bcm2711-rpi-4-b.dtb";

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

      #-----
      #nixpkgs.hostPlatform = "aarch64-linux";
      #nixpkgs.config.allowUnfree = lib.mkDefault true;
      #hardware = {
      ##raspberry-pi."4".apply-overlays-dtmerge.enable = true;
      #firmware = [ pkgs.linux-firmware ];
      #enableRedistributableFirmware = true;
      #};
      #console.enable = false;

      #boot = {
      #kernelParams = [
      #"console=tty0"
      #"earlycon=uart8250,mmio32,0xfe660000"
      #];
      #initrd.kernelModules = [
      #];
      #};
      #powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

      #local.useZfs = true;

      #boot.tmp.useTmpfs = true;
      #time.timeZone = "Europe/London";

      #environment.systemPackages = with pkgs; [
      #git
      #mc
      #psmisc
      #curl
      #wget
      #dig
      #file
      #nvd
      #ethtool
      #sysstat
      #neovim
      #dnsutils
      #jq
      #unzip
      #usbutils
      #lsof
      #];
      #
      #security.sudo.wheelNeedsPassword = false;
      #nix.settings.
      #i18n = {
      #defaultLocale = "en_GB.UTF-8";
      #};
      #environment.etc = {
      #"systemd/journald.conf.d/99-storage.conf".text = ''
      #[Journal]
      #Storage=volatile
      #'';
      #};
      #system.stateVersion = lib.mkDefault "25.11";
      #

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

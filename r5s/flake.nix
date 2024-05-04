{
  description = "R5S Image";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };
  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
  }: let
    imports = [
      nixos-hardware.nixosModules.friendlyarm-nanopi-r5s
    ];
    system = "aarch64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };

    nixosConfigurations.r5s = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [
        "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
        ({config, ...}: {
          config = {
            networking = {
              hostName = "r5s";
              domain = "darach.org.uk";
              hostId = "95849000";
              wireless.enable = false;
              useDHCP = true;
            };

            fileSystems."/" = {
              device = nixpkgs.lib.mkForce "/dev/mmcblk0p2";
              fsType = nixpkgs.lib.mkForce "ext4";
              neededForBoot = true;
            };

            swapDevices = [];

            boot = {
              kernelPackages = nixpkgs.lib.mkForce config.boot.zfs.package.latestCompatibleLinuxPackages;
              initrd = {
                supportedFilesystems = ["vfat" "zfs" "ext4" "ext2" "exfat"];
                availableKernelModules = [
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
              };

              loader = {
                timeout = 3;
                grub.enable = false;
                generic-extlinux-compatible = {
                  enable = true;
                  useGenerationDeviceTree = true;
                };
              };
              blacklistedKernelModules = ["rtc_rk808"];
              kernelParams = [
                "console=tty1"
                "console=ttyS2,1500000"
                "earlycon=uart8250,mmio32,0xfe660000"
              ];
            };
            nixpkgs.hostPlatform = nixpkgs.lib.mkDefault "aarch64-linux";
            powerManagement.cpuFreqGovernor = nixpkgs.lib.mkDefault "schedutil";
            hardware = {
              deviceTree = {
                name = "../../rk3568-nanopi-r5s.dtb";
              };
            };
            time.timeZone = "Europe/London";
            i18n.defaultLocale = "en_GB.UTF-8";
            i18n.extraLocaleSettings = {
              LC_ADDRESS = "en_GB.UTF-8";
              LC_IDENTIFICATION = "en_GB.UTF-8";
              LC_MEASUREMENT = "en_GB.UTF-8";
              LC_MONETARY = "en_GB.UTF-8";
              LC_NAME = "en_GB.UTF-8";
              LC_NUMERIC = "en_GB.UTF-8";
              LC_PAPER = "en_GB.UTF-8";
              LC_TELEPHONE = "en_GB.UTF-8";
              LC_TIME = "en_GB.UTF-8";
            };

            console.enable = true;
            sdImage = {
              compressImage = false;
              expandOnBoot = true;
              firmwareSize = 500;
              populateRootCommands = ''
                 mkdir -p ./files/boot
                cp "${self}/rk3568-nanopi-r5s.dtb" files/boot
              '';
            };
            console.keyMap = "uk";

            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN03gXcnqBMtsi1oD1xM1QJjFhgfzCwW+aez5FMfoHKl nixos-build"
            ];

            services.openssh = {
              enable = true;
              knownHosts = {
                nixos-build.hostNames = ["nixos-build.darach.org.uk"];
                nixos-build.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9qKrfo5/UkLCIU9kYNvzHkfVPpajZtvie7FHqMain1";
                github.hostNames = ["github.com"];
                github.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
              };
            };

            nix.settings.experimental-features = ["nix-command" "flakes" "repl-flake"];
            nix.distributedBuilds = true;
            nix.buildMachines = [
              {
                hostName = "nixos-build";
                systems = ["aarch64-linux"];
                maxJobs = 8;
                speedFactor = 2;
                supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
              }
            ];

            programs.ssh.extraConfig = ''
              Host nixos-build
                  HostName nixos-build.darach.org.uk
                  port 22
                  user neil
                  IdentitiesOnly yes
                  IdentityFile /root/.ssh/id_nixos-build
            '';

            system = {
              stateVersion = "23.11";
            };
            environment.systemPackages = [pkgs.neovim pkgs.git pkgs.curl];
          };
        })
      ];
    };
  in {
    image.r5s = nixosConfigurations.r5s.config.system.build.sdImage;
  };
}

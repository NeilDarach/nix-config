{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.hardware-r5s = nixosArgs@{ pkgs, config, ... }: {
      imports = with inputs.self.modules.nixos; [ hardware-r5s-netdriver ];
      options.nanopi-r5s = {
        nics = lib.mkOption {
          type = lib.types.listOf (lib.types.attrsOf lib.types.str);
          default = [
            {
              name = "wan0";
              path = "platform-fe2a0000.ethernet";
            }
            {
              name = "lan1";
              path = "platform-3c000000.ethernet";
            }
            {
              name = "lan2";
              path = "platform-3c040000.ethernet";
            }
          ];
          description =
            "The default names and identifiers of the network interfaces";
        };
        bootloader = {
          dtb = lib.mkOption {
            type = lib.types.str;
            default = "rockchip/rk3568-nanopi-r5s.dtb";
            description = "The device file to use when booting";
          };
          url = lib.mkOption {
            type = lib.types.str;
            default =
              "https://github.com/inindev/u-boot-build/releases/download/2025.01/rk3568-nanopi-r5s.zip";
            description = "The source of an r5s compatible u-boot distribution";
          };
          hash = lib.mkOption {
            type = lib.types.str;
            default = "sha256-ZJYM1sjaS0wCQPqKuP8HxmqXpy+eaSyjvMnWakTvZ80=";
            description = "The hash of the file in nanopi-r5s.bootloader.url";
          };
        };

        network.interfaces = builtins.listToAttrs (builtins.map (nic:
          lib.nameValuePair nic.name {
            name = lib.mkOption {
              type = lib.types.str;
              default = nic.name;
              description = "Interface name for ${nic.name}";
            };
            mac = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description =
                "Mac address for ${nic.name}, if unset a random address will be created on boot";
            };
          }) config.nanopi-r5s.nics);
      };
      config = {
        hardware.firmware = [ pkgs.linux-firmware ];
        hardware.deviceTree.name = "rockchip/rk3568-nanopi-r5s.dtb";
        boot.loader = {
          grub.enable = false;
          generic-extlinux-compatible = {
            enable = true;
            useGenerationDeviceTree = true;
          };
          timeout = 1;
        };
        boot.kernelParams =
          [ "console=tty0" "earlycon=uart8250,mmio32,0xfe660000" ];
        boot.initrd.kernelModules = [
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
        powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";

        systemd.network.links = builtins.listToAttrs (builtins.map (nic:
          let opts = config.nanopi-r5s.network.interfaces.${nic.name};
          in lib.nameValuePair "10-${nic.name}" {
            matchConfig = { Path = nic.path; };
            linkConfig = {
              Name = opts.name;
            } // (if (opts.mac != null) then {
              MACAddress = opts.mac;
            } else
              { });
          }) config.nanopi-r5s.nics);
      };
    };
  };
}


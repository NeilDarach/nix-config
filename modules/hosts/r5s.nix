{
  self,
  config,
  inputs,
  ...
}:
let
  inherit (config.flake.modules) nixos home-manager;
  devmode = false;
  main_ip = "192.168.4.2";
  iot_ip = "192.168.5.2";
in
{
  configurations.nixos.r5s.module =
    args@{
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [
        nixos.hardware-r5s
        nixos.impermanence
        nixos.home-manager
        inputs.disko.nixosModules.disko
        nixos.overlays
        nixos.sops
        inputs.sops-nix.nixosModules.sops
        nixos.common
        nixos.user-neil
        nixos.user-root
        inputs.home-manager.nixosModules.home-manager
        self.diskoConfigurations.r5s
      ];
      boot.supportedFilesystems = [ "vfat" ];
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = true;
        "net.ipv6.conf.all.forwarding" = true;

        # https://github.com/mdlayher/homelab/blob/master/nixos/routnerr-2/configurtion
        "net.ipv6.conf.all.accept_ra" = 0;
        "net.ipv6.conf.all.autoconf" = 0;
        "net.ipv6.conf.all.use_tempaddr" = 0;

        "net.ipv6.conf.wan0.accept_ra" = 2;
        "net.ipv6.conf.wan0.autoconf" = 1;
      };

      local = {
        useZfs = true;
        useDistributedBuilds = true;
        pi-hole.enable = true;
        router-firewall.enable = true;
        wireguard.enable = true;
      };

      environment.systemPackages = with pkgs; [
        tcpdump
        conntrack-tools
        ethtool
      ];
      networking = {
        hostName = "r5s";
        useDHCP = false;
        enableIPv6 = lib.mkForce true;
      };

      networking.networkmanager.enable = lib.mkForce false;
      systemd.network = {
        enable = true;
        netdevs = {
          "10-br0" = {
            netdevConfig = {
              Kind = "bridge";
              Name = "br0";
            };
          };
          "20-vlan-iot" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "vlan-iot";
            };
            vlanConfig.Id = 5;
          };
        };
        networks = {
          "30-wan" = {
            matchConfig.Name = "wan0";
            networkConfig = {
              DHCP = "yes";
              #LinkLocalAddressing = "no";
              IPv6AcceptRA = true;
            };
            linkConfig.RequiredForOnline = "routable";
          };
          "30-lan1" = {
            matchConfig.Name = "lan1";
            networkConfig.Bridge = "br0";
            DHCP = "no";
            linkConfig.RequiredForOnline = "enslaved";
          };
          "30-lan2" = {
            matchConfig.Name = "lan2";
            networkConfig.Bridge = "br0";
            DHCP = "no";
            linkConfig.RequiredForOnline = "enslaved";
          };
          "40-br0" = {
            matchConfig.Name = "br0";
            bridgeConfig = { };
            vlan = [ "vlan-iot" ];
            address = [ "${main_ip}/24" ];
            DHCP = "no";
            networkConfig = {
              IPv4Forwarding = true;
              DHCPServer = "no";
              IPv6AcceptRA = false;
            };
            linkConfig.RequiredForOnline = "routable";
          };
          "40-vlan-iot" = {
            matchConfig.Name = "vlan-iot";
            DHCP = "no";
            address = [ "${iot_ip}/24" ];
            networkConfig = {
              IPv4Forwarding = true;
              DHCPServer = "no";
              IPv6AcceptRA = false;
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };
      };

      services.avahi = {
        enable = false;
        reflector = true;
        allowInterfaces = [
          "br0"
          "vlan-iot"
        ];
      };
    };
}

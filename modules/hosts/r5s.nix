{
  self,
  config,
  inputs,
  ...
}:
let
  inherit (config.flake.modules) nixos home-manager;
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
      local = {
        useZfs = true;
        useDistributedBuilds = true;
        jellyfin.enable = true;
      };

      networking.hostName = "r5s";
      networking.useDHCP = false;
      systemd.network = {
        enable = true;
        netdevs = {
          "10-br0" = {
            netdevConfig = {
              Kind = "bridge";
              Name = "br0";
            };
          };
          "20-vlan5" = {
            netdevConfig = {
              Kind = "vlan";
              Name = "vlan5";
            };
            vlanConfig.Id = 5;
          };
        };
        networks = {
          "30-lan1" = {
            matchConfig.Name = "lan1";
            networkConfig.Bridge = "br0";
            linkConfig.RequiredForOnline = "enslaved";
          };
          "30-lan2" = {
            matchConfig.Name = "lan2";
            networkConfig.Bridge = "br0";
            linkConfig.RequiredForOnline = "enslaved";
          };
          "40-br0" = {
            matchConfig.Name = "br0";
            bridgeConfig = { };
            vlan = [ "vlan5" ];
            address = [ "192.168.4.2/24" ];
            routes = [ { Gateway = "192.168.4.1"; } ];
            networkConfig = {
              DHCP = "no";
              IPv6AcceptRA = false;
            };
            linkConfig.RequiredForOnline = "routable";
          };
          "40-vlan5" = {
            matchConfig.Name = "vlan5";
            address = [ "192.168.5.2/24" ];
            routes = [ { Gateway = "192.168.5.1"; } ];
            networkConfig = {
              DHCP = "no";
              IPv6AcceptRA = false;
            };
            linkConfig.RequiredForOnline = "routable";
          };
        };
      };

      /*
          useDHCP = lib.mkForce false;
          interfaces = {
            lan1.useDHCP = false;
            lan2.useDHCP = false;
            br0 = {
              useDHCP = false;
              ipv4.addresses = [
                {
                  address = "192.168.4.2";
                  prefixLength = 24;
                }
              ];
            };
            vlan5 = {
              useDHCP = false;
              ipv4.addresses = [
                {
                  address = "192.168.5.2";
                  prefixLength = 24;
                }
              ];
            };
          };

          bridges = {
            "br0" = {
              interfaces = [
                "lan1"
                "lan2"
              ];
            };
          };
          vlans = {
            vlan5 = {
              id = 5;
              interface = "br0";
            };
          };
        };
      */
      system.stateVersion = lib.mkDefault "25.11";
    };
}

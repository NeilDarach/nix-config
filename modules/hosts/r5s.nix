{
  self,
  config,
  inputs,
  ...
}:
let
  inherit (config.flake.modules) nixos home-manager;
  devmode = true;
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
      sops.secrets = {
        "pppoe/cuckoo/username" = { };
        "wireguard/server/private" = {
          mode = "640";
          owner = "systemd-network";
          group = "systemd-network";
        };
      };

      environment.etc."ppp/pap-secrets" = {
        mode = "0600";
        text = "pppoe-username * @${config.sops.secrets."pppoe/cuckoo/username".path} *";
      };
      services.pppd = {
        enable = true;

        peers = {
          cuckoo = {
            autostart = true;
            enable = true;
            config = ''
              plugin pppoe.so wan0
              persist
              maxfail 0
              holdoff 5
              name pppoe-username
              password anything

              noipdefault
              defaultroute
            '';
          };
        };
      };

      local = {
        useZfs = true;
        useDistributedBuilds = true;
        jellyfin.enable = true;
      };

      environment.systemPackages = with pkgs; [
        tcpdump
        conntrack-tools
        ethtool
        ppp
      ];
      networking = {
        hostName = "r5s";
        useDHCP = false;
        firewall.allowedUDPPorts = [ 51820 ];
        enableIPv6 = lib.mkForce true;
        nftables = {
          enable = true;
          ruleset = ''
            table inet filter {
              #enable flow offloading for better throughput
              #flowtable f {
                #hook ingress priority 0;
                #devices = { ppp0, br0 };
              #}

              chain output {
                type filter hook output priority 100; policy accept;
              }

              chain input {
                type filter hook input priority filter;  policy drop;
                # Allow trusted networks access to the router
                iifname { "br0", "wg0" } counter accept

                # Allow returning traffic from ppp0 and drop everything else
                iifname "ppp0" ct state { established, related } counter accept
                iifname "ppp0" drop

                # mDNS for avahi reflection
                iifname "iot-vlan@br0" tcp dport { llmnr } counter accept
                iifname "iot-vlan@br0" udp dport { mdns, llmnr } counter accept
                }
               chain forward {
                 type filter hook forward priority filter; policy drop;
                 # enable flow offloading for better througput
                 #ip protocol { tcp, udp } flow offload @f

                 # Allow trusted network wan access
                 iifname { "br0", "wg0" } 
                   oifname { "ppp0" } 
                   counter accept comment "Trusted network to WAN"
                 iifname { "ppp0" } 
                   oifname { "br0", "wg0" } 
                   ct state established, related counter accept comment "Return established connection data"
                 }
               }
               table ip nat {
                 chain prerouting {
                   type nat hook prerouting priority filter; policy accept;
                   }
                 chain postrouting {
                   type nat hook postrouting priority filter; policy accept;
                   oifname "ppp0" masquerade
                 }
               }
          '';
        };

        nat = {
          enable = true;
          enableIPv6 = true;
          externalInterface = "pppoe-wan";
          internalInterfaces = [
            "br0"
            "wg0"
          ];
        };
      };
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
          "50-wg0" = {
            netdevConfig = {
              Kind = "wireguard";
              Name = "wg0";
            };
            wireguardConfig = {
              RouteTable = "main";
              FirewallMark = 42;
              ListenPort = 51820;
              PrivateKeyFile = "${config.sops.secrets."wireguard/server/private".path}";
            };
            wireguardPeers = [
              {
                # Neil's iPhone
                PublicKey = "DNxpMqjysu33ZC82l+4fov2+7p4eA8pp2ZsVHG4Kuzs=";
                AllowedIPs = [ "192.168.9.9/32" ];
              }
              {
                # Neil's Laptop
                PublicKey = "jzq1KL7o110tOiOUu1qAoi5HlMKcN3fpkRhYm7WakQQ=";
                AllowedIPs = [ "192.168.9.7/32" ];
              }
              {
                # Marion's iPad
                PublicKey = "1IKRTwh+cckkkffgdKAojX1TI3ceUoE8jN/EQDEmvW4=";
                AllowedIPs = [ "192.168.9.21/32" ];
              }
              {
                # Marion's iPhone
                PublicKey = "yWcgqaFB35liq1nKsDyzPjGdkp2FV1w38EQGjsO1y3g=";
                AllowedIPs = [ "192.168.9.22/32" ];
              }
            ];
          };
        };
        networks = {
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
            address = [ "192.168.4.2/24" ];
            routes = lib.optionals devmode [ { Gateway = "192.168.4.1"; } ];
            DHCP = "no";
            networkConfig = {
              DHCPServer = if devmode then "no" else "yes";
              IPv6AcceptRA = false;
            };
            dhcpServerConfig = {
              PoolOffset = 100;
              PoolSize = 150;
              DefaultLeaseTimeSec = 900;
              EmitDNS = "yes";
              DNS = "192.168.4.2";
              EmitNTP = "yes";
              NTP = "192.168.4.2";
            };
            dhcpServerStaticLeases = [
              {
                Address = "192.168.4.5";
                MACAddress = "00:30:18:cc:7d:3e";
              }
            ];
            linkConfig.RequiredForOnline = "routable";
          };
          "40-vlan-iot" = {
            matchConfig.Name = "vlan-iot";
            address = [ "192.168.5.2/24" ];
            routes = lib.optionals devmode [ { Gateway = "192.168.5.1"; } ];
            DHCP = "no";
            networkConfig = {
              DHCPServer = if devmode then "no" else "yes";
              IPv6AcceptRA = false;
            };
            dhcpServerConfig = {
              PoolOffset = 100;
              PoolSize = 150;
              DefaultLeaseTimeSec = 900;
              EmitDNS = "yes";
              DNS = "192.168.5.2";
              EmitNTP = "yes";
              NTP = "192.168.5.2";
            };
            dhcpServerStaticLeases = [
            ];
            linkConfig.RequiredForOnline = "routable";
          };
          "50-wg0" = {
            matchConfig.Name = "wg0";
            address = [ "192.168.9.2/32" ];
            networkConfig = {
              IPv4Forwarding = true;
              IPv6Forwarding = true;
            };
          };

        };
      };

      services.avahi = {
        enable = true;
        reflector = true;
        allowInterfaces = [
          "br0"
          "vlan-iot@br0"
        ];
      };
      services.dhcpd4 = lib.mkIf (!devmode) {
        enable = true;
        interfaces = [
          "br0"
          "vlan-iot@br0"
        ];
        extraConfig = ''
          option domain-name-servers 192.168.4.2;
          option subnet-mask 255.255.255.0;

          subnet 192.168.4.0 netmask 255.255.255.0 {
            option broadcast-address 192.168.4.255;
            option routers 192.168.4.1;
            interface br0;
            range 192.168.4.100 192.168.4.200;
            }

          subnet 192.168.5.0 netmask 255.255.255.0 {
            option broadcast-address 192.168.5.255;
            option routers 192.168.5.1;
            interface vlan-iot@br0;
            range 192.168.5.100 192.168.5.200;
            }
        '';

      };

      system.stateVersion = lib.mkDefault "25.11";
    };
}

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
      sops.secrets = {
        "wireguard/server/private" = {
          mode = "640";
          owner = "systemd-network";
          group = "systemd-network";
        };
      };

      local = {
        useZfs = true;
        useDistributedBuilds = true;
      };

      environment.systemPackages = with pkgs; [
        tcpdump
        conntrack-tools
        ethtool
      ];
      networking = {
        hostName = "r5s";
        useDHCP = false;
        firewall.enable = true;
        firewall.allowedTCPPorts = [
          22
          53
          67
          68
          80
          88
          443
          1883
        ];
        firewall.allowedUDPPorts = [
          53
          67
          68
          51820
        ];
        enableIPv6 = lib.mkForce true;
        nftables = {
          enable = true;
          ruleset = ''
            define IOT = 192.168.5.0/24
            define LAN = 192.168.4.0/24
            define HA = 192.168.4.5/32

            table inet filter {
              chain output {
                type filter hook output priority 100; policy accept;
                }

              chain input {
                type filter hook input priority 0; policy drop;

                # Established/related connections
                ct state established,related accept

                # Loopback interface
                iifname lo accept
                ip saddr { $IOT, $LAN } accept
                accept
                }

              chain forward {
                type filter hook forward priority filter; policy drop; 
                ct state established, related accept
                ip saddr { $IOT } ip daddr { $HA, 192.168.5.2/32 } accept
                ip saddr { $LAN } accept
              }
              }

              table ip nat {
                chain prerouting { 
                  type nat hook prerouting priority filter; policy accept;
                  }

                chain postrouting {
                  type nat hook postrouting priority filter; policy accept;
                  oifname "wan0" masquerade
                  }
                }
          '';
        };

        nat = {
          enable = false;
          enableIPv6 = true;
          externalInterface = "ppp0";
          internalInterfaces = [
            "br0"
            "wg0"
          ];
          forwardPorts = [
            {
              destination = "192.168.4.5:32400";
              proto = "tcp";
              sourcePort = 32400;
            }
            {
              destination = "192.168.4.5:1883";
              proto = "tcp";
              sourcePort = 1883;
            }
            {
              destination = "192.168.4.5:8123";
              proto = "tcp";
              sourcePort = 8123;
            }
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
        };
        networks = {
          "30-wan" = {
            matchConfig.Name = "wan0";
            networkConfig = {
              DHCP = "yes";
              LinkLocalAddressing = "no";
              IPv6AcceptRA = false;
            };
            linkConfig.RequiredForOnline = "no";
            #linkConfig.Unmanaged = "yes";
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
      services.resolved.enable = false;
      services.dnsmasq = {
        enable = false;
        resolveLocalQueries = true;
        settings = {
          domain-needed = true;
          dhcp-authoritative = true;
          read-ethers = false;
          expand-hosts = true;
          bind-dynamic = true;
          address = [
            "/mqtt.darach.org.uk/192.168.4.5"
            "/mqtt.iot/192.168.4.5"
            "/darach.org.uk/192.168.4.5"
            "/etcd.darach.org.uk/192.168.4.5"
            "/r5s.darach.org.uk/${main_ip}"
            "/r5s.iot/${iot_ip}"
          ];
          except-interface = [
            "wan0"
            "wg0"
          ];
          stop-dns-rebind = true;
          rebind-localhost-ok = true;
          dhcp-broadcast = "tag:needs-broadcast";
          dhcp-ignore-names = "tag:dhcp_bogus_hostname";
          dhcp-host = [
            "00:30:18:cc:7d:3e,192.168.4.5"
            "7c:2f:80:89:1b:9e,192.168.4.6"
          ];
          domain = [
            "darach.org.uk,${main_ip}/24,local"
            "iot,${iot_ip}/24,local"
          ];
          dhcp-range = [
            "set:lan,192.168.4.100,192.168.4.200,255.255.255.0,12h"
            "set:iot,192.168.5.50,192.168.5.200,255.255.255.0,12h"
          ];
          dhcp-option = [
            "lan,option:router,${main_ip}"
            "lan,option:dns-server,${main_ip}"
            "lan,option:domain-name,darach.org.uk"
            "iot,option:router,${iot_ip}"
            "iot,option:dns-server,${iot_ip}"
            "iot,option:domain-name,iot"
          ];
        };
      };
      systemd.services.pihole-ftl = lib.mkIf config.services.pihole-ftl.enable {
        serviceConfig.StateDirectory = "pihole";
        serviceConfig.RuntimeDirectory = "pihole";
        serviceConfig.BindPaths = [ "/var/lib/misc" ];
      };
      systemd.tmpfiles.rules = lib.mkIf config.services.pihole-ftl.enable [
        "f /etc/pihole/versions 0644 pihole pihole - -"
        "d /var/lib/misc 0777 root root - -"
      ];
      services.pihole-ftl = {
        enable = true;
        lists = [
          {
            url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
            type = "block";
            enabled = true;
            description = "Steven Black's HOSTS";
          }
        ];

        openFirewallDNS = true;
        openFirewallDHCP = !devmode;
        openFirewallWebserver = true;
        queryLogDeleter.enable = true;
        settings = {
          dhcp.active = false;
          misc.readOnly = false;

          files.pid = "/run/pihole/pihole-FTL.pid";
          dns = {
            upstreams = [
              "1.1.1.1"
              "1.1.1.2"
            ];
            interface = "";
          };
          webserver = {
            api = {
              pwhash = "$BALLOON-SHA256$v=1$s=1024,t=32$+Xda1U5YIgOBuRYFYuxjBg==$lPaHrBGSYKonbgxVnDNJl9Xq7TXHsxIPJO7mqsWIc5k=";
            };
            session = {
              timeout = 43200; # 12h
            };
          };
        };
        useDnsmasqConfig = true;
      };
      services.pihole-web = {
        enable = config.services.pihole-ftl.enable;
        ports = [ 88 ];
      };
      system.stateVersion = lib.mkDefault "25.11";
    };
}

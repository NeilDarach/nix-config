{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-routerfirewall =
      nixosArgs@{ pkgs, config, ... }:
      let
        cannonicalizePortList = ports: lib.unique (builtins.sort builtins.lessThan ports);
        cannonicalizeInterfaceList = interfaces: lib.lists.uniqueStrings interfaces;
      in
      {
        imports = with inputs.self.modules.nixos; [ ];
        options = {
          local.router-firewall.enable = lib.mkEnableOption "firewall for the router";
          local.firewall.allowedInternalTCPPorts = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [ ];
            apply = cannonicalizePortList;
            example = [
              88
              1883
            ];
            description = "TCP ports to be opened for internal interfaces";
          };
          local.firewall.allowedInternalUDPPorts = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [ ];
            apply = cannonicalizePortList;
            example = [ 53 ];
            description = "UDP ports to be opened for internal interfaces";
          };
          local.firewall.allowedExternalTCPPorts = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [ ];
            apply = cannonicalizePortList;
            example = [ 22 ];
            description = "TCP ports to be opened for external interfaces";
          };
          local.firewall.allowedExternalUDPPorts = lib.mkOption {
            type = lib.types.listOf lib.types.port;
            default = [ ];
            apply = cannonicalizePortList;
            example = [ ];
            description = "UDP ports to be opened for external interfaces";
          };
          local.firewall.externalInterfaces = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            apply = cannonicalizeInterfaceList;
            example = [ "br0" ];
            description = "Interfaces to be treated as local for NFT port opening";
          };
          local.firewall.internalInterfaces = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            apply = cannonicalizeInterfaceList;
            example = [ "wan0" ];
            description = "Interfaces to be treated as external for NFT port opening";
          };
        };
        config = lib.mkIf config.local.router-firewall.enable {
          local.firewall.internalInterfaces = [
            "br0"
            "vlan-iot"
            "wg0"
          ];
          local.firewall.externalInterfaces = [ "wan0" ];
          local.firewall.allowedInternalTCPPorts = [
            22
            80
            443
            1883
          ];
          local.firewall.allowedExternalTCPPorts = [
            22
            80
            443
            3020
          ];
          local.firewall.allowedExternalUDPPorts = [ ];
          local.firewall.allowedInternalUDPPorts = [ ];
          networking = {
            firewall.enable = true;
            firewall.interfaces = lib.lists.fold (a: b: lib.recursiveUpdate a b) {} [
              (builtins.listToAttrs (
                map (n: {
                  name = n;
                  value = {
                    allowedTCPPorts = config.local.firewall.allowedInternalTCPPorts;
                  };
                }) config.local.firewall.internalInterfaces
              ))
               (builtins.listToAttrs (
                map (n: {
                  name = n;
                  value = {
                    allowedUDPPorts = config.local.firewall.allowedInternalUDPPorts;
                  };
                }) config.local.firewall.internalInterfaces)
              )
              (builtins.listToAttrs (
                map (n: {
                  name = n;
                  value = {
                    allowedTCPPorts = config.local.firewall.allowedExternalTCPPorts;
                  };
                }) config.local.firewall.externalInterfaces
              ))
              ( builtins.listToAttrs (
                map (n: {
                  name = n;
                  value = {
                    allowedUDPPorts = config.local.firewall.allowedExternalUDPPorts;
                  };
                }) config.local.firewall.externalInterfaces
              )) ];
            enableIPv6 = lib.mkForce true;
            nftables = {
              enable = true;
              ruleset = ''
                define IOT = 192.168.5.0/24
                define LAN = 192.168.4.0/24
                define WG = 192.168.9.0/24
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
                    ip saddr { $IOT, $LAN, $WG } accept
                    accept
                    }

                  chain forward {
                    type filter hook forward priority filter; policy drop; 
                    ct state established, related accept
                    #Allow all forwarded packets through
                    iif "wan0" oif { $LAN, $WG } ct status dnat accept
                    ip saddr { $IOT } ip daddr { $HA, 192.168.5.2/32 } accept
                    ip saddr { $LAN, $WG } accept
                  }
                  }

                  table ip nat {
                    chain prerouting { 
                      type nat hook prerouting priority filter; policy accept;
                      # Transmission port forward to gregor
                      udp dport 51413 dnat to 192.168.4.5:51413
                      tcp dport 51413 dnat to 192.168.4.5:51413
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
              externalInterface = "wan0";
              internalInterfaces = [
                "br0"
                "wg0"
                "vlan-iot"
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
        };
      };
  };
}

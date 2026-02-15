{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-wireguard =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.wireguard = {
          enable = lib.mkEnableOption "wireguard on this host";
        };
        config = lib.mkIf config.local.wireguard.enable {

          sops.secrets = {
            "wireguard/server/private" = {
              mode = "640";
              owner = "systemd-network";
              group = "systemd-network";
            };
          };
          local.firewall.allowedExternalUDPPorts = [ 51820 ];
          local.firewall.allowedInternalUDPPorts = [ 51820 ];
          systemd.network = {
            networks = {
              "50-wg0" = {
                matchConfig.Name = "wg0";
                address = [ "192.168.9.2/32" ];
                networkConfig = {
                  IPv4Forwarding = true;
                  IPv6Forwarding = true;
                };
              };
            };
            netdevs = {
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
          };
        };
      };
  };
}

{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-pihole =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [ ];
        options = {
          local.pi-hole.enable = lib.mkEnableOption "pi-hole ad blocker";
        };
        config = lib.mkIf config.local.pi-hole.enable {
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
                "/r5s.darach.org.uk/192.168.4.2"
                "/r5s.iot/192.168.5.2"
              ];
              except-interface = [
                "wan0"
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
                "darach.org.uk,192.168.4.0/24,local"
                "iot,192.168.5.0/24,local"
              ];
              dhcp-range = [
                "set:lan,192.168.4.100,192.168.4.200,255.255.255.0,12h"
                "set:iot,192.168.5.50,192.168.5.200,255.255.255.0,12h"
              ];
              dhcp-option = [
                "lan,option:router,192.168.4.2"
                "lan,option:dns-server,192.168.4.2"
                "lan,option:domain-name,darach.org.uk"
                "iot,option:router,192.168.5.2"
                "iot,option:dns-server,192.168.5.2"
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

            openFirewallDNS = false;
            openFirewallDHCP = false;
            openFirewallWebserver = false;
            queryLogDeleter.enable = true;
            settings = {
              dhcp.active = false;
              misc.readOnly = true;

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
          local.firewall.allowedInternalTCPPorts = [ 88 ];
          local.firewall.allowedInternalUDPPorts = [ 53 67 68 ];
          services.pihole-web = {
            enable = config.services.pihole-ftl.enable;
            ports = [ 88 ];
          };
        };
      };
  };
}

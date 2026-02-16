{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.fail2ban =
      { config, pkgs, ... }:
      {
        imports = with inputs.self.modules.nixos; [ http-tarpit ];

        config = lib.mkIf config.services.openssh.enable {
          systemd.services.fail2ban.partOf = [ "nftables.service" ];
          services.http-tarpit = {
            enable = true;
            port = 8081;
          };
          services.endlessh = {
            enable = true;
            port = 2222;
          };
          services.fail2ban = {
            enable = true;
            ignoreIP = [
              "192.168.4.0/24"
              "192.168.5.0/24"
              "192.168.9.0/24"
            ];
            bantime = "24h";
            extraPackages = [
              pkgs.gnugrep
              pkgs.gnused
            ];
            bantime-increment.enable = true;
            jails = {
              nginx-https.settings = {
              enable = true;
              port = 443;
              filter = "nginx-botsearch";
              backend = "systemd";
              action = "nftables-redirect-https";
                maxretry = 5;
                findtime = 300;
                bantime = "24h";
                };
              sshd.settings = {
                enabled = true;
                port = 22;
                filter = "sshd";
                backend = "systemd";
                action = "nftables-redirect-ssh";
                maxretry = 5;
                findtime = 300;
                bantime = "24h";
              };
            };
          };
          environment.etc = {
            "fail2ban/action.d/nftables-redirect-ssh.local".text = ''
              [Definition]
              actionstart = nft add table inet f2b-ssh
                            nft add chain inet f2b-ssh prerouting { type nat hook prerouting priority 0 \; }

              actionstop  = nft delete table inet f2b-ssh

              actionban   = nft add rule inet f2b-ssh prerouting ip saddr <ip> tcp dport 22 redirect to 2222

              actionunban = nft delete rule inet f2b-ssh prerouting handle $(nft -a list table inet f2b-ssh | grep <ip> | sed -e"s/.* //")

            '';
            "fail2ban/action.d/nftables-redirect-https.local".text = ''
              [Definition]
              actionstart = nft add table inet f2b-https
                            nft add chain inet f2b-https prerouting { type nat hook prerouting priority 0 \; }

              actionstop  = nft delete table inet f2b-https

              actionban   = nft add rule inet f2b-https prerouting ip saddr <ip> tcp dport 443 redirect to 8081

              actionunban = nft delete rule inet f2b-https prerouting handle $(nft -a list table inet f2b-https | grep <ip> | sed -e"s/.* //")

            '';
          };
        };
      };
  };
}

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
        config = lib.mkIf config.services.openssh.enable {
          systemd.services.fail2ban.partOf = [ "nftables.service" ];
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

              actionunban = nft delete rule inet f2b-ssh prerouting handle $(nft -a list ruleset | grep <ip> | sed -e"s/.* //")

            '';
          };
        };
      };
  };
}

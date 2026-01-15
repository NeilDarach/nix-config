{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-nfs =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.nfs = {
          enable = lib.mkEnableOption "nfs on this host";
        };
        config = lib.mkIf config.local.nfs.enable {
          services.nfs.server = {
            enable = true;
            lockdPort = 4001;
            mountdPort = 4002;
            statdPort = 4000;
            exports = ''
              /var/lib/nfs/yellow 192.168.4.89(rw,sync,no_subtree_check,no_root_squash)
            '';
          };

          networking.firewall.allowedTCPPorts = [
            111
            2049
            4000
            4001
            4002
          ];
          networking.firewall.allowedUDPPorts = [
            111
            2049
            4000
            4001
            4002
          ];

          environment.persistence."/persist".directories = [
            {
              directory = "/var/lib/nfs";
              user = "root";
              group = "root";
              mode = "u=rwx,g=rwx,o=rwx";
            }
          ];
        };
      };
  };
}

{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-tftpd =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.tftpd = {
          enable = lib.mkEnableOption "tftpd on this host";
        };
        config = lib.mkIf config.local.tftpd.enable {

          #fileSystems."/var/lib/tftp/93fed9e9" = {
          #device = "/var/lib/nfs/yellow/boot";
          #options = [ "bind" ];
          #};

          services.atftpd = {
            enable = true;
            root = "/var/lib/tftp";
          };
          networking.firewall.allowedUDPPorts = [ 69 ];

          environment.persistence."/persist".directories = [
            {
              directory = "/var/lib/tftp";
              user = "root";
              group = "root";
              mode = "u=rwx,g=rwx,o=rwx";
            }
          ];
        };
      };
  };
}

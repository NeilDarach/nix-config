{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.impermanence =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [ inputs.impermanence.nixosModules.impermanence ];
        config = {
          environment.persistence."/persist" = {
            hideMounts = true;
            directories = [
              "/etc/nixos"
              "/etc/NetworkManager"
              "/var/lib/nixos"
              "/var/lib/bluetooth"
            ];
            files = [ "/etc/machine-id" ];
          };
          boot.initrd.systemd.enable = true;
          boot.initrd.systemd.services.rollback = {
            description = "Rollback the root filesystem to a pristine state on boot";
            wantedBy = [ "initrd.target" ];
            after = [ "zfs-import-zroot.service" ];
            before = [ "sysroot.mount" ];
            path = with pkgs; [ zfs ];
            unitConfig.DefaultDependencies = "no";
            serviceConfig.Type = "oneshot";
            script = ''
              echo "    >> >> attempting  rollback << <<"
              zfs rollback -r zroot/weak/root@blank && echo "    >> >> rollback complete << <<"
            '';
          };

        };
      };
  };
}

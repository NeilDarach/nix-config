{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-etcd =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.etcd = {
          enable = lib.mkEnableOption "etcd on this host";
        };
        config = lib.mkIf config.local.etcd.enable {
          services.etcd = {
            enable = true;
            name = "etcd";
            advertiseClientUrls = [ "http://etcd.darach.org.uk:2379" ];
            listenClientUrls = [ "http://0.0.0.0:2379" ];
            listenPeerUrls = [ "http://0.0.0.0:2380" ];
            initialAdvertisePeerUrls = [ "http://etcd.darach.org.uk:2380" ];
            initialCluster = [ "etcd=http://etcd.darach.org.uk:2380" ];
            openFirewall = true;
            extraConf = {
              "AUTO_COMPACTION_RETENTION" = "1";
            };
          };
        };
      };
  };

}

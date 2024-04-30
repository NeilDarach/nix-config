{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.localServices;
in {
  imports = [
    ./homeassistant.nix
  ];
  options.localServices.homeassistant = {
    enable = mkEnableOption "Enable homeassistant on this host";
  };

  config = mkIf cfg.homeassistant.enable {
    virtualisation = {
      containers = {
        enable = true;
        storage = {
          settings = {
            storage = {
              driver = "zfs";
              graphroot = "/persist/podman/containers/storage";
              runroot = "/run/containers/storage";
            };
          };
        };
      };
      podman = {
        enable = true;
        dockerCompat = true;
        defaultNetwork.settings = {
          dns_enabled = true;
          ipv6_enabled = false;
        };
      };
      oci-containers = {
        backend = "podman";
      };
    };
  };
}

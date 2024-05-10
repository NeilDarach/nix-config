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
    ./catcam.nix
  ];
  options.localServices.homeassistant = {
    enable = mkEnableOption "Enable homeassistant on this host";
  };

  options.localServices.catcam = {
    enable = mkEnableOption "Enable Frigate to monitor catcam on this host";
  };

  config = mkIf cfg.homeassistant.enable {
    virtualisation = {
      containers = {
        enable = true;
        containersConf.settings.containers = {
          log_size_max = 10485760;
        };
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

{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  baseDir = "/services/homeassistant";
  inherit (config.localServices.homeassistant) pool enable;
in {
  options = {
    localServices.homeassistant.pool = lib.mkOption {
      default = config.networking.hostName;
      type = lib.types.str;
    };
  };

  config = mkIf enable {
    networking.firewall.allowedTCPPorts = [8123];
    virtualisation = {
      oci-containers = {
        backend = "podman";
        containers = {
          homeassistant = {
            image = "homeassistant/home-assistant:stable";
            environment = {
              "TZ" = "Europe/London";
            };
            volumes = [
              "${baseDir}:/config"
              "/run/dbus:/run/dbus:ro"
            ];
            extraOptions = [
              "--name=homeassistant"
              "--network=host"
              "--privileged"
            ];
            autoStart = true;
          };
        };
      };
    };
    systemd.services.prepare-homeassistant = {
      description = "Prepare for home assistant container";
      enable = true;
      wantedBy = ["podman-homeassistant.service"];

      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        mkdir -p ${baseDir}
        ${pkgs.zfs}/bin/zfs list ${pool}${baseDir} || ${pkgs.zfs}/bin/zfs create -p -u -o mountpoint=legacy ${pool}${baseDir}
        [[ -f ${baseDir}/mounted.txt ]] || ${pkgs.util-linux}/bin/mount -t zfs ${pool}${baseDir} ${baseDir}
        echo > ${baseDir}/mounted.txt
      '';
    };

    systemd.services.podman-homeassistant.after = ["prepare-homeassistant.service"];
  };
}

{
  pkgs,
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  enabled = config.localServices.homeassistant.enable;
in {
  config = mkIf enabled {
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
              "/home/neil/ha:/config"
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
        mkdir -p /services/homeassistant
        ${pkgs.zfs}/bin/zfs list pi400/services/homeassistant || ${pkgs.zfs}/bin/zfs create -p -u -o mountpoint=legacy pi400/services/homeassistant
        [[ -f /services/homeassistant/mounted.txt ]] || ${pkgs.util-linux}/bin/mount -t zfs pi400/services/homeassistant /services/homeassistant
        echo > /services/homeassistant/mounted.txt
      '';
    };

    systemd.services.podman-homeassistant.after = ["prepare-homeassistant.service"];
  };
}

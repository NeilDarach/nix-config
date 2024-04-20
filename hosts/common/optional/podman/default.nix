{
  pkgs,
  config,
  ...
}: {
  networking.firewall.allowedTCPPorts = [8123];
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
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
      mkdir /home/neil/ha/done
    '';
  };

  systemd.services.podman-homeassistant.after = ["prepare-homeassistant.service"];
}

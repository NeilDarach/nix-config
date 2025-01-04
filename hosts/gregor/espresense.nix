{ pkgs, config, outputs, ... }:
let
  base = pkgs.dockerTools.pullImage {
    imageName = "espresense/espresense-companion";
    sha256 = "sha256-e63HdqIlOetA3R85zly7n9zaOrIMrw3oROybTDTFw+A=";
    imageDigest =
      "sha256:a90b5bc99be211f3026cde3e61dc8559f03c9f716d0389cd58be4a463409e2a9";
  };
in {

  sops.secrets.mqtt-user = { restartUnits = [ "espresense.service" ]; };
  sops.secrets.mqtt-password = { restartUnits = [ "espresense.service" ]; };

  sops.templates."espresense-secret.yaml" = {
    content = ''
      user: ${config.sops.placeholder.mqtt-user}
      password: ${config.sops.placeholder.mqtt-password}
    '';
    path = "/var/lib/homeassistant/espresense/secret.yaml";
    owner = "homeassistant";
  };
  networking.firewall.allowedTCPPorts = [ 8267 8268 ];

  virtualisation.oci-containers = {
    containers.espresense = {
      volumes = [ "/var/lib/homeassistant/espresense:/config/espresense" ];
      environment.TZ = "Europe/London";
      image = "espresense/espresense-companion";
      imageFile = base;
      autoStart = true;
      ports = [ "8267:8267" "8268:8268" ];
      extraOptions = [ ];
    };
  };

  systemd.services.podman-espresense = {
    enable = true;
    serviceConfig = {
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration espresense 192.168.4.5 8267 "Espresense"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/espresense" ];
    };
    wants = [ "registration.timer" ];
  };
}


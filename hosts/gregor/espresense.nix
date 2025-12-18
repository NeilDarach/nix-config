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

  networking.firewall.allowedTCPPorts = [ 8267 8268 ];

  virtualisation.oci-containers = {
    containers.espresense = {
      volumes = [ "/strongStateDir/hans/espresense:/config/espresense" ];
      environment.TZ = "Europe/London";
      image = "espresense/espresense-companion";
      imageFile = base;
      autoStart = true;
      ports = [ "8267:8267" "8268:8268" ];
      extraOptions = [ ];
    };
  };

  registration.espresense = {
    serviceName = "podman-espresense";
    port = 8267;
    description = "Espresense";
  };

  systemd.services.podman-espresense.enable = true;
}


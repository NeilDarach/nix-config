{ pkgs, config, outputs, ... }:
let
  base = pkgs.dockerTools.pullImage {
    imageName = "lscr.io/linuxserver/homeassistant";
    sha256 = "sha256-HLgu4lCWYUwPUZrYiwpBIDyFJ+/t1BEop5aFJxsd2iE=";
    imageDigest =
      "sha256:315ddb540d5ee80ecedd68de5ad51af854e440387637b5cb1d915657758a4902";
  };
  patches = ./patches;
  ha-img = pkgs.dockerTools.buildImage {
    name = "nd-homeassistant";
    tag = "latest";
    fromImage = base;
    copyToRoot = [ patches ];
    config = {
      ExposedPorts = { "8123/tcp" = { }; };
      Entrypoint = [ "/init" ];
      Volumes = { "/config" = { }; };
      WorkingDir = "/";
    };
  };
in {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/homeassistant";
    user = "homeassistant";
    group = "homeassistant";
    mode = "u=rwx,g=rx,o=rx";
  }];

  users.users = {
    homeassistant = {
      group = "homeassistant";
      description = "Home Assistant user";
      home = "/var/lib/homeassistant";
      isNormalUser = true;
      uid = 8123;
    };
  };

  users.groups.homeassistant = { gid = 8123; };

  sops.secrets.twilio_sid = {
    restartUnits = [ "podman-homeassistant.service" ];
  };
  sops.secrets.twilio_token = {
    restartUnits = [ "podman-homeassistant.service" ];
  };

  sops.templates."ha-secret.yaml" = {
    content = ''
      twilio_sid: ${config.sops.placeholder.twilio_sid}
      twilio_token: ${config.sops.placeholder.twilio_token}
    '';
    path = "/var/lib/homeassistant/secrets.yaml";
    owner = "homeassistant";
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  virtualisation.containers.enable = true;
  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.homeassistant = {
      volumes =
        [ "/var/lib/homeassistant:/config" "/var/run/dbus:/var/run/dbus:ro" ];
      environment.TZ = "Europe/London";
      environment.PUID = "8123";
      environment.PGID = "8123";
      #image = "lscr.io/linuxserver/homeassistant";
      image = "nd-homeassistant";
      imageFile = ha-img;
      autoStart = true;
      ports = [ "8123:8123" ];
      extraOptions = [
        "--network=host"
        "--cap-add=NET_ADMIN"
        "--cap-add=NET_RAW"
        "--cap-add=NET_BIND_SERVICE"
        "--privileged"
      ];
    };
  };

  systemd.services.podman-homeassistant = {
    enable = true;
    serviceConfig = {
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration homeassistant-nix 192.168.4.5 8123 "HomeAssistant running on gregor"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/homeassistant-nix" ];
    };
    wants = [ "registration.timer" ];
  };

}


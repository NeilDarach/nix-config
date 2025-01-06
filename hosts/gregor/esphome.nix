{ pkgs, config, outputs, ... }: {

    #environment.persistence."/persist".directories = [{
    #directory = "/var/lib/esphome";
    #user = "esphome";
    #group = "esphome";
    #mode = "u=rwx,g=rx,o=rx";
    #}];

    #sops.secrets.mqtt-user = { restartUnits = [ "esphome.service" ]; };
    #sops.secrets.mqtt-password = { restartUnits = [ "esphome.service" ]; };

    #sops.templates."esph-secret.yaml" = {
    #content = ''
    #user: ${config.sops.placeholder.mqtt-user}
    #password: ${config.sops.placeholder.mqtt-password}
    #'';
    #path = "/var/lib/esphome/secret.yaml";
    #owner = "esphome";
    #};

    #users.users = {
    #esphome = {
    #group = "esphome";
    #description = "EspHome sandbox user";
    #home = "/var/lib/esphome";
    #isNormalUser = true;
    #};
    #};

    #users.groups.esphome = { };


  services.esphome = {
    enable = true;
        openFirewall = true;
        usePing = true;
        address = "0.0.0.0";
  };

  systemd.services.esphome = {
    enable = true;
    serviceConfig = {
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration esphome 192.168.4.5 6052 "esphome"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/esphome" ];
    };
    wants = [ "registration.timer" ];
  };

}


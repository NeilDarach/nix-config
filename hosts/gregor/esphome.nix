{ pkgs, config, lib, outputs, ... }: {

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
    serviceConfig = {
      ProtectSystem = lib.mkForce "off";
      DynamicUser = lib.mkForce "false";
      User = "esphome";
      Group = "esphome";
    };
  };

  users.users.esphome = {
    isSystemUser = true;
    home = "/var/lib/esphome";
    group = "esphome";
  };
  users.groups.esphome = { };

  registration.service.esphome = {
    port = 6052;
    description = "esphome";
  };

}


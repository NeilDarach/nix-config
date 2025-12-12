{ pkgs, config, outputs, ... }:
let
  details = {
    serviceName = "appdaemon";
    port = 5050;
    serviceDescription = "Python scripts to run on triggers";
  };
  configFile = pkgs.writeText "appdaemon.yaml" ''
    # appdaemon config file.
    # Do not edit
    # This file will be replaced from store on every service restart
    appdaemon:
      elevation: 17
      latitude: 55.8188356
      longitude: -4.2955707
      plugins:
        HASS:
          cert_verify: true
          ha_url: http://homeassistant.darach.org.uk
          token: !secret homeassistant_key
          type: hass
        MQTT:
          client_host: mqtt.darach.org.uk
          client_id: appdaemon
          client_password: !secret mqtt_password
          client_port: 1883
          client_user: !secret mqtt_user
          event_name: MQTT_EVENT
          namespace: mqtt
          type: mqtt
          verbose: true
      time_zone: Europe/London
    http:
      url: http://192.168.4.5:5050
    admin:
    api:
    hadashboard:
    logs:
      access_log:
        filename: /var/log/appdaemon/access.log
      diag_log:
        filename: /var/log/appdaemon/diag.log
      error_log:
        filename: /var/log/appdaemon/error.log
      main_log:
        filename: /var/log/appdaemon/appdaemon.log
    secrets: ${config.sops.templates."appdaemon-secrets.yaml".path} 
  '';

in {
  imports = [ (import ../../lib/service.nix { inherit pkgs details; }) ];
  sops.secrets.appdaemon_secrets = { restartUnits = [ "appdaemon.service" ]; };

  sops.templates."appdaemon-secrets.yaml" = {
    content = ''
      ${config.sops.placeholder.appdaemon_secrets}
    '';
    owner = "appdaemon";
  };

  users.users = {
    appdaemon = {
      group = "appdaemon";
      description = "Appdaemon sandbox user";
      home = "/strongStateDir/appdaemon";
      isNormalUser = true;
    };
  };

  users.groups.appdaemon = { };
  networking.firewall.allowedTCPPorts = [ 5050 ];
  systemd.services.appdaemon = {
    wantedBy = [ "multi-user.target" ];
    after = [ "home-assistant.service" ];
    serviceConfig = {
      User = "appdaemon";
      ExecStartPre =
        "${pkgs.coreutils}/bin/ln -s ${configFile} /strongStateDir/appdaemon/appdaemon.yaml";
      ExecStart =
        "${pkgs.appdaemon}/bin/appdaemon -c /strongStateDir/appdaemon";

    };
  };
}

#admin = null;
#  api = null;
#  hadashboard = null;


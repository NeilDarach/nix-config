{ pkgs, config, outputs, ... }:
let
  details = {
    serviceName = "zigbee2mqtt";
    port = 8080;
    serviceDescription = "Zigbee to MQTT bridge";
  };
in {
  sops.secrets.mqtt-user = { restartUnits = [ "zigbee2mqtt.service" ]; };
  sops.secrets.mqtt-password = { restartUnits = [ "zigbee2mqtt.service" ]; };

  sops.templates."z2m-secret.yaml" = {
    content = ''
      mqtt_user: ${config.sops.placeholder.mqtt-user}
      mqtt_password: ${config.sops.placeholder.mqtt-password}
    '';
    owner = "zigbee2mqtt";
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];

  strongStateDir.service.zigbee2mqtt.enable = true;
  registration.service.zigbee2mqtt = {
    port = 8080;
    description = "Bridge between zigbee devices and MQTT";
  };

  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/strongStateDir/zigbee2mqtt";
    settings = {
      homeassistant.enabled = config.services.home-assistant.enable;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://mqtt.darach.org.uk";
        user = "!${config.sops.templates."z2m-secret.yaml".path} mqtt_user";
        password =
          "!${config.sops.templates."z2m-secret.yaml".path} mqtt_password";
      };

      serial = { port = "/dev/ttyUSB0"; };
      homeassistant_discovery_topic = "homeassistant";
      homeassistant_status_topic = "homeassistant/status";
      advanced = {
        log_directory = "/var/log/zigbee2mqtt/%TIMESTAMP%";
        log_syslog = {
          app_name = "Zigbee2MQTT";
          eol = "/n";
          host = "localhost";
          localhost = "localhost";
          path = "/dev/log";
          pid = "process.pid";
          port = 123;
          protocol = "tcp4";
          type = "5424";

        };
        log_level = "info";
        last_seen = "ISO_8601_local";
        transmit_power = 10;
        version = 4;

      };
      device_options = { };
      frontend = {
        enabled = true;
        port = 8080;
        host = "0.0.0.0";
      };

    };
  };
  systemd.services.zigbee2mqtt = {
    serviceConfig.BindPaths = [ "/var/log/zigbee2mqtt" ];

  };

}


{ pkgs, config, outputs, ... }:
let utils = import ../../lib/svcUtils.nix;
in {

  sops.secrets.mqtt-user = { restartUnits = [ "zigbee2mqtt.service" ]; };
  sops.secrets.mqtt-password = { restartUnits = [ "zigbee2mqtt.service" ]; };

  sops.templates."z2m-secret.yaml" = {
    content = ''
      ZIGBEE2MQTT_CONFIG_MQTT_USER=${config.sops.placeholder.mqtt-user}
      ZIGBEE2MQTT_CONFIG_MQTT_PASSWORD=${config.sops.placeholder.mqtt-password}
    '';
    owner = "zigbee2mqtt";
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];

  users.users = {
    neil.extraGroups = [ "zigbee2mqtt" ];
    zigbee2mqtt.homeMode = "0770";
  };

  systemd.timers.strongStateDir-backup-zigbee2mqtt =
    (utils.zfsBackup "zigbee2mqtt" "zigbee2mqtt");
  services.strongStateDir.enable = true;
  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/strongStateDir/zigbee2mqtt";
    settings = {
      homeassistant = true;
      permit_join = true;
      mqtt = {
        base_topic = "zigbee2mqtt";
        server = "mqtt://mqtt.darach.org.uk";
      };

      serial = { port = "/dev/ttyUSB0"; };
      advanced = {
        homeassistant_legacy_entity_attributes = false;
        homeassistant_status_topic = "homeassistant/status";
        homeassistant_discovery_topic = "homeassistant";
        legacy_api = false;
        ikea_ota_use_test_url = false;
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
        legacy_availability_payload = true;
        last_seen = "ISO_8601_local";
        transmit_power = 10;

      };
      device_options.legacy = false;
      frontend = {
        port = 8080;
        host = "0.0.0.0";
      };

    };
  };
  systemd.services.zigbee2mqtt = {
    enable = true;
    serviceConfig = {
      UMask = pkgs.lib.mkForce "0007";
      StateDirectoryMode = "0770";
      WorkingDirectoryMode = "0770";
      LogsDirectory = "zigbee2mqtt";
      EnvironmentFile = "${config.sops.templates."z2m-secret.yaml".path}";
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration zigbee2mqtt 192.168.4.5 8080 "zigbee2mqtt"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/zigbee2mqtt" ];
    };
    wants = [
      "registration.timer"
      "strongStateDir@zigbee2mqtt:zigbee2mqtt:zigbee2mqtt:zigbee2mqtt.service"
    ];
  };

}


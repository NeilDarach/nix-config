{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/zigbee2mqtt";
    user = "zigbee2mqtt";
    group = "zigbee2mqtt";
    mode = "u=rwx,g=rx,o=rx";
  }];

  sops.secrets.mqtt-user = { restartUnits = [ "zigbee2mqtt.service" ]; };
  sops.secrets.mqtt-password = { restartUnits = [ "zigbee2mqtt.service" ]; };

  sops.templates."z2m-secret.yaml" = {
    content = ''
      user: ${config.sops.placeholder.mqtt-user}
      password: ${config.sops.placeholder.mqtt-password}
    '';
    path = "/var/lib/zigbee2mqtt/secret.yaml";
    owner = "zigbee2mqtt";
  };
  networking.firewall.allowedTCPPorts = [ 8080 ];

  services.zigbee2mqtt = {
    enable = true;
    dataDir = "/var/lib/zigbee2mqtt";
    settings = {
      homeassistant = true;
      permit_join = true;
      mqtt = {
        base_topic = "uzg01";
        server = "mqtt://mqtt.darach.org.uk";
        user = "!secret.yaml user";
        password = "!secret.yaml password";
      };

      secret = "${config.sops.templates."z2m-secret.yaml".path}";
      serial = {
        port = "tcp://192.168.4.233:6638";
        baudrate = 115200;
      };
      advanced = {
        homeassistant_legacy_entity_attributes = false;
        homeassistant_status_topic = "homeassistant/status";
        homeassistant_discovery_topic = "homeassistant";
        legacy_api = false;
        ikea_ota_use_test_url = false;
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
        channel = 25;
        log_level = "debug";
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
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration zigbee2mqtt-uzg 192.168.4.5 8080 "zigbee2mqtt running from the UZG-01"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/zigbee2mqtt" ];
    };
    wants = [ "registration.timer" ];
  };

}


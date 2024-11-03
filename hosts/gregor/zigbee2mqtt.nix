{
  networking.firewall.allowedTCPPorts = [ 2049 4000 4001 4002 ];
  networking.firewall.allowedUDPPorts = [ 2049 4000 4001 4002 ];
  services.zigbee2mqtt = {
    enable = true;
    settings = {
      permit_join = true;
      frontend = {
        port = 8080;
        host = "0.0.0.0";
      };
      mqtt = {
        base_topic = "zigbee2mqtt2";
        server = "mqtt://mqtt.darach.org.uk";
        user = "!secret.yaml mqtt_user";
        password = "!secret.yaml mqtt_password";
      };
      serial = {
        port = "tcp://uzg-01.darach.org.uk:6638";
        baudrate = 115200;
      };
      advanced = {
        pan_id = 64711;
        network_key = "!secret.yaml network_key";
      };
    };
    dataDir = "/var/lib/zigbee2mqtt";
  };
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/zigbee2mqtt";
    user = "zigbee2mqtt";
    group = "zigbee2mqtt";
    mode = "u=rwx,g=rx,o=rx";
  }];
}

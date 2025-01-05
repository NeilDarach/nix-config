{ config, pkgs, lib, ... }:
let
  home-assistant =
    pkgs.home-assistant.override { python312 = pkgs.python312Full; };
  #build custom components with the overriden Home Assistant,
  #avoid conflicting pythons
  haCallPackage = lib.callPackageWith (pkgs // home-assistant.python.pkgs // {
    buildHomeAssistantComponent =
      pkgs.buildHomeAssistantComponent.override { inherit home-assistant; };
    callPackage = haCallPackage;
  });
  custom-components = haCallPackage
    (import "${pkgs.path}/pkgs/servers/home-assistant/custom-components") { };
  ble_monitor = haCallPackage ./ble_monitor.nix { inherit home-assistant; };
in {

  systemd.services.home-assistant = {
    serviceConfig = {
      ExecStartPre = [''
        +${pkgs.bash}/bin/bash -c "touch /var/lib/hans/automations.yaml; chown hass:hass /var/lib/hans/automations.yaml"
      ''];
    };
  };
  services.home-assistant = {
    configDir = "/var/lib/hans";
    package = home-assistant;
    enable = true;
    openFirewall = true;
    configWritable = true;
    config = {
      http.server_port = 8124;
      homeassistant = {
        name = "HANS";
        latitude = 55.8190798606104;
        longitude = -4.2938411235809335;
        elevation = 100;
        unit_system = "metric";
        time_zone = "Europe/London";
        country = "GB";
      };
      "automation ui" = "!include automations.yaml";
    };
    extraComponents = [
      "homeassistant"
      "backup"
      "default_config"
      "met"
      "esphome"
      "radio_browser"
      "homeassistant_alerts"
      "tasmota"
      "mqtt"
    ];
    extraPackages = ps:
      with ps; [
        aioblescan
        janus
        gtts
        brother
        spotipy
        pychromecast
        pyatv
        pyipp
        reolink-aio
        plexapi
        plexwebsocket
        plexauth
        bluepy
        pybluez
                pycryptodome
      ];
            customComponents = [ ble_monitor ];
  };
}

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
  utils = import ../../../lib/svcUtils.nix;
in {
  imports = [ ./lights.nix { } ];
  _module.args.ha = import ../../../lib/ha.nix { lib = lib; };

  systemd.services.home-assistant = {
    serviceConfig = {
      User = "hass";
      Group = "hass";
      ExecStartPre = [''
        +${pkgs.bash}/bin/bash -c "touch /strongStateDir/hans/automations.yaml; chown hass:hass /strongStateDir/hans/automations.yaml"
      ''];
      ExecStartPost = [''
        +${pkgs.registration}/bin/registration homeassistant 192.168.4.5 8123 "Home Assistant"
      ''];
    };
    wants = [
      "registration.timer"
      "strongStateDir@hans:hass:hass:homeassistant.service"
    ];
  };

  users.users.neil.extraGroups = [ "hass" ];
  systemd.timers.strongStateDir-backup-homeassistant =
    (utils.zfsBackup "hans" "homeassistant");
  services.strongStateDir.enable = true;

  services.home-assistant = {
    configDir = "/strongStateDir/hans";
    package = home-assistant;
    enable = true;
    openFirewall = true;
    configWritable = true;
    config = {
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
      "mobile_app" = { };
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

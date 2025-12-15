{ config, pkgs, lib, ... }:
let
  #build custom components with the overriden Home Assistant,
  #avoid conflicting pythons
  home-assistant = pkgs.home-assistant;
  haCallPackage = lib.callPackageWith
    (pkgs // home-assistant.python.pkgs // { callPackage = haCallPackage; });
  ble_monitor = haCallPackage ./ble_monitor.nix { inherit home-assistant; };
  utils = import ../../../lib/svcUtils.nix;
in {
  imports = [ ./lights.nix { } ];
  _module.args.ha = import ../../../lib/ha.nix { lib = lib; };

  sops.secrets.twilio_sid = { restartUnits = [ "home-assistant.service" ]; };
  sops.secrets.twilio_token = { restartUnits = [ "home-assistant.service" ]; };
  sops.secrets.influx-ha-token = {
    restartUnits = [ "home-assistant.service" ];
  };

  sops.templates."home-assistant-secret.yaml" = {
    content = ''
      twilio_sid=${config.sops.placeholder.twilio_sid}
      twilio_token=${config.sops.placeholder.twilio_token}
      influx_token=${config.sops.placeholder.influx-ha-token}
    '';
    owner = "hass";
  };

  systemd.services.home-assistant = {
    serviceConfig = {
      User = "hass";
      Group = "hass";
      UMask = pkgs.lib.mkForce "0007";
      StateDirectoryMode = "0770";
      EnvironmentFile =
        "${config.sops.templates."home-assistant-secret.yaml".path}";
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

  users.users = {
    neil.extraGroups = [ "hass" ];
    hass.homeMode = "0770";
  };
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
      mobile_app = { };
      history = { };
      twilio = {
        account_sid = "!env_var twilio_sid";
        auth_token = "!env_var twilio_token";
      };
      influxdb = {
        api_version = 2;
        ssl = false;
        host = "localhost";
        port = 8086;
        token = "!env_var influx_token";
        organization = "cdbc11c95227235f";
        bucket = "homeassistant";
        tags.source = "HA";
        tags_attributes = [ "friendly_name" ];
        exclude = {
          entities = [ "zone.home" ];
          domains = [ "persitent_notification" "person" ];
        };
        include = { domains = [ "sensor" "binary_sensor" "sun" ]; };
      };

      notify = [{
        name = "SmsNotifier";
        platform = "twilio_sms";
        from_number = "+447723465616";
      }];
      recorder = {
        auto_purge = "true";
        purge_keep_days = "30";
        auto_repack = "true";
        exclude = {
          entity_globs = [
            "sensor.esp*uptime"
            "binary_sensor.espresence*"
            "sensor.espresence*"
          ];
          domains = [ "automation" ];
        };
      };
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
      "roku"
      "twilio"
      "twilio_sms"
      "pi_hole"
      "history"
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
        twilio
        hole
        zha
        zlib-ng
        universal-silabs-flasher
        ha-silabs-firmware-client
      ];
    customComponents = [ ble_monitor ];
  };
}

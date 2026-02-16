{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-homeassistant =
      nixosArgs@{ pkgs, config, ... }:
      let
        #build custom components with the overriden Home Assistant,
        #avoid conflicting pythons
        home-assistant = pkgs.home-assistant;
        haCallPackage = lib.callPackageWith (
          pkgs // home-assistant.python.pkgs // { callPackage = haCallPackage; }
        );
        ble_monitor = haCallPackage ./ble_monitor.nix { inherit home-assistant; };
      in
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.homeassistant = {
          enable = lib.mkEnableOption "homeassistant on this host";
        };
        config = lib.mkIf config.local.homeassistant.enable {
          sops.secrets = {
            "twilio/sid" = {
              restartUnits = [ "home-assistant.service" ];
            };
            "twilio/token" = {
              restartUnits = [ "home-assistant.service" ];
            };
            "influx/ha-token" = {
              restartUnits = [ "home-assistant.service" ];
            };
            "home-assistant/latitude" = {
              restartUnits = [ "home-assistant.service" ];
            };
            "home-assistant/longitude" = {
              restartUnits = [ "home-assistant.service" ];
            };
            "home-assistant/elevation" = {
              restartUnits = [ "home-assistant.service" ];
            };
          };

          sops.templates."home-assistant-secret.yaml" = {
            content = ''
              twilio_sid=${config.sops.placeholder."twilio/sid"}
              twilio_token=${config.sops.placeholder."twilio/token"}
              influx_token=${config.sops.placeholder."influx/ha-token"}
              latitude=${config.sops.placeholder."home-assistant/latitude"}
              longitude=${config.sops.placeholder."home-assistant/longitude"}
              elevation=${config.sops.placeholder."home-assistant/elevation"}
            '';
            owner = "hass";
          };

          systemd.services.home-assistant = {
            serviceConfig = {
              User = "hass";
              Group = "hass";
              UMask = pkgs.lib.mkForce "0007";
              StateDirectoryMode = "0770";
              EnvironmentFile = "${config.sops.templates."home-assistant-secret.yaml".path}";
              ExecStartPre = [
                ''
                  +${pkgs.bash}/bin/bash -c "touch /strongStateDir/hans/automations.yaml; chown hass:hass /strongStateDir/hans/automations.yaml"
                ''
              ];
            };
          };

          registration.service.home-assistant = {
            port = 8123;
            description = "Home Assistant";
          };

          users.users = {
            hass.homeMode = "0770";
          };

          strongStateDir.service.home-assistant = {
            enable = true;
            dataDir = "hans";
            datasetName = "hans";
          };

          services.home-assistant = {
            configDir = "/strongStateDir/hans";
            package = home-assistant;
            enable = true;
            openFirewall = true;
            configWritable = true;
            config = {
              homeassistant = {
                name = "Beaufort Ave";
                latitude = "!env_var latitude";
                longitude = "!env_var longitude";
                elevation = "!env_var elevation";
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
                organization = "Darach";
                bucket = "homeassistant";
                tags.source = "HA";
                tags_attributes = [ "friendly_name" ];
                exclude = {
                  entities = [ "zone.home" ];
                  domains = [
                    "persitent_notification"
                    "person"
                  ];
                };
                include = {
                  domains = [
                    "sensor"
                    "binary_sensor"
                    "sun"
                  ];
                };
              };

              notify = [
                {
                  name = "SmsNotifier";
                  platform = "twilio_sms";
                  from_number = "+447723465616";
                }
              ];
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
              template = [
                {
                  sensor = [
                    {
                      name = "Outside Temperature";
                      unit_of_measurement = "°C";
                      state = "{{ state_attr('weather.hans','temperature') }}";
                      device_class = "temperature";
                      state_class = "measurement";
                      unique_id = "weather_outside_temp";
                      icon = "mdi:thermometer";
                    }
                  ];
                }
              ];
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
              "open_meteo"
              "nut"
              "bthome"
              "esphome"
              "local_calendar"
              "google"
              "caldav"
              "xiaomi_ble"
              "pushover"
            ];

            extraPackages =
              ps: with ps; [
                aioblescan
                aioesphomeapi
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
            customComponents = [
            ];
          };
        };
      };
  };
}

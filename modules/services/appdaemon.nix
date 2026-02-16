{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-appdaemon =
      nixosArgs@{ pkgs, config, ... }:
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
                ha_url: http://home-assistant.darach.org.uk
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
            url: http://0.0.0.0:5050
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
          secrets: ${config.sops.templates."appdaemon_secrets.yaml".path} 
        '';

      in
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.appdaemon = {
          enable = lib.mkEnableOption "appdaemon on this host";
        };
        config = lib.mkIf config.local.appdaemon.enable {
          sops.templates."appdaemon_secrets.yaml" = {
            content = ''
              homeassistant_key: "${config.sops.placeholder."appdaemon/homeassistant_key"}"
              mqtt_user: ${config.sops.placeholder."mqtt/user"}
              mqtt_password: ${config.sops.placeholder."mqtt/password"}
            '';
            owner = "appdaemon";

          };
          sops.secrets."appdaemon/homeassistant_key" = { };
          sops.secrets."mqtt/user" = { };
          sops.secrets."mqtt/password" = { };

          strongStateDir.service.appdaemon.enable = true;
          registration.service.appdaemon = {
            port = 5050;
            description = "python trigger for HA";
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
              ExecStartPre = "${pkgs.coreutils}/bin/ln -fs ${configFile} /strongStateDir/appdaemon/appdaemon.yaml";
              ExecStart = "${pkgs.appdaemon}/bin/appdaemon -c /strongStateDir/appdaemon";
              LogsDirectory = "appdaemon";
            };
          };
        };
      };
  };
}

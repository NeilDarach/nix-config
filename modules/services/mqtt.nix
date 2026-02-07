{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-mqtt =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.mqtt = {
          enable = lib.mkEnableOption "mqtt on this host";
        };
        config = lib.mkIf config.local.mqtt.enable {
          services.mosquitto = {
            enable = true;
            listeners = [
              {
                address = "0.0.0.0";
                port = 1883;
                settings.allow_anonymous = true;
                users."mqtt-tasmota" = {
                  passwordFile = "${config.sops.templates."mqtt-tasmota.pw".path}";
                  acl = [ "readwrite #" ];
                };
              }
            ];
            logType = [ "debug" ];
          };
          sops.secrets.mqtt-password = { };
          sops.templates."mqtt-tasmota.pw" = {
            content = ''
              ${config.sops.placeholder.mqtt-password}
            '';
          };
          networking.firewall.allowedTCPPorts = [ 1883 ];
        };
      };
  };

}

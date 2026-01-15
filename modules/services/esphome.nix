{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-esphome =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
        ];
        options.local.esphome = {
          enable = lib.mkEnableOption "esphome on this host";
        };
        config = lib.mkIf config.local.esphome.enable {

          services.esphome = {
            enable = true;
            openFirewall = true;
            usePing = true;
            address = "0.0.0.0";
          };

          systemd.services.esphome = {
            serviceConfig = {
              ProtectSystem = lib.mkForce "off";
              DynamicUser = lib.mkForce "false";
              User = "esphome";
              Group = "esphome";
            };
          };

          users.users.esphome = {
            isSystemUser = true;
            home = "/var/lib/esphome";
            group = "esphome";
          };
          users.groups.esphome = { };

          registration.service.esphome = {
            port = 6052;
            description = "esphome";
          };
        };
      };
  };
}

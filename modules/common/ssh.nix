{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.ssh =
      { config, ... }:
      {
        config = lib.mkIf config.services.openssh.enable {
          services.openssh.settings = {
            PermitRootLogin = "prohibit-password";
            PasswordAuthentication = false;
            StreamLocalBindUnlink = "yes";
            GatewayPorts = "clientspecified";
          };
        };
      };
  };
}

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
            PermitRootLogin = "no";
            PasswordAuthentication = false;
            StreamLocalBindUnlink = "yes";
            GatewayPorts = "clientspecified";
            AllowUsers = [ "neil" ];
          };
        };
      };
  };
}

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
          services.openssh = {
            hostKeys = lib.mkForce [
              {
                type = "ed25519";
                path = "/etc/ssh/ssh_host_ed25519_key";
              }
            ];
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = false;
              StreamLocalBindUnlink = "yes";
              GatewayPorts = "clientspecified";
              AllowUsers = [ "neil" ];
            };
          };
        };
      };
  };
}

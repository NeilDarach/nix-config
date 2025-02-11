{ pkgs, config, outputs, ... }:
let
  details = {
    serviceName = "appdaemon";
    port = 5050;
    serviceDescription = "Python scripts to run on triggers";
  };
in {
  imports = [ (import ../../lib/service.nix { inherit pkgs details; }) ];

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
      ExecStart =
        "${pkgs.appdaemon}/bin/appdaemon -c /strongStateDir/${details.serviceName}";

    };
  };
}


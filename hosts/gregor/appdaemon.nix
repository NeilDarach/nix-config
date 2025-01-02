{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/appdaemon";
    user = "appdaemon";
    group = "appdaemon";
    mode = "u=rwx,g=rx,o=rx";
  }];

  users.users = {
    appdaemon = {
      group = "appdaemon";
      description = "Appdaemon sandbox user";
      home = "/var/lib/appdaemon";
      isNormalUser = true;
    };
  };

  users.groups.appdaemon = { };
  networking.firewall.allowedTCPPorts = [ 5050 ];
  systemd.services.appdaemon = {
    enable = true;
    serviceConfig = {
      ExecStart = "${pkgs.appdaemon}/bin/appdaemon -c /var/lib/appdaemon";
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration appdaemon 192.168.4.5 5050 "Appdaemon"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/appdaemon" ];
      User = "appdaemon";
      Group = "appdaemon";
      BindPaths = [ "/var/lib/appdaemon" ];
    };
    wants = [ "registration.timer" ];
  };

}


{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/gitea";
    user = "gitea";
    group = "gitea";
    mode = "u=rwx,g=rx,o=rx";
  }];

  systemd.services.gitea = {
    serviceConfig = {
      ExecStartPost = [
        ''
          +${pkgs.registration}/bin/registration gitea 192.168.4.5 3000 "Local git server"''
      ];
      ExecStop = [ "+rm /var/run/registration-leases/gitea" ];
    };
    wants = [ "registration.timer" ];
  };
    networking.firewall.allowedTCPPorts = [ 3000 ];

  services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/var/lib/gitea";
  };
}


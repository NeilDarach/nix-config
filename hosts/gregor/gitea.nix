{ pkgs, config, outputs, ... }: {
  environment.persistence."/persist".directories = [{
    directory = "/var/lib/gitea";
    user = "gitea";
    group = "gitea";
    mode = "u=rwx,g=rx,o=rx";
  }];

  registration.service.gitea = {
    port = 3000;
    description = "Local git server";
  };
  networking.firewall.allowedTCPPorts = [ 3000 ];

  services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/var/lib/gitea";
  };
}


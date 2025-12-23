{ pkgs, config, outputs, ... }: {
  strongStateDir.service.gitea.enable = true;
  registration.service.gitea = {
    port = 3000;
    description = "Local git server";
  };
  networking.firewall.allowedTCPPorts = [ 3000 ];

  services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/strongStateDir/gitea";
  };
}


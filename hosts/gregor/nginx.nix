{
  services.nginx = {
    enable = true;
    virtualHosts."192.168.4.5" = {
      locations."/" = { root = "/var/lib/nginx/www"; };
    };

  };

  networking.firewall.allowedTCPPorts = [80 ];

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/nginx";
    user = "nginx";
    group = "wheel";
    mode = "u=rwx,g=rwx,o=rx";
  }];
}


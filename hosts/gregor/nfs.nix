{
  services.nfs.server = {
    enable = true;
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
    exports = ''
      /var/lib/nfs/yellow 192.168.4.89(rw,sync,no_subtree_check,no_root_squash)
    '';
  };

  networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 ];

  environment.persistence."/persist".directories = [{
    directory = "/var/lib/nfs";
    user = "root";
    group = "root";
    mode = "u=rwx,g=rwx,o=rwx";
  }];
}


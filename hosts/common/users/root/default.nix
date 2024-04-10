{ 
  pkgs,
  config,
  ...
  } : 
  let 
    ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    users.mutableUsers = false;
    users.users.root = {
      isNormalUser = false;
      openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/neil/ssh.pub) 
                                      (builtins.readFile ../../id_nixos-build.pub) ];
      hashedPasswordFile = config.sops.secrets.root-password.path;
      packages = [ pkgs.home-manager ];
      };

    sops.secrets = {
      root-password = {
        sopsFile = ../../secrets.json;
        format = "json";
        neededForUsers = true;
        };

    ssh_nixos-build_key_root = {
      format = "json";
      sopsFile = ../../secrets.json;
      key = "ssh_nixos-build_key";
      path = "/root/.ssh/id_nixos-build";
      mode = "0400";
      owner = "root";
      group = "root";
      };
    };
  }

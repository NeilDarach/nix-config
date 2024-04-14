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
      openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/neil/id_ed25519.pub) 
                                      (builtins.readFile ../../public_keys/id_nixos-build.pub) ];
      hashedPasswordFile = config.sops.secrets.root-password.path;
      packages = [ pkgs.home-manager ];
      };

    sops.secrets = {
      root-password = {
        sopsFile = ../../secrets.yaml;
	key = "passwords/root";
        neededForUsers = true;
        };

      ssh_nixos-build_key_root = {
        sopsFile = ../../secrets.yaml;
        key = "private_keys/nixos-build";
        path = "/root/.ssh/id_nixos-build";
        mode = "0400";
        owner = "root";
        group = "root";
        };
    };
  }

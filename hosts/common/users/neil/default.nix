{ 
  pkgs,
  config,
  ...
  } : 
  let 
    ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {
    users.mutableUsers = false;
    users.users.neil = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
	] ++ ifTheyExist [
	"docker"
	"git"
	];

      openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/neil/ssh.pub) ];
      hashedPasswordFile = config.sops.secrets.neil-password.path;
      packages = [ pkgs.home-manager ];
      };

    sops.secrets = {
      neil-password = {
        sopsFile = ../../secrets.json;
        format = "json";
        neededForUsers = true;
        };

    ssh_nixos-build_key = {
      format = "json";
      sopsFile = ../../secrets.json;
      path = "/home/neil/.ssh/id_nixos-build";
      mode = "0400";
      owner = "neil";
      group = "users";
      };
    };

    home-manager.users.neil = import ../../../../home/neil/${config.networking.hostName}.nix;
  }

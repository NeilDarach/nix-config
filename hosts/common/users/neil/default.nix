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

    sops.secrets.neil-password = {
      sopsFile = ../../secrets.json;
      format = "json";
      neededForUsers = true;
      };

    home-manager.users.neil = import ../../../../home/neil/${config.networking.hostName}.nix;
  }

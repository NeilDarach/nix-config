{ 
  pkgs,
  config,
  lib,
  ...
  } : 
  let 
    ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
  in {

    systemd.tmpfiles.rules = [
      "d /home/guest/.ssh 0770 guest users -"
      "d /home/guest/.config 0700 guest users -"
      "d /home/guest/.config/sops 0700 guest users -"
      "d /home/guest/.config/sops/age 0700 guest users -"
      ];
    users.mutableUsers = false;
    users.users.guest = {
      uid = 1000;
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
	] ++ ifTheyExist [
	];

      openssh.authorizedKeys.keys = [ 
        (builtins.readFile ../../../../home/guest/id_ed25519.pub) 
        (builtins.readFile ../../../../home/neil/id_ed25519.pub) ];
      hashedPasswordFile = config.sops.secrets."password_guest".path;
      packages = [ pkgs.home-manager ];
      };


    sops = {
      secrets = {
        password_guest = {
          sopsFile=../../../../home/guest/secrets.yaml;
          neededForUsers = true;
	  key = "passwords/guest";
          };
	sshkey = {
          sopsFile=../../../../home/guest/secrets.yaml;
	  key = "private_keys/id_ed25519";
	  path = "/home/guest/.ssh/id_ed25519";
	  owner = "guest";
	  group = "users";
	  mode = "0400";
	  };
	agekey = {
          sopsFile=../../../../home/guest/secrets.yaml;
	  key = "private_keys/age";
	  path = "/home/guest/.config/sops/age/keys.txt";
	  owner = "guest";
	  group = "users";
	  mode = "0400";
	  };
	  
        };
      };
  
    home-manager.users.guest = import ../../../../home/guest/${config.networking.hostName}.nix;
  }

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
      "d /home/neil/.ssh 0770 neil users -"
      "d /home/neil/.config 0700 neil users -"
      "d /home/neil/.config/sops 0700 neil users -"
      "d /home/neil/.config/sops/age 0700 neil users -"
      ];

    users.mutableUsers = false;
    users.users.neil = {
      isNormalUser = true;
      shell = pkgs.fish;
      extraGroups = [
        "wheel"
	"dialout"
	] ++ ifTheyExist [
	"docker"
	"git"
	];

      openssh.authorizedKeys.keys = [ (builtins.readFile ../../../../home/neil/id_ed25519.pub) ];
      hashedPasswordFile = config.sops.secrets."password_neil".path;
      packages = [ pkgs.home-manager ];
      };


    sops.secrets = {
      password_neil = {
        sopsFile=../../../../home/neil/secrets.yaml;
        neededForUsers = true;
	key = "passwords/neil";
        };

      sshkey_neil = {
        sopsFile=../../../../home/neil/secrets.yaml;
        key = "private_keys/id_ed25519";
        path = "/home/neil/.ssh/id_ed25519";
        mode = "0400";
        owner = "neil";
        group = "users";
        };
      agekey_neil = {
        sopsFile=../../../../home/neil/secrets.yaml;
        key = "private_keys/age";
        path = "/home/neil/.config/sops/age/keys.txt";
        mode = "0400";
        owner = "neil";
        group = "users";
        };
      };

    home-manager.users.neil = import ../../../../home/neil/${config.networking.hostName}.nix;
  }

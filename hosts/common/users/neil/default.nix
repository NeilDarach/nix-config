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

      openssh.authorizedKeys.keys = [ (builtins.readFile ../../../common/public_keys/neil_id_ed25519.pub) ];
      hashedPasswordFile = config.sops.secrets.password_neil.path;
      packages = [ pkgs.home-manager ];
      };

    sops.secrets = {
      password_neil = {
        sopsFile=../../../../home/neil/secrets.yaml;
        neededForUsers = true;
	key = "passwords/neil";
        };

      ssh_nixos-build_key_neil = {
        key = "private_keys/nixos-build";
        path = "/home/neil/.ssh/id_nixos-build";
        mode = "0400";
        owner = "neil";
        group = "users";
        };

      ssh_private_key_neil = {
        key = "private_keys/neil";
        path = "/home/neil/.ssh/id_ed25519";
        mode = "0400";
        owner = "neil";
        group = "users";
        };
      };

    home-manager.users.neil = import ../../../../home/neil/${config.networking.hostName}.nix;
  }

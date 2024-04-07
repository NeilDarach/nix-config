
  users.users = {
    neil = {
      isNormalUser = true;
      home = "/home/neil";
      description = "Neil Darach";
      openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com" ];
      extraGroups = [ "wheel" ];
      };

  home-manager.users.neil = {
      home.stateVersion = "23.11";
      programs.bash = {
        enable = true;
	sessionVariables = {
	  EDITOR = "nvim";
	  };
	};
      programs.git = {
        enable = true;
	extraConfig = {
	  user = {
	    name = "Neil Darach";
	    email = "neil.darach@gmail.com";
	  };
	};
      };
    };


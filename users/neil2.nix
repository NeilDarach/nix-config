
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


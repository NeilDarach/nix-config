{
  programs.git = {
    enable = true;
    extraConfig = {
      user = {
        name = "Neil Darach";
	email = "neil.darach@gmail.com";
	};
      };
    ignores = [ ".direnv" "result" ];
    };
  }

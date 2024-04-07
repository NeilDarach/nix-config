{
  inputs,
  outputs,
  lib,
  pkgs,
  ...
  } : {
  imports = [
    ./global
    ];


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
    }


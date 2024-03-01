{ pkgs, ... }: 
  let 
    myAliases = {
      vi = "nvim";
      vim = "nvim";
      };
  in {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = myAliases;
      };
    home.packages = with pkgs; [
      direnv nix-direnv
      ];

    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;
  }

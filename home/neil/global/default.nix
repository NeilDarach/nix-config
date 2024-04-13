{ 
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
  }: {
  imports = [ 
   inputs.impermanence.nixosModules.home-manager.impermanence
    ../features/cli
    ../features/nvim
    ./direnv.nix
    ] ++ (builtins.attrValues outputs.homeManagerModules);

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowUnfree = true;
      };
    };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [
        "nix-command"
	"flakes"
	"repl-flake"
	];
      };
    };

  systemd.user.startServices = "sd-switch";

  programs = {
    home-manager.enable = true;
    };

  home = {
    username = lib.mkDefault "neil";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/Documents/NixConfig";
      };
    
    persistence = { };
    #persistence = {
      #homeDirectory = {
        #directories = [
	  #"Documents"
	  #"Downloads"
	  #".local/bin"
	  #".local/share/nix"
	  #];
	#allowOther = true;
        #};
      #};
    };

  programs.bash = {
    enable = true;
    sessionVariables = {
      EDITOR = "nvim";
      };
    };

  }


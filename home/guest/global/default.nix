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
   inputs.sops-nix.homeManagerModules.sops 
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
    username = lib.mkDefault "guest";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/Documents/NixConfig";
      };
    
    file.public_key = {
      target = "${config.home.homeDirectory}/.ssh/id_ed25519.pub" ;
      source = ../id_ed25519.pub;
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


  sops = {
    age = {
        sshKeyPaths = [ "/home/guest/.ssh/id_ed25519" ];
        keyFile = "/home/guest/.config/sops/age/keys.txt";
        };
      defaultSopsFile = ../secrets.yaml;
      };

  programs.neovim.enable = true;
  programs.bash = {
    enable = true;
    sessionVariables = {
      EDITOR = "nvim";
      };
    };

  }


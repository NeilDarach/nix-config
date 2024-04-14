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

  home = {
    username = lib.mkDefault "neil";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "23.11";
    sessionPath = [ "$HOME/.local/bin" ];
    sessionVariables = {
      FLAKE = "$HOME/Documents/NixConfig";
      };

    file.public_key = {
      target = "${config.home.homeDirectory}/.ssh/id_ed25519.pub}";
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
        sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
	keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
	};
      defaultSopsFile = ../secrets.yaml;

      secrets = {
        sshBuildKey = {
	  sopsFile = ../../../hosts/common/secrets.yaml;
	  key = "private_keys/nixos-build";
	  path = "${config.home.homeDirectory}/.ssh/id_nixos-build";
	  };
	};
      };

  programs = {
    tmux.enable = true;
    neovim.enable = true;
    home-manager.enable = true;
    bash = {
      enable = true;
      sessionVariables = {
        EDITOR = "nvim";
        };
      };
    }

  }


{
  pkgs,
  lib,
  config,
  ...
  } : 
  let
    inherit (lib) mkIf;
    packageNames = map (p: p.pname or p.name or null) config.home.packages;
    hasPackage = name: lib.any (x: x == name) packageNames;
    hasNeovim = config.programs.neovim.enable;
  in {
    programs.fish = {
      enable = true;
      plugins = [ ];
      shellAbbrs = rec {
        nr = "nixos-rebuild --flake .";
	nrs = "nixos-rebuild --flake . switch";
	nrss = "sudo nixos-rebuild --flake . switch";
	hm = "home-manager --flake .";
	hms = "home-manager --flake . switch";
	vim = mkIf hasNeovim "nvim";
	vi = vim;
        };
      functions = {
        fish_greeting = "";
	up-or-search = /* fish */
	        ''
          if commandline --search-mode
            commandline -f history-search-backward
            return
          end
          if commandline --paging-mode
            commandline -f up-line
            return
          end
          set -l lineno (commandline -L)
          switch $lineno
            case 1
              commandline -f history-search-backward
              #history merge
            case '*'
              commandline -f up-line
          end
        '';

      interactiveShellInit = /* fish */
        ''
	fish_vi_key_bindings
	set fish_cursor_default		block		blink
	set fish_cursor_insert		line		blink
	set fish_cursor_replace_one	underscore	blink
	set fish_cursor_visual		block
	'';
      };
    };
  }

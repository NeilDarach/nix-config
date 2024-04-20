{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}: {
  imports =
    [
      inputs.impermanence.nixosModules.home-manager.impermanence
      inputs.sops-nix.homeManagerModules.sops
      inputs.neovim-flake.homeManagerModules.default
      ../features/cli
      ./direnv.nix
    ]
    ++ (builtins.attrValues outputs.homeManagerModules);

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
    sessionPath = ["$HOME/.local/bin"];
    sessionVariables = {
      EDITOR = "nvim";
      FLAKE = "$HOME/Documents/NixConfig";
    };
    packages = builtins.attrValues {
      inherit
        (pkgs)
        screen
        ; # required by dunst
    };

    file.public_key = {
      target = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      source = ../id_ed25519.pub;
    };

    persistence = {};
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
      sshKeyPaths = ["${config.home.homeDirectory}/.ssh/id_ed25519"];
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
    neovim-flake = {
      enable = true;
      settings = {
        vim = {
          viAlias = true;
          vimAlias = true;
          telescope.enable = true;
          theme = {
            enable = true;
            name = "onedark";
            extraConfig = ''vim.o.background = "dark" '';
          };
          mapLeaderSpace = true;
          luaConfigRC.global =
            /*
            lua
            */
            ''
              vim.cmd("set expandtab")
              vim.cmd("set tabstop=2")
              vim.cmd("set softtabstop=2")
              vim.cmd("set shiftwidth=2")
            '';
          lsp = {
            enable = true;
            formatOnSave = true;
            nvimCodeActionMenu.enable = true;
          };
          languages = {
            enableLSP = true;
            enableFormat = true;
            enableTreesitter = true;
            enableExtraDiagnostics = true;

            lua.enable = true;
            nix.enable = true;
            html.enable = true;
            css.enable = true;
            bash.enable = true;
            rust = {
              enable = true;
              crates.enable = true;
            };
          };
          visuals = {
            enable = true;
            nvimWebDevicons.enable = true;
            scrollBar.enable = true;
            smoothScroll.enable = true;
            highlight-undo.enable = true;
            cursorline = {
              enable = true;
              lineTimeout = 0;
            };
          };
          statusline = {
            lualine = {
              enable = true;
              theme = "onedark";
            };
          };
          filetree.nvimTree = {
            enable = true;
            #mappings.toggle = "<leader>fe";
            openOnSetup = false;
            actions.openFile.quitOnOpen = true;
          };
          treesitter.context.enable = true;
          binds = {
            whichKey.enable = true;
            cheatsheet.enable = true;
          };
          git = {
            enable = true;
            gitsigns.enable = true;
            gitsigns.codeActions = false;
          };
          terminal = {
            toggleterm = {
              enable = true;
              lazygit.enable = true;
            };
          };
          comments = {
            comment-nvim.enable = true;
          };
        };
      };
    };
    home-manager.enable = true;
    bash.enable = true;
  };
}

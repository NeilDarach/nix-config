# Copyright (c) 2023 BirdeeHub
# Licensed under the MIT license
{
  description = "Generic NVim configuation";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixCats.url = "github:BirdeeHub/nixCats-nvim?dir=nix";
    lze.url = "github:BirdeeHub/lze";
    lze.inputs.nixpkgs.follows = "nixpkgs";
      # see :help nixCats.flake.inputs
  };

  # see :help nixCats.flake.outputs
  outputs = { self, nixpkgs, flake-utils, nixCats, ... }@inputs:
    let
      inherit (nixCats) utils;
      luaPath = "${./.}";
      forEachSystem = flake-utils.lib.eachSystem flake-utils.lib.allSystems;
      # the following extra_pkg_config contains any values
      # which you want to pass to the config set of nixpkgs
      # import nixpkgs { config = extra_pkg_config; inherit system; }
      # will not apply to module imports
      # as that will have your system values
      extra_pkg_config = {
        # allowUnfree = true;
      };

      system_resolved = forEachSystem (system:
        let
          dependencyOverlays = (import ./overlays inputs) ++ [
            (utils.sanitizedPluginOverlay inputs)
            inputs.lze.overlays.default
          ];

          #(import ./overlays inputs) ++ [ (standardPluginOverlay inputs)];
        in { inherit dependencyOverlays; });
      inherit (system_resolved) dependencyOverlays;
      # see :help nixCats.flake.outputs.categories
      # and
      # :help nixCats.flake.outputs.categoryDefinitions.scheme
      categoryDefinitions =
        { pkgs, settings, categories, name, ... }@packageDef: {
          # to define and use a new category, simply add a new list to a set here, 
          # and later, you will include categoryname = true; in the set you
          # provide when you build the package using this builder function.
          # see :help nixCats.flake.outputs.packageDefinitions for info on that section.

          # propagatedBuildInputs:
          # this section is for dependencies that should be available
          # at BUILD TIME for plugins. WILL NOT be available to PATH
          # However, they WILL be available to the shell 
          # and neovim path when using nix develop
          propagatedBuildInputs = { general = with pkgs; [ ]; };

          # lspsAndRuntimeDeps:
          # this section is for dependencies that should be available
          # at RUN TIME for plugins. Will be available to PATH within neovim terminal
          # this includes LSPs
          lspsAndRuntimeDeps = with pkgs; {
            general = [ curl ];
            bash = [ nodePackages.bash-language-server shfmt shellcheck ];
            lua = [ stylua lua-language-server ];
            nix = [ nixd nixfmt-classic ];
          };

          # This is for plugins that will load at startup without using packadd:
          startupPlugins = with pkgs.vimPlugins; {
            theme = builtins.getAttr categories.colorscheme {
              "onedark" = onedark-nvim;
              "catppuccin" = catppuccin-nvim;
            };
            general = with pkgs.neovimPlugins; [
              lze
              comment-nvim
              gitsigns-nvim
              which-key-nvim
              telescope-nvim
              telescope-fzf-native-nvim
              telescope-ui-select-nvim
              nvim-web-devicons
              plenary-nvim
              nvim-lspconfig
              lazydev-nvim
              fidget-nvim
              conform-nvim
              nvim-cmp
              luasnip
              cmp_luasnip
              cmp-nvim-lsp
              cmp-path
              todo-comments-nvim
              mini-nvim
              nvim-treesitter-textobjects
              nvim-treesitter.withAllGrammars
              lspkind-nvim
              vim-tmux-navigator
            ];
            indent_line = [ indent-blankline-nvim ];
            lint = [ nvim-lint ];
            autopairs = [ nvim-autopairs ];
            nvim-tree = [ nvim-tree-lua nvim-web-devicons ];
          };

          # not loaded automatically at startup.
          # use with packadd and an autocommand in config to achieve lazy loading
          # this config uses lazy.nvim, so this isn't relevent
          optionalPlugins = with pkgs.vimPlugins; {
            rust = [ rust-vim rustaceanvim ];

          };

          # shared libraries to be added to LD_LIBRARY_PATH
          # variable available to nvim runtime
          sharedLibraries = { general = { git = with pkgs; [ ]; }; };

          # environmentVariables:
          # this section is for environmentVariables that should be available
          # at RUN TIME for plugins. Will be available to path within neovim terminal
          environmentVariables = { };

          # If you know what these are, you can provide custom ones by category here.
          # If you dont, check this link out:
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/setup-hooks/make-wrapper.sh
          extraWrapperArgs = { };

          # lists of the functions you would have passed to
          # python.withPackages or lua.withPackages

          # get the path to this python environment
          # in your lua config via
          # vim.g.python3_host_prog
          # or run from nvim terminal via :!<packagename>-python3
          extraPython3Packages = { test = (_: [ ]); };
          # populates $LUA_PATH and $LUA_CPATH
          extraLuaPackages = { test = [ (_: [ ]) ]; };
        };

      extraNixdItems = pkgs: {
        nixpkgs = inputs.nixpkgs.outPath;
        flake-path = inputs.self.outPath;
        system = pkgs.system;
        systemCfgName = "nd@mac";
      };

      # And then build a package with specific categories from above here:
      # All categories you wish to include must be marked true,
      # but false may be omitted.
      # This entire set is also passed to nixCats for querying within the lua.
      common_settings = { pkgs, ... }: {
        configDirName = "nvim";
        wrapRc = true;
      };

      common_categories = { pkgs, ... }: {
        general = true;
        bash = true;
        lua = true;
        nix = true;
        gitPlugins = true;
        customPlugins = true;
        theme = true;
        colorscheme = "onedark";
        autopairs = true;
        nvim-tree = true;
        lint = true;
        indent_line = true;
        gitsigns = true;
        have_nerd_font = true;
        nixdExtras = extraNixdItems pkgs;
        rust = true;
      };

      # see :help nixCats.flake.outputs.packageDefinitions
      packageDefinitions = {
        nvim = args@{ pkgs, ... }: {
          # see :help nixCats.flake.outputs.settings
          settings = common_settings args // { aliases = [ "vi" "vim" ]; };
          categories = common_categories args // { };
        };
        nvim-dev = args@{ pkgs, ... }: {
          settings = common_settings args // {
            wrapRc = false;
            unwrappedCfgPath = "/Users/neil/nixNvim";
          };
          categories = common_categories args // { };
        };
      };
      defaultPackageName = "nvim";
      # see :help nixCats.flake.outputs.exports
    in forEachSystem (system:
      let
        nixCatsBuilder = utils.baseBuilder luaPath {
          inherit nixpkgs system dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions;
        defaultPackage = nixCatsBuilder defaultPackageName;
        # this is just for using utils such as pkgs.mkShell
        # The one used to build neovim is resolved inside the builder
        # and is passed to our categoryDefinitions and packageDefinitions
        pkgs = import nixpkgs { inherit system; };
      in {
        # these outputs will be wrapped with ${system} by utils.eachSystem

        # this will make a package out of each of the packageDefinitions defined above
        # and set the default package to the one passed in here.
        packages = utils.mkAllWithDefault defaultPackage;

        # choose your package for devShell
        # and add whatever else you want in it.
        devShells = {
          default = pkgs.mkShell {
            name = defaultPackageName;
            packages = [ defaultPackage ];
            inputsFrom = [ ];
            shellHook = "";
          };
          nvim-dev = pkgs.mkShell {
            name = "nvim-dev";
            packages = [ nixCatsBuilder "nvim-dev" ];
            inputsFrom = [ ];
            shellHook = "";
          };
        };

      }) // {

        # these outputs will be NOT wrapped with ${system}

        # this will make an overlay out of each of the packageDefinitions defined above
        # and set the default overlay to the one named here.
        overlays = utils.makeOverlays luaPath {
          inherit nixpkgs dependencyOverlays extra_pkg_config;
        } categoryDefinitions packageDefinitions defaultPackageName;

        # we also export a nixos module to allow reconfiguration from configuration.nix
        nixosModules.default = utils.mkNixosModules {
          inherit defaultPackageName dependencyOverlays luaPath
            categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
        };
        # and the same for home manager
        homeModule = utils.mkHomeModules {
          inherit defaultPackageName dependencyOverlays luaPath
            categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
        };
        inherit utils;
        inherit (utils) templates;
      };

}

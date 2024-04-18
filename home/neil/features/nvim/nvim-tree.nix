{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      nvim-tree-lua
      nvim-web-devicons
      ];
    extraLuaConfig = /* lua */ ''
    local nt = require("nvim-tree")
    local wk = require("which-key")

    nt.setup {
      disable_netrw = true,
      hijack_netrw = true,
      view = {
        number = true,
        relativenumber = true,
        },
      filters = {
        custom = { 'git' },
        exclude = { 'neogit.lua' },
        },
      actions = {
        open_file = {
          quit_on_open = true,
          },
        change_dir = {
          global = true,
          },
        },
      }

    wk.register({
      ["<leader>fe"] = { "<cmd>NvimTreeToggle<cr>", "Files" },
      })
    '';
    };
  }
  

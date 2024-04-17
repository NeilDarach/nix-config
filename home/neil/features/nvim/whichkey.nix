{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      which-key-nvim
      ];
    extraLuaConfig = /* lua */ ''
    local wk = require("which-key")

    vim.o.timeout = true
    vim.o.timeoutlen = 300

    wk.register({
      ["<leader>f"] = { name = "+file" },
      ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "Find File" },
      ["<leader>fb"] = { function() print("My lua config works") end, "Confirm" },
      })
    '';
    };
  }
  

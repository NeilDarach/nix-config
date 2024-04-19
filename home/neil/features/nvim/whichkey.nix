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
      })
    '';
    };
  }
  

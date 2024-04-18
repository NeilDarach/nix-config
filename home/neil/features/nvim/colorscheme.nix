{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      onedark-nvim
      ];
    extraLuaConfig = /* lua */ ''
    require('onedark').setup  {
      style = 'dark', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
      }

    vim.cmd.colorscheme 'onedark'
    vim.o.background = 'dark'
    '';
    };
  }

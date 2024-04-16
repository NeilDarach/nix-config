{ pkgs, ... }: {
  programs.neovim = {
    plugins = with pkgs.vimPlugins; [
      gruvbox-material
      ];
    extraLuaConfig = /* lua */ ''
    vim.o.termguicolors = true;
    vim.cmd('colorscheme gruvbox-material')
    vim.g.gruvbox_material_background = 'hard'
    '';
    };
  }

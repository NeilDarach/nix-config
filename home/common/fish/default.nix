{ config, inputs, outputs, pkgs, user, lib, ... }: {
  home.shellAliases = lib.mkIf config.programs.fish.enable {
    cat = "bat";
    less = "bat";
  };
  programs.fish.shellInit = ''
    fish_vi_key_bindings
  '';
}

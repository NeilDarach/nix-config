{ config, inputs, outputs, pkgs, user, lib, ... }: {
  home.shellAliases = lib.mkIf config.programs.fish.enable {
    cat = "bat";
    less = "bat";
  };
}

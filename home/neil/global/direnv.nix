{pkgs, ... } : {
  nixpkgs.overlays = [
    (self: super: {
      direnv = pkgs.unstable.direnv;
      }) ];

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true; # better than native direnv nix functionality - https://github.com/nix-community/nix-direnv
    config = { global = { hide_env_diff = true; }; };
  };
}

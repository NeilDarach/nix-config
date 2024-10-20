{ config, inputs, outputs, pkgs, lib, ... }: {
  options.gitcfg.email = lib.mkOption { type = lib.types.str; };
  options.gitcfg.name = lib.mkOption { type = lib.types.str; };
  config = {
    programs.git = lib.mkIf config.programs.git.enable {
      ignores = [ "*~" "*.swp" ];
      userEmail = config.gitcfg.email;
      userName = config.gitcfg.name;
    };
  };
}

/* Required to define 'homeConfigurations' in multiple files.
   Otherwise:
      The option 'flake.homeConfigurations' is defined multiple times while it is expected to be unique.
*/
{ lib, config, inputs, ... }: {
  options.configurations.home-manager = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
  config = {
    flake.modules.home-manager.home-manager = { config, ... }: {
      home.stateVersion = "25.11";
      backupFileExtension = "bak";
      useGlobalPackages = true;
      useUserPackages = true;
      programs.home-manager.enable = true;
    };

    flake.modules.nixos.home-manager = { config, ... }: {
      imports = [ inputs.home-manager.nixosModules.home-manager ];
      config = { home-manager = { extraSpecialArgs.inputs = inputs; }; };
    };
  };
}

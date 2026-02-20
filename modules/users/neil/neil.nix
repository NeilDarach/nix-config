{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    homeManager.user-neil =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.homeManager; [
          neil-direnv
          neil-fish
        ];
        home = {
          stateVersion = "25.11";
          sessionVariables = {
            PAGER = "less";
            CLICOLOR = 1;
            EDITOR = "vim";
          };
          shellAliases = {
            cat = "bat";
            less = "bat";
            ll = "ls -altr";
          };
          packages = with pkgs; [ fd ];
        };
        programs = {
          bash.enable = true;
          fish.enable = true;
          direnv.enable = true;
          git = {
            enable = true;
            ignores = [
              "*~"
              "*.swp"
              ".direnv"
            ];
            settings = {
              user = {
                name = "Neil Darach";
                email = "neil.darach@gmail.com";
              };
            };
          };
        };
      };

    nixos.user-neil =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
          inputs.sops-nix.nixosModules.sops
          (inputs.self.functions.mkUser { username = "neil"; })
        ];
        config = {
          sops.secrets = {
            "hashed_passwords/neil" = {
              neededForUsers = true;
            };
            "user_keys/neil/age/private" = {
              path = "/home/neil/.config/sops/age/keys.txt";
              owner = "neil";
              group = "neil";
              mode = "0600";
            };
            "neil_nixbuild" = lib.mkIf config.local.useDistributedBuilds {
              key = "user_keys/nixbuild/ed25519/private";
              path = "/home/neil/.ssh/id_nixbuild";
              owner = "neil";
              group = "neil";
              mode = "0600";
            };
          };
          systemd.tmpfiles.rules = [
            "d /home/neil/.config 755 neil neil"
            "d /home/neil/.config/sops 755 neil neil"
            "d /home/neil/.config/sops/age 755 neil neil"
          ];
          users.users.neil = {
            description = "Neil Darach";
            shell = pkgs.fish;
            extraGroups = [
              "networkmanager"
              "wheel"
            ];
            hashedPasswordFile = config.sops.secrets."hashed_passwords/neil".path;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
            ];

          };
        };
      };
  };
}

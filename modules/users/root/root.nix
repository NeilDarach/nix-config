{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    homeManager.user-root =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.homeManager; [
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
          packages = with pkgs; [ ];
        };
        home.file.".ssh/system_known_hosts" = {
          text = ''
            vps.goip.org.uk ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrqQK4MqFsQNmtUQO0giT/ixn01RM9fgLdm4lgUEJkQ
          '';
        };
        programs = {
          ssh = {
            enable = true;
            enableDefaultConfig = false;
            matchBlocks = {
              "*" = {
                userKnownHostsFile = "~/.ssh/known_hosts ~/.ssh/system_known_hosts";
              };
              "backup" = {
                hostname = "vps.goip.org.uk";
                user = "duplicati";
                identityFile = "~/.ssh/id_backup";
                addressFamily = "inet";
              };
            };
          };

          bash.enable = true;
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

    nixos.user-root =
      nixosArgs@{ pkgs, config, ... }:
      {
        imports = with inputs.self.modules.nixos; [
          inputs.sops-nix.nixosModules.sops
        ];
        config = {
          sops.secrets = {
            "root_password_hashed" = {
              neededForUsers = true;
            };
            "root_nixbuild" = lib.mkIf config.local.useDistributedBuilds {
              key = "ssh_privatekey_nixbuild";
              path = "/root/.ssh/id_nixbuild";
              owner = "root";
              group = "root";
              mode = "0400";
            };
            "ssh_privatekey_backup" = {
              path = "/root/.ssh/id_backup";
              owner = "root";
              group = "root";
              mode = "0400";
            };
          };
          users.users.root = {
            hashedPasswordFile = config.sops.secrets.root_password_hashed.path;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
            ];
          };
          systemd.tmpfiles.rules = [ "d /root/.ssh 0700 root root" ];
          home-manager.users.root.imports = with inputs.self.modules.homeManager; [
            common
            user-root
          ];
        };
      };
  };
}

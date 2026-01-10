{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.user-neil = nixosArgs@{ pkgs, config, ... }: {
      imports = with inputs.self.modules.nixos;
        [ inputs.sops-nix.nixosModules.sops ];
      config = {
        sops.secrets."user_password_hashed" = { neededForUsers = true; };
        users.users.neil = {
          isNormalUser = true;
          description = "Neil Darach";
          extraGroups = [ "networkmanager" "wheel" ];
          hashedPasswordFile = config.sops.secrets.user_password_hashed.path;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com"
          ];

        };
      };
    };
  };
}

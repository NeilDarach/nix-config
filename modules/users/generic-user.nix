{ config, lib, inputs, ... }: {
  config.flake.functions.mkUser = { username, ... }: {
    systemd.tmpfiles.rules =
      [ "d /home/${username}/.ssh 0700 ${username} ${username}" ];
    sops.secrets = {
      "users/${username}/ssh_ed25519_key" = {
        path = "/home/${username}/.ssh/id_ed25519";
        owner = "${username}";
        group = "${username}";
        mode = "0600";
      };
      "users/${username}/ssh_rsa_key" = {
        path = "/home/${username}/.ssh/id_rsa";
        owner = "${username}";
        group = "${username}";
        mode = "0600";
      };
    };

    users.groups."${username}" = { };
    users.users."${username}" = {
      isNormalUser = true;
      group = "${username}";
    };

    programs = {
      direnv.enable = lib.mkDefault true;
      fish.enable = lib.mkDefault true;
      git.enable = lib.mkDefault true;
    };
  };
}

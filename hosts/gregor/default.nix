{
    config,
    pkgs,
    lib,
    inputs,
    outputs,
    user,
    ...
} : {
    imports = [
        ./hardware-configuration.nix
        ./disko-config.nix
        ../server.nix
        ../../home
    ];
    sops.age.keyFile = "/persist/var/lib/sops-nix/key.txt";
    sops.defaultSopsFormat = "yaml";
    sops.secrets.user_password_hashed.neededForUsers = true;
    sops.secrets.root_password_hashed.neededForUsers = true;
    sops.defaultSopsFile = ../../secrets/secrets.yaml;

    networking = {
        hostName = "gregor";
        hostId = "42231481";
        firewall.enable = true;
        networkmanager.enable = true;
    };

    fileSystems."/home" = {
        device = "silent/home";
        fsType = "zfs";
        neededForBoot = true;
    };

    environment =  {
        shellAliases.nr = "sudo rm -rf /tmp/system && sudo git clone --branch gregor https://github.com/NeilDarach/nix-config /tmp/system && sudo nixos-rebuild switch --flake /tmp/system/.#gregor";
    };
}

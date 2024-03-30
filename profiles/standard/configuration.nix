{ pkgs, lib, systemSettings, userSettings, nixos-hardware, ... }: {
  imports = [
    ../../system/hardware-configuration.nix
    ../../system/hardware/time.nix
    ../../system/hardware/bluetooth.nix
    ./pi.nix
    ];

  sops.defaultSopsFile = ../../secrets/common.json;
  sops.defaultSopsFormat = "json";
  sops.age.sshKeyPaths = [ "/root/.ssh/id_ed25519" ];
  sops.secrets.hostKeys_hayellow = {
    mode = "0400";
    path = "/etc/ssh/ssh_host_ed25519_key";
    };

  sops.secrets.hostKeys_hayellow_pub = {
    mode = "0466";
    path = "/etc/ssh/ssh_host_ed25519_key.pub";
    };
   
  nix.nixPath = [ "nixos-config=$HOME/.dotfiles/system/configuration.nix" ];
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    '';

  nix.distributedBuilds = true;
  nix.buildMachines = [
    { hostName = "nixos-build";
      systems = [ "aarch64-linux" ];
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      }
      ];


  nixpkgs.config.allowUnfree = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;

  networking.hostName = systemSettings.hostname;
  services.openssh.enable = true;
  services.openssh.knownHosts.githubed.hostNames = [ "github.com" ];
  services.openssh.knownHosts.githubed.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  services.openssh.knownHosts.githubrsa.hostNames = [ "github.com" ];
  services.openssh.knownHosts.githubrsa.publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
  services.openssh.knownHosts.githubecdsa.hostNames = [ "github.com" ];
  services.openssh.knownHosts.githubecdsa.publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="; 


  services.openssh.knownHosts.nixos-build.hostNames = [ "nixos-build.darach.org.uk" ];
  services.openssh.knownHosts.nixos-build.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9qKrfo5/UkLCIU9kYNvzHkfVPpajZtvie7FHqMain1"; 

  services.openssh.hostKeys = [ ];

  programs.ssh.extraConfig = ''
Host nixos-build
    HostName nixos-build.darach.org.uk
    port 22
    user neil
    IdentitiesOnly yes
    IdentityFile /root/.ssh/id_nixos-build
    AddressFamily inet
    '';


  time.timeZone = systemSettings.timezone;
  i18n.defaultLocale = systemSettings.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = systemSettings.locale;
    LC_IDENTIFICATION = systemSettings.locale;
    LC_MEASUREMENT = systemSettings.locale;
    LC_MONETARY = systemSettings.locale;
    LC_NAME = systemSettings.locale;
    LC_NUMERIC = systemSettings.locale;
    LC_PAPER = systemSettings.locale;
    LC_TELEPHONE = systemSettings.locale;
    LC_TIME = systemSettings.locale;
    };

  environment.systemPackages = with pkgs; [
    age
    binutils
    neovim
    tmux
    git
    wget
    curl
    home-manager
    docker
    nix-output-monitor
    sops
    ssh-to-age
    ];

  environment.shells = with pkgs; [ bash ];
  users.defaultUserShell = pkgs.bash;

  users.users.neil = {
    isNormalUser = true;
    home = "/home/neil";
    description = "Neil Darach";
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com" ];
    };

  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIJ0nGtONOY4QnJs/xj+N4rKf4pCWfl25BOfc8hEczUg neil.darach@gmail.com" ];
    };

  system.stateVersion = "23.11";
  }

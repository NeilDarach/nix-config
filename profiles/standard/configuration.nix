{ ... }: {
  imports = [
    ../../system/hardware-configuration.nix
    ../../system/time.nix
    ../../system/bluetooth.nix
    ];

  nix.nixPath = [ "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
                  "nixos-config=$HOME/dotfiles/system/configuration.nix"
		  "/nix/var/nix/profiles/per-user/root/channels"
		  ];
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    '';

  nix.pkgs.config.allowUnfree = true;


  networking.hostname = systemSettings.hostname;


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
    neovim
    tmux
    git
    wget
    curl
    home-manager
    ];

  environment.shells = with pkgs; [ bash ];
  usrs.defaultUserShell = pkgs.bash;
  programs.bash.enable = true;

  system.stateVersion = "22.11";
  }

* Repair the nix store, checking for hash mis-matches
```sudo nix-store --verify --check-contents --repair```
* Generations are stored in /nix/var/nix/profiles and can be deleted
* Delete unreachable links
```sudo nix store gc```
* Delete automatic roots (created by, e.g. nixos-rebuild build) in /nix/var/nix/gcroots/auto


All the secrets are kept in a separate input.
Checkout github:NeilDarach/secrets and edit them with sops before pushing and updating the flake


= Links for flashing a better firmware onto Xiaomi temperature sensors
* https://pvvx.github.io/ATC_MiThermometer/TelinkOTA.html
* https://pvvx.github.io/ATC_MiThermometer/TelinkMiFlasher.html
* https://github.com/pvvx/ATC_MiThermometer


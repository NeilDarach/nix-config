# Installing nix onto a nanopi r5s

## References
* https://gist.github.com/MatrixManAtYrService/95459c761449dafd8a24da10f2d5a5be
* https://github.com/inindev/nanopi-r5/issues/11#issuecomment-2658328071
* https://github.com/bdew/nixos-nanopi

## Prepare the image
* Build a bootable SD image for the r5s and write it to a handy SD card
```
nix build --builders "" .#nanopi-r5s-image
xz -d result/nanopi-r5s-nixos.img.xz ./nanopi-r5s-nixos.img
```
Boot the r5s to hostname:nixos
Run the install script
```
just deploy_r5s
```
which will use nixos-anywhere to partition the disks, install the boot loader on the eMMC, copy the age key for sops decryption and install nixos on the partitioned disks.
Remove the sd card and reboot.

# Xiaomi temperature sensors
 Links for flashing a better firmware onto Xiaomi temperature sensors
 * https://pvvx.github.io/ATC_MiThermometer/TelinkOTA.html
 * https://pvvx.github.io/ATC_MiThermometer/TelinkMiFlasher.html
 * https://github.com/pvvx/ATC_MiThermometer


 # Secrets
 All the secrets are kept in a separate input.
Checkout github:NeilDarach/secrets and edit them with sops before pushing and updating the flake

# Managing the nix store
* Repair the nix store, checking for hash mis-matches
```
sudo nix-store --verify --check-contents --repair
```
 * Generations are stored in /nix/var/nix/profiles and can be deleted
 * Delete unreachable links
 ```
 sudo nix store gc
 ```
 * Delete automatic roots (created by, e.g. nixos-rebuild build) in /nix/var/nix/gcroots/auto


# disko
 Do the disko partitioning from hosts/<host>/disko.sh
 Validate that the partitions are mounted with
     mount | grep /mnt
 Make sure the host age key in in /mnt/persist/var/lib/sops-nix/key.txt
 sudo nixos-install --flake .#gregor


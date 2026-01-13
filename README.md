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


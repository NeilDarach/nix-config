# Installing nix onto a nanopi r5s

## References
* https://gist.github.com/MatrixManAtYrService/95459c761449dafd8a24da10f2d5a5be
* https://github.com/inindev/nanopi-r5/issues/11#issuecomment-2658328071
* https://github.com/bdew/nixos-nanopi

## Prepare the image
* Get a copy of the bootable image from bdew
```
git clone git@github.com:bdew/nixos-nanopi.git
cd nixos-nanopi
nix build .#nanopi-r5s-image
zstd -d result/nanopi-r5s-nixos.img.zst -o ../nanopi-r5s-nixos.img
```
which  will create nanopi-r5s-nixos.img
Write this image to an SD card
Boot from the SD card
Write the image to the eMMC
```
cat nanopi-r5s-nixos.img | ssh nix@<host> "sudo cat > /dev/mmcblk1 && sync"
```

Relabel the eMMC partition as a boot partition, generate some random UUIDs and resize
the partition to 100%
```
sudo e2label /dev/mmcblk1p1 NIXOS_BOOT
sudo tune2fs -U random /dev/mmcblk1p1
sudo tune2fs -U random /dev/mmcblk0p1
sudo parted /dev/mmcblk1 ---pretend-input-tty resizepart 1 100%
sudo resize2fs /dev/mmcblk1p1
```

Create a filesystem on the NVME drive


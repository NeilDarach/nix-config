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
Boot the r5s
Clone the main nix repository
```
git clone https://github.com/NeilDarach/nix-r5s.git
```
Run the partitining script if necessary
```
cd modules/disko
./disko-r5s.sh
```
Copy the system key
and ssh keys to ~nix/.ssh and /root/.ssh to access the secrets repo on github
```
/keys/key.txt
```
Install the main configuration
```
cd ~/r5s
sudo nixos-install --flake .#r5s
```
Reboot

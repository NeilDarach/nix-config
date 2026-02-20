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

= GOIP configuration
zfs datapool contains backups
postfix docker image
nginx web server
backup user (duplicati) can run zfs commands
```
zfs snapshot
zfs destroy*@*
zfs mount
zfs list -t snap*
zfs send*
zfs recv*
zfs mount*
zfs umount*
zfs create*
zfs list
```
 - vda1     bios boot   1M
 - vda2     root        23G
 - vda3     swap        1G
 - vda4     zfs         1TB
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: ens3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 00:16:3c:4f:01:de brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 78.128.99.39/26 brd 78.128.99.63 scope global dynamic ens3
       valid_lft 15744942sec preferred_lft 15744942sec
    inet6 2a01:8740:1:ffd7::349b/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::216:3cff:fe4f:1de/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:30:1d:3c:e1 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 2a01:8740:1:ffd7:1::1/80 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::1/64 scope link 
       valid_lft forever preferred_lft forever
    inet6 fe80::42:30ff:fe1d:3ce1/64 scope link 
       valid_lft forever preferred_lft forever
98: br-57154fbf27f7: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:40:be:f3:90 brd ff:ff:ff:ff:ff:ff
    inet 172.24.0.1/16 brd 172.24.255.255 scope global br-57154fbf27f7
       valid_lft forever preferred_lft forever
    inet6 fe80::42:40ff:febe:f390/64 scope link 
       valid_lft forever preferred_lft forever


==Rebuilding the goip vps host
* Log in to the web console and change boot order to CD-ROM & ISO to netboot.xyz
* Reboot, open a noVNC console and select Linux Network Installs (64-bit) / NixOS / most recent
* Add an SSH key to ~nixos/.ssh/authorized_keys
* Run 'just deploy_goip' which will partition the disk, install the flake config and leave the system ready to accept the datapool restore
* sudo zfs send -R linstore/datapool/backups@nixrebuild | ssh -oUserKnownHostsFile=/dev/null nixos@goip.org.uk "sudo zfs recv -u zroot/datapool/backups"
* Reset the boot order and reboot
 

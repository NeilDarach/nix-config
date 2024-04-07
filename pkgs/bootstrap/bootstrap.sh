case $1 in 
  "zfs") 
cat <<-EOF
  zpool create -f               
    -m none	                
    -R /mnt                   
    -o ashift=12               
    -o listsnapshots=on        
    -O acltype=posix           
    -O compression=lz4          
    -O canmount=off             
    -O atime=off                
    -O relatime=on              
    -O recordsize=64K          
    -O dnodesize=auto         
    -O xattr=sa              
    -O normalization=formD  
    -O secondarycache=none  
    $2 "$3"

  zfs create -p -v -o secondarycache=none -o mountpoint=legacy $2/local/root
  zfs create -p -v -o secondarycache=none -o mountpoint=legacy $2/local/nix
  zfs create -p -v -o secondarycache=none -o mountpoint=legacy $2/safe/home
  zfs create -p -v -o secondarycache=none -o mountpoint=legacy $2/safe/persist

  # create an empty snapshot for root
  zfs snapshot $2/local/root@blank

  # reserved dataset for emergency deletion to free space
  zfs create -o refreservation=2G -o primarycache=none -o secondarycache=none -o mountpoint=none $2/reserved
	EOF
  ;;
  "mount") 
    cat <<-EOF
  mkdir -p /mnt/nixos
  zpool import -f $2
  mount -t zfs $2/local/root /mnt/nixos
  mkdir -p /mnt/nixos/{nix,home,persist,boot}
  mount -t zfs $2/local/nix /mnt/nixos/nix
  mount -t zfs $2/safe/home /mnt/nixos/home
  mount -t zfs $2/safe/persist /mnt/nixos/persist
  mount -t vfat $3 /mnt/nixos/boot

  # create some persist directories
  mkdir -p /mnt/nixos/persist/etc/{ssh,users,nixos,wireguard,NetworkManager/system-connections}
  mkdir -p /mnt/nixos/persist/var/{log,lib/bluetooth}
  mkdir -p /mnt/nixos/etc/nixos
  mkdir -p /mnt/nixos/var/log

  # bind mount
  mount -o bind /mnt/nixos/persist/etc/nixos /mnt/nixos/etc/nixos
  mount -o bind /mnt/nixos/persist/var/log /mnt/nixos/var/log
	EOF
	;;
  "close")
cat <<-EOF
  umount -R /mnt/nixos
  zpool export $2
  sfdisk -A $3 1
	EOF
esac

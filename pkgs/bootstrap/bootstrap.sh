set -eu
set -o pipefail

SCRIPTDIR=$(dirname $(realpath $0))
SCRIPT=$(basename $0)

function showUsage() {
  cat <<-EOF
	${SCRIPT} zfs <poolName> <zfsDevice>
	${SCRIPT} mount <poolName> <bootDevice>
	${SCRIPT} close <poolName> <bootDevice>
	${SCRIPT} install <host> <poolName> <zfsDevice> <bootDevice>
	${SCRIPT} info <host>
	${SCRIPT} switch <host> 
	EOF
}

# https://git.2li.ch/Nebucatnetzer/nixos/src/branch/master/scripts/update-all-machines
#
function showSwitch() {
  local host 
  if [[ $# != 1 ]] ; then echo "${SCRIPT} ${CMD} <host>"; return 1 ; fi
  host=$1
  cat <<-EOF
	SSH_NIXOPTS="-t -i ~/.ssh/id_nixos-build" nixos-rebuild switch -j auto --use-remote-sudo --target-host ${host} --flake github:NeilDarach/nix-config#${host}
	EOF
}
  	

function showInstall() {
  local host pool zfsDevice bootDevice
  if [[ $# != 4 ]] ; then echo "${SCRIPT} ${CMD} <host> <poolName> <zfsDevice> <bootDevice>"; return 1 ; fi
  host=$1
  pool=$2
  zfsDevice=$3
  bootDevice=$4
  cat <<-EOF
	ssh root@${host} -i ~/.ssh/id_nixos-build "nix run git:NeilDarach/nix-config#bootstrap zfs ${pool} ${zfsDevice} | bash"
	ssh root@${host} -i ~/.ssh/id_nixos-build "nix run git:NeilDarach/nix-config#bootstrap zfs ${pool} ${bootDevice} | bash"
	ssh root@${host} -i ~/.ssh/id_nixos-build "nixos-install --root /mnt/nixos --flake github:NeilDarach/nix-config#${pool}"
	ssh root@${host} -i ~/.ssh/id_nixos-build "nix run git:NeilDarach/nix-config#close ${pool} ${bootDevice} | bash"
	EOF
}

function showInfo() {
  local host 
  if [[ $# != 1 ]] ; then echo "${SCRIPT} ${CMD} <host>"; return 1 ; fi
  host=$1
  cat <<-EOF
	ssh root@${host} -i ~/.ssh/id_nixos-build "ls -ltr /dev/disk/by-id"
	EOF
}

function showZfs() {
  local pool device
  if [[ $# != 2 ]] ; then echo "${SCRIPT} ${CMD} <poolName> <zfsDevice>"; return 1 ; fi
  pool=$1
  device=$2
  cat <<-EOF
	zpool create -f                       \\
	-m none -R /mnt -o ashift=12          \\
	-o listsnapshots=on -O acltype=posix  \\
	-O compression=lz4 -O canmount=off    \\
	-O atime=off -O relatime=on           \\
	-O recordsize=64K -O dnodesize=auto   \\
	-O xattr=sa -O normalization=formD    \\
	-O secondarycache=none                \\
	${pool} ${device}

	zfs create -p -v -o secondarycache=none -o mountpoint=legacy ${pool}/local/root
	zfs create -p -v -o secondarycache=none -o mountpoint=legacy ${pool}/local/nix
	zfs create -p -v -o secondarycache=none -o mountpoint=legacy ${pool}/safe/home
	zfs create -p -v -o secondarycache=none -o mountpoint=legacy ${pool}/safe/persist

	# create an empty snapshot for root
	zfs snapshot ${pool}/local/root@blank

	# reserved dataset for emergency deletion to free space
	zfs create -o refreservation=2G -o primarycache=none -o secondarycache=none -o mountpoint=none ${pool}/reserved
	EOF
  return 0
}

function showMount() {
  local pool bootdevice
  if [[ $# != 2 ]] ; then echo "${SCRIPT} ${CMD} <poolName> <bootDevice>"; return 1 ; fi
  pool=$1
  bootdevice=$2
  cat <<-EOF
	mkdir -p /mnt/nixos
	zpool import -f ${pool}
	mount -t zfs ${pool}/local/root /mnt/nixos
	mkdir -p /mnt/nixos/{nix,home,persist,boot}
	mount -t zfs ${pool}/local/nix /mnt/nixos/nix
	mount -t zfs ${pool}/safe/home /mnt/nixos/home
	mount -t zfs ${pool}/safe/persist /mnt/nixos/persist
	fatlabel ${bootdevice} FIRMWARE
	mount -t vfat ${bootdevice} /mnt/nixos/boot

	# create some persist directories
	mkdir -p /mnt/nixos/persist/etc/{ssh,users,nixos,wireguard,NetworkManager/system-connections}
	mkdir -p /mnt/nixos/persist/var/{log,lib/bluetooth}
	mkdir -p /mnt/nixos/etc/nixos
	mkdir -p /mnt/nixos/var/log

	# bind mount
	mount -o bind /mnt/nixos/persist/etc/nixos /mnt/nixos/etc/nixos
	mount -o bind /mnt/nixos/persist/var/log /mnt/nixos/var/log
	EOF
  return 0
}

function showClose() {
  local pool
  if [[ $# != 2 ]] ; then echo "${SCRIPT} ${CMD} <poolName> <bootDevice>"; return 1 ; fi
  pool=$1
  bootDevice=$2
  cat <<-EOF
	umount -R /mnt/nixos
	zpool export ${pool}
	sfdisk -A ${bootDevice} 1
	EOF
  return 0
}

if [[ $# -lt 1 ]] ; then
  showUsage
  exit 0
fi

CMD=$1
shift
case ${CMD} in 
  "zfs") showZfs $*
	  ;;
  "mount") showMount $*
	  ;;
  "close") showClose $*
	  ;;
  "install") showInstall $*
	  ;;
  "info") showInfo $*
	  ;;
  "switch") showSwitch $*
	  ;;
  *) showUsage 
	  ;;
esac

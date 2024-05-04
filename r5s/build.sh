# Build the bootable image.
# Once it gets to the creation of the disk images, cancel the build and re-issue with
#   --builders ''
# to avoid building disk images on a remote host
nix build .#image.r5s

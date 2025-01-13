{pkgs, ...}: {
    local_transcode = pkgs.callPackage ./transcode {};
    registration = pkgs.callPackage ./registration {};
    zfs-backup = pkgs.callPackage ./zfs-backup {};
    strongStateDir = pkgs.callPackage ./strongStateDir {};
}

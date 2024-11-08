{pkgs, ...}: {
    local_transcode = pkgs.callPackage ./transcode {};
    registration = pkgs.callPackage ./registration {};
}

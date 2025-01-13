{
  zfsBackup = src: dst: {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "Sun 20:03:00";
      RandomizedDelaySec = "1200";
      Unit = "zfs-backup@${src}:${dst}.service";
    };
  };

}

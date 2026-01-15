{
  config,
  lib,
  inputs,
  ...
}:
{
  flake.modules = {
    nixos.svc-ups =
      nixosArgs@{ pkgs, config, ... }:
      {
        options.local.nut-client = {
          enable = lib.mkEnableOption "nut client monitoring on this host";
        };
        config =
          let
            # How many seconds the system should wait for the UPS to come back
            systemGraceTime = "600";

            upssched-dispatch = pkgs.writeShellApplication {
              name = "upssched-dispatch";
              runtimeInputs = [ pkgs.logger ];
              text =
                # bash
                ''
                  # This script will be called by upssched via the CMDSCRIPT directive.
                  # The first argument passed to CMDSCRIPT is the name of the 
                  # timer from the AT line or the value of the EXECUTE directive
                  case $1 in 
                  halt)
                    logger -t upssched-dispatch "Received a HALT event"
                    ${pkgs.systemd}/bin/shutdown now
                    ;;
                  *)
                    logger -t upssched-dispatch "Unrecognised or unimplemented command: $1"
                    ;;
                  esac
                '';
            };
          in
          lib.mkIf config.local.nut-client.enable {
            power.ups = {
              enable = true;
              mode = "netclient";

              upsmon.settings = {
                POWERDOWNFLAG = "/var/state/ups/killpower";
                NOTIFYFLAG = [
                  [
                    "ONLINE"
                    "SYSLOG+WALL"
                  ]
                  [
                    "ONBATT"
                    "SYSLOG+WALL"
                  ]
                  [
                    "LOWBATT"
                    "SYSLOG+WALL"
                  ]
                  [
                    "FSD"
                    "SYSLOG+WALL"
                  ]
                  [
                    "ONLINE"
                    "SYSLOG+WALL"
                  ]
                  [
                    "COMBAD"
                    "EXEC"
                  ]
                  [
                    "SHUTDOWN"
                    "SYSLOG+WALL"
                  ]
                  [
                    "REPLBATT"
                    "SYSLOG+WALL"
                  ]
                  [
                    "NOCOMM"
                    "SYSLOG+WALL+EXEC"
                  ]
                  [
                    "NOPARENT"
                    "SYSLOG+WALL"
                  ]
                ];
              };

              upsmon.monitor.eaton = {
                user = "upsmon";
                powerValue = 1;
                system = "eaton@arde.darach.org.uk:3493";
                passwordFile = config.sops.secrets."nut/nut_password".path;
                type = "secondary";
              };

              schedulerRules =
                pkgs.lib.pipe
                  ''
                    CMDSCRIPT ${pkgs.lib.getExe upssched-dispatch}
                    PIPEFN /var/state/ups/upssched.pipe
                    LOCKFN /var/state/ups/upssched.lock
                    # Syntax: 
                    # AT <notifyType> <upsName> <command>
                    AT ONLINE * CANCEL-TIMER halt

                    # If the UPS is on battery -- start a countdown timer and die
                    AT ONBATT * START-TIMER halt ${systemGraceTime}
                    # If the batter is low, just shut down
                    AT LOWBATT * EXECUTE halt
                    # Halt on a forced shutdown
                    AT FSD * EXECUTE halt

                    # If communication is lost, start a shutdown timer
                    AT COMMBAD * START-TIMER halt ${systemGraceTime}
                    AT NOCOMM * START-TIMER halt ${systemGraceTime}
                    # Cancel if communication is restored
                    AT COMMOK * CANCEL-TIMER halt

                    # Do nothing, this will be caught by monitoring
                    AT REPLBATT * EXECUTE REPLBAT
                    AT NOPARENT * EXECUTE NOPARENT
                    AT CAL * EXECUTE CAL
                    AT NOTCAL * EXECUTE NOTCAL
                    AT OFF * EXECUTE OFF
                    AT NOTOFF * EXECUTE NOTOFF
                    AT BYPASS * EXECUTE BYPASS
                    AT NOTBYPASS * EXECUTE NOTBYPASS
                    AT SUSPEND_STARTING * EXECUTE SUSPEND_STARTING
                    AT SUSPEND_FINISHED * EXECUTE SUSPEND_FINISHED
                  ''
                  [
                    (pkgs.writeText "upssched.conf")
                    toString
                  ];

            };

            users.groups.nutmon = { };
            users.users.nutmon.group = "nutmon";
            users.users.nutmon.isSystemUser = true;
            sops.secrets."nut/nut_password" = {
              owner = "nutmon";
            };
          };
      };
  };

}

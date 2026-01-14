{ config, lib, inputs, ... }: {
  flake.modules = {
    nixos.hardware-r5s-irq = nixosArgs@{ pkgs, config, ... }: {
      imports = with inputs.self.modules.nixos; [ ];
      options = { };
      config = {
        systemd.services."irqbalance-oneshot" = {
          enable = true;
          description = ''
            Distribute interrupts after booting using "irqbalance --oneshot"'';
          documentation = [ "man:irqbalance" ];
          wantedBy = [ "sysinit.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart =
              "${pkgs.irqbalance}/bin/irqbalance --foreground --oneshot";
          };
        };
      };
    };
  };
}


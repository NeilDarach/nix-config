{ config, lib, pkgs, ha, ... }: {
  services.home-assistant.config = {
    "automation manual" = [ ] ++ (ha.lightBrightness "TestBrightLights" 255 {
      entities = [ "light.livingroom_lamp_left" "light.livingroom_lamp_right" ];
    }) ++ (ha.lightBrightness "TestDimLights" 100 {
      transition = 5;
      entities = [ "light.livingroom_lamp_left" "light.livingroom_lamp_right" ];
    }) ++ [{
      alias = "Explicit Automation";
      description = "Long form in light.nix";
      trigger = [ ];
      condition = [ ];
      action = [
        {
          service = "light.turn_on";
          data = {
            transition = 5;
            color_temp = 153;
          };
          target.entity_id = [ "light.livingroom_lamp_left" "light.livingroom_lamp_right"];
        }
        { delay.seconds = 3; }
        {
          service = "light.turn_on";
          data.color_temp = 500;
          target.entity_id = [ "light.livingroom_lamp_left" "light.livingroom_lamp_right"];
        }
      ];
      mode = "single";
    }];
  };
}

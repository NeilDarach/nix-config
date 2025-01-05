{ config, lib, pkgs, ha, ... }: {
  services.home-assistant.config = {
    "automation manual" = [ ] ++ (ha.lightBrightness "TestBrightLights" 255 {
      entities = [ "light.livingroom_lamp_left" "light.livingroom_lamp_right" ];
    }) ++ (ha.lightBrightness "TestDimLights" 100 {
      transition = 5;
      entities = [ "light.livingroom_lamp_left" "light.livingroom_lamp_right" ];
    });
  };
}

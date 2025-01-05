{ stdenv, pkgs, fetchFromGitHub, buildHomeAssistantComponent, home-assistant }:

buildHomeAssistantComponent rec {
  owner = "custom-components";
  domain = "ble_monitor";
  version = "12.11.3";


  src = fetchFromGitHub {
    owner = "custom-components";
    repo = "ble_monitor";
    rev = "${version}";
    sha256 = "sha256-dDiypaOqV6n6duJUWLxlfjNHOYUnNRsV6srJuSHlZns=";
  };

  propagatedBuildInputs =  [ 
    home-assistant.python.pkgs.pycryptodomex
    home-assistant.python.pkgs.janus
    home-assistant.python.pkgs.aioblescan
    home-assistant.python.pkgs.btsocket
    home-assistant.python.pkgs.pyric
    ];
}

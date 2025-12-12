{ stdenv, pkgs, fetchFromGitHub, buildHomeAssistantComponent, home-assistant }:

buildHomeAssistantComponent rec {
  owner = "custom-components";
  domain = "ble_monitor";
  version = "13.10.1";

  src = fetchFromGitHub {
    owner = "custom-components";
    repo = "ble_monitor";
    rev = "${version}";
    sha256 = "sha256-MwYCQDc9cIy5lYcU+p8rKGeAXrMJjg+LTyafCveBcDI=";
  };

  propagatedBuildInputs = [
    home-assistant.python.pkgs.pycryptodomex
    home-assistant.python.pkgs.janus
    home-assistant.python.pkgs.aioblescan
    home-assistant.python.pkgs.btsocket
    home-assistant.python.pkgs.pyric
  ];
}

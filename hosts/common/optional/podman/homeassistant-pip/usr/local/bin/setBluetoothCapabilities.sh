#!/bin/bash
set -xe
# Set capabilities so Home Assistant can recieve BLE broadcasts
# BLE docs say to set capabilities on $(which python3), but the linuxserver docker
# image explicitly sets cap_net_bind_service just before starting the main process,
# reverting the change

# install packages needed for BLE scanning
pip install --no-index --find-links file:///pkgs aioblescan janus

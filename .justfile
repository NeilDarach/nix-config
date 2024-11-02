_default:
  @just --list

# Rebuild the httpboot eeprom and flash it to the pi
httpboot:
  usbboot/tools/update-pieeprom.sh -k "$KEY_FILE" -c pieeprom-http/boot.conf \
  -i usbboot/recovery/pieeprom.original.bin -o pieeprom-http/pieeprom.bin \
  && usbboot/rpiboot -v -d pieeprom-http

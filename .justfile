_default:
  @just --list

# Rebuild the httpboot eeprom and flash it to the pi
httpboot:
  usbboot/tools/update-pieeprom.sh -k "$KEY_FILE" -c pieeprom-http/boot.conf \
  -i usbboot/recovery/pieeprom.original.bin -o pieeprom-http/pieeprom.bin \
  && usbboot/rpiboot -v -d pieeprom-http

# Build a boot.img from ./boot and generate a signature
bootimg:
  mkdir -p boot
  touch boot/config.txt
  dd if=/dev/zero of=boot.img bs=1M count=95
  mformat -i boot.img -F ::
  mcopy -s -i boot.img boot/* ::
  usbboot/tools/rpi-eeprom-digest -i boot.img -o boot.sig -k "$KEY_FILE"
  cp boot.img boot.sig /var/lib/nginx/www/pi/yellow

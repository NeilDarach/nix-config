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
    just mkboot
    just initramfs
    dd if=/dev/zero of=boot.img bs=1M count=95
    mformat -i boot.img -F ::
    mcopy -s -i boot.img boot/* ::
    usbboot/tools/rpi-eeprom-digest -i boot.img -o boot.sig -k "$KEY_FILE"
    mv boot.img boot.sig /var/lib/nginx/www/pi/yellow

# Copy the files from the mass_storage_gadget into ./boot
mkboot:
    rm -rf boot.tmp
    rm -f msg.img
    dd if=usbboot/mass-storage-gadget/boot.img bs=512 skip=1 of=msg.img
    mkdir -p boot.tmp
    mcopy -s -n -i msg.img :: boot.tmp
    mv boot.tmp/config.txt boot.tmp/config-msg.txt
    cp -r boot.tmp/* boot

# Rebuild the initramfs
initramfs:
    sudo rm -rf initramfs.d
    mkdir initramfs.d
    cd initramfs.d ; zstdcat ../boot.tmp/rootfs.cpio.zst | sudo cpio -i -f dev/console
    #sudo mknod -m 600 initramfs.d/dev/console c 5 1
    sudo rm initramfs.d/etc/init.d/S21msdadget
    sudo cp -r initramfs.changes/* initramfs.d
    cd initramfs.d ; sudo find . -print0 | sudo cpio --null --create --format=newc | zstd > ../boot/rootfs.cpio.zst

# Remove all the intermediate artifacts
clean:
    sudo rm -rf initramfs.d
    sudo rm -rf boot.tmp
    rm -f msg.img

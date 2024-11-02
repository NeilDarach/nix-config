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
    cp boot.img boot.sig /var/lib/nginx/www/pi/yellow

# Copy the files from the mass_storage_gadget into ./boot
mkboot:
    dd if=usbboot/mass-storage-gadget/boot.img bs=512 skip=1 of=msg.img
    mkdir -p boot.tmp
    mcopy -s -i msg.img :: boot.tmp
    mv boot.tmp/rootfs.cpio.zst .
    rm boot.tmp/config.txt
    cp -r boot.tmp/* boot
    rm msg.img
    rm -rf boot.tmp

# Rebuild the initramfs
initramfs:
    mkdir -p initramfs.d
    cd initramfs.d ; zstdcat ../rootfs.cpio.zst | cpio -i -f dev/console
    sudo mknod -m 600 initramfs.d/dev/console c 5 1
    cp -r initramfs.changes/* initramfs.d
    cd initramfs.d ; find . -print0 | cpio --null --create --format=newc | zstd > ../boot/rootfs.cpio.zstd
    rm -rf initramfs.d


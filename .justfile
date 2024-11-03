_default:
    @just --list

# Initialize a newly created clone by downloading the submodules and building rpiboot
init:
    git submodule update --init --recursive
    cd usbboot; make

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
    rm -rf boot
    dd if=usbboot/mass-storage-gadget/boot.img bs=512 skip=1 of=msg.img
    mkdir -p boot
    mcopy -s -n -i msg.img :: boot
    cp -r ssh-img/boot/* boot

# Rebuild the initramfs
initramfs:
    sudo rm -rf initramfs.d
    mkdir initramfs.d
    cd initramfs.d ; zstdcat ../boot/rootfs.cpio.zst | cpio -i -f "dev/*"
    cp -r ssh-img/root/* initramfs.d
    gen_init_cpio <(cat ssh-img/cpio-nodes.txt; ./gen_initramfs_list.sh -u $(id -u) -g $(id -g) initramfs.d) | zstd > boot/rootfs.cpio.zst



# Remove all the intermediate artifacts
clean:
    rm -rf initramfs.d
    rm -rf boot
    rm -f msg.img

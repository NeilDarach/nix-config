_default:
    @just --list

# Initialize a newly created clone by downloading the submodules and building rpiboot
init:
    git submodule update --init --recursive
    cd usbboot; make

# Rebuild the eeprom to boot from http preferentially and flash it to the pi
bootnet:
    usbboot/tools/update-pieeprom.sh -k "$KEY_FILE" -c pieeprom/http.conf \
    -i usbboot/recovery/pieeprom.original.bin -o pieeprom/pieeprom.bin \
    && usbboot/rpiboot -v -d pieeprom

# Rebuild the eeprom to boot from emmc preferentially and flash it to the pi
bootlocal:
    usbboot/tools/update-pieeprom.sh -k "$KEY_FILE" -c pieeprom/emmc.conf \
    -i usbboot/recovery/pieeprom.original.bin -o pieeprom/pieeprom.bin \
    && usbboot/rpiboot -v -d pieeprom

# Build a 32bit boot.img from ./boot and generate a signature
bootimg32:
    mkdir -p boot
    just initramfs32
    dd if=/dev/zero of=boot.img bs=1M count=95
    mformat -i boot.img -F ::
    mcopy -s -i boot.img boot/* ::
    usbboot/tools/rpi-eeprom-digest -i boot.img -o boot.sig -k "$KEY_FILE"
    mv boot.img boot.sig /var/lib/nginx/www/pi/yellow

# Build a 64bit boot.img from ./boot and generate a signature
bootimg64:
    just mkboot64
    just initramfs64
    dd if=/dev/zero of=boot.img bs=1M count=95
    mformat -i boot.img -F ::
    mcopy -s -n -i boot.img boot/* ::
    usbboot/tools/rpi-eeprom-digest -i boot.img -o boot.sig -k "$KEY_FILE"
    mv boot.img boot.sig /var/lib/nginx/www/pi/yellow

# Copy the files from the mass_storage_gadget into ./boot
mkboot32:
    rm -rf boot
    mkdir -p boot
    dd if=usbboot/mass-storage-gadget/boot.img bs=512 skip=1 of=msg.img
    mcopy -s -n -i msg.img :: boot

# Copy the files from the kernel build into ./boot
mkboot64:
    rm -rf boot
    mkdir -p boot
    #cp -r --no-preserve=ownership,mode kernel/result/dtbs boot
    # cp -r kernel/result/Image boot/zImage
    cp zImage boot
    cp -r ssh64/boot/* boot

# Rebuild the initramfs for a 32bit image
initramfs32:
    just mkboot32
    sudo rm -rf initramfs.d
    mkdir initramfs.d
    cd initramfs.d ; zstdcat ../boot/rootfs.cpio.zst | sudo cpio -i -R neil -f "dev/*"
    gen_init_cpio <(./gen_initramfs_list.sh -u $(id -u) -g $(id -g) initramfs.d ; cat ssh32/cpio-*.txt) | zstd > boot/rootfs.cpio.zst

# Rebuild the initramfs for a 64bit image
initramfs64:
    sudo rm -rf initramfs.d
    mkdir initramfs.d
    cp -r --no-preserve=ownership,mode kernel/result/lib initramfs.d/lib
    rm -rf initramfs.d/lib/modules/6.1.63/kernel/sound
    tar -C initramfs.d -xf ssh64/alpine.tar
    cp dropbear/result/bin/dropbear initramfs.d/sbin
    rm initramfs.d/bin/tar
    cp tar/result/bin/tar initramfs.d/bin
    rm initramfs.d/sbin/init
    cp -r ssh64/root/* initramfs.d
    #gen_init_cpio <(./gen_initramfs_list.sh -u $(id -u) -g $(id -g) initramfs.d ; cat ssh64/cpio-*.txt) | zstd > boot/rootfs.cpio.zst
    cp rootfs.cpio.zst boot



# Remove all the intermediate artifacts
clean:
    rm -rf initramfs.d
    rm -rf boot
    rm -f msg.img

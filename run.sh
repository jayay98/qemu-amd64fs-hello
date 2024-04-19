#!/bin/sh

#-----------------------------------------------------------------------------
# Variables
ISO_URL=http://tinycorelinux.net/15.x/x86/release/Core-current.iso

WORK_DIR=/tmp/workstation
ISOFILES_DIR=$WORK_DIR/isofiles
INITRD_DIR=$WORK_DIR/initrd
OUTPUT_DIR=$WORK_DIR/iso
OUTPUT_BOOT_DIR=$OUTPUT_DIR/boot
OUTPUT_GRUB_DIR=$OUTPUT_BOOT_DIR/grub

ISO_PATH=$WORK_DIR/sample.iso
INITRDGZ_RELPATH=boot/core.gz
KERNEL_RELPATH=boot/vmlinuz
OUTPUT_ISO_PATH=./myos.iso

BOOT_MESSAGE="hello world"

# ----------------------------------------------------------------------------
# Download tool dependencies
sudo apt-get install qemu-system \
	xorriso \
	mtools \
	libarchive-tools \
	wget

# Download TinyCore Binary
mkdir $WORK_DIR
wget $ISO_URL -O $ISO_PATH

# Extract ISO contents
mkdir $ISOFILES_DIR
bsdtar -xzf $ISO_PATH -C $ISOFILES_DIR

# Extract Initrd contents
mkdir $INITRD_DIR
sudo bsdtar -xzf $ISOFILES_DIR/$INITRDGZ_RELPATH -C $INITRD_DIR

# Patch init file in init ram disk
cat <<EOF > $WORK_DIR/init
#!/bin/sh
mount -t devtmpfs dev
mount -t proc proc
mount -t sysfs sys
echo "$BOOT_MESSAGE"
exec /bin/sh
EOF
sudo cp $WORK_DIR/init $INITRD_DIR/init

# Pack Initrd contents
mkdir -p $OUTPUT_GRUB_DIR
cd $INITRD_DIR
find . -print0 | cpio --null -ov --format=newc | gzip -9 > $OUTPUT_DIR/$INITRDGZ_RELPATH
cd -

# Pack files into bootable image
cat <<EOF > $OUTPUT_GRUB_DIR/grub.cfg
set default=0
set timeout=10
menuentry 'myos' --class os {
    insmod gzio
    insmod part_msdos
    linux /$KERNEL_RELPATH
    initrd /$INITRDGZ_RELPATH
}
EOF
sudo cp $ISOFILES_DIR/$KERNEL_RELPATH $OUTPUT_DIR/$KERNEL_RELPATH
grub-mkrescue -o $OUTPUT_ISO_PATH $OUTPUT_DIR

# Cleanup
if [ "$CLEANUP" == "1" ]; then sudo rm -rf $WORK_DIR; fi

# Launch
if [ "$LAUNCH" == "1" ]; then qemu-system-x86_64 -m 512 -cdrom $OUTPUT_ISO_PATH -boot d; fi
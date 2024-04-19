#!/bin/sh

# Download tool dependencies
sudo apt-get install qemu-system \
	xorriso \
	mtools \
	libarchive-tools \
	wget

# Download TinyCore Binary
mkdir /tmp/workstation
wget http://tinycorelinux.net/15.x/x86/release/Core-current.iso -O /tmp/workstation/Core-current.iso

# Extract ISO contents
mkdir /tmp/workstation/isofiles
bsdtar -xzpvf /tmp/workstation/Core-current.iso -C /tmp/workstation/isofiles

# Extract Initrd contents
mkdir /tmp/workstation/initrd
sudo bsdtar -xzvpf /tmp/workstation/isofiles/boot/core.gz -C /tmp/workstation/initrd

# Edit init
sudo cp ./init /tmp/workstation/initrd/init

# Pack Initrd contents with `cpio`
mkdir -p /tmp/workstation/iso/boot/grub/
cd /tmp/workstation/initrd/
find . -print0 | cpio --null -ov --format=newc | gzip -9 > /tmp/workstation/iso/boot/initramfs.cpio.gz
cd -

# Create `boot/`, move files and pack into bootable image & grub.cfg
cp grub.cfg /tmp/workstation/iso/boot/grub/
sudo cp /tmp/workstation/isofiles/boot/vmlinuz /tmp/workstation/iso/boot/
grub-mkrescue -o myos.iso /tmp/workstation/iso/

# Cleanup
sudo rm -rf /tmp/workstation

# qemu-system-x86_64 -m 512 -cdrom ./myos.iso -boot d
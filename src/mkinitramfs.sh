#!/bin/sh

BUILD=/tmp/ramfs
OUT=/boot/initrd.img


# create base directory structure
printf "creating directories..."

mkdir -p $BUILD/tmp
cd $BUILD
mkdir -p bin dev etc lib proc run sbin sys usr
mkdir -p lib/firmware lib/modules lib/udev
mkdir -p etc/modprobe.d etc/udev

ln -s lib lib64
ln -s ../bin usr/bin
ln -s ../sbin usr/sbin
printf "OK\n"

# copy binaries
printf "populating /bin..."
for b in dash cat cp dd killall kmod ln ls mkdir \
    mknod mount rm sed sh sleep umount uname \
    basename readlink; do
    cp -a /bin/$b bin/
done

ln -s kmod bin/insmod
ln -s kmod bin/lsmod
printf "OK\n"

# create nodes for udev to mount
printf "creating nodes..."
mknod -m 600 dev/console c 5 1
mknod -m 666 dev/null c 1 3
printf "OK\n"

# Copy udev configuration
printf "configuring udev..."
cp  /etc/udev/udev.conf etc/udev/
cp -r /etc/udev/rules.d   etc/udev/
cp -r /lib/udev/*         lib/udev/
printf "OK\n"

# set module order
touch etc/modprobe.d/modprobe.conf

# copy the init script
printf "installing init script..."
cp /sbin/initramfs-init sbin/init
printf "OK\n"

# copy required libraries
printf "populating /lib..."
for l in libc acl attre blkid cap kmod lzma mount ncursesw readline z curses history terminfo zstd; do
        cp /lib/lib$l.so lib/
done
ln -s libc.so /ld-musl-$(uname -m).so.1
printf "OK\n"

# copy any firmware
printf "installing firmware..."
cp -r /lib/firmware/* lib/firmware/
printf "OK\n"

# copy any modules
printf "installing modules..."
cp  -r /lib/modules/* lib/modules/
printf "OK\n"

# create the initramfs image
printf "creating initramfs image..."
find ./ | cpio -o -H newc | gzip -9 > $OUT
printf "OK\n"

printf "Written initramfs image to $OUT\n"

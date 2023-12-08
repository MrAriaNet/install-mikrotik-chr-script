#!/bin/bash

# Downloading the MikroTik image
wget https://download.mikrotik.com/routeros/7.11.2/chr-7.11.2.img.zip -O chr.img.zip

# Unzipping the image
gunzip -c chr.img.zip > chr.img

# Mounting the image
mount -o loop,offset=33571840 chr.img /mnt

# Determining the primary network interface and gateway
INTERFACE=$(ip route | grep default | awk '{print $5}')
ADDRESS=$(ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | head -n 1)
GATEWAY=$(ip route list | grep default | cut -d' ' -f 3)

# Determining the primary disk device
DISK_DEVICE=$(fdisk -l | grep "^Disk /dev")

# Creating the autorun script with MikroTik commands
cat > /mnt/rw/autorun.scr <<EOF
/ip dns/set servers=8.8.8.8
/ip address add address=$ADDRESS interface=[/interface ethernet find where name=ether1]
/ip route add gateway=$GATEWAY
EOF

# Unmounting the image
umount /mnt

# Triggering kernel to dump its caches
echo u > /proc/sysrq-trigger

# Writing the image to the primary disk device
dd if=chr.img bs=1024 of=$DISK_DEVICE

# Syncing file system
echo s > /proc/sysrq-trigger

# Rebooting
echo b > /proc/sysrq-trigger

#!/bin/bash

# Downloading the MikroTik image
wget https://download.mikrotik.com/routeros/7.6/chr-7.6.img.zip -O chr.img.zip

# Unzipping the image
gunzip -c chr.img.zip > chr.img

# Mounting the image
mount -o loop,offset=33571840 chr.img /mnt

# Determining the primary network interface and gateway
INTERFACE=$(ip route | grep default | awk '{print $5}')
ADDRESS=$(ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | cut -d'/' -f 1 | head -n 1)
GATEWAY=$(ip route list | grep default | cut -d' ' -f 3)
NETWORK=$(ip addr show $INTERFACE | grep global | cut -d' ' -f 6 | cut -d'/' -f 1 | cut -d '.' -f1-3 | head -n 1)

# Determining the primary disk device
DISK=$(lsblk | grep disk | cut -d ' ' -f 1 | head -n 1)

# Creating the autorun script with MikroTik commands
cat > /mnt/rw/autorun.scr <<EOF
/ip dns/set servers=8.8.8.8
:put "dns set"
/ip address add address=$ADDRESS/24 interface=[/interface ethernet find where name=ether1]
:put "address set"
/ip route add gateway=$GATEWAY
:put "1 gate set"
/ip route add gateway=$NETWORK.1
:put "2 gate set 30 sec d"

:delay 30s
/system package update check-for-updates
:put "check done 30 sec d"
:delay 30s
/system package update download
:put "down done 90s d"
:delay 90s
:put "gonna reboot"
/system reboot
EOF


# Unmounting the image
umount /mnt

# Triggering kernel to dump its caches
echo u > /proc/sysrq-trigger

# Writing the image to the primary disk device
dd if=chr.img of=/dev/$DISK bs=4M oflag=sync

# Syncing file system
echo s > /proc/sysrq-trigger

# Rebooting
echo b > /proc/sysrq-trigger

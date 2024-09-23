#!/bin/bash

# Downloading the MikroTik image
wget https://download.mikrotik.com/routeros/7.15/chr-7.15.img.zip -O chr.img.zip

# Unzipping the image
gunzip -c chr.img.zip > chr.img

# Mounting the image
mount -o loop,offset=33571840 chr.img /mnt

# Determining the primary disk device
DISK=$(lsblk | grep disk | cut -d ' ' -f 1 | head -n 1)

# Creating the autorun script with MikroTik commands
# In some cases the first method to find the gateway might not work, so I added a backup one
# You can remove the excess invalid gateway later 
cat > /mnt/rw/autorun.scr <<EOF
:do {:delay 60s} on-error {}
:do {/ip dhcp-client/add add-default-route=yes use-peer-dns=yes use-peer-ntp=yes interface=ether0 dhcp-options=hostname,clientid} on-error {}
:do {/ip dhcp-client/add add-default-route=yes use-peer-dns=yes use-peer-ntp=yes interface=ether1 dhcp-options=hostname,clientid} on-error {}
:do {/ip dhcp-client/add add-default-route=yes use-peer-dns=yes use-peer-ntp=yes interface=ether2 dhcp-options=hostname,clientid} on-error {}
:do {/ip dhcp-client/add add-default-route=yes use-peer-dns=yes use-peer-ntp=yes interface=ether3 dhcp-options=hostname,clientid} on-error {}
:do {/ip dhcp-client/add add-default-route=yes use-peer-dns=yes use-peer-ntp=yes interface=ether4 dhcp-options=hostname,clientid} on-error {}
EOF

# Unmounting the image
umount /mnt

# Triggering kernel to dump its caches
echo u > /proc/sysrq-trigger

# Writing the image to the primary disk device
dd if=chr.img of=/dev/$DISK bs=4M oflag=sync

# Syncing file system
echo s > /proc/sysrq-trigger
sleep 5
echo "Rebooting..."

# Rebooting
echo b > /proc/sysrq-trigger

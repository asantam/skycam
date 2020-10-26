#!/bin/sh

# Check for root
if test "$(id -u)" -ne "0"; then
  printf "%s\n" "Must be run as root" >&2
  exit 1
fi

# Generate new partition for data
printf "n\np\n3\n13115392\n\nw" | fdisk /dev/mmcblk0

# Format new partition
mkfs.ext4 /dev/mmcblk0p3

# Add entry to fstab
>>/etc/fstab printf "%s\n" "/dev/mmcblk0p3 /home/control/data ext4 defaults,noatime,nofail,x-systemd.device-timeout=9 0 2"

# Mount and change ownership
mkdir /home/control/data
mount /dev/mmcblk0p3
chown control:control /home/control/data

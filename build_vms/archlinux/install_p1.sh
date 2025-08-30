#!/usr/bin/bash
timedatectl set-ntp true
pacman -Syy --noconfirm
pacman -Sy --noconfirm vim
sfdisk /dev/sda << EOF
label: dos
label-id: 0xfd3433dc
device: /dev/sda
unit: sectors
sector-size: 512

/dev/sda1 : start=        2048, size=     2097152, type=ef, bootable
/dev/sda2 : start=     2099200, size=    16777216, type=82
/dev/sda3 : start=    18876416, size=    44038144, type=83
EOF
sfdisk -l /dev/sda;
mkfs.ext4 /dev/sda3
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
df -kh
cp install_pkgs.sh /mnt
ls /mnt;

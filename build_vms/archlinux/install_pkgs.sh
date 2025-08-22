timedatectl set-ntp true

pacman -Sy vim
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2
pacstrap /mnt base base-devel linux linux-firmware
genfstab -U /mnt >> /mnt/etc/fstab
arch-choot /mnt
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock -systohc
echo "archlinuxvmNN" > /etc/hostname
sed -i -e 's/#en_US.UTF8/en_US.UTF8/' /etc/locale.gen
local-gen
pacman -S dhcpcd nfs-utils sudo openssh
pacman -S vim emacs
pacman -S cmake doxygen graphviz
pacman -S git gitlab-runner
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable dhcpcd
systemctl enable gitlab-runner
systemctl enable sshd

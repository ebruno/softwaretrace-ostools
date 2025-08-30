#!/usr/bin/bash
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock -systohc
echo "archlinuxvm02" > /etc/hostname
sed -i -e 's/#en_US.UTF8/en_US.UTF8/' /etc/locale.gen
local-gen
pacman -Syy --noconfirm;
pacman -Sy --noconfirm  dhcpcd nfs-utils sudo openssh grub efibootmgr
pacman -Sy --noconfirm vim emacs
pacman -Sy --noconfirm cmake doxygen graphviz pacman
pacman -Sy --noconfirm git gitlab-runner
mkinitcpio -P
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCHLINUX
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable dhcpcd
systemctl enable gitlab-runner
systemctl enable sshd
echo "gitlab-runner ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers.d/admins"
chmod 440 "/etc/sudoers.d/admins"
useradd -m -G wheel -s /bin/bash ebruno;
echo "ebruno ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers.d/admins"
# Set password for root and ebruno.

#!/usr/bin/bash
VALID_OPTS=":heVl";
declare -i exit_status=0;
declare -i efi_build=1;
declare -i install_vmware_tools=1;
declare -i install_libvirt_tools=1;
display_help() {
    echo "setup_phase_1 [-h -e]";
    echo " -h  - display this message.";
    echo " -e  - build for EFI boot.";
    echo " -l  - Install libvirt tools.";
    echo " -V  - Install Vmware tools."
    echo "if -e is not specified BIOS boot will be configured."
    return 0;
}
echo "[INFO] Starting install_pkgs"
while getopts "${VALID_OPTS}" option;
do
    case "${option}" in
    h)
	display_help;
	exit 0;
      ;;
    e)
	efi_build=0;
	echo "[INFO] Building for efi boot";
	;;
    l)
	install_libvirt_tools=0;
	;;
    V)
	install_vmware_tools=0;
	;;
    \?)
	display_help;
	exit 1;
	;;
    :)
	echo "Error: Option -$OPTARG requires an argument.";
	exit 1;
	;;
    esac;
done;
shift $((OPTIND-1))
if [ $# -ge 1 ]; then
    admin_user="${1}";
else
    admin_user="packer";
fi;
if [ $# -eq 2 ]; then
    build_user="${1}";
else
    build_user="builduser";
fi;
tmp_val=$(lsblk | grep -v fd | grep -m 1 disk);
read -a tmp_diskinfo <<< ${tmp_val};
disk_prefix="${tmp_diskinfo[0]}";
echo "[INFO] Using disk_prefix: ${disk_prefix}";
ln -sf /usr/share/zoneinfo/US/Pacific /etc/localtime
hwclock --systohc
sed -i -e 's/#en_US.UTF8/en_US.UTF8/' /etc/locale.gen
local-gen
pacman -Syy --noconfirm;
pacman -Sy --noconfirm  dhcpcd dnsutils nfs-utils sudo openssh grub;
pacman -Sy --noconfirm vim emacs-nox;
if [ ${efi_build} -eq 0 ]; then
    echo "[INFO] Installing efibootmgr";
    pacman -Sy --noconfirm efibootmgr;
fi;
if [ ${install_vmware_tools} -eq 0 ]; then
    echo "[INFO] Installing open-vm-tools";
    pacman -Sy --noconfirm open-vm-tools;
    systemctl enable vmtoolsd;
fi;
if [ ${install_libvirt_tools} -eq 0 ]; then
    echo "[INFO] Installing qemu-guest-agent";
    pacman -Sy --noconfirm qemu-guest-agent;
    systemctl enable qemu-guest-agent;
fi;
systemctl enable dhcpcd;
systemctl enable sshd;
# not working reliable disable for now.
#systemctl enable systemd-networkd.service systemd-networkd-wait-online.service
install /root/update_etc_issue.sh /usr/local/bin;
install -m 664 /root/show_ip_on_login.service /usr/lib/systemd/system;
# not working disable for now.
# systemctl disable show_ip_on_login.service;
rm -f root/update_etc_issue.sh /root/show_ip_on_login.service;
echo "[INFO] Package install completed.";
for userid in ${admin_user} ${build_user}
do
    echo "[INFO] Adding account: ${userid}";
    useradd -m -G wheel -s /bin/bash ${userid};
    echo "${userid} ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers.d/admins";
done;
chmod 440 "/etc/sudoers.d/admins";
echo "[INFO] Set password for root, ${admin_user} ${build_user}.";

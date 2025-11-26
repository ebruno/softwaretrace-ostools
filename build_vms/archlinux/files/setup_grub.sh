#!/usr/bin/env bash
VALID_OPTS=":he";
declare -i exit_status=0;
declare -i efi_build=1;
display_help() {
    echo "setup_phase_1 [-h -e]";
    echo " -h  - display this message";
    echo " -e  - build for EFI boot"
    echo "if -e is not specified BIOS boot will be configured."
    return 0;
}
while getopts "${VALID_OPTS}" option;
do
    case "${option}" in
    h)
	display_help;
	exit 0;
      ;;
    e)
	efi_build=0;
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
    shift $((OPTIND-1));
done;
shift $((OPTIND-1))
if [ -f "/tmp/install_disk_prefix.sh" ]; then
    . "/tmp/install_disk_prefix.sh";
    rm -f "/tmp/install_disk_prefix.sh";
else
    DISK_PREFIX="sda"
fi;
echo "[INFO] Regenerate initramfs";
echo "KEYMAP=us" | sudo tee /etc/vconsole.conf
echo "FONT=Lat2-Terminus16" | sudo tee -a /etc/vconsole.conf
mkinitcpio -P
echo "[INFO] Installing Grub at /dev/${DISK_PREFIX}";
if [ ${efi_build} -eq 0 ]; then
    echo "Configuring for EFI boot.";
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ARCHLINUX
else
    echo "Configure for BIOS boot.";
    grub-install --target=i386-pc /dev/${DISK_PREFIX};
fi;
echo "[INFO] running grub-mkconfig"
grub-mkconfig -o /boot/grub/grub.cfg
echo "[INFO] grub configuration completed.";

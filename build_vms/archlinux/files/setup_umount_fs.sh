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
tmp_val=$(lsblk | grep -v fd | grep -m 1 disk);
read -a tmp_diskinfo <<< ${tmp_val};
disk_prefix="${tmp_diskinfo[0]}";
echo "[INFO] Using disk_prefix: ${disk_prefix}";
if [ ${efi_build} -eq 0 ]; then
    echo "[INFO] Dismounting /mnt and turning off swap partition /dev/${disk_prefix}2";
    umount /mnt/boot;
    umount /mnt;
    swapoff /dev/${disk_prefix}2;
else
    echo "[INFO] Dismounting /mnt and turning off swap partition /dev/${disk_prefix}1";
    umount /mnt
    swapoff /dev/${disk_prefix}1;
fi;

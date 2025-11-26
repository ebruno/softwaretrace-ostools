#!/usr/bin/bash
VALID_OPTS=":he";
declare -i exit_status=0;
declare -i efi_build=0;
display_help() {
    echo "setup_phase_1 [-h -e] [disk prefix]";
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
if [ $# -eq 1 ]; then
    disk_prefix="${1}";
    lsblk | grep -m 1 "disk" | grep -q "${disk_prefix}";
    if [ ! $? -eq 0 ]; then
	echo "[ERROR] specified prefix \"${disk_prefix}\" not found."
	exit 1;
    fi;
else
    tmp_val=$(lsblk | grep -v fd | grep -m 1 disk);
    read -a tmp_diskinfo <<< ${tmp_val};
    disk_prefix="${tmp_diskinfo[0]}"
fi;
echo "[INFO] Using disk prefix \"${disk_prefix}\"" 1>&2;
timedatectl set-ntp true
pacman -Syy --noconfirm
pacman -Sy --noconfirm vim
if [ ${efi_build} -eq 0 ]; then
    echo "Configure for EFI Booting";
sfdisk /dev/${disk_prefix} << EOF
label: dos
label-id: 0xfd3433dc
device: /dev/${disk_prefix}
unit: sectors
sector-size: 512

/dev/${disk_prefix}1 : start=        2048, size=     2097152, type=ef,bootable
/dev/${disk_prefix}2 : start=     2099200, size=    16777216, type=82
/dev/${disk_prefix}3 : start=    18876416, size=    +, type=83
EOF
    sfdisk -l /dev/${disk_prefix};
    mkfs.ext4 /dev/${disk_prefix}3;
    mkfs.fat -F 32 /dev/${disk_prefix}1;
    mkswap /dev/${disk_prefix}2;
    mount /dev/${disk_prefix}3 /mnt;
    mkdir -p /mnt/boot;
    mount /dev/${disk_prefix}1 /mnt/boot;
    swapon /dev/${disk_prefix}2;
    pacstrap /mnt base base-devel linux linux-firmware;
    genfstab -U /mnt >> /mnt/etc/fstab;
else
    echo "Configure for BIOS Booting";
sfdisk /dev/${disk_prefix} << EOF
label: dos
label-id: 0xfd3433dc
device: /dev/${disk_prefix}
unit: sectors
sector-size: 512

/dev/${disk_prefix}1 : start=        2048, size=8388608     , type=82
/dev/${disk_prefix}2 : start=     8390656, size=+           , type=83, bootable
EOF
   sfdisk -l /dev/${disk_prefix};
   mkfs.ext4 /dev/${disk_prefix}2;
   mkswap /dev/${disk_prefix}1 ;
   swapon /dev/${disk_prefix}1;
   mount /dev/${disk_prefix}2 /mnt;
   pacstrap /mnt base base-devel linux linux-firmware;
   genfstab -U /mnt >> /mnt/etc/fstab;
fi;
cp /tmp/install/* /mnt/root;
echo "[INFO] Phase 1 install completed";

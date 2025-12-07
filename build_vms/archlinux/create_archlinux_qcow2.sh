#!/usr/bin/env bash

declare -i exit_status=1;
declare -i options_valid=0;
declare -i dryrun=1;
VALID_OPTS=":hna:H:i:b:";
ISO_MIRROR="https://qnap02.brunoe.net:8175/Archlinux";
#ISO_MIRROR="https://dfw.mirror.rackspace.com/archlinux/iso";
libvirt_image_dir="/var/lib/libvirt/images";
ADMIN_ACCT_NAME="packer";
DEFAULT_PASSWORD="packer";
ISO_BUILD_DATE="$(date +"%Y.%m.01")";
packer_basename="archlinux";
hostname="archlinux03";
hcl_name="${packer_basename}_qcow2.pkr.hcl";
display_help() {
    echo "create_freebsd_qcow2.sh [-h] [-n] [-a <admin account name>] [hcl_filename]" ;
    echo "  -h   - display this message.";
    echo "  -a   - admin user account name.";
    echo "  -b   - build date (YYYY-MM.01).";
    echo "  -H   - hostname.";
    echo "  -i   - libvirt image directory.";
    echo "  -n   - dryrun.";
    echo " hcl_filename to use to generate the image";
    return 0;
}
while getopts "${VALID_OPTS}" option
do
    case ${option} in
	h)
	    display_help;
	    exit 0;
	    ;;
	a)
	    ADMIN_ACCT_NAME="${OPTARG}";
	    ;;
	b)
	    ISO_BUILD_DATE="${ISO_BUILD_DATE}";
	    ;;
	H)
	    hostname="${OPTARG}";
	    ;;
	i) libvirt_image_dir="${OPTARG}";
	   ;;
	n)
	    dryrun=0;
	    ;;
	:)
	    echo "[ERROR] Option -$OPTARG requires an argument." 1>&2;
	    options_valid=1;
	    ;;
	*)
	    echo "[ERROR] Invalid option -$OPTARG." 1>&2;
	    display_help;
	    options_valid=1;
	    ;;
    esac;
done;
shift $((OPTIND - 1))
if [ $# -eq 1 ]; then
    hcl_name="${1}";
elif [ $# -gt 1 ]; then
    echo "[ERROR] $# parameters specified, only 1 allowed." 1>&2;
    exit_status=1;
    options_valid=1;
fi;

if [ ${dryrun} -eq 0 ] && [ ${options_valid} -eq 0 ]; then
       echo "[DRYRUN] will generate the VM with the following settings" 1>&2;
       echo "[DRYRUN] release: archLinux-${ISO_BUILD_DATE}" 1>&2
       echo "[DRYRUN] ADMIN_ACCT_NAME: ${ADMIN_ACCT_NAME}" 1>&2;
fi;
if [ -f /etc/os-release ] && [ ${options_valid} -eq 0 ]; then
   . /etc/os-release
   PACKER_CMD=$(which packer 2> /dev/null);
   if [ -n "${PACKER_CMD}" ]; then
      declare -A efi_info=([debian]="/usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_VARS_4M.fd"
			   [ubuntu]="/usr/share/OVMF/OVMF_CODE_4M.fd /usr/share/OVMF/OVMF_VARS_4M.fd"
			   [fedora]="/usr/share/edk2/ovmf/OVMF_CODE.fd /usr/share/edk2/ovmf/OVMF_VARS.fd"
			   [rhel]="/usr/share/edk2/ovmf/OVMF_CODE.fd /usr/share/edk2/ovmf/OVMF_VARS.fd")
      declare -A qemu_binary=(["rhel,10"]="/usr/libexec/qemu-kvm"
			      ["rhel,9"]="/usr/libexec/qemu-kvm"
			      ["rhel,8"]="/usr/libexec/qemu-kvm")

      # For future use to allow vm creation without using sudo
      # this gets a bit complicated since it varies per host operating system.
      #      declare -A usr_group=([debian]="root root"
      #			    [fedora]="root root"
      #			    [rhel]="root root")

      packer_basename="archlinux";
      pkrvars_name="${packer_basename}.pkrvars.hcl";
      ISO_NAME="archlinux-${ISO_BUILD_DATE}-x86_64.iso";
      if [ ${dryrun} -eq 0 ]; then
	  echo "[DRYRUN] pkvars name: ${pkrvars_name}" 1>&2;
	  echo "[DRYRUN] hcl name   : ${hcl_name}" 1>&2;
      else
	  if [ -f ./assets/id_rsa ]; then
	      rm -f ./assets/id_rsa*;
	  else
	      if [ ! -d ./assets ]; then
		  mkdir assets;
	      fi;
	  fi;
	  ssh-keygen -t rsa -b 4096 -N "" -f assets/id_rsa -C "packer_key_for_build" > /dev/null 2>&1;
	  public_key="$(cat ./assets/id_rsa.pub)";
	  builduser_passwd="$(echo packer | openssl passwd -6 -salt $(openssl rand -base64 16) --stdin)"
	  root_passwd="$(echo packer | openssl passwd -6 -salt $(openssl rand -base64 16)  --stdin)"
      fi;
      # setup pkrvars file for run.
      echo "hostname=\"archlinuxvm03\"" > "${pkrvars_name}";
      echo "vm_name=\"archlinux-${ISO_BUILD_DATE}\"" >> "${pkrvars_name}";
      if [ ${dryrun} -eq 0 ]; then
	  echo "[DRYRUN] hostname: ${hostname}" 1>&2;
	  echo "[DRYRUN] vm_name : ${packer_basename}srv-${ISO_BUILD_DATE}" 1>&2;
	  echo "[DRYRUN] iso_url : ${ISO_MIRROR}/${ISO_NAME}" 1>&2;
      else
	  echo "iso_url=\"${ISO_MIRROR}/${ISO_BUILD_DATE}/${ISO_NAME}\"" >> "${pkrvars_name}";
	  curl -s -O "${ISO_MIRROR}/${ISO_BUILD_DATE}/sha256sums.txt"
	  while read -a line
	  do
	      if [ "${line[1]}" = "${ISO_NAME}" ]; then
		  echo "iso_checksum=\"sha256:${line[0]}\"" >> "${pkrvars_name}";
	      fi;
	  done < "./sha256sums.txt";
      fi;
      declare -a efi_files=(${efi_info[${ID}]});
      if [ ${dryrun} -eq 0 ]; then
	  echo "[DRYRUN] efi_firmware_code: ${efi_files[0]}" 1>&2;
	  echo "[DRYRUN] efi_firmware_vars: ${efi_files[1]}" 1>&2;
      else
	  echo "efi_firmware_code=\"${efi_files[0]}\"" >> "${pkrvars_name}";
	  echo "efi_firmware_vars=\"${efi_files[1]}\"" >> "${pkrvars_name}";
      fi;
      if [ "${ID}" = "rhel" ]; then
	  echo "[INFO] Adjusting settings for ${PRETTY_NAME}." 1>&2;
	  binary_path="${qemu_binary[${ID},${VERSION_ID%%.*}]}";
	  if [ -x "${binary_path}" ]; then
	      if [[ ! "${PATH}" == *"${binary_path}"* ]]; then
		  # need to add to path
		  base_path=$(dirname ${binary_path});
		  export "PATH=${PATH}:${base_path}";
		  echo "[INFO] Path has been updated to ${PATH}" 1>&2;
	      fi;
	      binary_name="$(basename ${binary_path})";
	      echo "[INFO] QEMU binary is now set to: ${binary_name}" 1>&2;
	      echo "qemu_binary=\"${binary_name}\"" >> "${pkrvars_name}";
	      exit_status=0;
	  else
	      echo "[ERROR] unable to locate ${binary_path}, fatal, exiting." 1>&2;
	      exit_status=1;
	  fi;
      else
	  exit_status=0;
      fi;
      if [ ${exit_status} -eq 0 ]; then
	     if [ ${dryrun} -eq 0 ]; then
		 echo "[DRYRUN] packer init ${hcl_name}" 1>&2;
		 echo "[DRYRUN] packer build -force -var \"builduser_passwd=<hidden>\" -var \"root_passwd=<hidden>\" -var \"public_key=<hidden>\" -var \"libvirt_vm_image_dir=${libvirt_image_dir}\" -var-file=\"${pkrvars_name}\"  ${hcl_name};" 1>&2;
	     else
		packer init ${hcl_name};
		rm -r -f output-artifacts;
		packer build -force -var "builduser_passwd=${builduser_passwd}" \
		       -var "root_passwd=${root_passwd}" \
		       -var "public_key=${public_key}" \
		       -var "libvirt_vm_image_dir=${libvirt_image_dir}" \
		       -var-file="${pkrvars_name}"  ${hcl_name};
		exit_status=$?;
		rm -f "${pkrvars_name}";
	     fi;
      fi;
   else
      echo "[ERROR] packer not installed." 1>&2;
   fi;
else
    echo "[ERROR] /etc/os-release missing.";
fi;
exit ${exit_status};

#!/usr/bin/env bash
declare -i exit_status=1;
PACKER_CMD=$(which packer 2> /dev/null);
if [ -n "${PACKER_CMD}" ]; then
   if [ $# -eq 1 ]; then
       ISO_BUILD_DATE="${1}";
   else	  
       ISO_BUILD_DATE="$(date +"%Y.%m.01")";
   fi;
   if [ $# -eq 1 ]; then
       vcenter_vars="${1}";
   else
       vcenter_vars="vcenter.pkvars.hcl"
   fi;
   echo "[INFO] Using ${vcenter_vars} for vSphere/vCenter login access" 2>&1;
   FREEBSD_MAJOR="14"
   FREEBSD_MINOR="3"
   packer_basename="freebsd14srv";
   pkrvars_name="${packer_basename}.pkrvars.hcl";
   hcl_name="${packer_basename}.pkr.hcl";
   FREEBSD_VERSION="${FREEBSD_MAJOR}.${FREEBSD_MINOR}"
   ISO_MIRROR="https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/${FREEBSD_VERSION}";
   ISO_NAME="FreeBSD-14.3-RELEASE-amd64-dvd1.iso";
   if [ -f ./assets/id_rsa ]; then
       rm -f ./assets/id_rsa*;
   else
       if [ ! -d ./assets ]; then
	   mkdir assets;
       fi;
   fi;
   ssh-keygen -t rsa -b 4096 -N "" -f assets/id_rsa -C "packer_key_for_build" > /dev/null 2>&1;
   public_key="$(cat ./assets/id_rsa.pub)";
   ssh_passwd="$(echo packer | openssl passwd -6 -salt $(openssl rand -base64 16) --stdin)"
   root_passwd="$(echo packer | openssl passwd -6 -salt $(openssl rand -base64 16)  --stdin)"
   # setup pkrvars file for run.
   echo "hostname=\"freebsd${FREEBSD_MAJOR}${FREEBSD_MINOR}vm03\"" > "${pkrvars_name}";
   echo "root_password_enc=\"${root_passwd}\"" >> "${pkrvars_name}";
   echo "ssh_password_enc=\"${ssh_passwd}\"" >> "${pkrvars_name}";
   echo "iso_url=\"${ISO_MIRROR}/${ISO_NAME}\"" >> "${pkrvars_name}";
   curl -s -O "${ISO_MIRROR}/CHECKSUM.SHA256-FreeBSD-${FREEBSD_VERSION}-RELEASE-amd64";
   while read -a line
   do
       if [ "${line[1]}" = "(${ISO_NAME})" ]; then
	   echo "iso_checksum=\"sha256:${line[3]}\"" >> "${pkrvars_name}";
       fi;
   done < "./CHECKSUM.SHA256-FreeBSD-${FREEBSD_VERSION}-RELEASE-amd64";
   packer init freebsd14srv_vsphere.pkr.hcl;
   rm -r -f output-artifacts;
   packer build -force  -var "public_key=${public_key}" -var-file="${pkrvars_name}" -var-file="${vcenter_vars}" freebsd14srv_vsphere.pkr.hcl;
   exit_status=$?;
   rm -f "${pkrvars_name}";
   exit_status=0;
else
   echo "[ERROR] packer not installed." 1>&2;
fi;
exit ${exit_status};

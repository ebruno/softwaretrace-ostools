packer {
  required_version = ">= 1.14.0"
  required_plugins {
    qemu = {
      version = "~> 1.1.4"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

source "qemu" "freebsd" {
  iso_url           = "${var.iso_url}"
  iso_checksum      = "${var.iso_checksum}"
  vm_name           = "${var.vm_name}.qcow2"
  disk_size         = "400G"
  format            = "qcow2" # Specify qcow2 as the desired disk format
# enable the efi menu to allow getting in to the efi boot manager for debugging"
#  qemuargs          = [["-boot","menu=on,splash-time=60", ]]
  accelerator       = "kvm"
  headless          = "false"
  memory            = 2048
  net_device        = "virtio-net"
  disk_interface    = "virtio"
  net_bridge        = "bridge0"
  boot_wait         = "20s"
  vtpm              = false
  machine_type      = "q35"
  use_pflash        = true
  efi_boot          = true
  efi_firmware_code = "${var.efi_firmware_code}"
  efi_firmware_vars = "${var.efi_firmware_vars}"
  efi_drop_efivars  = false
  shutdown_command   = "doas shutdown -p now"
  boot_key_interval = "10ms" # Depending on the environment this value may need to be increased.
  boot_command = [
    "<wait5>S",
    "<wait>export PARITIONS=DEFAULT<enter>",
    "export DISTRIBUTIONS=\"base.txz kernel.txz kernel-dbg.txz ports.txz lib32.txz\"<enter>",
    "export ROOTPASS_ENC='${var.root_password_enc}'<enter>",
    "export ADMINPASS_ENC='${var.adminuser_password_enc}'<enter>",
    "export BSDINSTALL_CHROOT=/mnt<enter>",
    "export BSDINSTALL_TMPETC=/tmp/bsdinstall_etc<enter>",
    "export BSDINSTALL_TMPBOOT=/tmp/bsdinstall_boot<enter>",
    "export BSDINSTALL_LOG=/tmp/bsdinstall_log<enter>",
    "export BSDINSTALL_SKIP_KEYMAP=\"true\"<enter>",
    "export BSDINSTALL_SKIP_HARDENING=\"true\"<enter>",
    "export BSDINSTALL_SKIP_HOSTNAME=\"true\"<enter>",
    "export BSDINSTALL_SKIP_FIRMWARE=\"true\"<enter>",
    "export BSDINSTALL_SKIP_TIME=\"true\"<enter>",
    "export BSDINSTALL_SKIP_USERS=\"true\"<enter>",
    #    "<wait2>env<enter><wait30>",
    "bsdinstall scriptedpart vtbd0<enter>",
    "<wait15s>bsdinstall mount<enter>",
    "<wait5>bsdinstall entropy<enter>",
    "<wait5>bsdinstall distextract<enter>",
    "<wait60>bsdinstall netconfig<enter>",
    "<wait2><enter><wait2><enter><wait2><enter><right><wait2><enter><wait2><enter>",
    "<wait5>bsdinstall rootpass<enter>",
    "<wait5>bsdinstall bootconfig<enter>",
    "<wait5>bsdinstall config<enter>",
    "<wait2>chroot /mnt tzsetup America/Los_Angeles<enter>",
    "<wait2>chroot /mnt sysrc sshd_enable=YES<enter>",
    "<wait2>chroot /mnt sysrc keymap=\"us.kbd\"<enter>",
    "<wait2>chroot /mnt sysrc hostname=\"${var.hostname}\"<enter>",
    "<wait2>chroot /mnt sysrc ntpd_enable=YES<enter>",
    "<wait2>chroot /mnt sysrc ntpd_sync_on_start=YES<enter>",
    "<wait2>chroot /mnt pw adduser -c \"Admin User\" -m -n ${var.adminuser} -G wheel -s tcsh<enter>",
    "<wait2>echo \"#!/bin/sh\" > /tmp/addpasswd.sh<enter>",
    "<wait2>echo \"printf '%s\\n' \"\\$ADMINPASS_ENC\" | pw -R \\$BSDINSTALL_CHROOT usermod ${var.adminuser} -H0;\" >> /tmp/addpasswd.sh<enter>",
    "<wait2>chmod a+x /tmp/addpasswd.sh<enter>",
    "<wait2>/tmp/addpasswd.sh<enter>",
    "<wait2>rm -f /tmp/addpasswd.sh<enter>",
    "<wait2>chroot /mnt mkdir -p /home/${var.adminuser}/.ssh<enter>",
    "<wait2>echo '${var.public_key}' > /mnt/home/${var.adminuser}/.ssh/authorized_keys<enter>",
    "<wait2>chroot /mnt chmod 600 /home/${var.adminuser}/.ssh/authorized_keys<enter>",
    "<wait2>chroot /mnt chmod 700 /home/${var.adminuser}/.ssh<enter>",
    "<wait2>chroot /mnt chown -R ${var.adminuser}:${var.adminuser} /home/${var.adminuser}/.ssh<enter>",
    "<wait2>export INTERFACE=`ifconfig -l ether`<enter>",
    "<wait>chroot /mnt dhclient $INTERFACE<enter>",
    "<wait>mkdir -p /mnt/tmp/install/nfssettings<enter>",
    "<wait>chmod -R 777 /mnt/tmp/install<enter>",
    # Install doas set to all no password access for the adminuser account.
    "<wait5>chroot /mnt pkg install -y doas<enter>",
    "<wait30>echo  \"permit nopass :wheel as root\" > /mnt/usr/local/etc/doas.conf<enter>",
    "<wait2>echo  \"permit nopass ${var.adminuser} as root\" >> /mnt/usr/local/etc/doas.conf<enter>",
    "<wait>export BOOT_NUM=`efibootmgr | grep 'Misc Device' | sed -e 's/\\*.$$//g' | sed -e 's/ Boot//g'`<enter>",
    "<wait>chroot /mnt efibootmgr -a -b $BOOT_NUM<enter>",
    "<wait>chroot /mnt efibootmgr -n -b $BOOT_NUM<enter>",
    "<wait>chroot /mnt efibootmgr -v<enter>",
    "<wait3>sync<enter>",
    "<wait3>sync<enter>",
    "<wait>umount /mnt/boot/efi<enter>",
    "<wait3>umount /mnt/dist/packages<enter>",
    "<wait3>reboot<enter>",
  ]
  output_directory     = local.output_directory
  qemu_binary          = "${var.qemu_binary}"
  ssh_username         = "${var.ssh_user}"
  ssh_password         = "${var.adminuser_password}"
  ssh_private_key_file = "./assets/id_rsa"
  ssh_timeout          = "20m"
}

# File destinations for uploads are
# created in boot_command section.
build {
  name    = "runner-vm"
  sources = ["source.qemu.freebsd"]
  provisioner "file" {
    sources     = ["files/required_pkgs.sh",
		   "gitlab_runner",
		   "gitlabrunner.csh",
		   "pkg_install.csh",
		   "register_gitlab_runner.csh",
		   ]
    destination = "/tmp/install/"
  }
  provisioner "shell" {
    execute_command = "/bin/sh \"{{ .Path }}\""
    inline = [
      "echo \"[INFO] Starting Configuration.\"",
    ]
  }
  provisioner "file" {
    sources     = ["./nfssettings/auto_master",
		   "./nfssettings/autofs.d",
		   "./nfssettings/rc_conf_setup.csh",
		   "./nfssettings/setupautomounts.csh",
		  ]
    destination = "/tmp/install/nfssettings/"
  }
  provisioner "shell" {
    execute_command = "/bin/sh \"{{ .Path }}\""
    inline = [
      "doas pkg update",
      "doas pkg upgrade -y",
      "ls -lR /tmp/install",
      "doas /tmp/install/required_pkgs.sh",
      "doas /tmp/install/pkg_install.csh",
      "doas /tmp/install/nfssettings/setupautomounts.csh",
      "doas /tmp/install/nfssettings/rc_conf_setup.csh",
      "doas /tmp/install/gitlabrunner.csh ${var.adminuser}",
      "doas mkdir -p /usr/share/doc/gitlab-runner",
      "doas cp /tmp/install/register_gitlab_runner.csh /usr/share/doc/gitlab-runner",
      "doas rm -r -f /tmp/install",
    ]
  }

 post-processor "shell-local" {
    inline = [
      <<EOT
 #!/usr/bin/env bash
 cat << EOF > ./create_${var.vm_name}_vm.sh
# Sample commands to create the virtual machine xml file.
#!/usr/bin/env bash
echo "[INFO] Copying ${var.vm_name}.qcow2 to ${var.libvirt_vm_image_dir}";
sudo cp  ./${local.output_directory}/${var.vm_name}.qcow2 ${var.libvirt_vm_image_dir}/${var.vm_name}.qcow2;
sudo chown ${var.libvirt_owner}:${var.libvirt_group} ${var.libvirt_vm_image_dir}/${var.vm_name}.qcow2;
sudo chmod 664 ${var.libvirt_vm_image_dir}/${var.vm_name}.qcow2;
echo "[INFO] Copying efivars.fd to ${var.libvirt_nvram_dir}/${var.vm_name}_VARS.fd";
sudo cp ./${local.output_directory}/efivars.fd ${var.libvirt_nvram_dir}/${var.vm_name}_VARS.fd;
sudo chown ${var.nvram_owner}:${var.nvram_group} ${var.libvirt_nvram_dir}/${var.vm_name}_VARS.fd;
sudo chmod 664 ${var.libvirt_nvram_dir}/${var.vm_name}_VARS.fd;
sudo virt-install \
--name freebsd_gitlabrunner \
--memory 4086 \
--vcpus 4 \
--disk path=${var.libvirt_vm_image_dir}/${var.vm_name}.qcow2,format=qcow2 \
--disk device=cdrom,bus=sata \
--import \
--network bridge=bridge0 \
--os-variant freebsd14.2 \
--graphics vnc,listen=0.0.0.0 \
--boot uefi,loader=${var.efi_firmware_code},nvram=${var.libvirt_nvram_dir}/${var.vm_name}_VARS.fd \
--print-xml > ./${var.vm_name}.xml;
sudo virsh define ./${var.vm_name}.xml;
EOF
EOT
    ]
  }
  post-processor "shell-local" {
    inline = [
      "chmod a+x ./create_${var.vm_name}_vm.sh",
      "cat ./create_${var.vm_name}_vm.sh",
    ]
  }
  post-processor "checksum" {
    checksum_types = ["sha1", "sha256"]
    output         = "packer_{{.BuildName}}_{{.ChecksumType}}.txt"
  }

  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}

locals {
  output_directory = "output-artifacts/${var.vm_name}"
}

variable "adminuser" {
  type        = string
  default     = "packer"
  description = "Admin User acccount to set set the VM."
}

variable "adminuser_password" {
  type        = string
  default     = "packer"
  description = "Password to set in the VM for adminuser."
}

variable "adminuser_password_enc" {
  type        = string
  default     = "$1$packer$zBicTzVGZp3.RqEuQUnd1/"
  description = "Encrypted password to set in the VM for adminuser."
}

variable "efi_firmware_code" {
  type        = string
  default     = "/usr/share/OVMF/OVMF_CODE_4M.fd"
  description = "The location and name of this may vary accross operating systems."
}

variable "efi_firmware_vars" {
  type        = string
  default     = "/usr/share/OVMF/OVMF_VARS_4M.fd"
  description = "The location and name of this may vary accross operating systems."
}

variable "hostname" {
  type        = string
  default     = "freebsdvmNN"
  description = "Hostname"
}

variable "install_ssh_key" {
  type        = string
  default     = "root packer"
  description = "Indicates if the systems unique ssh should be installed for the default following users"
}

# Replace with the actual checksum for the specific iso.
variable "iso_checksum" {
  type = string
  #  default  = "sha256:3e285faab79b139a8f75dfdc2650e6a79e68fdbe0aa82645828de8f3cf584da1" # Replace with the actual checksum
  description = "Check sum for iso file"
}

# To use a local file use the relative or absolute path to iso.
variable "iso_url" {
  type = string
  # default = "https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.3/FreeBSD-14.3-RELEASE-amd64-dvd1.iso"
  description = "URL for iso file"
}

variable "libvirt_nvram_dir" {
  type        = string
  default     = "/var/lib/libvirt/qemu/nvram"
  description = "Location for virtural machine nvram files in your environment"
}

variable "libvirt_vm_image_dir" {
  type        = string
  default     = "/var/lib/libvirt/images"
  description = "Location for virtural machine images in your environment"
}

variable "libvirt_owner" {
      type = string
      default = "root"
      description = "Name of the owner of the images directory"
}

variable "libvirt_group" {
      type = string
      default = "libvirt"
      description = "Name of the group of the images directory"
}

variable "nvram_owner" {
      type = string
      default = "root"
      description = "Name of the owner of the nvram images directory"
}

variable "nvram_group" {
      type = string
      default = "libvirt"
      description = "Name of the group of the nvram images directory"
}

variable "public_key" {
  type        = string
  description = "Public ssh key for installation"
}

variable "root_passwd" {
  type        = string
  default     = "packer"
  description = "Password for root default is packer"
}
variable "root_password_enc" {
  type        = string
  default     = "$1$packer$zBicTzVGZp3.RqEuQUnd1/"
  description = "Root password to set in the VM."
}

variable "ssh_password" {
  type        = string
  default     = "packer"
  description = "ssh password to set in the VM."
}

variable "ssh_password_enc" {
  type        = string
  default     = "$1$packer$zBicTzVGZp3.RqEuQUnd1/"
  description = "ssh password to set in the VM."
}

variable "ssh_private_key_file" {
  type        = string
  default     = "./assets/id_rsa"
  description = "Private key for to allow login via ssh"
}

variable "ssh_user" {
  type        = string
  default     = "packer"
  description = "ssh user to set in the VM."
}


variable qemu_binary {
# For RHEL 8, 9 and 10 this needs to set to qemu-kvm
# The should also check Roecky Linux 8 and 9
# The binary is loccated in /usr/libexec
# The packer default is qemu-system-x86_64.
  type = string
  default = "qemu-system-x86_64"
  description = "The name of the Qemu binary to look for. This defaults to qemu-system-x86_64, but may need to be changed for some platforms. For example qemu-kvm on RHEL 8, 9 and 10."
}

variable "vm_name" {
  type        = string
  default     = "freebsd-143-gitlabrunner"
  description = "Name of qcow2 image file to be exported."
}

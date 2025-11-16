packer {
  required_version = ">= 1.14.0"
  required_plugins {
    vsphere-iso = {
      version = "~> 1.2.7"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vsphere-iso" "freebsd" {
  iso_url           = "https://download.freebsd.org/releases/amd64/amd64/ISO-IMAGES/14.3/FreeBSD-14.3-RELEASE-amd64-dvd1.iso"
  iso_checksum      = "sha256:3e285faab79b139a8f75dfdc2650e6a79e68fdbe0aa82645828de8f3cf584da1"
  http_directory    = ""
  ssh_username      = "${var.ssh_user}"
  ssh_password      = "${var.ssh_password}"
  ssh_private_key_file = "${var.ssh_private_key_file}"
  ip_wait_timeout   = "10m"
  ip_settle_timeout = "30s"
  vcenter_server    = "${var.vcenter_server}"
  host              = "${var.esxi_server}"
  username          = "${var.remote_username}"
  password          = "${var.remote_password}"
  datacenter        = "${var.datacenter}"
  datastore         = "${var.vcenter_datastore}"
  # Any firewalls must allow this port range.
  http_port_min       = 8100
  http_port_max       = 8400
  shutdown_command    = "doas shutdown -p now"
  insecure_connection = true # This may need to set to true if using autogenrated certs.
  storage {
    disk_size             = 400000
    disk_thin_provisioned = true
  }
  vm_name    = "${var.vm_name}"
  vm_version = 20
  CPUs       = 4
  RAM        = 4096
  # freebsd14_64Guest          FreeBSD 14 or later versions (64-bit)
  # freebsd14Guest             FreeBSD 14 or later versions (32-bit)
  guest_os_type       = "freebsd14_64Guest"
  convert_to_template = var.convert_to_template
  export {
    force            = true
    output_directory = "./output-artifacts"
    image_files      = true
  }
  # If more than one network adapter is defined
  # The network configuration section will need to be modified
  # bsdinstall netconfig and the dhcpclient areas will need changes.
  network_adapters {
    network      = "VM Network"
    network_card = "vmxnet3"
  }
  boot_keygroup_interval = "40ms" # default is 100ms.
  boot_wait = "35s" # This may need to be adjusted based on the environment.
  # The bsdinstall sections are called manual, make sure the
  # default BSDINSTALL are set. See the bsdinstall man page for more information.
  boot_command = [
    "<wait>S",
    "<wait>export PARITIONS=DEFAULT<enter>",
    "export DISTRIBUTIONS=\"base.txz kernel.txz kernel-dbg.txz ports.txz lib32.txz\"<enter>",
    "export ROOTPASS_ENC='${var.root_password_enc}'<enter>",
    "export SSHPASS_ENC='${var.ssh_password_enc}'<enter>",
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
    "bsdinstall scriptedpart da0<enter>",
    "<wait10>bsdinstall mount<enter>",
    "<wait5>bsdinstall entropy<enter>",
    "<wait5>bsdinstall distextract<enter>",
    "<wait60>bsdinstall netconfig<enter>",
    "<wait2><enter><wait2><enter><wait2><enter><right><wait2><enter><wait2><enter>",
    "<wait5>bsdinstall rootpass<enter>",
    "<wait5>bsdinstall config<enter>",
    "<wait2>chroot /mnt tzsetup America/Los_Angeles<enter>",
    "<wait2>chroot /mnt sysrc sshd_enable=YES<enter>",
    "<wait2>chroot /mnt sysrc keymap=\"us.kbd\"<enter>",
    "<wait2>chroot /mnt sysrc hostname=\"${var.hostname}\"<enter>",
    "<wait2>chroot /mnt sysrc ntpd_enable=YES<enter>",
    "<wait2>chroot /mnt sysrc ntpd_sync_on_start=YES<enter>",
    "<wait2>chroot /mnt pw adduser -c \"Packer Installer\" -m -n ${var.ssh_user} -G wheel -s tcsh<enter>",
    "<wait2>chroot /mnt pw adduser -c \"Admin User\" -m -n ${var.adminuser} -G wheel -s tcsh<enter>",
    "<wait2>echo \"#!/bin/sh\" > /tmp/addpasswd.sh<enter>",
    "<wait2>echo \"printf '%s\\n' \"\\$SSHPASS_ENC\" | pw -R \\$BSDINSTALL_CHROOT usermod ${var.ssh_user} -H0;\" >> /tmp/addpasswd.sh<enter>",
    "<wait2>echo \"printf '%s\\n' \"\\$ADMINPASS_ENC\" | pw -R \\$BSDINSTALL_CHROOT usermod ${var.adminuser} -H0;\" >> /tmp/addpasswd.sh<enter>",
    "<wait2>chmod a+x /tmp/addpasswd.sh<enter>",
    "<wait2>/tmp/addpasswd.sh<enter>",
    "<wait2>rm -f /tmp/addpasswd.sh<enter>",
    "<wait2>chroot /mnt mkdir -p /home/packer/.ssh<enter>",
    "<wait2>echo '${var.public_key}' > /mnt/home/packer/.ssh/authorized_keys<enter>",
    "<wait2>chroot /mnt chmod 600 /home/packer/.ssh/authorized_keys<enter>",
    "<wait2>chroot /mnt chmod 700 /home/packer/.ssh<enter>",
    "<wait2>chroot /mnt chown -R ${var.ssh_user}:${var.ssh_user} /home/packer/.ssh<enter>",
    "<wait2>export INTERFACE=`ifconfig -l ether`<enter>",
    "<wait>chroot /mnt dhclient $INTERFACE<enter>",
    "<wait>mkdir -p /mnt/tmp/install/nfssettings<enter>",
    "<wait>chmod -R 777 /mnt/tmp/install<enter>",
    # The system is headless, so install the no X11 version of open-vm-tools.
    # set doas to all no password access for the ssh_user and adminuser accounts.
    # open-vmware-tools is need by packer to find the VM's IP after reboot.
    "<wait5>chroot /mnt pkg install -y open-vm-tools-nox11 doas<enter>",
    "<wait60>echo  \"permit nopass :wheel as root\" > /mnt/usr/local/etc/doas.conf<enter>",
    "<wait2>echo  \"permit nopass ${var.ssh_user} as root\" >> /mnt/usr/local/etc/doas.conf<enter>",
    "<wait2>echo  \"permit nopass ${var.adminuser} as root\" >> /mnt/usr/local/etc/doas.conf<enter>",
    "<wait2>umount /packages<enter>",
    "<wait>reboot<enter>",
  ]
}

build {
  sources = ["source.vsphere-iso.freebsd"]
  provisioner "file" {
    sources     = ["files/freebsd/required_pkgs.sh",
    		   "gitlab_runner",
		   "gitlabrunner.csh",
		   "pkg_install.csh",
		   "register_gitlab_runner.csh",
		   ]
    destination = "/tmp/install/"
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
      "doas /tmp/install/gitlabrunner.csh ${var.adminuser} ${var.ssh_user}",
      "doas mkdir -p /usr/share/doc/gitlab-runner",
      "doas cp /tmp/install/register_gitlab_runner.csh /usr/share/doc/gitlab-runner", 
      "doas rm -r -f /tmp/install",
    ]
  }
  post-processor "shell-local" {
    inline = [
      "ovftool \"${var.output_directory}/${var.vm_name}.ovf\" \"${var.output_directory}/${local.artifact_name}\"",
    ]
  }
}

locals {
  artifact_name = "${var.vm_name}-${local.current_time}.ova"
  current_time  = formatdate("YYYYMMDDhhmmss", timestamp())
}
variable "adminuser" {
  type        = string
  default     = "builduser"
  description = "Admin User acccount to set in the VM."
}
variable "adminuser_password" {
  type        = string
  default     = "runneradmin!"
  description = "Password to set in the VM for adminuser."
}
# Use the command:
# openssl passwd -6 -salt xxxxxxxx password
# $6$xxxxxxxx$wqnb6MLqmjMU5Hx4wQ0qsgf/VWMnStSJlbRMy5buT2fPUnVASxaE4zm2JBuj6ISxoGFOWhZODdzl2VyW/Ltzz.
# To generate an encypted password.
# The use the entire genrated string.
# The salt may be anything you wish, it will be
# included in the generated string.

variable "adminuser_password_enc" {
  type        = string
  default     = "$6$runneradmin$E2iAhtd8xUlMp9EefX/XHsD2of7DwFojOxVQakmROdyRTNdoiOqpqGyBzh7O00L4nWnzGEwxaEwFh9s.7RHZu."
  description = "Encrypted password to set in the VM for adminuser."
}

variable "convert_to_template" {
  type        = bool
  default     = true
  description = "Convert the virtual machine to a template after the build is complete. If set to true, the virtual machine can not be imported into a content library."
}

variable "datacenter" {
  type        = string
  description = "Remote esxi server."
}

variable "esxi_server" {
  type        = string
  description = "esxi server."
}

variable "hostname" {
  type        = string
  description = "Hostname to use for the system."
}

variable "output_directory" {
  type        = string
  default     = "./output-artifacts"
  description = "Output directory for VM artifacts"
}

variable "public_key" {
  type        = string
  description = "Public key for ssh login."
}

variable "remote_password" {
  type        = string
  description = "User password for login."
}

variable "remote_username" {
  type        = string
  description = "User name for login."
}

variable "root_password_enc" {
  type        = string
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

variable "vcenter_datastore" {
  type        = string
  default     = "datastore1"
  description = "Datastore to create the VM."
}

variable "vcenter_server" {
  type        = string
  description = "vCenter server."
}

variable "vm_name" {
  type        = string
  default     = "FreeBSD143_Runner"
  description = "Virtual Machine name to build"
}

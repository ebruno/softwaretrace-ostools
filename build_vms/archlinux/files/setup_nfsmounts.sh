#!/usr/bin/env bash

if [ ! -d "/mnt/qnap02/Web" ]; then
   mkdir -p /mnt/qnap02/Web;
fi;
echo "# Qnap02 Web directory" >> /etc/fstab;
echo '10.10.41.158:/Web /mnt/qnap02/Web nfs defaults,noauto,x-systemd.automount,x-systemd.idle-timeout=5min 0 0' >> /etc/fstab;
systemctl enable remote-fs.target;
systemctl restart remote-fs.target;
echo "[INFO] NFS automounts have been configured using systemd";
cat /etc/fstab;


#!/usr/bin/env tcsh
if ( $# > 0) then
  set userlist = ($argv:q "gitlab-runner")
else
  set userlist = ("gitlab-runner")
endif
pkg install -y doas cmake bash git git-lfs git-who go doxygen graphviz hs-pandoc hs-pandoc-crossref mscgen python3
sleep 20
if ( -e /usr/local/etc/doas.conf ) then
  foreach username ($userlist)
    echo "[INFO] Checking if $username is in doas.conf"
    grep -q $username:q /usr/local/etc/doas.conf
    if ( $status == 1 ) then
        echo "[INFO] Adding $username as root to doas.conf"
	echo "permit nopass $username as root" >> /usr/local/etc/doas.conf
    endif
  end
else
  foreach username ($userlist)
    echo "[INFO] Adding $username as root to doas.conf"
    echo "permit nopass $username as root" >> /usr/local/etc/doas.conf
  end
endif
set userlist = ("root" $argv:q)
foreach username ($userlist)
    echo "[INFO] Adding $username as gitlab-runner to doas.conf"
    echo "permit nopass $username as gitlab-runner" >> /usr/local/etc/doas.conf
end
echo "[INFO] doas.conf"
cat /usr/local/etc/doas.conf
set fullpath=`realpath $0`
set basedir="$fullpath:h"
pw group add -n gitlab-runner
pw user add -n gitlab-runner -g gitlab-runner -s /usr/local/bin/bash
mkdir /home/gitlab-runner
chown gitlab-runner:gitlab-runner /home/gitlab-runner
# For amd64
fetch -o /usr/local/bin/gitlab-runner https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-freebsd-amd64
chmod a+rx /usr/local/bin/gitlab-runner
touch /var/log/gitlab_runner.log && chown gitlab-runner:gitlab-runner /var/log/gitlab_runner.log
cp ${basedir}/gitlab_runner /usr/local/etc/rc.d/gitlab_runner
chmod a+rx /usr/local/etc/rc.d/gitlab_runner
sysrc gitlab_runner_enable=YES
service gitlab_runner start
echo "[INFO] Use the script /usr/share/doc/gitlab-runner/register_runner.csh"
echo "[INFO] to register the runner with the gitlab instance."

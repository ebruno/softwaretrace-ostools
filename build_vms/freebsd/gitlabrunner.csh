#!/bin/tcsh
pkg install -y doas cmake bash git git-lfs git-who go doxygen graphviz hs-pandoc hs-pandoc-crossref mscgen python3
if ( -e /usr/local/etc/doas.conf ) then
  foreach username (ebruno gitlab-runner)
    grep -q $username /usr/local/etc/doas.conf
    if ( $status == 1) then
	echo "permit nopass $username as root" >> /usr/local/etc/doas.conf
    endif
  end
else
  foreach username (ebruno gitlab-runner)
    echo "permit nopass $username as root" >> /usr/local/etc/doas.conf
  end
endif
pw group add -n gitlab-runner
pw user add -n gitlab-runner -g gitlab-runner -s /usr/local/bin/bash
mkdir /home/gitlab-runner
chown gitlab-runner:gitlab-runner /home/gitlab-runner
# For amd64
fetch -o /usr/local/bin/gitlab-runner https://s3.dualstack.us-east-1.amazonaws.com/gitlab-runner-downloads/latest/binaries/gitlab-runner-freebsd-amd64
chmod a+rx /usr/local/bin/gitlab-runner
touch /var/log/gitlab_runner.log && chown gitlab-runner:gitlab-runner /var/log/gitlab_runner.log
cp gitlab_runner /usr/local/etc/rc.d/gitlab_runner
chmod a+rx /usr/local/etc/rc.d/gitlab_runner
sysrc gitlab_runner_enable=YES
service gitlab_runner start

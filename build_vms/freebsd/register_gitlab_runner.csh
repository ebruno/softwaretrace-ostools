#!/usr/bin/env tcsh
if ( $# == 2 ) then
  if ( "$2"  != "" ) then
     echo "[INFO] Registering the runner as gitlab-runner user".
     doas -u gitlab-runner /usr/local/bin/gitlab-runner register --url "$1" --token "$2"
     echo "[INFO] Check if the config.toml file is in the correct location /home/gitlab-runner/.gitlab-runner/config.toml"
     if ( ! -e "/home/gitlab-runner/.gitlab-runner/config.toml" ) then
	if ( -f "/etc/gitlab-runner/config.toml" ) then
	  doas cp "/etc/gitlab-runner/config.toml" "/home/gitlab-runner/.gitlab-runner"
	endif
     endif
     echo doas chown -R gitlab-runner:gitlab-runner "/home/gitlab-runner/.gitlab-runner"
     echo "[INFO] Check /var/log/gitlab_runner.log."
  else
     echo "[WARNING] Gitlab token is empty, skipping registration."
     echo "[WARNING| Runner registration not attempted."
  endif
else
  echo "[ERROR] Gitlab token not supplied as parameter 2."
  echo "[WARNING| Runner registration not attempted."
endif

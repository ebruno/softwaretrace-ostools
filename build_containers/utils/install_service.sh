#!/usr/bin/env bash
#DRYRUN="echo [DRYRUN]"
SERVICE_INSTALL_DIR="/usr/lib/systemd/system";
PRESET_INSTALL_DIR="/usr/lib/systemd/system-preset";
BIN_INSTALL_DIR="/usr/bin"

SERVICES="swtr_containers_prune.service swtr_containers_prune.timer";
PRESETS="95_swtr_containers_prune.preset";
BIN_APPS="swtr_clear_container_cache.sh"
declare -A install_items=([${PRESET_INSTALL_DIR}]="${PRESETS}"
			  [${SERVICE_INSTALL_DIR}]="${SERVICES}");
declare -A install_bin=([${BIN_INSTALL_DIR}]=${BIN_APPS});
declare -i exit_status=0;
if [  ${EUID} -eq 0 ]; then
    if [ -f /etc/os-release ]; then
	. /etc/os-release;
    fi;
    # The service must define the correct required service of podman.service or docker.service.
    if [ -x /usr/bin/podman ]; then
	echo "[INFO] Detected podman configuring containers_prune service for podman." 1>&2;
	cp --preserve=mode,timestamps swtr_containers_prune.service_podman swtr_containers_prune.service;
    elif [ -x /usr/bin/docker ]; then
	echo "[INFO] Detected docker configuring containers_prune service for docker." 1>&2;
	cp --preserve=mode,timestamps swtr_containers_prune.service_docker swtr_containers_prune.service;
    else
	echo "[ERROR] Neither docker or podman detected, skipping installation." 1>&2;
	exit_status=1;
    fi;
    if [ ${exit_status} -eq 0 ]; then
	for dest in ${!install_items[@]}
	do
	    for item in ${install_items[${dest}]};
	    do
		${DRYRUN} install -m 664 ${item} ${dest};
	    done;
	done;
	for dest in ${!install_bin[@]}
	do
	    for item in ${install_bin[${dest}]};
	    do
		${DRYRUN} install ${item} ${dest};
	    done;
	done;
	rm -f swtr_containers_prune.service;
	systemctl daemon-reload;
	systemctl enable swtr_containers_prune.timer;
	systemctl start swtr_containers_prune.timer;
	systemctl status swtr_containers_prune.timer;
	systemctl status swtr_containers_prune.service;
    fi;
else
    echo "[ERROR] Script must be run as root or with sudo." 1>&2;
    exit_status=1;
fi;
exit ${exit_status};

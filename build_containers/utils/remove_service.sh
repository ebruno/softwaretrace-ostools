#!/usr/bin/env bash
#DRYRUN="echo [DRYRUN]"
SERVICE_REMOVE_DIR="/usr/lib/systemd/system";
PRESET_REMOVE_DIR="/usr/lib/systemd/system-preset";
BIN_REMOVE_DIR="/usr/bin"

SERVICES="swtr_containers_prune.service swtr_containers_prune.timer";
PRESETS="95_swtr_containers_prune.preset";
BIN_APPS="swtr_clear_container_cache.sh"
declare -A remove_items=([${PRESET_REMOVE_DIR}]="${PRESETS}"
			  [${SERVICE_REMOVE_DIR}]="${SERVICES}");
declare -A remove_bin=([${BIN_REMOVE_DIR}]=${BIN_APPS});
declare -i exit_status=0;
if [  ${EUID} -eq 0 ]; then
    if [ -f /etc/os-release ]; then
	. /etc/os-release;
    fi;
    systemctl stop swtr_containers_prune.timer;
    systemctl stop swtr_containers_prune.service;
    systemctl disable swtr_containers_prune.timer;
    systemctl disable swtr_containers_prune.service;
    for dest in ${!remove_items[@]}
    do
	for item in ${remove_items[${dest}]};
	do
	    ${DRYRUN} rm -f  ${dest}/${item};
	done;
    done;
    for dest in ${!remove_bin[@]}
    do
	for item in ${remove_bin[${dest}]};
	do
	    ${DRYRUN} install ${dest}/${item};
	done;
    done;
    systemctl daemon-reload;
else
    echo "[ERROR] Script must be run as root or with sudo." 1>&2;
    exit_status=1;
fi;
exit ${exit_status};

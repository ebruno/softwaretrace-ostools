#!/usr/bin/env bash

declare -i exit_status=0;
if [ -x /usr/bin/podman ]; then
  PODMAN="podman";
fi;
if [ -x /usr/bin/docker ]; then
    DOCKER="docker";
fi;
if [ -n "${PODMAN}" ]; then
   CONTAINER_APP="${PODMAN}";
elif [ -n "${DOCKER}" ]; then
   CONTAINER_APP="${DOCKER}";
else
  echo "[ERROR] podman or docker not present in environment." 1>&2;
   exit_status=1;
fi;

if [ ${exit_status} -eq 0 ]; then
    ${CONTAINER_APP} system prune -af --filter "until=24h"
    exit_status=$?;
fi;
exit ${exit_status};

#!/usr/bin/bash
PODMAN=$(which podman);
DOCKER=$(which docker);
declare -i exit_status=0;
if [ -n "${PODMAN}" ]; then
    CONTAINER_APP="${PODMAN}";
elif [ -n "${DOCKER}" ]; then
    CONTAINER_APP="${DOCKER}";
else
    exit_status=1;
fi;
if [ ${exit_status} -eq 0 ]; then
  ${CONTAINER_APP} build -t gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/rhel10rpmbuild -t rhel10rpmbuild -f rhel10/Containerfile;
  ${CONTAINER_APP} push gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/rhel10rpmbuild;
  ${CONTAINER_APP} build -t gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/archlinux -t archlinux -f archlinux/Dockerfile;
  ${CONTAINER_APP} push gitlab01.brunoe.net:5050/ebruno/softwaretrace-ostools/archlinux;
fi;

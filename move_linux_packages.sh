#!/usr/bin/bash
ARTIFACTDIR="$1"
PACKAGE_EXT="$2"
ID="$3"
NAS_REPO_ROOT_PATH="$4"
REPO_ROOT_NAME="$5"
machine="$6"

if [ "${ID}" = "arch" ]; then
    echo find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Install Package:%f\n" -exec install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine} \;
    find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Install Package:%f\n" -exec install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine} \;
#find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Copying Package:%f\n" -exec basename {}; install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine} \;
    cd ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux;
    pwd;
    ls -l;
   echo repo-add --new ./sfwtrace-repo.db.tar.tz sfwtrace/os/${machine}/${PACKAGE_EXT}
fi;

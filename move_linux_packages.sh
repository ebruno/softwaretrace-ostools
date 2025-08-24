#!/usr/bin/bash
env;
echo "ID=${ID}";
if [ "${ID}" = "arch" ]; then
    echo find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Install Package:%f\n" -exec install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine} \;
#find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Copying Package:%f\n" -exec basename {}; install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine} \;
   echo cd ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux;
   echo repo-add --new ./sfwtrace-repo.db.tar.tz sfwtrace/os/${machine}/${PACKAGE_EXT}
fi;

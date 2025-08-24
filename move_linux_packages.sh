#!/usr/bin/bash
echo cp --preserve=timestamps "${ARTIFACTDIR}/${PACKAGE_EXT}" ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine};
install -p -m 664 ${ARTIFACTDIR}/${PACKAGE_EXT} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine};
find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Copying Package:%f\n" -exec basename {}; install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux/sfwtrace/os/${machine} \;
if [ "${ID} = "arch" ]; then
   echo cd ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_NAME}/${ID}linux;
   echo repo-add --new ./sfwtrace-repo.db.tar.tz sfwtrace/os/${machine}/${PACKAGE_EXT}
fi;

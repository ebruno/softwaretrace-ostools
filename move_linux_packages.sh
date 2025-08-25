#!/usr/bin/bash
ARTIFACTDIR="$1";
PACKAGE_EXT="$2";
ID="$3";
NAS_REPO_ROOT_PATH="$4";
REPO_ROOT_PATH="$5";
REPO_NAME="$6";
machine="$7";

if [ "${ID}" = "arch" ]; then
    echo find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Install Package:%f\n" -exec install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}linux/${REPO_NAME}/os/${machine} \;
    find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -printf "[INFO] Install Package:%f\n" -exec install -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}linux/${REPO_NAME}/os/${machine} \;
    cd ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}linux/${REPO_NAME}/os/${machine};
    chmod a+r *;
    repo-add -p -R --new ./${REPO_NAME}.db.tar.gz ${PACKAGE_EXT}
    ls -l;
fi;

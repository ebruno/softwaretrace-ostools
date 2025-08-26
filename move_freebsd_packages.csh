#!/bin/tcsh
set ARTIFACTDIR = "$1";
set PACKAGE_EXT = "$2";
set ID = "$3";
set NAS_REPO_ROOT_PATH = "$4";
set REPO_ROOT_PATH = "$5";
set REPO_NAME = "$6";
set machine = "$7";
echo "start script"
if ( "${ID}" == "freebsd" ) then
    echo find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -exec install -v -p -m 664 {} "${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}/${REPO_NAME}/All";
    ls -l "${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}/${REPO_NAME}/All"
    find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}" -exec install -v -p -m 664 {} "${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}/${REPO_NAME}/All" \;
    cd "${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}/${REPO_NAME}/All";
    chmod a+r *;
    #repo-add -p -R --new ./${REPO_NAME}.db.tar.gz ${PACKAGE_EXT}
    ls -l;
endif;
echo "exit script"
exit 0;

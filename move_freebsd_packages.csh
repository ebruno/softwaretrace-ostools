#!/bin/tcsh
set exit_status = 0;
set ARTIFACTDIR = "$1";
set PACKAGE_EXT = "$2";
set ID = "$3";
set NAS_REPO_ROOT_PATH = "$4";
set REPO_ROOT_PATH = "$5";
set REPO_NAME = "$6";
set machine = "$7";
set myscript = `basename $0`;
echo "[INFO] Enter: ${myscript}";
if ( "${ID}" == "freebsd" ) then
    echo "[INFO] Installing ${ID} Packages."
    find "${ARTIFACTDIR}" -name "${PACKAGE_EXT}"  -exec install -v -p -m 664 {} ${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}/${REPO_NAME}/All \;
    cd "${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}/${REPO_NAME}";
    pkg repo .;
    ls -l;
endif;
echo "[INFO] exit: ${myscript}"; 
exit ${exit_status};

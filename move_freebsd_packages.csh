#!/bin/tcsh
set exit_status = 0;
set ARTIFACTDIR = "$1";
set PACKAGE_EXT = "$2";
set ID = "$3";
set NAS_REPO_ROOT_PATH = "$4";
set REPO_ROOT_PATH = "$5";
set REPO_NAME = "$6";
set machine = "$7";
if ( "${ID}" == "freebsd" ) then

    cd "${NAS_REPO_ROOT_PATH}/${REPO_ROOT_PATH}/${ID}/${REPO_NAME}";
    doas pkg repo;
    ls -l;
endif;
exit ${exit_status};

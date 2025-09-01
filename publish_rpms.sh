#!/usr/bin/env bash
. /etc/os-release;
echo "param count $#";
if [ $# -eq 7 ]; then
    ARTIFACTDIR="$1";
    PACKAGE_EXT="$2";
    ID="$3";
    NAS_AUTOFS_ROOT_PATH="$4";
    REPO_ROOT_PATH="$5";
    REPO_NAME="$6";
    machine="$7";
else
    if [ -z "${NAS_AUTOFS_ROOT_PATH}" ]; then
	NAS_AUTOFS_ROOT_PATH="${PWD}/qnap02/Web"
    fi;
    if [ -z "${REPO_NAME}" ]; then
	REPO_NAME="sfwtrace"
    fi;
    if [ -z "${REPO_ROOT_PATH}" ]; then
	REPO_ROOT_PATH="softwaretracerepos"
    fi;
fi;
REPO_BASE_DIR="${NAS_AUTOFS_ROOT_PATH}/${REPO_ROOT_PATH}"

declare -A OS_DIR=(["fc"]="fedora" ["el"]="rhel");
RPM_DIRS="${PWD}/packages/${ID}";
tmpfile="$(mktemp)";
CREATEREPO="$(which createrepo)";
OS_ID="";
OS_RELEASE="";
SUDO="";
declare -a updated_repos;

if [ -n "${CI_JOB_ID}" ]; then
    pwd;
fi;

find "${RPM_DIRS}" -name "*.rpm" > "${tmpfile}";
while read line
do
    echo "${line}";
    IFS=. read -a record <<< "${line}";
    echo "${record[-1]} ${record[-2]} ${record[-3]}";
    if [[ "${record[-3]}" =~ ^fc.* ]]; then
	OS_ID="fc"
	OS_RELEASE="${record[-3]/fc}";
    elif [[ "${record[-3]}" =~ ^el.* ]]; then
	OS_ID="el";
	OS_RELEASE="${record[-3]}/el}";
    fi;
    if [ -n "${OS_ID}" ] & [ "${OS_RELEASE}" ]; then
	updated_repos+=("${record[-3]}");
	if [ ! -d "${REPO_BASE_DIR}/${OS_DIR[${OS_ID}]}/${REPO_NAME}/${OS_RELEASE}/${record[-2]}" ]; then
	    mkdir -p "${REPO_BASE_DIR}/${OS_DIR[${OS_ID}]}/${REPO_NAME}/${OS_RELEASE}/${record[-2]}";
	fi;
	item="$(basename "${line}")";
	echo "Installing ${item}";
	install -m 644 "${line}" "${REPO_BASE_DIR}/${OS_DIR[${OS_ID}]}/${REPO_NAME}/${OS_RELEASE}/${record[-2]}/${item}";
    fi;
done < "${tmpfile}";
rm -f "${tmpfile}";
for repo in ${updated_repos[@]}
do
    if [[ "${repo}" =~ ^fc.* ]]; then
	OS_ID="fc"
	OS_RELEASE="${repo/fc}";
    elif [[ "${repo}" =~ ^el.* ]]; then
	OS_ID="el";
	OS_RELEASE="${repo/el}";
    else
	continue;
    fi;
    if [ -d "${REPO_BASE_DIR}/${OS_DIR[${OS_ID}]}/${REPO_NAME}/${OS_RELEASE}" ] & [ -n "{CREATEREPO}" ]; then
	echo "[INFO] Updating ${REPO_BASE_DIR}/${OS_DIR[${OS_ID}]}/${REPO_NAME}/${OS_RELEASE}";
	${CREATEREPO} --update "${REPO_BASE_DIR}/${OS_DIR[${OS_ID}]}/${REPO_NAME}/${OS_RELEASE}";
    fi;
done;

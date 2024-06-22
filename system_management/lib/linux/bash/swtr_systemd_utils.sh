# Systemd utilites.
    # systemctl is-enabled return values.
    #  ┌───────────────────┬────────────────────────────────────────────────────────────────────────────┬───────────┐
    #  │ Name              │ Description                                                                │ Exit Code │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "enabled"         │ Enabled via .wants/, .requires/ or Alias= symlinks (permanently in         │           │
    #  ├───────────────────┤ /etc/systemd/system/, or transiently in /run/systemd/system/).             │ 0         │
    #  │ "enabled-runtime" │                                                                            │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "linked"          │ Made available through one or more symlinks to the unit file (permanently  │           │
    #  ├───────────────────┤ in /etc/systemd/system/ or transiently in /run/systemd/system/), even      │ > 0       │
    #  │ "linked-runtime"  │ though the unit file might reside outside of the unit file search path.    │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "alias"           │ The name is an alias (symlink to another unit file).                       │ 0         │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "masked"          │ Completely disabled, so that any start operation on it fails (permanently  │           │
    #  ├───────────────────┤ in /etc/systemd/system/ or transiently in /run/systemd/systemd/).          │ > 0       │
    #  │ "masked-runtime"  │                                                                            │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "static"          │ The unit file is not enabled, and has no provisions for enabling in the    │ 0         │
    #  │                   │ [Install] unit file section.                                               │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "indirect"        │ The unit file itself is not enabled, but it has a non-empty Also= setting  │ 0         │
    #  │                   │ in the [Install] unit file section, listing other unit files that might be │           │
    #  │                   │ enabled, or it has an alias under a different name through a symlink that  │           │
    #  │                   │ is not specified in Also=. For template unit files, an instance different  │           │
    #  │                   │ than the one specified in DefaultInstance= is enabled.                     │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "disabled"        │ The unit file is not enabled, but contains an [Install] section with       │ > 0       │
    #  │                   │ installation instructions.                                                 │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "generated"       │ The unit file was generated dynamically via a generator tool. See          │ 0         │
    #  │                   │ systemd.generator(7). Generated unit files may not be enabled, they are    │           │
    #  │                   │ enabled implicitly by their generator.                                     │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "transient"       │ The unit file has been created dynamically with the runtime API. Transient │ 0         │
    #  │                   │ units may not be enabled.                                                  │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "bad"             │ The unit file is invalid or another error occurred. Note that is-enabled   │ > 0       │
    #  │                   │ will not actually return this state, but print an error message instead.   │           │
    #  │                   │ However the unit file listing printed by list-unit-files might show it.    │           │
    #  ├───────────────────┼────────────────────────────────────────────────────────────────────────────┼───────────┤
    #  │ "not-found"       │ The unit file doesn't exist.                                               │ 4         │
    #  └───────────────────┴────────────────────────────────────────────────────────────────────────────┴───────────┘
    #

swtr_systemd_version() {
    # Returns the systemd version to stdout or to an variable.
    # Param 1 optional variable to return the version id to.
    # Returns 0 or 1;
    local -i local_status=1;
    local -i required_parameters=0;
    tmpfile="$(mktemp)";
    systemctl --version > "${tmpfile}";
    while read -r -a version_info
    do
	if [ ${#version_info[*]} -ge 2 ]; then
	    #shellcheck disable=SC2181
	    if [ ${#} -eq 1 ]; then
		local -n local_version="${1}";
		#shellcheck disable=SC2034
		local_version="${version_info[1]}";
	    else
		printf "%s" "${version_info[1]}";
	    fi;
	    local_status=0;
	fi;
	break;
    done < "${tmpfile}";
    rm -f "${tmpfile}";
    return "${local_status}";
}

swtr_is_systemd_unit_installed() {
    # Param 1 variable type:
    # systemdctl status returns "not-found" │ The unit file doesn't exist. │ 4
    local -i required_parameters=1;
    local -i local_status=1;
    local required_systemd_version="238"
    local current_version="";
    if [ $# -eq ${required_parameters} ]; then
	systemd_version current_version;
	#shellcheck disable=SC2181
	if [ $? -eq 0 ]; then
	    if [ "${current_version}" -ge ${required_systemd_version} ]; then
		systemctl status "${1}" &>/dev/null;
		unit_status=$?;
		if [ ${unit_status} -ne 4 ]; then
		    local_status=0;
		fi;
	    else
		echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} only systemd version ${required_systemd_version} and higher supported." 1>&2;
		echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} current systemd version is ${current_version}." 1>&2;
	    fi;
	else
	   echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} unable to determine  systemd version." 1>&2;
	fi;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

swtr_is_unit_enabled() {
    # Param 1 unit name to test.
    # Param 2 variable to return status in.
    # Returns: 0 or 1.
    local -i required_parameters=2;
    local -i local_status=1;
    if [ $# -eq ${required_parameters} ]; then
	local -n current_status="${2}";
	current_status="$(systemctl is-enabled "${1}")";
	#shellcheck disable=SC2181
	if [ $? -eq 0 ] && [ "${current_status}" = "enabled" ]; then
	    local_status=0;
	fi;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

swtr_is_unit() {
    # Param 1 unit name to test.
    # Param 2 status to test.
    # Returns: 0 or 1.
    local -i required_parameters=2;
    local -i local_status=1;
    if [ $# -eq ${required_parameters} ]; then
	local -n current_status="${2}";
	current_status="$(systemctl is-enabled "${1}")";
	if [ "${current_status}" = "${2}" ]; then
	    local_status=0;
	fi;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

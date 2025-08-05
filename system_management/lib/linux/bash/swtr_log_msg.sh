# Log msg requires the swtr_is_vartype function.
type -t swtr_is_vartype >& /dev/null;
if [ $? -eq 1 ]; then
    tmp_path="$(readlink -f -n "${BASH_SOURCE[0]}")";
    tmp_path="$(dirname "${tmp_path}")";
    if [ -f "${tmp_path}/swtr_is_vartype.sh" ]; then
	. "${tmp_path}/swtr_is_vartype.sh";
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires swtr_is_vartype function." 1>&2;
	return 1;
    fi;
fi;

swtr_log_msg_to_journald() {
    # Syntax: log a message to stdout or an indexed array.
    # Message can be plain text of JSON formated.
    # returns 0 on success 1 on failure.
    # PARAM 1 Loglevel "emerg", "alert", "crit", "err", "warning", "notice", "info", "debug"
    # PARAM 2 Msg format "text", "json"
    # PARAM 3 identifier
    # PARAM 4 indexed array or message.
    # PARAM 5 message if param 4 is indexed array.
    #
    # systemd-cat --identifier (short string that is used to identify the logging tool.
    #                           If not specified, no identification string is written to the journal.)
    local -i required_parameters=4;
    local -i local_status=1;
    local -i test_status=1;
    local -A loglevels;
    loglevels=([emerg]="0" [alert]="1" [crit]="2" [error]="3" [warning]="4" [notice]="5" [info]="6" [debug]="7");
    if [ $# -ge ${required_parameters} ]; then
	systemd_cat_options="";
	if [ -n "${3}" ]; then
	    systemd_cat_options="${systemd_cat_options} --identifier=${3}";
	fi;
	systemd_cat_options="${systemd_cat_options} --level-prefix=true";
	if [ $# -eq 5 ]; then
	    read -r -a tmp_info <<< "${4}";
	    swtr_is_vartype "-a" "${tmp_info[0]}";
	    test_status=${?};
	    if [ ${test_status} -eq 0 ]; then
		local -n local_array="${4}";
		local_status=0;
	    else
		echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} third parameter \"${4}\" should be indexed array." 1>&2;
	    fi;
	elif [ $# -eq ${required_parameters} ]; then
	    local_status=0;
	fi;
	if [ ${local_status} -eq 0 ]; then
	    local -l loglevel="${1}";
	    loglevel_id="${loglevels[${loglevel}]}"
	    if [ ${test_status} -eq 1 ] && [ "${2}" = "text" ]; then
		# shellcheck disable=SC2086
		systemd-cat ${systemd_cat_options} printf "<%s> %s\n" "${loglevel_id}" "${4}";
	    elif [ ${test_status} -eq 1 ] && [ "${2}" = "json" ]; then
		# shellcheck disable=SC2086
		systemd-cat ${systemd_cat_options} printf "<%s>{\"LOGLEVEL\":\"%s\",\"msg\":\"%s\"}\n" "${loglevel_id}" "${1}" "${4}";
	    elif [ ${test_status} -eq 0 ] && [ "${2}" = "text" ]; then
		msg="$(printf "<%s> %s\n" "${loglevel_id}" "${5}")";
		local_array+=("${msg}");
	    elif [ ${test_status} -eq 0 ] && [ "${2}" = "json" ]; then
		msg="$(printf "<%s>{\"LOGLEVEL\":\"<%s>\",\"msg\":\"%s\"}\n" "${loglevel_id}" "${1}" "${5}")";
		local_array+=("${msg}");
	    else
		echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} unsupported output format \"${2}\"." 1>&2;
		local_status=1;
	    fi;
	fi;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} or more parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};


swtr_log_msg() {
    # Syntax: log a message to stdout or an indexed array.
    # Message can be plain text of JSON formated.
    # returns 0 on success 1 on failure.
    # PARAM 1 Loglevel
    # PARAM 2 Msg format "text", "json"
    # PARAM 3 indexed array or message.
    # PARAM 4 message if param 3 is indexed array.
    local -i required_parameters=3;
    local -i local_status=1;
    local -i test_status=1;
    if [ $# -ge ${required_parameters} ]; then
	if [ $# -eq 4 ]; then
	    read -r -a tmp_info <<< "${3}";
	    swtr_is_vartype "-a" "${tmp_info[0]}";
	    test_status=${?};
	    if [ ${test_status} -eq 0 ]; then
		# shellcheck disable=SC2178
		local -n local_array="${3}";
		local_status=0;
	    else
		echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} third parameter \"${3}\" should be indexed array." 1>&2;
	    fi;
	elif [ $# -eq ${required_parameters} ]; then
	    local_status=0;
	fi;
	if [ ${local_status} -eq 0 ]; then
	    if [ ${test_status} -eq 1 ] && [ "${2}" = "text" ]; then
		printf "[%s] %s\n" "${1}" "${3}";
	    elif [ ${test_status} -eq 1 ] && [ "${2}" = "json" ]; then
		printf "{\"LOGLEVEL\":\"%s\",\"msg\":\"%s\"}\n" "${1}" "${3}";
	    elif [ ${test_status} -eq 0 ] && [ "${2}" = "text" ]; then
		msg="$(printf "[%s] %s\n" "${1}" "${4}")";
		local_array+=("${msg}");
	    elif [ ${test_status} -eq 0 ] && [ "${2}" = "json" ]; then
		msg="$(printf "{\"LOGLEVEL\":\"%s\",\"msg\":\"%s\"}\n" "${1}" "${4}")";
		local_array+=("${msg}");
	    else
		echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} unsupported output format \"${2}\"." 1>&2;
		local_status=1;
	    fi;
	fi;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} or more parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

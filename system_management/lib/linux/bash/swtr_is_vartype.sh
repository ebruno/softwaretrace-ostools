swtr_is_vartype() {
    # Param 1 variable type:
    # (examples)
    #   -- text
    #   -a indexed array
    #   -A associated array
    #   -i integer
    #
    local -i required_parameters=2;
    local -i local_status=1;
    if [ $# -eq ${required_parameters} ]; then
	read -r -a var_info <<< "$(declare -p "${2}" 2>/dev/null)";
	if [ ${#var_info[@]} -ge 3 ]; then
	    if [ "${var_info[0]}" = "declare" ] && [ "${var_info[1]}" = "${1}" ]; then
		local_status=0;
	    fi;
	fi;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

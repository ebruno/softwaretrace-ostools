swtr_report_log_array() {
    # Syntax: report_log_array <name of array> [descending];
    # writes the contents of an indexed array to stdout in
    # ascending or descending order.
    # Param 1 indexed array
    # Param 2 ascending or descending, default is ascending.
    # returns 0 on success 1 on failure.
    #
    local -i required_parameters=1;
    local -i local_status=1;
    local order="${2:-ascending}";
    if [ $# -ge ${required_parameters} ]; then
	if [ "${order}" = "ascending" ] || [ "${order}" == "descending" ]; then
	    local -n local_array="${1}";
	    num_entries="${#local_array[@]}";
	    idx=0;
	    if [ "${order}" = "descending" ]; then
		idx=-1;
	    fi;
	    while ((num_entries--))
	    do
		printf "%s\n" "${local_array[${idx}]}";
		if [ "${order}" = "descending" ]; then
		    ((--idx));
		else
		    ((++idx));
		fi;
	    done;
	    local_status=0;
	else
	    echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requested order is \"${order}\", allowed values are [ ascending, descending]." 1>&2;
	fi;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} or more parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

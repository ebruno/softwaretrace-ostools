# Function template.

swtr_function_name() {
    # Param 1 variable type:
    #
    local -i required_parameters=1;
    local -i local_status=1;
    if [ $# -eq ${required_parameters} ]; then
	echo "do something";
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

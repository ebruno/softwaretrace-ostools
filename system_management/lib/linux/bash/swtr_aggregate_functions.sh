swtr_aggregate_functions() {
    # Param 1 associated array of function names and paths to source files to load.:
    # Param 2 file name of the file to output the functions."
    # Use only one parameter is supplied output will got to stdout and if param 2 is '-'.
    local -i required_parameters=;
    local -i local_status=1;
    local -l outfile="${2:-/dev/stdout}";
    if [ $# -eq ${required_parameters} ]; then
	local -n array_name="${1}";
	if [ "${outfile}" = "-" ]; then
	    outfile="/dev/stdout";
	fi;
	for entry in "${!array_name[@]}"
	do
	    if [ -f "${array_name[${entry}]}" ]; then
		printf "%s" "#\n# Including ${entry} from \"${array_name[${entry}]}\"\n#\n" >> "${outfile}";
		cat "${array_name[${entry}]}" >> "${outfile}";
	    else
		echo "[WARNING] ${FUNCNAME[0]} file: \"${array_name[${entry}]}\" not found skipping." 1>&2;
	    fi;
	done;
    else
	echo "[ERROR] ${FUNCNAME[0]} in ${BASH_SOURCE[0]} at line ${BASH_LINENO[0]} requires ${required_parameters} parameter(s), $# provided." 1>&2;
    fi;
    return ${local_status};
};

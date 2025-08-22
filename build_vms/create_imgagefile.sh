#!/usr/local/bin/bash
exit_status=0;
VALID_OPTIONS=":hc:n"
DRYRUN_CMD="";
BLOCK_COUNT=1024

display_help() {
    echo "create_imagefile [-h] [-c <blocksize>] filename"
    echo "Options:"
    echo "  -h              - display this message"
    echo "  -c count blocks - Number of 1 Mbyte blocks to write."
    echo "  -n              - dryrun;"
    return 0;
}


while getopts "${VALID_OPTIONS}" curopt;
do
    case ${curopt} in
	h)
	    display_help;
	    exit_status=2
	    ;;
	c)
	    BLOCK_COUNT=${OPTARG};
	    ;;
	n)
	    DRYRUN_CMD="echo";
	    ;;
	\?)
	    echo "Invalid option: -${OPTARG}" 1>&2;;
	    ;;
    esac;
done;
shift $((OPTIND - 1))
if [ $# -eq 1 ]; then
    if [ ${exit_status} -eq 0 ]; then
       exit_satatus=$?
       ${DRYRUN_CMD} BLOCK_COUNT=${BLOCK_COUNT};
       ${DRYRUN_CMD} dd if=/dev/zero of="${1}" bs=1M count=${BLOCK_COUNT};
       ${DRYRUN_CMD} mkfs.ext4 "${1}";
       ${DRYRUN_CMD} mount -o loop  -P "${1}"
    fi;
else
    echo "[FATAL] Path to output file required." 1>&2;
    display_help;
    exit_status=1;
fi;
if [ ${exit_status} -eq 2 ]; then
   exit_status=0;
fi;
exit ${exit_status};

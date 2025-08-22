#!/usr/bin/bash
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
	    DRYRUN_CMD="echo [DRYRUN] ";
	    ;;
	\?)
	    echo "Invalid option: -${OPTARG}" 1>&2;
	    ;;
    esac;
done;
shift $((OPTIND - 1))
if [ $# -eq 1 ]; then
    if [ ${exit_status} -eq 0 ]; then
       exit_satatus=$?
       ${DRYRUN_CMD} touch "${1}";
       ${DRYRUN_CMD} dd if=/dev/zero of="${1}" bs=1M count=${BLOCK_COUNT};
       ${DRYRUN_CMD} sudo mkfs.ext4 "${1}";
       ${DRYRUN_CMD} mkdir -p mnt;
       ${DRYRUN_CMD} sudo mount -o loop "${1}" ./mnt
       ${DRYRUN_CMD} sudo cp -r --preserve=timestamps,mode archlinux ./mnt
       ${DRYRUN_CMD} sudo ls -lR ./mnt;
       ${DRYRUN_CMD} sudo umount ./mnt;
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

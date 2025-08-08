#/bin/bash
OPTSTRING="hcCp";
exit_status=0;
lint_c=1;
lint_cpp=1;
lint_python=1;
PYTHON3=$(which python3);
CPPCHECK=$(which cppcheck);
FULLPATH=$(readlink -f $0);
FULL_DIRPATH=$(dirname ${FULLPATH});
REPORT_FILES="cppcheck-result_src_c cppcheck-result_src_cpp"
REPORT_DIR="${FULL_DIRPATH}/reports";
display_help() {
  echo "lint_code.sh [-h] [-c] [-C] [-p]"
  echo "-h - display this message."
  echo "-c - lint c language code."
  echo "-C - lint c++ language code."
  echo "-p - lint python language code."
  echo "if no options are specified, than all languages will be processed,";
  return 0;
}
if [ $# -gt 0 ]; then
       while getopts ${OPTSTRING} option; do
	   case ${option} in
	       h)
		   display_help;
		   exit_status=2;
		   ;;
	       c)
		   lint_c=0;
		   ;;
	       C)
		   lint_cpp=0;
		   ;;
	       p)
		   lint_python=0;
		   ;;
	       :)
		   echo "[ERROR] Option -${OPTARG} requires an argument." 1>%2;
		   exit_status=1;
		   break;
		   ;;
	       ?)
		   echo "[ERROR] Invalid option: -${OPTARG}." 1>%2;
		   exit_status=1;
		   break;
		   ;;
	   esac;
      done;
else
    lint_c=0;
    lint_cpp=1; # no cpp code yet.
    lint_python=0;
fi;
# create virtual environment
if [ ${exit_status} -eq 0 ]; then
    if [ -n "${PYTHON3}" ]; then
	${PYTHON3} -m venv lint_tools;
	source ./lint_tools/bin/activate;
	pip install -r requirements.txt
	if [ -d  ${REPORT_DIR} ]; then
	    rm -r -f ${REPORT_DIR}/*;
	else
	    mkdir -p ${REPORT_DIR};
	fi;
	# Python is linted on github with built in ruff action.
	if [ -z "${GITHUB_WORKSPACE}" ] && [ ${lint_python} -eq 0 ]; then
	    pushd .
	    cd python
	    ruff check --output-format gitlab src/*.py procmgt/*.py childmgt/*.py wsgi/*.py > ${REPORT_DIR}/python_code_gitlab.json;
	    ruff check --output-format junit src/*.py procmgt/*.py childmgt/*.py wsgi/*.py > ${REPORT_DIR}/python_code_junit.junit;
	    popd
	fi;
    else
	if [ -z "${PYTHON3}" ]; then
	    echo "[WARNING] Python3 not installed, skipping python checks." 1>%2;
	fi;
    fi;
    if [ ${lint_c} -eq 0 ]; then
	pushd .
	cd c_cpp/src_c;
	${CPPCHECK} --xml-version=2 --enable=all . 2> ${REPORT_DIR}/cppcheck-result_src_c.xml
	popd
    fi;
    if [ ${lint_cpp} -eq 0 ]; then
	pushd .
	cd  c_cpp/src_cpp
	${CPPCHECK} --xml-version=2 --enable=all . 2> ${REPORT_DIR}/cppcheck-result_src_cpp.xml
	popd
    fi;
    pushd .
    cd ${REPORT_DIR};
    for item in ${REPORT_FILES}
    do
	if [ -f "${item}.xml" ]; then
	    cppcheck_junit ${item}.xml ${item}.junit;
	fi;
    done;
    popd
    deactivate;
    rm -r -f lint_tools;
fi;
if [ ${exit_status} -eq 2 ]; then
       exit_status = 0;
fi;
exit ${exit_status};

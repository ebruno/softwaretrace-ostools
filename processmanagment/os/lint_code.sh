#/bin/bash
PYTHON3=$(which python3);
CPPCHECK=$(which cppcheck);
FULLPATH=$(readlink -f $0);
FULL_DIRPATH=$(dirname ${FULLPATH});
REPORT_FILES="cppcheck-result_src_c cppcheck-result_src_cpp"
REPORT_DIR="${FULL_DIRPATH}/reports";
# create virtual environment
if [ -n "${PYTHON3}" ]; then
    ${PYTHON3} -m venv lint_tools;
    source ./lint_tools/bin/activate;
    pip install -r requirements.txt
    if [ -d  ${REPORT_DIR} ]; then
	rm -r -f ${REPORT_DIR}/*;
    else
	mkdir -p ${REPORT_DIR};
    fi;
    pushd .
    cd c_cpp/src_c;
    ${CPPCHECK} --xml-version=2 --enable=all . 2> ${REPORT_DIR}/cppcheck-result_src_c.xml
    popd
#    pushd .
#    cd  c_cpp/src_cpp
#    ${CPPCHECK} --xml-version=2 --enable=all . 2> ${REPORT_DIR}/cppcheck-result_src_cpp.xml
#    popd
    pushd .
    cd ${REPORT_DIR};
    for item in ${REPORT_FILES}
    do
	cppcheck_junit ${item}.xml ${item}.junit;
    done;
    popd
    pushd .
    cd python
    env;
    ruff check --output-format gitlab src/*.py procmgt/*.py childmgt/*.py wsgi/*.py > ${REPORT_DIR}/python_code_gitlab.json;
    ruff check --output-format github src/*.py procmgt/*.py childmgt/*.py wsgi/*.py > ${REPORT_DIR}/python_code_github.txt;
    ruff check --output-format junit src/*.py procmgt/*.py childmgt/*.py wsgi/*.py > ${REPORT_DIR}/python_code_junit.junit;
    deactivate;
    popd
    rm -r -f lint_tools;
fi;

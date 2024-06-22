BASEDIR   =  .

DOCDIR_ROOT = ${BASEDIR}
BASE_DOCDIR    =  doc

DOXYGEN_TEMPLATES = childmgt_python

TEMP_DIRS = doc

all:

.PHONY: create_doc create

create_doc: 
	@echo "Creating Documentation"
	@if ! test -d ${DOCDIR_ROOT}/${BASE_DOCDIR}; then \
	mkdir -p ${DOCDIR_ROOT}/${BASE_DOCDIR}; \
	fi;
	$(foreach item, ${DOXYGEN_TEMPLATES},(cat Doxyfile_${item}; echo "OUTPUT_DIRECTORY=${DOCDIR_ROOT}/${BASE_DOCDIR}/${item}" ) | doxygen -)

clean: 
	@echo "Cleaning...";
	@rm -f *.~;
	@find . -name "*.pyc" -exec rm -f {} \;
	@find . -name "#*#" -exec rm -f {} \;

dist_clean: clean
	@rm -r -f ${TEMP_DIRS}

BASEDIR   =  .

DOCDIR_ROOT = ${BASEDIR}
BASE_DOCDIR    =  doc

DOXYGEN_TEMPLATES = childmgt

all:

.PHONY: create_doc

create_doc: 
	@echo "Creating Documentation"
	@if ! test -d ${DOCDIR_ROOT}/${BASE_DOCDIR}; then \
	mkdir -p ${DOCDIR_ROOT}/${BASE_DOCDIR}; \
	fi;
	$(foreach item, ${DOXYGEN_TEMPLATES},(cat Doxyfile_${item}; echo "OUTPUT_DIRECTORY=${DOCDIR_ROOT}/${BASE_DOCDIR}/${item}" ) | doxygen -)



SWTRSTRLIB_NAME           = swtrstrlib

SWTRSTRLIB_MAJOR          = 0

SWTRSTRLIB_MINOR          = 9

SWTRSTRLIB_SUBVERSION     = 0

SWTRSTRLIB_PRIVATE_BUILD_ID     = 0

SWTRSTRLIB_BUILD_NUMBER     = 2

SWTRSTRLIB_RELEASE_KEY     = 0
#swtrstrlib_0.9.0.0.2.orig.tar.gz
SWTRSTRLIB_TARFILE_NAME   = ${TARFILE_NAME}_${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}.${SWTRSTRLIB_PRIVATE_BUILD_ID}.${SWTRSTRLIB_BUILD_NUMBER}_orig.tar.gz

SWTRSTRLIB_SRCDIR_NAME   = ${SWTRSTRLIB_NAME}-${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}.${SWTRSTRLIB_PRIVATE_BUILD_ID}.${SWTRSTRLIB_BUILD_NUMBER}



SWTRCOMMON_FILES          = CMakeLists.txt Makefile_packages Makefile_doc
SWTRSTRLIB_DOC_FILES 	  = 
SWTRSTRLIB_FILES          = make_swtrstrlib_ubuntu_deb.mk
SWTRSTRLIB_DIRS           = src_c

swtrstrlib_all:
		@echo "dummy_all"
		@echo "DEBBUILD_BASE=${DEBBUILD_BASE}"
		@echo "DEBBUILD_SOURCE_DIR=${DEBBUILD_SOURCE_DIR}"
		@exit 0;

swtrstrlib_create_src:
	@echo "Creating Source Distribution ${SWTRSTRLIB_TARFILE_NAME}";
	@if test -d "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; then \
	   rm -r -f "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; \
	fi;
	@mkdir -p "${SWTRSTRLIB_SRCDIR_NAME}";
	@$(foreach item, ${SWTRCOMMON_FILES} ${SWTRSTRLIB_FILES} ${SWTRSTRLIB_DOC_FILES},cp -p ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@$(foreach item, ${SWTRSTRLIB_DIRS}, cp -r ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@tar -czf ${DEBBUILD_SOURCE_DIR}/${SWTRSTRLIB_TARFILE_NAME} "${SWTRSTRLIB_SRCDIR_NAME}"
	@rm -r -f "${SWTRSTRLIB_SRCDIR_NAME}";

swtrstrlib_create_pkg:
		@echo "Currently Not implemented"


SWTRSTRLIB_NAME           = swtrstrlib

SWTRSTRLIB_MAJOR          = 0

SWTRSTRLIB_MINOR          = 9

SWTRSTRLIB_SUBVERSION     = 0

SWTRSTRLIB_PRIVATE_BUILD_ID     = 0

SWTRSTRLIB_BUILD_NUMBER     = 2

SWTRSTRLIB_RELEASE_KEY     = 0

SWTRSTRLIB_TARFILE_NAME   = ${TARFILE_NAME}-${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}.${SWTRSTRLIB_PRIVATE_BUILD_ID}.${SWTRSTRLIB_BUILD_NUMBER}.tar.gz

SWTRSTRLIB_SRCDIR_NAME   = ${SWTRSTRLIB_NAME}-${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}.${SWTRSTRLIB_PRIVATE_BUILD_ID}.${SWTRSTRLIB_BUILD_NUMBER}

SWTRCOMMON_FILES          = CMakeLists.txt Makefile_rpms Makefile_doc
SWTRSTRLIB_DOC_FILES 	  = 
SWTRSTRLIB_FILES          = make_swtrstrlib_rpm.mk
SWTRSTRLIB_DIRS           = src_c

swtrstrlib_create_src:
	@echo "Creating Source Distribution ${SWTRSTRLIB_TARFILE_NAME}";
	@if test -d "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; then \
	   rm -r -f "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; \
	fi;
	@mkdir -p "${SWTRSTRLIB_SRCDIR_NAME}";
	@$(foreach item, ${SWTRCOMMON_FILES} ${SWTRSTRLIB_FILES} ${SWTRSTRLIB_DOC_FILES},cp -p ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@$(foreach item, ${SWTRSTRLIB_DIRS}, cp -r ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@tar -czf ${RPMBUILD_SOURCE_DIR}/${SWTRSTRLIB_TARFILE_NAME} "${SWTRSTRLIB_SRCDIR_NAME}"
	@rm -r -f "${SWTRSTRLIB_SRCDIR_NAME}";

swtrstrlib_create_rpm:
	@if ! test -d ${CURDIR}/${SPEC_DIR}; then \
		mkdir -p ${CURDIR}/${SPEC_DIR}; \
	fi;
	@if test -d ${CURDIR}/${SPEC_TEMPLATE_DIR}; then \
		cat ${SPEC_TEMPLATE_DIR}/${SWTRSTRLIB_NAME}.spec.tmpl | sed -e "s/XMAJOR/${SWTRSTRLIB_MAJOR}/g" > ${SPEC_DIR}/${SWTRSTRLIB_NAME}.spec; \
		sed -e "s/XMINOR/${SWTRSTRLIB_MINOR}/g" -i ${SPEC_DIR}/${SWTRSTRLIB_NAME}.spec;\
		sed -e "s/XSUBVERSION/${SWTRSTRLIB_SUBVERSION}/g" -i ${SPEC_DIR}/${SWTRSTRLIB_NAME}.spec;\
		sed -e "s/XPRIVATE_BUILD_ID/${SWTRSTRLIB_PRIVATE_BUILD_ID}/g" -i ${SPEC_DIR}/${SWTRSTRLIB_NAME}.spec;\
		sed -e "s/XBUILD_NUMBER/${SWTRSTRLIB_BUILD_NUMBER}/g" -i ${SPEC_DIR}/${SWTRSTRLIB_NAME}.spec;\
		sed -e "s/XRELEASE_KEY/${SWTRSTRLIB_RELEASE_KEY}/g" -i ${SPEC_DIR}/${SWTRSTRLIB_NAME}.spec;\
		rpmbuild $(RPM_VERBOSE} -bb ${SPEC_DIR}/${SWTRSTRLIB_NAME}.spec; \
	else \
	  echo "Error unable to locate ${CURDIR}/${SPEC_TEMPLATE_DIR}, fatal,terminating"; \
	  exit 1; \
	fi;


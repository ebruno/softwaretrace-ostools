
SWTRSTRLIB_NAME           = swtrstrlib

SWTRSTRLIB_MAJOR          = 0

SWTRSTRLIB_MINOR          = 9

SWTRSTRLIB_SUBVERSION     = 0

SWTRSTRLIB_PRIVATE_BUILD_ID     = 0

SWTRSTRLIB_BUILD_NUMBER     = 2

SWTRSTRLIB_RELEASE_KEY     = 0

#swtrstrlib_0.9.0.0.2.orig.tar.gz
SWTRSTRLIB_TARFILE_NAME   = ${SWTRSTRLIB_NAME}-${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}.${SWTRSTRLIB_PRIVATE_BUILD_ID}.${SWTRSTRLIB_BUILD_NUMBER}.tar.gz

SWTRSTRLIB_SRCDIR_NAME   = ${SWTRSTRLIB_NAME}-${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}.${SWTRSTRLIB_PRIVATE_BUILD_ID}.${SWTRSTRLIB_BUILD_NUMBER}

SWTRSTRLIB_ARCHLINUX_BUILDDIRS = sources srcpackages packages logs

SWTRCOMMON_FILES          = CMakeLists.txt Makefile_packages Makefile_doc
SWTRSTRLIB_DOC_FILES 	  = 
SWTRSTRLIB_LICENSE_FILES  = ../../../LICENSE
SWTRSTRLIB_FILES          = make_swtrstrlib_ubuntu_deb.mk
SWTRSTRLIB_DIRS           = src_c

swtrstrlib_all:
		@echo "dummy_all"
		@exit 0;

swtrstrlib_create_distro: swtrstrlib_create_changelog swtrstrlib_create_src swtrstrlib_create_pkg

swtrstrlib_create_src:
	@echo "Creating Source Distribution ${SWTRSTRLIB_TARFILE_NAME}";
	@if ! test -d ${PACMANBUILD_BASE}; then \
               $(foreach item,${SWTRSTRLIB_ARCHLINUX_BUILDDIRS}, mkdir -p ${PACMANBUILD_BASE}/${item};) \
	fi;
	@if test -d "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; then \
	   rm -r -f "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; \
	fi;
	@mkdir -p "${SWTRSTRLIB_SRCDIR_NAME}";
	@$(foreach item, ${SWTRCOMMON_FILES} ${SWTRSTRLIB_FILES} ${SWTRSTRLIB_DOC_FILES} ${SWTRSTRLIB_LICENSE_FILES},cp -p ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@$(foreach item, ${SWTRSTRLIB_DIRS}, cp -r ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@if test -d "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; then \
	   rm -r -f "${SWTRSTRLIB_NAME}.${SWTRSTRLIB_MAJOR}.${SWTRSTRLIB_MINOR}.${SWTRSTRLIB_SUBVERSION}"; \
	fi;
	@mkdir -p "${SWTRSTRLIB_SRCDIR_NAME}";
	@$(foreach item, ${SWTRCOMMON_FILES} ${SWTRSTRLIB_FILES} ${SWTRSTRLIB_DOC_FILES},cp -p ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@$(foreach item, ${SWTRSTRLIB_DIRS}, cp -r ${item} ${SWTRSTRLIB_SRCDIR_NAME};)
	@if ! test -d ${ARCLINUX_SOURCE_DIR}; then \
	   echo "Creating ${ARCLINUX_SOURCE_DIR}"; \
	   mkdir -p ${ARCLINUX_SOURCE_DIR}; \
	fi;
	@tar -czf ${ARCLINUX_SOURCE_DIR}/${SWTRSTRLIB_TARFILE_NAME} "${SWTRSTRLIB_SRCDIR_NAME}"
	@rm -r -f "${SWTRSTRLIB_SRCDIR_NAME}";

swtrstrlib_create_changelog:

swtrstrlib_create_pkg:
		@cp archpkg_templates/PKGBUILD.proto ${PACMANBUILD_BASE}/PKGBUILD;
		@if ! test -d ${PACMANBUILD_BASE}; then \
		   $(foreach item,${SWTRSTRLIB_ARCHLINUX_BUILDDIRS}, mkdir -p ${PACMANBUILD_BASE}/${item};) \
		else \
		   rm -f ${PACMANBUILD_BASE}/${ARCLINUX_PACKAGE_DIR}/${SWTRSTRLIB_NAME}*.tar.xz; \
		fi;
		@echo "Update checksums";
	        @export PKGDEST="${PACMANBUILD_BASE}/${ARCLINUX_PACKAGE_DIR}"; \
		export BUILDDIR="${PACMANBUILD_BASE}"; \
		export SRCDEST="${PACMANBUILD_BASE}/sources"; \
		export SRCPKGDEST="${PACMANBUILD_BASE}/srcpackages"; \
		export LOGDEST="${PACMANBUILD_BASE}/logs"; \
		export PACKAGER="Eric Bruno <eric@ebruno.org>"; \
		cd ${PACMANBUILD_BASE}; pwd; \
		makepkg -g >> ${PACMANBUILD_BASE}/PKGBUILD; \
	        export PKGDEST="${PACMANBUILD_BASE}/${ARCLINUX_PACKAGE_DIR}"; \
		export BUILDDIR="${PACMANBUILD_BASE}"; \
		export SRCDEST="${PACMANBUILD_BASE}/sources"; \
		export SRCPKGDEST="${PACMANBUILD_BASE}/srcpackages"; \
		export LOGDEST="${PACMANBUILD_BASE}/logs"; \
		export PACKAGER="Eric Bruno <eric@ebruno.org>"; \
		makepkg -C ${SWTRSTRLIB_PACMAN_OVERRIDE} updpkgsums


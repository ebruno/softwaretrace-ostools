cmake_minimum_required(VERSION 3.20)
project(swtrprocmgtdemo C)
if ("${CMAKE_BUILD_TYPE}" STREQUAL "")
     set(CMAKE_BUILD_TYPE "Release" "BuildType")
endif ("${CMAKE_BUILD_TYPE}" STREQUAL "")

message("---- CMAKE_INSTALL_LOCALSTATEDIR ${CMAKE_INSTALL_LOCALSTATEDIR}")
message("---- CMAKE_INSTALL_SYSCONFDIR  ${CMAKE_INSTALL_SYSCONFDIR}")
message("---- CMAKE_LIBRARY_PATH  ${CMAKE_LIBRARY_PATH}")
message("---- CMAKE_SYSTEM ${CMAKE_SYSTEM}")
message("---- CMAKE_SYSTEM_NAME ${CMAKE_SYSTEM_NAME}")
message("---- CMAKE_HOST_SYSTEM ${CMAKE_HOST_SYSTEM}")
message("---- CMAKE_HOST_SYSTEM_NAME ${CMAKE_HOST_SYSTEM_NAME}")
message("---- CMAKE_HOST_UNIX ${CMAKE_HOST_UNIX}")

if (EXISTS "/etc/os-release")
  file(STRINGS "/etc/os-release" OS_RELEASE_INFO REGEX "^ID=*")
  message("---- OS_RELEASE_INFO ${OS_RELEASE_INFO}")
  if (OS_RELEASE_INFO MATCHES "ID=")
    string(STRIP "${OS_RELEASE_INFO}"  OS_RELEASE_INFO)
    string(SUBSTRING "${OS_RELEASE_INFO}" 3 -1 OS_NAME)
  endif(OS_RELEASE_INFO MATCHES "ID=")
else (EXISTS "/etc/os-release")
    set(OS_NAME ${CMAKE_HOST_SYSTEM_NAME})
endif(EXISTS "/etc/os-release")
message("---- OS_NAME '${OS_NAME}'")

message("-- CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/demo_bin)
set (DOXYGEN_TEMPLATES childmgt)
set (DOCDIR_ROOT ${CMAKE_BINARY_DIR})
set (BASE_DOCDIR doc)

if (DEFINED SWTRLIB_BUILD_LIBS)
  message("-- CMDLINE OVERRIDE BUILDING LIBS: ${SWTRLIB_BUILD_LIBS}")
else (DEFINED SWTRLIB_BUILD_LIBS)
  set (SWTRLIB_BUILD_LIBS "swtrprocmgt;swtrstrlib")
endif (DEFINED SWTRLIB_BUILD_LIBS)

message("-- Building libraries ${SWTRLIB_BUILD_LIBS}")
list(LENGTH SWTRLIB_BUILD_LIBS num_libs)
if (num_libs EQUAL 1)
  set (CMAKE_INSTALL_PREFIX "usr")
else(num_libs EQUAL 1)
  set (CMAKE_INSTALL_PREFIX "opt/swtrlibprocmgt")
endif(num_libs EQUAL 1)
message("-- CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")

if (CMAKE_BUILD_TYPE MATCHES Debug)
    add_compile_options(-std=c99 ${CMAKE_C_FLAGS_DEBUG} -Wall)
elseif (CMAKE_BUILD_TYPE MATCHES Release)
   add_compile_options(-std=c99 -O3)
elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    add_compile_options(-std=c99 -O2 ${CMAKE_C_FLAGS_DEBUG})
endif(CMAKE_BUILD_TYPE MATCHES Debug)

if (CMAKE_SYSTEM_NAME MATCHES Linux)
set (libsrc src_c/getmaxpid.c
    src_c/init_ctrl.c
    src_c/getprocstat.c
    src_c/count_children.c
    src_c/set_kernel_version.c
    src_c/reapzombie_status.c)
elseif (CMAKE_SYSTEM_NAME MATCHES FreeBSD)
set (libsrc src_c/getmaxpid.c
    src_c/init_ctrl.c
    src_c/getprocstat.c
    src_c/freebsd_count_children.c
    src_c/set_kernel_version.c
    src_c/freebsd_reapzombie_status.c)
endif (CMAKE_SYSTEM_NAME MATCHES Linux)

set (SWTRPROCMGT_LIB_VERSION_MAJOR 0)
set (SWTRPROCMGT_LIB_VERSION_MINOR 9)
set (SWTRPROCMGT_LIB_VERSION_SUBVERSION 5)
set (SWTRPROCMGT_LIB_VERSION 0.9.5)

set (libsrc_string swtrstrlib/src_c/lremove_char.c
     swtrstrlib/src_c/rremove_char.c
     swtrstrlib/src_c/remove_char.c
    )
set (SWTRSTRLIB_LIB_VERSION_MAJOR 0)
set (SWTRSTRLIB_LIB_VERSION_MINOR 9)
set (SWTRSTRLIB_LIB_VERSION_SUBVERSION 5)
set (SWTRSTRLIB_LIB_VERSION 0.9.5)
if ("swtrstrlib" IN_LIST SWTRLIB_BUILD_LIBS)
message("-- Adding library swtrstrlib to build.")
add_library(swtrstrlib SHARED ${libsrc_string})
add_library(swtrstrlib_static STATIC ${libsrc_string})
set_target_properties(swtrstrlib swtrstrlib_static PROPERTIES VERSION ${SWTRSTRLIB_LIB_VERSION} SOVERSION ${SWTRSTRLIB_LIB_VERSION})
message("-- Adding library swtrstrlib to install.")
install(TARGETS swtrstrlib swtrstrlib_static
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		COMPONENT SWTRSTRLIB
	)
install(FILES swtrstrlib/src_c/swtrstrlib.h DESTINATION include COMPONENT SWTRSTRLIB)
endif ("swtrstrlib" IN_LIST SWTRLIB_BUILD_LIBS)

if (DEFINED SWTRLIB_LIB_INSTALL_ROOT)
  message("-- CMDLINE OVERRIDE INSTALL ROOT: ${SWTRLIB_LIB_INSTALL_ROOT}")
else (DEFINED SWTRLIB_LIB_INSTALL_ROOT)
  set (SWTRLIB_LIB_INSTALL_ROOT ${CMAKE_BINARY_DIR})
endif (DEFINED SWTRLIB_LIB_INSTALL_ROOT )

message("-- INSTALL ROOT: ${SWTRLIB_LIB_INSTALL_ROOT}")

if ("swtrprocmgt" IN_LIST SWTRLIB_BUILD_LIBS)
message("-- Adding library swtrprocmgt to build.")
add_library(swtrprocmgt SHARED ${libsrc})
add_library(swtrprocmgt_static STATIC ${libsrc})
set_target_properties(swtrprocmgt swtrprocmgt_static PROPERTIES VERSION ${SWTRPROCMGT_LIB_VERSION} SOVERSION ${SWTRPROCMGT_LIB_VERSION})
message("-- Adding library swtrprocmgt to install.")
install(TARGETS swtrprocmgt swtrprocmgt_static
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		COMPONENT SWTRPROCLIB
	)
install(FILES src_c/swtrprocmgt.h DESTINATION include COMPONENT SWTRPROCLIB)
endif ("swtrprocmgt" IN_LIST SWTRLIB_BUILD_LIBS)
if (NOT ("${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseLibsOnly;BuildType"))
    set(HEADERS_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/src_c")
    set(HEADERS_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/src_c")
    message("-- moving ${HEADERS_SOURCE_DIR} to ${HEADERS_BUILD_DIR}")
    file(COPY "${HEADERS_SOURCE_DIR}/"
      DESTINATION "${HEADERS_BUILD_DIR}"
      FILES_MATCHING
      PATTERN "*.h")
    message("-- Adding demo programs")
    set(CMAKE_INSTALL_RPATH /opt/${PROJECT_NAME}/lib)
    add_executable(demo_001 src_demo_c/demo_001.c)
    set_target_properties(demo_001 PROPERTIES INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src_c)
    target_link_libraries(demo_001 swtrprocmgt swtrstrlib)
    add_executable(demo_002 src_demo_c/demo_002.c)
    set_target_properties(demo_002 PROPERTIES INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src_c)
    target_link_libraries(demo_002 swtrprocmgt swtrstrlib)
    add_executable(demo_003 src_demo_c/demo_003.c)
    set_target_properties(demo_003 PROPERTIES INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src_c)
    target_link_libraries(demo_003 swtrprocmgt swtrstrlib)
    install(TARGETS demo_001 DESTINATION demo_bin)
    install(TARGETS demo_002 DESTINATION demo_bin)
    install(TARGETS demo_003 DESTINATION demo_bin)
endif (NOT ("${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseLibsOnly;BuildType"))
list(LENGTH SWTRLIB_BUILD_LIBS num_libs)
message("-- num_libs: ${num_libs}")
if (num_libs EQUAL 2)
  if ("${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseLibsOnly;BuildType")
    message("-- project name: ${PROJECT_NAME}")
    string(REPLACE "demo" "" pkg_name "${PROJECT_NAME}")
    set(CPACK_PACKAGE_NAME ${pkg_name})
    set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${pkg_name}")
  else ("${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseLibsOnly;BuildType")
    set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/${PROJECT_NAME}")
  endif ("${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseLibsOnly;BuildType")
endif (num_libs EQUAL 2)

set(CPACK_PACKAGE_VERSION_MAJOR ${SWTRSTRLIB_LIB_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${SWTRSTRLIB_LIB_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${SWTRSTRLIB_LIB_VERSION_SUBVERSION})
set(CPACK_PACKAGE_CONTACT "Eric Bruno <eric@ebruno.org>")
if (OS_NAME MATCHES debian)
  message("-- Configure to build a ${OS_NAME} package.")
  message("-- CMAKE_INSTALL_PREFIX: ${CMAKE_INSTALL_PREFIX}")
  set(CPACK_GENERATOR "DEB")
  list(LENGTH SWTRLIB_BUILD_LIBS num_libs)
  if (num_libs EQUAL 1)
    list(GET SWTRLIB_BUILD_LIBS 0 pkg_name)
    set(CPACK_PACKAGE_NAME ${pkg_name})
  else(num_libs EQUAL 1)
    set (CMAKE_SET_DESTDIR ON)
  endif(num_libs EQUAL 1)
  set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
  set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Eric Bruno <eric@ebruno.org>")
  set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "SoftwareTrace String library")
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Description.txt") # Create this file
  message("-- CPACK_DEBIAN_PACKAGE_MAINTAINER ${CPACK_DEBIAN_PACKAGE_MAINTAINER}")
  list(LENGTH SWTRLIB_BUILD_LIBS num_libs)
  include (CPack)
  set(CPACK_COMPONENTS_ALL "SWTRSTRLIB;SWTRPROCMGT")
  set(CPACK_DEB_COMPONENT_INSTALL ON)
  cpack_add_component(SWTRSTRLIB DISPLAY_NAME "Softwaretrace string library" DESCRIPTION "Softwaretrace string library")
  cpack_add_component(SWTRPROCMGT DISPLAY_NAME "Softwaretrace process management library" DESCRIPTION "Softwaretrace process management library")
endif (OS_NAME MATCHES debian)
if (OS_NAME MATCHES fedora)
  set(CPACK_GENERATOR "RPM")
  set(CPACK_RPM_PACKAGE_ARCHITECTURE "${CMAKE_SYSTEM_PROCESSOR}")
  message("-- Configure to build a ${OS_NAME} package for ${CPACK_RPM_PACKAGE_ARCHITECTURE}.")
  list(GET SWTRLIB_BUILD_LIBS 0 pkg_name)
  if (num_libs EQUAL 1)
  set(CPACK_PACKAGE_NAME ${pkg_name})
  set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/swtr")
else(num_libs EQUAL 1)
  set (CMAKE_SET_DESTDIR ON)
endif(num_libs EQUAL 1)
  set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
  set(CPACK_RPM_PACKAGE_RELEASE_DIST ON)
  set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/Description.txt") # Create this file
  message("-- CPACK_RPM_PACKAGE_MAINTAINER: ${CPACK_RPM_PACKAGE_MAINTAINER}")
  include (CPack)
endif (OS_NAME MATCHES fedora)

add_custom_target(create_doc make -C ${CMAKE_BINARY_DIR} DOCDIR_ROOT=${DOCDIR_ROOT} BASE_DOCDIR=${BASE_DOCDIR} -f ${CMAKE_BINARY_DIR}/Makefile_doc create_doc_c
			     COMMAND make -C ${CMAKE_BINARY_DIR} DOCDIR_ROOT=${DOCDIR_ROOT} BASE_DOCDIR=${BASE_DOCDIR} -f ${CMAKE_BINARY_DIR}/Makefile_doc create_doc_cpp
			     COMMENT "Documentation Generation"
		 )

add_custom_target(dist_clean ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/demo_bin
			     COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/doc
			     COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/SPECS
			     COMMAND rm -f *~ src_c/*~ src_cpp/*~ spec_templates/*~  *.xz *.gz
			     COMMAND rm -f */*.so* */*.a
			     COMMAND rm -f -r ${CMAKE_BINARY_DIR}/CMakeFiles cmake_install.cmake CMakeCache.txt CTestTestfile.cmake Makefile src)

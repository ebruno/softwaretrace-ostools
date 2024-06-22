cmake_minimum_required(VERSION 2.8)
project(swtrprocmgt C)
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
  file(STRINGS "/etc/os-release" OS_RELEASE_INFO REGEX "^NAME=*") 
  message("---- OS_RELEASE_INFO ${OS_RELEASE_INFO}")
  if (OS_RELEASE_INFO MATCHES "NAME=")
    string(REPLACE "\"" "" OS_RELEASE_INFO "${OS_RELEASE_INFO}")
    string(STRIP "${OS_RELEASE_INFO}"  OS_RELEASE_INFO)
    string(SUBSTRING "${OS_RELEASE_INFO}" 5 -1 OS_NAME)
  endif(OS_RELEASE_INFO MATCHES "NAME=")  
else (EXISTS "/etc/os-release")
    set(OS_NAME ${CMAKE_HOST_SYSTEM_NAME})
endif(EXISTS "/etc/os-release")
message("---- OS_NAME '${OS_NAME}'")

message("-- ${CMAKE_BUILD_TYPE}")
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/src_c)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/src_c)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/demo_bin)
set (DOXYGEN_TEMPLATES childmgt)
set (DOCDIR_ROOT ${CMAKE_BINARY_DIR})
set (BASE_DOCDIR doc) 

if (DEFINED SWTRLIB_BUILD_LIBS)
  message("-- CMDLINE OVERRIDE BUILDING LIBS: ${SWTRLIB_BUILD_LIBS}")
else (DEFINED SWTRLIB_BUILD_LIBS)
  set (SWTRLIB_BUILD_LIBS "swtrstrlib swtrprocmgt")
endif (DEFINED SWTRLIB_BUILD_LIBS)

message("-- Building librarys ${SWTRLIB_BUILD_LIBS}")
# The Unix distros have some sight differences that cause compiler warnings.
# Pass the OS_NAME as define so the appropriate adjustments 
# can be made at compile time.
add_definitions(-D${OS_NAME}) 
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

set (libsrc_string src_c/lremove_char.c
     src_c/rremove_char.c
     src_c/remove_char.c
    )
set (SWTRSTRLIB_LIB_VERSION_MAJOR 0)
set (SWTRSTRLIB_LIB_VERSION_MINOR 9)
set (SWTRSTRLIB_LIB_VERSION_SUBVERSION 0)
set (SWTRSTRLIB_LIB_VERSION 0.9.0)
if (DEFINED SWTRLIB_LIB_INSTALL_ROOT)
  message("-- CMDLINE OVERRIDE INSTALL ROOT: ${SWTRLIB_LIB_INSTALL_ROOT}")
else (DEFINED SWTRLIB_LIB_INSTALL_ROOT)
  set (SWTRLIB_LIB_INSTALL_ROOT ${CMAKE_BINARY_DIR})
endif (DEFINED SWTRLIB_LIB_INSTALL_ROOT )
message("-- INSTALL ROOT: ${SWTRLIB_LIB_INSTALL_ROOT}")

if (${SWTRLIB_BUILD_LIBS} MATCHES "swtrstrlib")
message("-- Adding library swtrstrlib to build.")
add_library(swtrstrlib SHARED ${libsrc_string})
add_library(swtrstrlib_static STATIC ${libsrc_string})
set_target_properties(swtrstrlib swtrstrlib_static PROPERTIES VERSION ${SWTRSTRLIB_LIB_VERSION} SOVERSION ${SWTRSTRLIB_LIB_VERSION})
message("-- Adding library swtrstrlib to install.")
install(FILES src_c/swtrstrlib.h DESTINATION ${SWTRLIB_LIB_INSTALL_ROOT}/include)

if (${OS_NAME} MATCHES "Arch Linux")
message("-- Adding License file to install list")
install(FILES LICENSE DESTINATION ${SWTRLIB_LIB_INSTALL_ROOT}/share/licenses/swtrstrlib)
endif (${OS_NAME} MATCHES "Arch Linux")

install(TARGETS swtrstrlib swtrstrlib_static
		LIBRARY DESTINATION ${SWTRLIB_LIB_INSTALL_ROOT}/lib
		ARCHIVE DESTINATION ${SWTRLIB_LIB_INSTALL_ROOT}/lib
	)
endif (${SWTRLIB_BUILD_LIBS} MATCHES "swtrstrlib")

set (SWTRPROCMGT_LIB_VERSION 0.9.0)
if (${SWTRLIB_BUILD_LIBS} MATCHES "swtrprocmgt")
   message("-- Adding library swtrprocmgt to build.")
   add_library(swtrprocmgt SHARED ${libsrc})
   add_library(swtrprocmgt_static STATIC ${libsrc})
   set_target_properties(swtrprocmgt swtrprocmgt_static PROPERTIES VERSION ${SWTRPROCMGT_LIB_VERSION} SOVERSION ${SWTRPROCMGT_LIB_VERSION})
if (CMAKE_SYSTEM_NAME MATCHES FreeBSD)    
   target_link_libraries(swtrprocmgt procstat)
   target_link_libraries(swtrprocmgt_static procstat)
endif (CMAKE_SYSTEM_NAME MATCHES FreeBSD)    
   message("-- Adding library swtrprocmgt to install.")
   install(FILES src_c/swtrpocmgt.h DESTINATION ${SWTRLIB_LIB_INSTALL_ROOT}/include)
   install(TARGETS swtrprocmgt swtrprocmgt_static
   		   LIBRARY DESTINATION ${SWTRLIB_LIB_INSTALL_ROOT}/lib
		  ARCHIVE DESTINATION ${SWTRLIB_LIB_INSTALL_ROOT}/lib
	  )
endif(${SWTRLIB_BUILD_LIBS} MATCHES "swtrprocmgt")

if (NOT ("${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseLibsOnly;BuildType"))
   message("-- Adding demo programs")
   add_executable(demo_001 src_demo_c/demo_001.c)
   set_target_properties(demo_001 PROPERTIES INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src_c)
   target_link_libraries(demo_001 swtrprocmgt swtrstrlib)

   add_executable(demo_002 src_demo_c/demo_002.c)
   set_target_properties(demo_002 PROPERTIES INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src_c)
   target_link_libraries(demo_002 swtrprocmgt swtrstrlib)

if (CMAKE_SYSTEM_NAME MATCHES Linux)
   add_executable(demo_003 src_demo_c/demo_003.c)
   set_target_properties(demo_003 PROPERTIES INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src_c)
   target_link_libraries(demo_003 swtrprocmgt swtrstrlib)
   install(TARGETS demo_001 DESTINATION test_bin)
#   install(TARGETS ${SWTRLIB_BUILD_LIBS} DESTINATION LIBRARY DESTINATION lib INCLUDES DESTINATION include)
endif (CMAKE_SYSTEM_NAME MATCHES Linux)
endif (NOT ("${CMAKE_BUILD_TYPE}" STREQUAL "ReleaseLibsOnly;BuildType"))


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

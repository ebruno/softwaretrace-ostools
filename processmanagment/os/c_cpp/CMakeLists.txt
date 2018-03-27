cmake_minimum_required(VERSION 2.8)
project(swtrprocmgt C)

set(CMAKE_BUILD_TYPE
    "Release"
    "BuildType")
message("-- ${CMAKE_BUILD_TYPE}")
set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/src_c)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/src_c)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/demo_bin)
set (DOXYGEN_TEMPLATES childmgt)
set (DOCDIR_ROOT ${CMAKE_BINARY_DIR})
set (BASE_DOCDIR doc) 
if (CMAKE_BUILD_TYPE MATCHES Debug)
    add_compile_options(-std=c99 ${CMAKE_C_FLAGS_DEBUG})
else (CMAKE_BUILD_TYPE MATCHES Release)
   add_compile_options(-std=c99 -O3)
elseif (CMAKE_BUILD_TYPE MATCHES RelWithDebInfo)
    add_compile_options(-std=c99 -O2 ${CMAKE_C_FLAGS_DEBUG})
endif(CMAKE_BUILD_TYPE MATCHES Debug)

set (libsrc src_c/getmaxpid.c src_c/count_children.c src_c/reapzombie_status.c)
set (SWTRPROCMGT_LIB_VERSION 0.9.0)
add_library(swtrprocmgt SHARED ${libsrc})
add_library(swtrprocmgt_static STATIC ${libsrc})
set_target_properties(swtrprocmgt swtrprocmgt_static PROPERTIES VERSION ${SWTRPROCMGT_LIB_VERSION} SOVERSION ${SWTRPROCMGT_LIB_VERSION})
install(FILES src_c/swtrpocmgt.h DESTINATION ${CMAKE_BINARY_DIR}/include)
install(TARGETS swtrprocmgt swtrprocmgt_static
		LIBRARY DESTINATION ${CMAKE_BINARY_DIR}/lib
		ARCHIVE DESTINATION ${CMAKE_BINARY_DIR}/lib
	)
add_executable(demo_001 src_demo_c/demo_001.c)
set_target_properties(demo_001 PROPERTIES INCLUDE_DIRECTORIES ${CMAKE_BINARY_DIR}/src_c)
target_link_libraries(demo_001 swtrprocmgt)
install(TARGETS swtrprocmgt DESTINATION LIBRARY DESTINATION lib INCLUDES DESTINATION include)
install(TARGETS demo_001 DESTINATION test_bin)


add_custom_target(create_doc make -C ${CMAKE_BINARY_DIR} DOCDIR_ROOT=${DOCDIR_ROOT} BASE_DOCDIR=${BASE_DOCDIR} -f ${CMAKE_BINARY_DIR}/Makefile_doc create_doc_c
			     COMMAND make -C ${CMAKE_BINARY_DIR} DOCDIR_ROOT=${DOCDIR_ROOT} BASE_DOCDIR=${BASE_DOCDIR} -f ${CMAKE_BINARY_DIR}/Makefile_doc create_doc_cpp
			     COMMENT "Documentation Generation"
                 )

add_custom_target(dist_clean ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/demo_bin
			     COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/doc
			     COMMAND rm -f *~ src_c/*~ src_cpp/*~
			     COMMAND rm -f -r ${CMAKE_BINARY_DIR}/CMakeFiles cmake_install.cmake CMakeCache.txt CTestTestfile.cmake Makefile)

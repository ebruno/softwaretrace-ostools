cmake_minimum_required(VERSION 2.8)
project(swtrprocmgt C)

set(CMAKE_BUILD_TYPE
    "Debug"
    "BuildType")

set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/src_c)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/src_c)
add_compile_options(-std=c99 -g)
set (libsrc src_c/count_children.c)
add_library(swtrprocmgt SHARED ${libsrc})
add_library(swtrprocmgt_static STATIC ${libsrc})
install(FILES src_c/swtrpocmgt.h DESTINATION ${CMAKE_BINARY_DIR}/include)
install(TARGETS swtrprocmgt swtrprocmgt_static
		LIBRARY DESTINATION ${CMAKE_BINARY_DIR}/lib
		ARCHIVE DESTINATION ${CMAKE_BINARY_DIR}/lib
	)
enable_testing()
add_executable(test_1 src_c/test_1.c)
target_link_libraries(test_1 swtrprocmgt)
install(TARGETS swtrprocmgt DESTINATION LIBRARY DESTINATION lib INCLUDES DESTINATION include)
install(TARGETS test_1 DESTINATION test_bin)

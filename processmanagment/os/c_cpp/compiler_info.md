|Compiler                  | C macros                            | C++ macros  |
| -------------------------| ------------------------------------| -----------------------------------|
|Clang/LLVM	               | clang -dM -E -x c /dev/null	     | clang++ -dM -E -x c++ /dev/null
|GNU GCC/G++               | gcc   -dM -E -x c /dev/null         | g++     -dM -E -x c++ /dev/null
|Hewlett-Packard C         | aC++	cc    -dM -E -x c /dev/null	 | aCC     -dM -E -x c++ /dev/null
|IBM XL C/C++	           | xlc   -qshowmacros -E /dev/null	 | xlc++   -qshowmacros -E /dev/null
|Intel ICC/ICPC	           | icc   -dM -E -x c /dev/null	     | icpc    -dM -E -x c++ /dev/null
|Oracle Solaris Studio     | cc    -xdumpmacros -E /dev/null	 | CC      -xdumpmacros -E /dev/null	
|Portland Group PGCC/PGCPP | pgcc  -dM -E	                     | N/A

References:

http://nadeausoftware.com/articles/2011/12/c_c_tip_how_list_compiler_predefined_macros

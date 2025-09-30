# Compiler Information #
## Verified Compilers ##
The libraries/tools have been built and verifed using the following compilers:

| Compiler                 | Verfied/Supported  | Operating System                         |
|--------------------------| :-----------------:| -----------------------------------------|
|Clang/LLVM	               | Yes	            | FreeBSD                                  |
|GNU GCC/G++               | Yes                | RHEL, Fedora, Debian, Ubuntu, ArchLinux  | 
|Hewlett-Packard C         | No	                |                                          |
|IBM XL C/C++	           | No                 |                                          |
|Intel ICC/ICPC	           | No                 |                                          |
|Oracle Solaris Studio     | No                 |                                          |
|Portland Group PGCC/PGCPP | No                 |                                          |

## Obtaining Predefined Macros ##
|Compiler                  | C macros                            | C++ macros  |
| -------------------------| ------------------------------------| -----------------------------------|
|Clang/LLVM	               | clang -dM -E -x c /dev/null	     | clang++ -dM -E -x c++ /dev/null
|GNU GCC/G++               | gcc   -dM -E -x c /dev/null         | g++     -dM -E -x c++ /dev/null
|Hewlett-Packard C         | aC++	cc  -dM -E -x c /dev/null	 | aCC     -dM -E -x c++ /dev/null
|IBM XL C/C++	           | xlc   -qshowmacros -E /dev/null	 | xlc++   -qshowmacros -E /dev/null
|Intel ICC/ICPC	           | icc   -dM -E -x c /dev/null	     | icpc    -dM -E -x c++ /dev/null
|Oracle Solaris Studio     | cc    -xdumpmacros -E /dev/null	 | CC      -xdumpmacros -E /dev/null	
|Portland Group PGCC/PGCPP | pgcc  -dM -E	                     | N/A




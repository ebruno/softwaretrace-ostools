# Child Process Management Libraries and Utilities  #

## Background Information ##
When attempting to deal with process management issues developers often take the 'quick approach' and simply use the system command to shell out to command line tools or custom stripts to obtain this type of information.

The Software Engineering Institute (SEI) at Carnegie Mellon University is part of the Computer Emergency Response Team (CERT)
SEI CERT publishes coding standards for various languages (C, C++, Java and Perl). 
The C specification can found here:[SEI CERT C Standard](https://wiki.sei.cmu.edu/confluence/display/c/SEI+CERT+C+Coding+Standard)
The recommendation we are interested in is [ENV33-C. Do not call system](https://wiki.sei.cmu.edu/confluence/pages/viewpage.action?pageId=87152177)

In brief what ENV33-C states is shown below:

> The C Standard system() function executes a specified command by invoking an implementation-defined command processor, 
> such as a UNIX shell or CMD.EXE in Microsoft Windows. The POSIX popen() and Windows _popen() functions also invoke a command 
> processor but create a pipe between the calling program and the executed command, returning a pointer to a stream that can 
> be used to either read from or write to the pipe [IEEE Std 1003.1:2013]. 
> 
> Use of the system() function can result in exploitable vulnerabilities, in the worst case allowing execution of arbitrary system commands. Situations in which calls to system() have high risk include the following: 
> 
>   * When passing an unsanitized or improperly sanitized command string originating from a tainted source
> 
>   * If a command is specified without a path name and the command processor path name resolution mechanism is accessible to an attacker
> 
>   * If a relative path to an executable is specified and control over the current working directory is accessible to an attacker
> 
>   * If the specified executable program can be spoofed by an attacker
> 
> Do not invoke a command processor via system() or equivalent functions to execute a command.

The recommendation ENV33-C is actually applicable to any programming language in an Linux/Unix platform that has a "system" command feature.

The functions in this library allow a developer to obtain the same type of information when API's do not exist to obtain the information.


## Building and Packaging ##
Supported Operating Systems are show below:

 * ArchLinux 4.N
 * Fedora 42.N
 * FreeBSD 14.N
 * RedHat Enterprise Linux 9.N
 * Ubuntu 24.4
 
 Note when building the rpm on Fedora and RHEL
 You will need to set the following environment variable;
 
	
Cmake version 3.20 is the minimum version supported.	
The cmake will create a build environment for the c and c++ versions of the tools.

### Building ###
After checking out the code from github perform the following steps:

    cd softwaretrace-ostools/processmanagment/os/c_cpp
    
	To create build system for the release version enter:
    mkdir build;
	cd build;
	cmake ..<cr>
	-- Using version.mk
	-- Building 0.9.5
	-- OS_NAME 'fedora' CMAKE version 3.20
	-- Loaded cmake version 3.31.6
	-- The C compiler identification is GNU 15.2.1
	-- Detecting C compiler ABI info
	-- Detecting C compiler ABI info - done
	-- Check for working C compiler: /usr/bin/cc - skipped
	-- Detecting C compile features
	-- Detecting C compile features - done
	-- CMAKE_INSTALL_LOCALSTATEDIR
	-- CMAKE_INSTALL_SYSCONFDIR
	-- CMAKE_LIBRARY_PATH
	-- CMAKE_SYSTEM Linux-6.16.7-200.fc42.x86_64
	-- CMAKE_SYSTEM_NAME Linux
	-- CMAKE_HOST_SYSTEM Linux-6.16.7-200.fc42.x86_64
	-- CMAKE_HOST_SYSTEM_NAME Linux
	-- CMAKE_HOST_UNIX 1
	-- CMAKE_BUILD_TYPE: Release CMAKE_BINARY_DIR=/home/ebruno/source/softwaretrace-ostools/processmanagment/os/c_cpp/build
	-- Building libraries swtrprocmgt;swtrstrlib
	-- CMAKE_BUILD_TYPE: Release
	-- Adding compile options for Release;Builds
	-- C Flags:
	-- Adding library swtrstrlib to build.
	-- Adding library swtrstrlib to install.
	-- Adding library swtrprocmgt to build.
	-- Adding compile options for Release;Builds
	-- Adding library swtrprocmgt to install.
	-- moving /home/ebruno/source/softwaretrace-ostools/processmanagment/os/c_cpp/src_c to /home/ebruno/source/softwaretrace-ostools/processmanagment/os/c_cpp/build/src_c
	-- Adding demo programs
	-- CMAKE_INSTALL_DEFAULT_COMPONENT_NAME: applications
	-- num_libs: 2
	-- Configure to build a fedora package for x86_64.
	-- CPACK_RPM_PACKAGE_MAINTAINER: Eric Bruno <eric@ebruno.org>
	-- Configuring done (0.4s)
	-- Generating done (0.1s)
	-- Build files have been written to: /home/ebruno/source/softwaretrace-ostools/processmanagment/os/c_cpp/build

    make<cr>
	[  3%] Building C object CMakeFiles/swtrstrlib.dir/swtrstrlib/src_c/lremove_char.c.o
	[  7%] Building C object CMakeFiles/swtrstrlib.dir/swtrstrlib/src_c/rremove_char.c.o
	[ 10%] Building C object CMakeFiles/swtrstrlib.dir/swtrstrlib/src_c/remove_char.c.o
	[ 14%] Linking C shared library lib/libswtrstrlib.so
	[ 14%] Built target swtrstrlib
	[ 17%] Building C object CMakeFiles/swtrstrlib_static.dir/swtrstrlib/src_c/lremove_char.c.o
	[ 21%] Building C object CMakeFiles/swtrstrlib_static.dir/swtrstrlib/src_c/rremove_char.c.o
	[ 25%] Building C object CMakeFiles/swtrstrlib_static.dir/swtrstrlib/src_c/remove_char.c.o
	[ 28%] Linking C static library lib/libswtrstrlib_static.a
	[ 28%] Built target swtrstrlib_static
	[ 32%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/getmaxpid.c.o
	[ 35%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/init_ctrl.c.o
	[ 39%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/getprocstat.c.o
	[ 42%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/count_children.c.o
	[ 46%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/set_kernel_version.c.o
	[ 50%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/reapzombie_status.c.o
	[ 53%] Linking C shared library lib/libswtrprocmgt.so
	[ 53%] Built target swtrprocmgt
	[ 57%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/getmaxpid.c.o
	[ 60%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/init_ctrl.c.o
	[ 64%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/getprocstat.c.o
	[ 67%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/count_children.c.o
	[ 71%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/set_kernel_version.c.o
	[ 75%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/reapzombie_status.c.o
	[ 78%] Linking C static library lib/libswtrprocmgt_static.a
	[ 78%] Built target swtrprocmgt_static
	[ 82%] Building C object CMakeFiles/demo_001.dir/src_demo_c/demo_001.c.o
	[ 85%] Linking C executable demo_bin/demo_001
	[ 85%] Built target demo_001
	[ 89%] Building C object CMakeFiles/demo_002.dir/src_demo_c/demo_002.c.o
	[ 92%] Linking C executable demo_bin/demo_002
	[ 92%] Built target demo_002
	[ 96%] Building C object CMakeFiles/demo_003.dir/src_demo_c/demo_003.c.o
	[100%] Linking C executable demo_bin/demo_003
	[100%] Built target demo_003
	
To clean up after a build enter make clean, to clean up to a pristine state enter make dist_clean.

### Packaging ###
To build a package use cmake and cpack

    mkdir build
    cd build;
    cmake;
	# On Fedora and RHEL you will need to set this enviroment variable before running cpack 
	# export QA_RPATHS=$(( 0x0001|0x0010|0x0002 ))
	cpack;
	CPack: Create package using RPM
    CPack: Install projects
    CPack: - Run preinstall target for: swtrprocmgtdemo
    CPack: - Install project: swtrprocmgtdemo []
    CPack: Create package
    CPackRPM: Will use GENERATED spec file: /home/ebruno/source/softwaretrace-ostools/processmanagment/os/c_cpp/build/_CPack_Packages/Linux/RPM/SPECS/swtrprocmgtdemo.spec
    CPack: - package: /home/ebruno/source/softwaretrace-ostools/processmanagment/os/c_cpp/build/swtrprocmgtdemo-0.9.5-1.fc42.x86_64.rpm generated.

	rpm -ql -p ./swtrprocmgtdemo-0.9.5-1.fc42.x86_6a4.rpm
	/opt/swtrprocmgtdemo
	/opt/swtrprocmgtdemo/demo_bin
	/opt/swtrprocmgtdemo/demo_bin/demo_001
	/opt/swtrprocmgtdemo/demo_bin/demo_002
	/opt/swtrprocmgtdemo/demo_bin/demo_003
	/opt/swtrprocmgtdemo/include
	/opt/swtrprocmgtdemo/include/swtrprocmgt.h
	/opt/swtrprocmgtdemo/include/swtrstrlib.h
	/opt/swtrprocmgtdemo/lib
	/opt/swtrprocmgtdemo/lib/libswtrprocmgt.so
	/opt/swtrprocmgtdemo/lib/libswtrprocmgt.so.0.9.5
	/opt/swtrprocmgtdemo/lib/libswtrprocmgt_static.a
	/opt/swtrprocmgtdemo/lib/libswtrstrlib.so
	/opt/swtrprocmgtdemo/lib/libswtrstrlib.so.0.9.5
	/opt/swtrprocmgtdemo/lib/libswtrstrlib_static.a	

	rpm -qi -p ./swtrprocmgtdemo-0.9.5-1.fc42.x86_64.rpm
	Name        : swtrprocmgtdemo
	Version     : 0.9.5
	Release     : 1.fc42
	Architecture: x86_64
	Install Date: (not installed)
	Group       : unknown
	Size        : 99349
	License     : BSD
	Signature   : (none)
	Source RPM  : swtrprocmgtdemo-0.9.5-1.fc42.src.rpm
	Build Date  : Mon 29 Sep 2025 02:28:07 PM PDT
	Build Host  : fedorasrv01.sc.brunoe.net
	Relocations : /opt/swtrprocmgtdemo
	Vendor      : Humanity
	URL         : https://github.com/ebruno/softwaretrace-ostools
	Summary     : SoftwareTrace String library
	Description :
	Process Management Demo
	Contains routines to help manage child processes
	Note: count_children and reapzombie status use glob which is thread unsafe.
	MT-Unsafe race:utent env sig:ALRM timer locale

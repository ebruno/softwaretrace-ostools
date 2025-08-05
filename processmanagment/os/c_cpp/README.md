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
	* CentOS 7.N
	* Fedora 27.N
	* FreeBSD 11.N (FreeBSD version 9.N should also work)
	* RedHat Enterprise Linux 7.N
	* Ubuntu 16.N
	
Cmake version 2.8 is the minimum version supported.	
The cmake will create build environment for the c and c++ versions of the tools.
### Building ###
After checking out the code from github perform the following steps:

    cd softwaretrace-ostools/processmanagment/os/c_cpp
    
	To create build system for the release version enter:
    cmake .<cr>
	-- The C compiler identification is GNU 4.8.5

    -- Check for working C compiler: /usr/bin/cc
    -- Check for working C compiler: /usr/bin/cc -- works
    -- Detecting C compiler ABI info
    -- Detecting C compiler ABI info - done
    ---- CMAKE_INSTALL_LOCALSTATEDIR 
    ---- CMAKE_INSTALL_SYSCONFDIR  
    ---- CMAKE_LIBRARY_PATH  
    ---- CMAKE_SYSTEM Linux-3.10.0-693.21.1.el7.x86_64
    ---- CMAKE_SYSTEM_NAME Linux
    ---- CMAKE_HOST_SYSTEM Linux-3.10.0-693.21.1.el7.x86_64
    ---- CMAKE_HOST_SYSTEM_NAME Linux
    ---- CMAKE_HOST_UNIX 1
    ---- OS_RELEASE_INFO NAME="CentOS Linux"
    ---- OS_NAME 'CentOS Linux'
    -- Release;BuildType
    -- Building librarys swtrstrlib swtrprocmgt
    -- INSTALL ROOT: /home/ebruno/softwaretrace-ostools/processmanagment/os/c_cpp
    -- Adding library swtrstrlib to build.
    -- Adding library swtrstrlib to install.
    -- Adding library swtrprocmgt to build.
    -- Adding library swtrprocmgt to install.
    -- Adding demo programs
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /home/ebruno/softwaretrace-ostools/processmanagment/os/c_cpp

    make<cr>
	
    To create build system for the version compile with debuging support enter:
    cmake -DCMAKE_BUILD_TYPE MATCHES:STRING=Debug .<cr>
    make<cr>

    ---- CMAKE_INSTALL_LOCALSTATEDIR 
    ---- CMAKE_INSTALL_SYSCONFDIR  
    ---- CMAKE_LIBRARY_PATH  
    ---- CMAKE_SYSTEM Linux-3.10.0-693.21.1.el7.x86_64
    ---- CMAKE_SYSTEM_NAME Linux
    ---- CMAKE_HOST_SYSTEM Linux-3.10.0-693.21.1.el7.x86_64
    ---- CMAKE_HOST_SYSTEM_NAME Linux
    ---- CMAKE_HOST_UNIX 1
    ---- OS_RELEASE_INFO NAME="CentOS Linux"
    ---- OS_NAME 'CentOS Linux'
    -- Debug
    -- Building librarys swtrstrlib swtrprocmgt
    -- INSTALL ROOT: /home/ebruno/softwaretrace-ostools/processmanagment/os/c_cpp
    -- Adding library swtrstrlib to build.
    -- Adding library swtrstrlib to install.
    -- Adding library swtrprocmgt to build.
    -- Adding library swtrprocmgt to install.
    -- Adding demo programs
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /home/ebruno/softwaretrace-ostools/processmanagment/os/c_cpp

	Sample Build output:
	Scanning dependencies of target swtrprocmgt

    [  4%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/getmaxpid.c.o
    [  9%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/init_ctrl.c.o
    [ 14%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/getprocstat.c.o
    [ 19%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/count_children.c.o
    [ 23%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/set_kernel_version.c.o
    [ 28%] Building C object CMakeFiles/swtrprocmgt.dir/src_c/reapzombie_status.c.o
    Linking C shared library src_c/libswtrprocmgt.so
    [ 28%] Built target swtrprocmgt
    Scanning dependencies of target swtrstrlib
    [ 33%] Building C object CMakeFiles/swtrstrlib.dir/src_c/lremove_char.c.o
    [ 38%] Building C object CMakeFiles/swtrstrlib.dir/src_c/rremove_char.c.o
    [ 42%] Building C object CMakeFiles/swtrstrlib.dir/src_c/remove_char.c.o
    Linking C shared library src_c/libswtrstrlib.so
    [ 42%] Built target swtrstrlib
    Scanning dependencies of target demo_001
    [ 47%] Building C object CMakeFiles/demo_001.dir/src_demo_c/demo_001.c.o
    Linking C executable demo_bin/demo_001
    [ 47%] Built target demo_001
    Scanning dependencies of target demo_002
    [ 52%] Building C object CMakeFiles/demo_002.dir/src_demo_c/demo_002.c.o
    Linking C executable demo_bin/demo_002
    [ 52%] Built target demo_002
    Scanning dependencies of target demo_003
    [ 57%] Building C object CMakeFiles/demo_003.dir/src_demo_c/demo_003.c.o
    Linking C executable demo_bin/demo_003
    [ 57%] Built target demo_003
    Scanning dependencies of target swtrprocmgt_static
    [ 61%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/getmaxpid.c.o
    [ 66%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/init_ctrl.c.o
    [ 71%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/getprocstat.c.o
    [ 76%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/count_children.c.o
    [ 80%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/set_kernel_version.c.o
    [ 85%] Building C object CMakeFiles/swtrprocmgt_static.dir/src_c/reapzombie_status.c.o
    Linking C static library src_c/libswtrprocmgt_static.a
    [ 85%] Built target swtrprocmgt_static
    Scanning dependencies of target swtrstrlib_static
    [ 90%] Building C object CMakeFiles/swtrstrlib_static.dir/src_c/lremove_char.c.o
    [ 95%] Building C object CMakeFiles/swtrstrlib_static.dir/src_c/rremove_char.c.o
    [100%] Building C object CMakeFiles/swtrstrlib_static.dir/src_c/remove_char.c.o
    Linking C static library src_c/libswtrstrlib_static.a
    [100%] Built target swtrstrlib_static

To clean up after a build enter make clean, to clean up to a pristine state enter make dist_clean.

### Packaging ###
To build a package use the make file Makefile_packages
cmake will be run as part of package creation process.

    make -f Makefile_packages <rule name> 
    For example if specify the ArchLinux rule on CentOS the following will be displayed:
	[user@system c_cpp]$ make -f Makefile_packages swtrstrlib_create_distro

	Checking to see if OS/Distro ""CentOS Linux"" is supported
	OS/Distro ""CentOS Linux"" is supported, continuing.
	make: *** No rule to make target `swtrstrlib_create_distro'.  Stop.

Note rules only work on stated operating system.

| Operation System       | packaging rule name       |
|------------------------|---------------------------|
| RHEL,CentOS, Fedora    | swtrstrlib_create_rpm, swtrprocmgtutilslib_create_rpm    |
| Ubuntu                 | swtrstrlib_create_pkg, swtrprocmgtutilslib_create_pkg    |
| ArchLinux              | swtrstrlib_create_distro, swtrprocmgtutils_create_distro |
| FreeBSD                | \todo Provide packaging for FreeBSD                      

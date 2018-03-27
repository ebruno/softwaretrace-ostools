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

The functions in this library allow a developer to option the same type of information when API's do not exist to obtain the information.





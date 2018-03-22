# Child Process Management Libraries and Utilities  #

## Background Information ##

With the advent of threaded programes the possibility of creating zombie processes increases. When a process is created in UNIX using the fork() system call, the address space of the parent process is replicated. The parent process has the option waiting for the child process to complete using the wait system call. When wait is called the execution of the parent is susspended until the child terminates. When the child terminates a 'SIGCHLD' signal is generated and delivered to the parent by the kernel. The parent process on receipt of the 'SIGCHLD' reaps the status of the child from the process table. In order to check asyncronously the waitpid system call is used. 

When the child is terminates, there is an entry in the process table corresponding to the child where the status is stored until the parent process collects the status.  Until the parent process reads the child process exit status the child process entry remains in this state is called the zombie state.  A process who's parent has not reaped it's exit status is a zombie process.


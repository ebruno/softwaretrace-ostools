# Child Process Management #
## Linux ##
When a process is created in UNIX using the fork() system call, the address space of the Parent process is replicated. 
If the parent process calls wait() system call, then the execution of parent is suspended until the child is terminated. 
At the termination of the child, a ‘SIGCHLD’ signal is generated which is delivered to the parent by the kernel. 
Parent, on receipt of ‘SIGCHLD’ reaps the status of the child from the process table. Even though, the child is terminated, 
there is an entry in the process table corresponding to the child where the status is stored. When parent collects the status, 
this entry is deleted. Thus, all the traces of the child process are removed from the system. If the parent decides not to 
wait for the child’s termination and it executes its subsequent task, then at the termination of the child, the exit status 
is not read. Hence, there remains an entry in the process table even after the termination of the child. 
This state of the child process is known as the Zombie state. 


### Zombie/Defunct Processes ###
With the advent of threaded programes the possibility of creating zombie processes increases. When a process is created in UNIX using the fork() system call, the address space of the parent process is replicated. The parent process has the option waiting for the child process to complete using the wait system call. When wait is called the execution of the parent is susspended until the child terminates. When the child terminates a 'SIGCHLD' signal is generated and delivered to the parent by the kernel. The parent process on receipt of the 'SIGCHLD' reaps the status of the child from the process table. In order to check asyncronously the waitpid system call is used. 

When the child is terminates, there is an entry in the process table corresponding to the child where the status is stored until the parent process collects the status.  Until the parent process reads the child process exit status the child process entry remains in this state is called the zombie state.  A process who's parent has not reaped it's exit status is a zombie process.

The following shell commands can be used to determine the zombie/defunct processes associated with process:
<kbd>ps -aef | grep &lt;pid&gt; | grep defunct&lt;cr&gt;</kbd>

	ebruno    13178  13177  0 18:09 pts/1    00:00:00 [demo_001] <defunct>
	ebruno    13179  13177  0 18:09 pts/1    00:00:00 [demo_001] <defunct>
	ebruno    13180  13177  0 18:09 pts/1    00:00:00 [demo_001] <defunct>
	ebruno    13181  13177  0 18:09 pts/1    00:00:00 [demo_001] <defunct>
	ebruno    13182  13177  0 18:09 pts/1    00:00:00 [demo_001] <defunct>

To just get the child pid's:
<kbd>ps -aef | grep &lt;pid&gt; | grep defunct | awk '{print $2}'&lt;cr&gt;</kbd>

	13178
	13179
	13180
	13181
	13182


So the question is how can we get the same information, the standard API's available do not provide a way to get this information. 
Linux systems have the procfs, the information needed exists in this file system.

The ps program actually used the proc file system. It uses the file /proc/&lt;pid&gt;/stat a sample of information in this file is shown below:
The fields of interest to finding a processes children and the state of the child are fields 1, 3 and 4.  The pid, state and ppid fields.

    351 (scsi_eh_5) S 2 0 0 0 -1 2138176 0 0 0 0 0 0 0 0 20 0 1 0 1271 0 0 18446744073709551615 0 0 0 0 0 0 0 2147483647 0 18446744073709551615 0 0 17 3 0 0 0 0 0 0 0 0 0 0 0 0 0

From the procfs man page:

The fields, in order, with their proper scanf(3) format specifiers, are:

  * pid %d      (1) The process ID.

  * comm %s     (2) The filename of the executable, in parentheses.  This is visible whether or not the executable is swapped out.

  * state %c    (3)  One  character  from  the string "RSDZTW" where R is running, S is sleeping in an interruptible wait, D is waiting in
            uninterruptible disk sleep, Z is zombie, T is traced or stopped (on a signal), and W is paging.
    
  * ppid %d     (4) The PID of the parent.
  
  * pgrp %d     (5) The process group ID of the process.

  * session %d  (6) The session ID of the process.

  * tty_nr %d   (7) The controlling terminal of the process.  (The minor device number is contained in the combination of bits  31  to  20
            and 7 to 0; the major device number is in bits 15 to 8.)

  *  tpgid %d    (8) The ID of the foreground process group of the controlling terminal of the process.

  *  flags %u (%lu before Linux 2.6.22)
            (9)  The  kernel  flags  word  of  the  process.   For  bit meanings, see the PF_* defines in the Linux kernel source file
            include/linux/sched.h.  Details depend on the kernel version.

  *  minflt %lu  (10) The number of minor faults the process has made which have not required loading a memory page from disk.

  *  cminflt %lu (11) The number of minor faults that the process's waited-for children have made.

  *  majflt %lu  (12) The number of major faults the process has made which have required loading a memory page from disk.

  *  cmajflt %lu (13) The number of major faults that the process's waited-for children have made.

  *  utime %lu   (14) Amount  of  time  that  this  process  has  been  scheduled  in  user  mode,  measured  in  clock  ticks  (divide  by
            sysconf(_SC_CLK_TCK)).  This includes guest time, guest_time (time spent running a virtual CPU, see below), so that appli‐
            cations that are not aware of the guest time field do not lose that time from their calculations.

  *  stime %lu   (15) Amount of time  that  this  process  has  been  scheduled  in  kernel  mode,  measured  in  clock  ticks  (divide  by
            sysconf(_SC_CLK_TCK)).

  *  cutime %ld  (16)  Amount  of  time  that  this process's waited-for children have been scheduled in user mode, measured in clock ticks
            (divide by sysconf(_SC_CLK_TCK)).  (See also times(2).)  This includes guest time, cguest_time (time spent running a  vir‐
            tual CPU, see below).

  *  cstime %ld  (17)  Amount  of  time that this process's waited-for children have been scheduled in kernel mode, measured in clock ticks
            (divide by sysconf(_SC_CLK_TCK)).

  *  priority %ld
            (18) (Explanation for Linux 2.6) For processes running a real-time scheduling policy (policy  below;  see  sched_setsched‐
            uler(2)),  this is the negated scheduling priority, minus one; that is, a number in the range -2 to -100, corresponding to
            real-time priorities 1 to 99.  For processes running under a non-real-time scheduling policy, this is the raw  nice  value
            (setpriority(2))  as  represented  in  the  kernel.   The kernel stores nice values as numbers in the range 0 (high) to 39
            (low), corresponding to the user-visible nice range of -20 to 19. Before Linux 2.6, this was a scaled value based on the scheduler weighting given to this process.

  *  nice %ld (19) The nice value (see setpriority(2)), a value in the range 19 (low priority) to -20 (high priority).
  *  num_threads %ld
            (20) Number of threads in this process (since Linux 2.6).  Before kernel 2.6, this field was hard coded to 0 as  a  place‐
            holder for an earlier removed field.
  *  itrealvalue %ld
            (21)  The  time  in jiffies before the next SIGALRM is sent to the process due to an interval timer.  Since kernel 2.6.17,
            this field is no longer maintained, and is hard coded as 0.
  *  starttime %llu (was %lu before Linux 2.6)
            (22) The time the process started after system boot.  In kernels before Linux 2.6, this value was  expressed  in  jiffies.
            Since Linux 2.6, the value is expressed in clock ticks (divide by sysconf(_SC_CLK_TCK)).
  *  vsize %lu   (23) Virtual memory size in bytes.

  *  rss %ld     (24)  Resident  Set Size: number of pages the process has in real memory.  This is just the pages which count toward text,
             data, or stack space.  This does not include pages which have not been demand-loaded in, or which are swapped out.
  
  *  rsslim %lu  (25) Current soft limit in bytes on the rss of the process; see the description of RLIMIT_RSS in getrlimit(2).
   
  *  startcode %lu (26) The address above which program text can run.
   
  *  endcode %lu (27) The address below which program text can run.
  
  *  startstack %lu (28) The address of the start (i.e., bottom) of the stack.
   
  *  kstkesp %lu (29) The current value of ESP (stack pointer), as found in the kernel stack page for the process.

  *  kstkeip %lu (30) The current EIP (instruction pointer).
   
  *  signal %lu  (31) The bitmap of pending signals, displayed as a decimal number.  Obsolete, because it does not provide  information  on
             real-time signals; use /proc/[pid]/status instead.
   
  *  blocked %lu (32)  The  bitmap of blocked signals, displayed as a decimal number.  Obsolete, because it does not provide information on
            real-time signals; use /proc/[pid]/status instead.
   
  *  sigignore %lu (33) The bitmap of ignored signals, displayed as a decimal number.  Obsolete, because it does not provide  information  on
             real-time signals; use /proc/[pid]/status instead.
  *  sigcatch %lu (34)  The  bitmap  of caught signals, displayed as a decimal number.  Obsolete, because it does not provide information on
            real-time signals; use /proc/[pid]/status instead.
  *  wchan %lu   (35) This is the "channel" in which the process is waiting.  It is the address of a system call, and can be looked up in a
            namelist if you need a textual name.  (If you have an up-to-date /etc/psdatabase, then try ps -l to see the WCHAN field in
            action.)
  *  nswap %lu   (36) Number of pages swapped (not maintained).
  *  cnswap %lu  (37) Cumulative nswap for child processes (not maintained).
  *  exit_signal %d (since Linux 2.1.22)
            (38) Signal to be sent to parent when we die.
  *  processor %d (since Linux 2.2.8)
            (39) CPU number last executed on.
  *  rt_priority %u (since Linux 2.5.19; was %lu before Linux 2.6.22) (40) Real-time scheduling priority, a number in the range 1 to 99 for processes scheduled under a real-time policy, or  0,
            for non-real-time processes (see sched_setscheduler(2)).
  *  policy %u (since Linux 2.5.19; was %lu before Linux 2.6.22) (41) Scheduling policy (see sched_setscheduler(2)).  Decode using the SCHED_* constants in linux/sched.h.
  *  delayacct_blkio_ticks %llu (since Linux 2.6.18) (42) Aggregated block I/O delays, measured in clock ticks (centiseconds).
  *  guest_time %lu (since Linux 2.6.24) (43)  Guest  time  of the process (time spent running a virtual CPU for a guest operating system), measured in clock ticks (divide by sysconf(_SC_CLK_TCK)).	   
  *  cguest_time %ld (since Linux 2.6.24) (44) Guest time of the process's children, measured in clock ticks (divide by sysconf(_SC_CLK_TCK)).
  *  start_data %lu (since Linux 3.3) (45) Address above which program data+bss is placed.
  *  end_data %lu (since Linux 3.3) (46) Address below which program data+bss is placed.
  *  start_brk %lu (since Linux 3.3) (47) Address above which program heap can be expanded with brk().
  *  arg_start %lu (since Linux 3.5) (48) Address above which program command line is placed.
  *  arg_end %lu (since Linux 3.5) (49) Address below which program command line is placed.
  *  env_start %lu (since Linux 3.5) (50) Address above which program environment is placed.
  *  env_end %lu (since Linux 3.5) (51) Address below which program environment is placed.
  *  exit_code %d (since Linux 3.5) (52) The thread's exit_code in the form reported by the waitpid system.


pid_t waitpid(pid_t pid, int *status, int options);

int waitid(idtype_t idtype, id_t id, siginfo_t *infop, int options);

Feature Test Macro Requirements for glibc (see feature_test_macros(7)):

waitid():
    SVID_SOURCE || _XOPEN_SOURCE &gt;= 500 || _XOPEN_SOURCE && _XOPEN_SOURCE_EXTENDED || /* Since glibc 2.12: */ _POSIX_C_SOURCE >= 200809L


## FreeBSD ##
FreeBSD does not have the /proc file system as standard feature. However the procstat library is available. Which provides the same information.

From the man page:

The libprocstat library contains the API for runtime file and process information retrieval from	the running kernel via the sysctl(3) library
backend, and for post-mortem analysis via the kvm(3) library backend, or from the process core(5) file, searching for statistics in	special	elf(3) note sections.

For more detail see [FreeBSD libprocstat man page](https://www.freebsd.org/cgi/man.cgi?query=libprocstat&sektion=3&apropos=0&manpath=FreeBSD%2010.0-RELEASE "FreeBSD libprocstat")

From [FreeBSD user.h source code](https://github.com/freebsd/freebsd/blob/master/sys/sys/user.h)

For child processes and zombies/defunct processing the fields that are of interest are 
``` ki_pid, ki_ppid and ki_stat. 
```
The structure returned is shown below:

```
struct kinfo_proc {
	int	ki_structsize;		/* size of this structure */
	int	ki_layout;		/* reserved: layout identifier */
	struct	pargs *ki_args;		/* address of command arguments */
	struct	proc *ki_paddr;		/* address of proc */
	struct	user *ki_addr;		/* kernel virtual addr of u-area */
	struct	vnode *ki_tracep;	/* pointer to trace file */
	struct	vnode *ki_textvp;	/* pointer to executable file */
	struct	filedesc *ki_fd;	/* pointer to open file info */
	struct	vmspace *ki_vmspace;	/* pointer to kernel vmspace struct */
	void	*ki_wchan;		/* sleep address */
	pid_t	ki_pid;			/* Process identifier */
	pid_t	ki_ppid;		/* parent process id */
	pid_t	ki_pgid;		/* process group id */
	pid_t	ki_tpgid;		/* tty process group id */
	pid_t	ki_sid;			/* Process session ID */
	pid_t	ki_tsid;		/* Terminal session ID */
	short	ki_jobc;		/* job control counter */
	short	ki_spare_short1;	/* unused (just here for alignment) */
	uint32_t ki_tdev_freebsd11;	/* controlling tty dev */
	sigset_t ki_siglist;		/* Signals arrived but not delivered */
	sigset_t ki_sigmask;		/* Current signal mask */
	sigset_t ki_sigignore;		/* Signals being ignored */
	sigset_t ki_sigcatch;		/* Signals being caught by user */
	uid_t	ki_uid;			/* effective user id */
	uid_t	ki_ruid;		/* Real user id */
	uid_t	ki_svuid;		/* Saved effective user id */
	gid_t	ki_rgid;		/* Real group id */
	gid_t	ki_svgid;		/* Saved effective group id */
	short	ki_ngroups;		/* number of groups */
	short	ki_spare_short2;	/* unused (just here for alignment) */
	gid_t	ki_groups[KI_NGROUPS];	/* groups */
	vm_size_t ki_size;		/* virtual size */
	segsz_t ki_rssize;		/* current resident set size in pages */
	segsz_t ki_swrss;		/* resident set size before last swap */
	segsz_t ki_tsize;		/* text size (pages) XXX */
	segsz_t ki_dsize;		/* data size (pages) XXX */
	segsz_t ki_ssize;		/* stack size (pages) */
	u_short	ki_xstat;		/* Exit status for wait & stop signal */
	u_short	ki_acflag;		/* Accounting flags */
	fixpt_t	ki_pctcpu;	 	/* %cpu for process during ki_swtime */
	u_int	ki_estcpu;	 	/* Time averaged value of ki_cpticks */
	u_int	ki_slptime;	 	/* Time since last blocked */
	u_int	ki_swtime;	 	/* Time swapped in or out */
	u_int	ki_cow;			/* number of copy-on-write faults */
	u_int64_t ki_runtime;		/* Real time in microsec */
	struct	timeval ki_start;	/* starting time */
	struct	timeval ki_childtime;	/* time used by process children */
	long	ki_flag;		/* P_* flags */
	long	ki_kiflag;		/* KI_* flags (below) */
	int	ki_traceflag;		/* Kernel trace points */
	char	ki_stat;		/* S* process status */
	signed char ki_nice;		/* Process "nice" value */
	char	ki_lock;		/* Process lock (prevent swap) count */
	char	ki_rqindex;		/* Run queue index */
	u_char	ki_oncpu_old;		/* Which cpu we are on (legacy) */
	u_char	ki_lastcpu_old;		/* Last cpu we were on (legacy) */
	char	ki_tdname[TDNAMLEN+1];	/* thread name */
	char	ki_wmesg[WMESGLEN+1];	/* wchan message */
	char	ki_login[LOGNAMELEN+1];	/* setlogin name */
	char	ki_lockname[LOCKNAMELEN+1]; /* lock name */
	char	ki_comm[COMMLEN+1];	/* command name */
	char	ki_emul[KI_EMULNAMELEN+1];  /* emulation name */
	char	ki_loginclass[LOGINCLASSLEN+1]; /* login class */
	char	ki_moretdname[MAXCOMLEN-TDNAMLEN+1];	/* more thread name */
	/*
	 * When adding new variables, take space for char-strings from the
	 * front of ki_sparestrings, and ints from the end of ki_spareints.
	 * That way the spare room from both arrays will remain contiguous.
	 */
	char	ki_sparestrings[46];	/* spare string space */
	int	ki_spareints[KI_NSPARE_INT];	/* spare room for growth */
	uint64_t ki_tdev;		/* controlling tty dev */
	int	ki_oncpu;		/* Which cpu we are on */
	int	ki_lastcpu;		/* Last cpu we were on */
	int	ki_tracer;		/* Pid of tracing process */
	int	ki_flag2;		/* P2_* flags */
	int	ki_fibnum;		/* Default FIB number */
	u_int	ki_cr_flags;		/* Credential flags */
	int	ki_jid;			/* Process jail ID */
	int	ki_numthreads;		/* XXXKSE number of threads in total */
	lwpid_t	ki_tid;			/* XXXKSE thread id */
	struct	priority ki_pri;	/* process priority */
	struct	rusage ki_rusage;	/* process rusage statistics */
	/* XXX - most fields in ki_rusage_ch are not (yet) filled in */
	struct	rusage ki_rusage_ch;	/* rusage of children processes */
	struct	pcb *ki_pcb;		/* kernel virtual addr of pcb */
	void	*ki_kstack;		/* kernel virtual addr of stack */
	void	*ki_udata;		/* User convenience pointer */
	struct	thread *ki_tdaddr;	/* address of thread */
	/*
	 * When adding new variables, take space for pointers from the
	 * front of ki_spareptrs, and longs from the end of ki_sparelongs.
	 * That way the spare room from both arrays will remain contiguous.
	 */
	void	*ki_spareptrs[KI_NSPARE_PTR];	/* spare room for growth */
	long	ki_sparelongs[KI_NSPARE_LONG];	/* spare room for growth */
	long	ki_sflag;		/* PS_* flags */
	long	ki_tdflags;		/* XXXKSE kthread flag */
}; 
```

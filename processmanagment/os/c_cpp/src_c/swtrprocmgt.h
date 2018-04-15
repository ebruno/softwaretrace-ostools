/*!
  \file
  \brief Softwaretrace process management header file.
 */

#if !defined (__SWTRPROCMGT_H__)
#define __SWTRPROCMGT_H__
#include <sys/types.h>

#include <stdbool.h>

#include "swtrcommon.h"
#if defined (__FreeBSD__)
#include <sys/proc.h>
#endif


#ifdef __cplusplus
extern "C" {
#endif
  /*! \name Process Status
      @{
   */
#if defined (__linux__)

#define SWTRPOCMGT_RUNNING_C 'R'              /**< \brief Running */
#define SWTRPOCMGT_ZOMBIE_C  'Z'              /**< \brief Zombie/defunct */
#define SWTRPOCMGT_SLEEPING_C  'S'            /**< \brief Sleeping */
#define SWTRPOCMGT_UNINTEREDISKSLEEP_C  'D'   /**< \brief Uniterruptable Disk Sleep */
#define SWTRPOCMGT_TRACE_STOPPED_C  'T'       /**< \brief Trace/Stopped */
#define SWTRPOCMGT_PAGING_C  'W'              /**< \brief Paging */
#elif defined (__FreeBSD__)
#define SWTRPOCMGT_RUNNING_C SIDL                           /**< \brief Running */
#define SWTRPOCMGT_ZOMBIE_C  SZOMB                          /**< \brief Zombie/defunct */
#define SWTRPOCMGT_SLEEPING_C  SSLEEP                       /**< \brief Sleeping */
#define SWTRPOCMGT_PROCESS_BEING_CREATED_BY_FORK_C SIDL     /**< \brief Uniterruptable Disk Sleep */
#define SWTRPOCMGT_TRACE_STOPPED_C  SSTOP                   /**< \brief Trace/Stopped */
#define SWTRPOCMGT_WAITING_FOR_INTERRUPT_C  SWAIT           /**< \brief waiting for interrupt. */
#define SWTRPOCMGT_BLOCKED_ON_LOCK_C SLOCK                  /**< \brief blocked on a lock. */
#else
  #error "Operating System currently not supported."
#endif
  /*!
    @}
   */
  /*! C String Terminator. */
#define SWTRPOCMGT_STRING_TERMINATOR_C '\0'
#define SWTRPOCMGT_KERNEL_MAJOR_V3 3
#define SWTRPOCMGT_KERNEL_MAJOR_V2 2
#define SWTRPOCMGT_KERNEL_MINOR_V3 3
#define SWTRPOCMGT_KERNEL_MINOR_V4 4
#define SWTRPOCMGT_KERNEL_MINOR_V5 5
#define SWTRPOCMGT_KERNEL_MINOR_V6 6

  /*! Maximum work buf size. */
#define SWTRPOCMGT_MAX_WRKBUF  1024
#define SWTRPCCMGT_STRUCT_V1 1
#define SWTRPCCMGT_STRUCT_V2 2
#define SWTPROC_STAT_INFO_V1 1
#define SWTPROC_STAT_INFO_V2 2
#define SWTPROC_STAT_INFO_CURRENT SWTPROC_STAT_INFO_V1

#if defined(__linux__)
#define SWTRPCCMGT_PROCFS_ROOT "/proc"
#elif defined(__FreeBSD__)
#define SWTRPCCMGT_PROCFS_ROOT ""
#else
#error "Operating System is currently not supported."
#endif   
/*! Max length of the comm field
 This value needs to be >= TASK_COMM_LEN in linux/sched.h 
*/
#define SWTRPCCMGT_TASK_COMM_LEN 32	

  /*! Format string for parsing the stat record. Pre Kernel V3.3 */    
#define SWTRPOCMGT_STAT_FMT_PRE_KV33 "%d %s %c %d %d %d %d %d %u %lu %lu %lu %lu %lu %lu %ld %ld %ld %ld %ld %ld %llu %lu %ld %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %d %d %u %u %llu %lu %ld"
  /* Additional Fields Linux 3.3 */
#define SWTRPOCMGT_STAT_FMT_KV33_EXTRA "%lu %lu %lu"
#define SWTRPOCMGT_STAT_FMT_KV35_EXTRA "%lu %lu %lu %lu %d"
  /*! Format string for parsing the stat record. Kernel V3.3 and higher. */    
#define SWTRPOCMGT_STAT_FMT_KV33 "%d %s %c %d %d %d %d %d %u %lu %lu %lu %lu %lu %lu %ld %ld %ld %ld %ld %ld %llu %lu %ld %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %d %d %u %u %llu %lu %ld %lu %lu %lu" 
  /*! Format string for parsing the stat record. Kernel V3.5 and higher. */

#define SWTRPOCMGT_STAT_FMT "%d %s %c %d %d %d %d %d %u %lu %lu %lu %lu %lu %lu %ld %ld %ld %ld %ld %ld %llu %lu %ld %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %d %d %u %u %llu %lu %ld %lu %lu %lu %lu %lu %lu %lu %d" 
  /*! Dummy state to get all child processes */
#define SWTRPROCMG_ALL_STATES 'A'
  /*! Small work buf size. */
#define SWTRPOCMGT_SMALL_WRKBUF  64
  /*! PID Field ID */
#define SWTRPOCMGT_FIELD_PID 1
#define SWTRPOCMGT_FIELD_FILENAME 2
#define SWTRPOCMGT_FIELD_STATE 3
  /*! PPID Field ID */
#define SWTRPOCMGT_FIELD_PPID 4
#define SWTRPOCMGT_FIELD_PROCESS_GROUP 5
#define SWTRPOCMGT_DEFAULT_MAX_PID 65536
#define SWTRPCCMGT_DEFAULT_REALLOC_UNIT_SIZE 10
  /*! Function/Operation succeeded. */
#define SWTRPCCMGT_SUCCESS 0
  /*! Function/Operation failed. */
#define SWTRPCCMGT_FAILURE -1
#define SWTRPCCMGT_STRUCT_CURRENT_VERSION 1


  typedef struct SWTPROC_STAT_INFO {
  int version_id;
  int kernel_major;
  int kernel_minor;
  int kernel_subversion;
  union {
  struct {
  pid_t pid;
  char comm[SWTRPCCMGT_TASK_COMM_LEN+1];
  char state;
  pid_t ppid;
  pid_t pgrp;
  int session;
  int tty_nr;
  int tpgid;
  unsigned int flags;
  unsigned long minflt;
  unsigned long cminflt; 
  unsigned long majflt;
  unsigned long cmajflt;
  unsigned long utime;
  unsigned long stime;
  long cutime;
  long cstime;
  long priority;
  long nice;
  long num_threads;
  long itrealvalue;
  unsigned long long starttime;
  unsigned long vsize;
  long rss;
  unsigned long rsslim;
  unsigned long startcode;
  unsigned long endcode;
  unsigned long startstack;
  unsigned long kstkesp;
  unsigned long kstkeip;
  unsigned long signal;
  unsigned long blocked;
  unsigned long sigignore;
  unsigned long sigcatch;
  unsigned long wchan;
  unsigned long nswap;
  unsigned long cnswap;
  long exit_signal;
  long processor;
  unsigned rt_priority;
  unsigned policy;
  unsigned long long delayacct_blkio_ticks;
  unsigned long guest_time;
  unsigned long cguest_time;
 } kernel_2_6;
  struct {
  pid_t pid;
  char comm[SWTRPCCMGT_TASK_COMM_LEN+1];
  char state;
  pid_t ppid;
  pid_t pgrp;
  int session;
  int tty_nr;
  int tpgid;
  unsigned int flags;
  unsigned long minflt;
  unsigned long cminflt; 
  unsigned long majflt;
  unsigned long cmajflt;
  unsigned long utime;
  unsigned long stime;
  long cutime;
  long cstime;
  long priority;
  long nice;
  long num_threads;
  long itrealvalue;
  unsigned long long starttime;
  unsigned long vsize;
  long rss;
  unsigned long rsslim;
  unsigned long startcode;
  unsigned long endcode;
  unsigned long startstack;
  unsigned long kstkesp;
  unsigned long kstkeip;
  unsigned long signal;
  unsigned long blocked;
  unsigned long sigignore;
  unsigned long sigcatch;
  unsigned long wchan;
  unsigned long nswap;
  unsigned long cnswap;
  long exit_signal;
  long processor;
  unsigned rt_priority;
  unsigned policy;
  unsigned long long delayacct_blkio_ticks;
  unsigned long guest_time;
  unsigned long cguest_time;
  unsigned long start_data;
  unsigned long end_data;
  unsigned long start_brk;
} kernel_3_3;
  struct  {
  pid_t pid;
  char comm[SWTRPCCMGT_TASK_COMM_LEN+1];
  char state;
  pid_t ppid;
  pid_t pgrp;
  int session;
  int tty_nr;
  int tpgid;
  unsigned int flags;
  unsigned long minflt;
  unsigned long cminflt; 
  unsigned long majflt;
  unsigned long cmajflt;
  unsigned long utime;
  unsigned long stime;
  long cutime;
  long cstime;
  long priority;
  long nice;
  long num_threads;
  long itrealvalue;
  unsigned long long starttime;
  unsigned long vsize;
  long rss;
  unsigned long rsslim;
  unsigned long startcode;
  unsigned long endcode;
  unsigned long startstack;
  unsigned long kstkesp;
  unsigned long kstkeip;
  unsigned long signal;
  unsigned long blocked;
  unsigned long sigignore;
  unsigned long sigcatch;
  unsigned long wchan;
  unsigned long nswap;
  unsigned long cnswap;
  long exit_signal;
  long processor;
  unsigned rt_priority;
  unsigned policy;
  unsigned long long delayacct_blkio_ticks;
  unsigned long guest_time;
  unsigned long cguest_time;
  unsigned long start_data;
  unsigned long end_data;
  unsigned long start_brk;
  unsigned long arg_start;
  unsigned long arg_end;
  unsigned long env_start;
  unsigned long env_end;
  int exit_code;
     } kernel_3_5;
} stat;
} SWTPROC_STAT_INFO;


  /*! Process, child process and child process status */
  typedef struct SWTPROC_PROCESS_INFO {
  int version_id;  /*!< \brief Version ID of the structure. */
  union {
    /*! Version 1 */
    struct {
      pid_t ppid;      /*!< \brief parent pid. */
      pid_t child_pid; /*!< \brief child process pid. */
      int status;      /*!< \brief child process raw status from waitpid. */
    } v1;
    /*! Version 2 */
    struct {
      pid_t ppid;      /*!< \brief parent pid. */
      pid_t child_pid; /*!< \brief child process pid. */
      int status;      /*!< \brief child process raw status from waitpid. */
    } v2;
  } proc;
} SWTPROC_PROCESS_INFO;

  /*! Structure for passing common parameters to functions. 
   */
typedef struct SWTPROC_MGT  {
  int version_id;           /*!< \brief Version ID of the structure. */
  /*! Union to support multiple versions of the structure. */
  union mgt {
    /*! Version 1 */
    struct {
      char *proc_system_root;   /*!< \brief proc file system root path */
      pid_t max_pid;            /*!< \brief Max PID value for the system */
      int errno_code;           /*!< \brief errno associated with last call if an error has occurred. */
      int error_code;           /*!< \brief non-zero if and error has occurred. */
      bool errno_meaningfull;   /*!< \brief indicates that errno value is meaning for understanding the error */
      int kernel_major;         /*!< \brief Kernel version major */
      int kernel_minor;         /*!< \brief Kernel version minor */
      int kernel_subversion;    /*!< \brief Kernel version subversion */
    } v1;
    /*! Version 2 */
    struct {
      char *proc_system_root;   /*!< \brief proc file system root path */
      pid_t max_pid;            /*!< \brief Max PID value for the system */
      int errno_code;           /*!< \brief errno associated with last call if an error has occurred. */
      int error_code;           /*!< \brief non-zero if and error has occurred. */
      bool errno_meaningfull;   /*!< \brief indicates that errno value is meaning for understanding the error */
      int kernel_major;
      int kernel_minor;
      int kernel_subversion;
    } v2;
  } mgt;
} SWTPROC_MGT;
#define SWTPROC_INIT_MGTCTRL(a) swtrprcmgt_init_ctrl(a,SWTRPCCMGT_STRUCT_CURRENT_VERSION)  
#define SWTPROC_INIT_MGTCTRL_V1(a) swtrprcmgt_init_ctrl(a,SWTRPCCMGT_STRUCT_V1)  
#define SWTPROC_INIT_MGTCTRL_V2(a) swtrprcmgt_init_ctrl(a,SWTRPCCMGT_STRUCT_V2)  

extern int swtrprcmgt_count_children(SWTPROC_MGT *ctrl, pid_t pid, char state);
extern int swtrprcmgt_get_process_stat(SWTPROC_MGT *ctrl,pid_t pid,SWTPROC_STAT_INFO *proc_info);
extern int swtrprcmgt_init_ctrl(SWTPROC_MGT *ctrl,int version);
extern int swtrprcmgt_reapzombie_status(SWTPROC_MGT *ctrl, pid_t pid,SWTPROC_PROCESS_INFO **child_info);
extern int swtrprcmgt_set_maxpid(SWTPROC_MGT *ctrl);
extern int swtrprcmgt_set_kernel_version(SWTPROC_MGT *ctrl);

#ifdef __cplusplus
}
#endif

#endif

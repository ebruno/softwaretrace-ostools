/*!
  \file
  \brief Softwaretrace process management header file.
 */

#if !defined (__SWTRPROCMGT_H__)
#define __SWTRPROCMGT_H__
#include <stdbool.h>
#ifdef __cplusplus
extern "C" {
#endif
  /*! \name Process Status
      @{
   */
#define SWTRPOCMGT_RUNNING_C 'R'              /**< \brief Running */
#define SWTRPOCMGT_ZOMBIE_C  'Z'              /**< \brief Zombie/defunct */
#define SWTRPOCMGT_SLEEPING_C  'S'            /**< \brief Sleeping */
#define SWTRPOCMGT_UNINTEREDISKSLEEP_C  'D'   /**< \brief Uniterruptable Disk Sleep */
#define SWTRPOCMGT_TRACE_STOPPED_C  'T'       /**< \brief Trace/Stopped */
#define SWTRPOCMGT_PAGING_C  'W'              /**< \brief Paging */
  /*!
    @}
   */
  /*! C String Terminator. */
#define SWTRPOCMGT_STRING_TERMINATOR_C '\0'
  /*! Maximum work buf size. */
#define SWTRPOCMGT_MAX_WRKBUF  1024
  /*! Format string for parsing the stat record. Pre Kernel V3.3 */    
#define SWTRPOCMGT_STAT_FMT_PRE_KV33 "%d %s %c %d %d %d %d %d %u %lu %lu %lu %lu %lu %lu %ld %ld %ld %ld %ld %ld %llu %lu %ld %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %lu %d %d %u %u %llu %lu %ld"
  /* Additional Fields Linux 3.3 */
#define SWTRPOCMGT_STAT_FMT_KV33 "%lu %lu %lu %lu %lu %lu %lu %d"
  /*! Format string for parsing the stat record. Kernel V3.3 and higher. */    
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
#define SWTRPCCMGT_DEFAULT_REALLOC_UNIT_SIZE = 10;
  /*! Function/Operation succeeded. */
#define SWTRPCCMGT_SUCCESS 0
  /*! Function/Operation failed. */
#define SWTRPCCMGT_FAILURE -1
#define SWTRPCCMGT_STRUCT_CURRENT_VERSION 1
  /*! Process, child process and child process status */
typedef struct SWTPROC_PROCESS_INFO {
  int version_id;  /*!< \brief Version ID of the structure. */
  pid_t ppid;      /*!< \brief parent pid. */
  pid_t child_pid; /*!< \brief child process pid. */
  int status;      /*!< \brief child process raw status from waitpid. */
} SWTPROC_PROCESS_INFO;

  /*! Structure for passing common parameters to functions. 
   */
typedef struct SWTPROC_MGT  {
  int version_id;           /*!< \brief Version ID of the structure. */
  char *proc_system_root;   /*!< \brief proc file system root path */
  pid_t max_pid;            /*!< \brief Max PID value for the system */
  int errno_code;           /*!< \brief errno associated with last call if an error has occurred. */
  int error_code;           /*!< \brief non-zero if and error has occurred. */
  bool errno_meaningfull;   /*!< \brief indicates that errno value is meaning for understanding the error */
} SWTPROC_MGT;

#define SWTPROC_INIT_MGTCTRL_V1  {1,"/proc",SWTRPOCMGT_DEFAULT_MAX_PID}  

  extern int swtrprcmgt_count_children(SWTPROC_MGT *ctrl, pid_t pid, char state);
  extern int swtrprcmgt_reapzombie_status(SWTPROC_MGT *ctrl, pid_t pid,SWTPROC_PROCESS_INFO **child_info);
  extern int swtrprcmgt_set_maxpid(SWTPROC_MGT *ctrl);
#ifdef __cplusplus
}
#endif

#endif

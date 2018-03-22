/*!
  \file
  Softwaretrace process managment.
 */

#if !defined (__SWTRPROCMGT_H__)
#define __SWTRPROCMGT_H__

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
  /*! Format string for parsing the stat record. */
#define SWTRPOCMGT_STAT_FMT "%d %s %c %d "
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

  /*! Process, child process and child process status */
typedef struct _SWTPROC_PROCESS_INFO {
    pid_t ppid;
    pid_t child_pid;
    int status;
} SWTPROC_PROCESS_INFO;

  /*! Structure for passing common parameters to functions. 
   */
typedef  struct _SWTPROC_MGT {
  char *proc_system_root;   /*< \brief proc file system root path */
  pid_t max_pid;            /*< \breif Max PID value for the system */
  
} SWTPROC_MGT;

  extern int count_children(SWTPROC_MGT *ctrl, pid_t pid, char state);
#ifdef __cplusplus
}
#endif

#endif

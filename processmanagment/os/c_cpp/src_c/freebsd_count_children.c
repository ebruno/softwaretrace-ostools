/*! \file 
   \brief Count Child Processes.
    <p>Count all children of a process that are in the specified state.</p>
    
 */
#if defined (__FreeBSD__)
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/param.h>
#include <sys/queue.h>
#include <kvm.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <libprocstat.h>
#include <unistd.h>
#include <string.h>
#include <stdbool.h>
#include "swtrprocmgt.h"

/*! Count all children of a pid that is in the specified state.
   The function searchs for all /proc/&ltpid&gt/stat files.
   It opens each file to determine if pid is the parent pid of the process and the process is state.

  @param ctrl  Pointer to common parameters
  @param pid   pid of the pocess to locate child processes of.
  @param state One of the following: \ref SWTRPOCMGT_RUNNING_C 
                                     \ref SWTRPOCMGT_ZOMBIE_C
                                     \ref SWTRPOCMGT_SLEEPING_C
                                     \ref SWTRPOCMGT_UNINTEREDISKSLEEP_C
                                     \ref SWTRPOCMGT_TRACE_STOPPED_C
                                     \ref SWTRPOCMGT_PAGING_C



  @return Count of children  or -1 of on an error.
 
  Note: The function is only interested in the pid, ppid and state fields.
  
*/
int swtrprcmgt_count_children(SWTPROC_MGT *ctrl, pid_t pid, char state) {
  int arg = 0;
  int result = SWTRPCCMGT_FAILURE;
  int what = KERN_PROC_PROC;
  struct kinfo_proc *proc_info = NULL;
  struct kinfo_proc *tmp_info = NULL;
  struct procstat *proc_ctrl = NULL;
  unsigned int count;
  int child_count = 0;

  if (ctrl != NULL) {
    if (pid <= ctrl->mgt.v1.max_pid) {
      proc_ctrl = procstat_open_sysctl();
      if (proc_ctrl != NULL) {
	proc_info = procstat_getprocs(proc_ctrl,what,arg,&count);
	if (count > 0) {
	  tmp_info = proc_info;
	  for (int index = 0; index < count; index++) {
	    if ((state == SWTRPROCMG_ALL_STATES) && (pid == tmp_info->ki_ppid)) {
	      child_count++;
	    }
	    else if ((state == tmp_info->ki_stat) && (pid == tmp_info->ki_ppid)) {
	      child_count++;
	    };
	    tmp_info++;
	  }
	  procstat_freeprocs(proc_ctrl,proc_info);
	  result = child_count;
	}
	procstat_close(proc_ctrl);
      };
    };
  };
  return result;
}
#endif
 

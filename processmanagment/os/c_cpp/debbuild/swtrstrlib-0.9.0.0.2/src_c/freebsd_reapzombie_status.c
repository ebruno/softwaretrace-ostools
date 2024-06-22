/*! \file 
   \brief FreeBSD version Reap status of all of the processes children that are in zombie/defunct state..
    <p>Finds all of the children of a process that are in the zombie state and uses waitpid to get status. This implementation uses libprocstat instead of the /proc file system.</p>
    
 */
#if defined (__FreeBSD__)
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/param.h>
#include <sys/queue.h>
#include <kvm.h>
#include <sys/sysctl.h>
#include <sys/user.h>
#include <libprocstat.h>
#include <unistd.h>
#include <string.h>
#include "swtrprocmgt.h"

/*! \brief FreeBSD version Reap status of all of the processes children that are in zombie/defunct state..
    <p>Finds all of the children of a process that are in the zombie state and uses waitpid to get status. This implementation uses libprocstat instead of the /proc file system.</p>
   This uses libprocstat to find all of a processe's children that are in a zombie/defunct state and reaps the status use waitpid. 

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
int swtrprcmgt_reapzombie_status(SWTPROC_MGT *ctrl, pid_t pid,SWTPROC_PROCESS_INFO **child_info) {
  char state = SWTRPOCMGT_ZOMBIE_C;
  int arg = 0;
  int count_entries = 0;
  int count_free_entries = 0;
  int result = SWTRPCCMGT_FAILURE;
  int child_count = 0;
  int what = KERN_PROC_PROC;
  int zombie_status = 0;
  struct kinfo_proc *proc_info = NULL;
  struct kinfo_proc *tmp_info = NULL;
  struct procstat *proc_ctrl = NULL;
  unsigned int count;
  if (ctrl != NULL) {
    if (pid <= ctrl->mgt.v1.max_pid) {
      proc_ctrl = procstat_open_sysctl();
      if (proc_ctrl != NULL) {
	proc_info = procstat_getprocs(proc_ctrl,what,arg,&count);
	if (count > 0) {
	  tmp_info = proc_info;
	  for (int index = 0; index < count; index++) {
	    if ((state == tmp_info->ki_stat) && (pid == tmp_info->ki_ppid)) {
	      if(waitpid(tmp_info->ki_pid,&zombie_status,WNOHANG) == tmp_info->ki_pid) {
		/*! TODO: return process id and raw status if child_info is not NULL 
		 */
		if (child_info == NULL) {
		  child_count++;
		} else {
		  child_count++;
		};		  
	      };
	    };
	    tmp_info++;
	  };
	  procstat_freeprocs(proc_ctrl,proc_info);
	  procstat_close(proc_ctrl);
	  result = child_count;
	};
      };
    };
  };
  return result;
};
#endif
 

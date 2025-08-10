#if defined (__linux__)
/*! \file
   \brief Load /proc/&lt;pid&gt;/stat in to a structure.
    <p>Reads the stat file and parses it using sprintf</p>

 */
// cppcheck-suppress-begin missingIncludeSystem
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <glob.h>
#include <string.h>
#include <stdbool.h>
#include <sys/utsname.h>
#include "swtrprocmgt.h"
#include "swtrstrlib.h"
// cppcheck-suppress-end missingIncludeSystem

/*! Count all children of a pid that is in the specified state.
   The function searchs for all /proc/&ltpid&gt/stat files.
   It opens each file to determine if pid is the parent pid of the process and the process is state.

  @param ctrl  Pointer to common parameters
  @param pid   pid of the pocess
  @param *proc_info pointer to a SWTPROC_STAT_INFO structure.


  @return Returns 0  or -1.

*/
int swtrprcmgt_get_process_stat(const SWTPROC_MGT *ctrl, pid_t pid, SWTPROC_STAT_INFO *proc_info) {
// cppcheck-suppress-begin [variableScope, unreadVariable, constVariablePointer,unusedVariable]
  char *field_start = NULL;
  char comm[SWTRPOCMGT_SMALL_WRKBUF+1] = "";
  char cur_state = '\0';
  const char stat_file_pattern[SWTRPOCMGT_SMALL_WRKBUF+1] = "%s/%d/stat";
  char stat_file_name[SWTRPOCMGT_SMALL_WRKBUF+1] = "";
  char stat_info[SWTRPOCMGT_MAX_WRKBUF+1] = "";
  struct utsname sysinfo;
  int bytes_read = 0;
  int result = SWTRPCCMGT_FAILURE;
  int tmp_handle = -1;
  int count_fields = 0;
// cppcheck-suppress-end [variableScope, unreadVariable, constVariablePointer,unusedVariable]
  if (ctrl != NULL) {
    if (pid <= ctrl->mgt.v1.max_pid) {
      sprintf(stat_file_name,stat_file_pattern,ctrl->mgt.v1.proc_system_root,pid);
      tmp_handle = open(stat_file_name,O_RDONLY);
      if (tmp_handle != -1) {
	memset(stat_info,0,SWTRPOCMGT_MAX_WRKBUF+1);
	bytes_read = read(tmp_handle,stat_info,SWTRPOCMGT_MAX_WRKBUF);
	close(tmp_handle);
	if (bytes_read != -1) {
	/* Trim and trailing white space */
	  swtrstrlib_right_remove_char(stat_info,'\n');
	  swtrstrlib_right_remove_char(stat_info,' ');
	  swtrstrlib_left_remove_char(stat_info,' ');
	  memset(proc_info,0,sizeof(SWTPROC_STAT_INFO));
	  if ((ctrl->mgt.v1.kernel_major >= SWTRPOCMGT_KERNEL_MAJOR_V3) && (ctrl->mgt.v1.kernel_minor >= SWTRPOCMGT_KERNEL_MINOR_V5)) {
	    proc_info->version_id = SWTPROC_STAT_INFO_CURRENT;
	    proc_info->kernel_major = ctrl->mgt.v1.kernel_major;
	    proc_info->kernel_minor = ctrl->mgt.v1.kernel_minor;
	    proc_info->kernel_subversion = ctrl->mgt.v1.kernel_subversion;
	    // cppcheck-suppress [invalidScanfArgType_int,invalidscanf,unreadVariable]
	    count_fields = sscanf(stat_info,SWTRPOCMGT_STAT_FMT,
				  &proc_info->stat.kernel_3_5.pid,
				  (char *) &proc_info->stat.kernel_3_5.comm,
				  &proc_info->stat.kernel_3_5.state,
				  &proc_info->stat.kernel_3_5.ppid,
				  &proc_info->stat.kernel_3_5.pgrp,
				  &proc_info->stat.kernel_3_5.session,
				  &proc_info->stat.kernel_3_5.tty_nr,
				  &proc_info->stat.kernel_3_5.tpgid,
				  &proc_info->stat.kernel_3_5.flags,
				  &proc_info->stat.kernel_3_5.minflt,
				  &proc_info->stat.kernel_3_5.cminflt,
				  &proc_info->stat.kernel_3_5.majflt,
				  &proc_info->stat.kernel_3_5.cmajflt,
				  &proc_info->stat.kernel_3_5.utime,
				  &proc_info->stat.kernel_3_5.stime,
				  &proc_info->stat.kernel_3_5.cutime,
				  &proc_info->stat.kernel_3_5.cstime,
				  &proc_info->stat.kernel_3_5.priority,
				  &proc_info->stat.kernel_3_5.nice,
				  &proc_info->stat.kernel_3_5.num_threads,
				  &proc_info->stat.kernel_3_5.itrealvalue,
				  &proc_info->stat.kernel_3_5.starttime,
				  &proc_info->stat.kernel_3_5.vsize,
				  &proc_info->stat.kernel_3_5.rss,
				  &proc_info->stat.kernel_3_5.rsslim,
				  &proc_info->stat.kernel_3_5.startcode,
				  &proc_info->stat.kernel_3_5.endcode,
				  &proc_info->stat.kernel_3_5.startstack,
				  &proc_info->stat.kernel_3_5.kstkesp,
				  &proc_info->stat.kernel_3_5.kstkeip,
				  &proc_info->stat.kernel_3_5.signal,
				  &proc_info->stat.kernel_3_5.blocked,
				  &proc_info->stat.kernel_3_5.sigignore,
				  &proc_info->stat.kernel_3_5.sigcatch,
				  &proc_info->stat.kernel_3_5.wchan,
				  &proc_info->stat.kernel_3_5.nswap,
				  &proc_info->stat.kernel_3_5.cnswap,
				  &proc_info->stat.kernel_3_5.exit_signal,
				  &proc_info->stat.kernel_3_5.processor,
				  &proc_info->stat.kernel_3_5.rt_priority,
				  &proc_info->stat.kernel_3_5.policy,
				  &proc_info->stat.kernel_3_5.delayacct_blkio_ticks,
				  &proc_info->stat.kernel_3_5.guest_time,
				  &proc_info->stat.kernel_3_5.cguest_time,
				  &proc_info->stat.kernel_3_5.start_data,
				  &proc_info->stat.kernel_3_5.end_data,
				  &proc_info->stat.kernel_3_5.start_brk,
				  &proc_info->stat.kernel_3_5.arg_start,
				  &proc_info->stat.kernel_3_5.arg_end,
				  &proc_info->stat.kernel_3_5.env_start,
				  &proc_info->stat.kernel_3_5.env_end,
				  &proc_info->stat.kernel_3_5.exit_code
				  );
	  } else if ((ctrl->mgt.v1.kernel_major >= SWTRPOCMGT_KERNEL_MAJOR_V3) && (ctrl->mgt.v1.kernel_minor >= SWTRPOCMGT_KERNEL_MINOR_V3)) {
	    // cppcheck-suppress [invalidScanfArgType_int,invalidscanf]
		    sscanf(stat_info,SWTRPOCMGT_STAT_FMT_KV33,
				  &proc_info->stat.kernel_3_3.pid,
				  (char *) &proc_info->stat.kernel_3_3.comm,
				  &proc_info->stat.kernel_3_3.state,
				  &proc_info->stat.kernel_3_3.ppid,
				  &proc_info->stat.kernel_3_3.pgrp,
				  &proc_info->stat.kernel_3_3.session,
				  &proc_info->stat.kernel_3_3.tty_nr,
				  &proc_info->stat.kernel_3_3.tpgid,
				  &proc_info->stat.kernel_3_3.flags,
				  &proc_info->stat.kernel_3_3.minflt,
				  &proc_info->stat.kernel_3_3.cminflt,
				  &proc_info->stat.kernel_3_3.majflt,
				  &proc_info->stat.kernel_3_3.cmajflt,
				  &proc_info->stat.kernel_3_3.utime,
				  &proc_info->stat.kernel_3_3.stime,
				  &proc_info->stat.kernel_3_3.cutime,
				  &proc_info->stat.kernel_3_3.cstime,
				  &proc_info->stat.kernel_3_3.priority,
				  &proc_info->stat.kernel_3_3.nice,
				  &proc_info->stat.kernel_3_3.num_threads,
				  &proc_info->stat.kernel_3_3.itrealvalue,
				  &proc_info->stat.kernel_3_5.starttime,
				  &proc_info->stat.kernel_3_3.vsize,
				  &proc_info->stat.kernel_3_3.rss,
				  &proc_info->stat.kernel_3_3.rsslim,
				  &proc_info->stat.kernel_3_3.startcode,
				  &proc_info->stat.kernel_3_3.endcode,
				  &proc_info->stat.kernel_3_3.startstack,
				  &proc_info->stat.kernel_3_3.kstkesp,
				  &proc_info->stat.kernel_3_3.kstkeip,
				  &proc_info->stat.kernel_3_3.signal,
				  &proc_info->stat.kernel_3_3.blocked,
				  &proc_info->stat.kernel_3_3.sigignore,
				  &proc_info->stat.kernel_3_3.sigcatch,
				  &proc_info->stat.kernel_3_3.wchan,
				  &proc_info->stat.kernel_3_3.nswap,
		 &proc_info->stat.kernel_3_3.cnswap,
		 &proc_info->stat.kernel_3_3.exit_signal,
		 &proc_info->stat.kernel_3_3.processor,
		 &proc_info->stat.kernel_3_3.rt_priority,
		 &proc_info->stat.kernel_3_3.policy,
		 &proc_info->stat.kernel_3_3.delayacct_blkio_ticks,
		 &proc_info->stat.kernel_3_3.guest_time,
		 &proc_info->stat.kernel_3_3.cguest_time,
		 &proc_info->stat.kernel_3_3.start_data,
		 &proc_info->stat.kernel_3_3.end_data,
		 &proc_info->stat.kernel_3_3.start_brk
		 );
	  } else if ((ctrl->mgt.v1.kernel_major == SWTRPOCMGT_KERNEL_MAJOR_V2) && (ctrl->mgt.v1.kernel_minor >= SWTRPOCMGT_KERNEL_MINOR_V6)) {
	    // cppcheck-suppress [invalidScanfArgType_int,invalidscanf]
		      sscanf(stat_info,SWTRPOCMGT_STAT_FMT_PRE_KV33,
				  &proc_info->stat.kernel_2_6.pid,
				  (char *) &proc_info->stat.kernel_2_6.comm,
				  &proc_info->stat.kernel_2_6.state,
				  &proc_info->stat.kernel_2_6.ppid,
				  &proc_info->stat.kernel_2_6.pgrp,
				  &proc_info->stat.kernel_2_6.session,
				  &proc_info->stat.kernel_2_6.tty_nr,
				  &proc_info->stat.kernel_2_6.tpgid,
				  &proc_info->stat.kernel_2_6.flags,
				  &proc_info->stat.kernel_2_6.minflt,
				  &proc_info->stat.kernel_2_6.cminflt,
				  &proc_info->stat.kernel_2_6.majflt,
				  &proc_info->stat.kernel_2_6.cmajflt,
				  &proc_info->stat.kernel_2_6.utime,
				  &proc_info->stat.kernel_2_6.stime,
				  &proc_info->stat.kernel_2_6.cutime,
				  &proc_info->stat.kernel_2_6.cstime,
				  &proc_info->stat.kernel_2_6.priority,
				  &proc_info->stat.kernel_2_6.nice,
				  &proc_info->stat.kernel_2_6.num_threads,
				  &proc_info->stat.kernel_2_6.itrealvalue,
				  &proc_info->stat.kernel_3_5.starttime,
				  &proc_info->stat.kernel_2_6.vsize,
				  &proc_info->stat.kernel_2_6.rss,
				  &proc_info->stat.kernel_2_6.rsslim,
				  &proc_info->stat.kernel_2_6.startcode,
				  &proc_info->stat.kernel_2_6.endcode,
				  &proc_info->stat.kernel_2_6.startstack,
				  &proc_info->stat.kernel_2_6.kstkesp,
				  &proc_info->stat.kernel_2_6.kstkeip,
				  &proc_info->stat.kernel_2_6.signal,
				  &proc_info->stat.kernel_2_6.blocked,
				  &proc_info->stat.kernel_2_6.sigignore,
				  &proc_info->stat.kernel_2_6.sigcatch,
				  &proc_info->stat.kernel_2_6.wchan,
				  &proc_info->stat.kernel_2_6.nswap,
				  &proc_info->stat.kernel_2_6.cnswap,
				  &proc_info->stat.kernel_2_6.exit_signal,
				  &proc_info->stat.kernel_2_6.processor,
				  &proc_info->stat.kernel_2_6.rt_priority,
				  &proc_info->stat.kernel_2_6.policy,
				  &proc_info->stat.kernel_2_6.delayacct_blkio_ticks,
				  &proc_info->stat.kernel_2_6.guest_time,
				  &proc_info->stat.kernel_2_6.cguest_time
			      );
	  };
	};
      };
    };
  };
  return result;
};
#endif

/*! \file
   \brief Set the Max PID allowed for this system in control block.
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <glob.h>
#include <string.h>

#include "swtrpocmgt.h"

/*! Get max PID allowed by the system.
    The max pid is stored in /proc/sys/kernel/pid_max
    This function reads the value and stores in max_pid in the control block.
    if an error occurs the value \ref SWTRPOCMGT_DEFAULT_MAX_PID is set.

  @param ctrl  Pointer Control Block for the library.

  @return 0 or -1 if an error occurs.
     
*/
int swtrprcmgt_set_maxpid(SWTPROC_MGT *ctrl) {
  char field_fmt[] = "%d";
  char proc_fmt_pattern[SWTRPOCMGT_SMALL_WRKBUF+1] = "%s/sys/kernel/pid_max";
  char proc_pattern[SWTRPOCMGT_SMALL_WRKBUF+1] = "";
  char info[SWTRPOCMGT_MAX_WRKBUF+1] = "";
  int bytes_read = 0;
  int result = SWTRPCCMGT_FAILURE;
  int tmp_handle = -1;
  int tmp_status = 0;
  pid_t max_pid = 0;
  if (ctrl != NULL) {
    switch (ctrl->version_id) {
    case SWTRPCCMGT_STRUCT_V1:
      sprintf(proc_pattern,proc_fmt_pattern,ctrl->mgt.v1.proc_system_root);
      break;
    case SWTRPCCMGT_STRUCT_V2:
      sprintf(proc_pattern,proc_fmt_pattern,ctrl->mgt.v2.proc_system_root);
      break;
    default:
      result = SWTRPCCMGT_FAILURE;
      break;
    };
    if (strlen(proc_pattern) > 0) {
      tmp_handle = open(proc_pattern,O_RDONLY);
      if (tmp_handle != -1) {
	memset(info,0,SWTRPOCMGT_MAX_WRKBUF+1);
	bytes_read = read(tmp_handle,info,SWTRPOCMGT_MAX_WRKBUF);
	close(tmp_handle);
	if (bytes_read != -1) {
	  tmp_status = sscanf(info,field_fmt,&max_pid);
	  if (tmp_status != 1) {
	    max_pid = SWTRPOCMGT_DEFAULT_MAX_PID;
	  } else {
	    result = SWTRPCCMGT_SUCCESS;
	  }
	}
      };
      switch (ctrl->version_id) {
      case SWTRPCCMGT_STRUCT_V1:
	ctrl->mgt.v1.max_pid = max_pid;
	break;
      case SWTRPCCMGT_STRUCT_V2:
	ctrl->mgt.v2.max_pid = max_pid;
	break;
      default:
      result = SWTRPCCMGT_FAILURE;
      break;
      };
    };
  };
  return result;
};

 

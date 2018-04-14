/*! \file 
   \brief Count Child Processes.
    <p>Count all children of a process that are in the specified state.</p>
    
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <glob.h>
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
  <br>pid is field 1
  <br>comm is field 2
  <br>state is field 3
  <br>ppid is field 4
  
  70409 (someproc) S 66024 
  
*/
int swtrprcmgt_count_children(SWTPROC_MGT *ctrl, pid_t pid, char state) {
  bool continue_processing = false;   
  char *field_start = NULL;
  char *tmp_ptr = NULL;
  char comm[SWTRPOCMGT_SMALL_WRKBUF+1] = "";
  char cur_state = '\0'; 
  char field_fmt[SWTRPOCMGT_SMALL_WRKBUF+1] = "%d %s %c %d";
  char glob_fmt_pattern[SWTRPOCMGT_SMALL_WRKBUF+1] = "%s/[0-9]*/stat";
  char glob_pattern[SWTRPOCMGT_SMALL_WRKBUF+1] = "";
  char stat_info[SWTRPOCMGT_MAX_WRKBUF+1] = "";
  glob_t pglob;
  int bytes_read = 0;
  int field_id = 0;
  int flags = 0;
  int looking_for_field = 0;
  int result = SWTRPCCMGT_FAILURE;
  int required_count_fields = 4;
  int tmp_handle = -1;
  int field_count = 0;
  pid_t cpid = 0;
  pid_t ppid = 0;
  if (ctrl != NULL) {
    if (pid <= ctrl->mgt.v1.max_pid) {
      sprintf(glob_pattern,glob_fmt_pattern,ctrl->mgt.v1.proc_system_root);
      result = glob(glob_pattern,flags,NULL,&pglob);
      if (result == 0) {
	char **base_entry = pglob.gl_pathv;
	for (size_t item = 0; item < pglob.gl_pathc; item++) {
	  tmp_handle = open(*base_entry,O_RDONLY);
	  if (tmp_handle != -1) {
	    memset(stat_info,0,SWTRPOCMGT_MAX_WRKBUF+1);
	    bytes_read = read(tmp_handle,stat_info,SWTRPOCMGT_MAX_WRKBUF);
	    close(tmp_handle);

	    if (bytes_read != -1) {
	      tmp_ptr = (char *) &stat_info;
	      field_start = tmp_ptr;
	      continue_processing = true;
	      looking_for_field = SWTRPOCMGT_FIELD_PROCESS_GROUP;
	      field_id = SWTRPOCMGT_FIELD_PID;
	      while (continue_processing == true){
		if ((field_id == SWTRPOCMGT_FIELD_PROCESS_GROUP) && (looking_for_field == SWTRPOCMGT_FIELD_PROCESS_GROUP)) {
		  // truncate the buffer.
		  tmp_ptr--;
		  *(tmp_ptr) = SWTRPOCMGT_STRING_TERMINATOR_C;
		  field_count = sscanf(field_start,field_fmt,&cpid,&comm,&cur_state,&ppid);
		  continue_processing = false;
		  if (field_count == required_count_fields) {
		    if ((state == SWTRPROCMG_ALL_STATES) && (pid == ppid)) {
		      result++;
		    } 
		    else if ((state == cur_state) && (pid == ppid)) {
		      result++;
		    } 
		  }
		  continue;
		} 
		else if (*(tmp_ptr) == SWTRPOCMGT_STRING_TERMINATOR_C) {
		  continue_processing = false;
		  continue;
		} 
		else if (*(tmp_ptr) == ' ') {
		  field_id++;
		}
		tmp_ptr++;
	      }
	    }
	  }
	  *(base_entry)++;	
	};
	globfree(&pglob);
      }
    }
  }
  return result;
}

 

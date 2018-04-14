#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/utsname.h>
#include "swtrprocmgt.h"

#ifdef __cplusplus
extern "C" {
#endif

int swtrprcmgt_set_kernel_version(SWTPROC_MGT *ctrl) {

  int result = SWTRPCCMGT_SUCCESS;
  struct utsname sysinfo;
  char *tmp_ptr = NULL;
  char scan_fmt[] = "%d.%d.%d%s";
  char tmp_buf[SWTRPOCMGT_SMALL_WRKBUF+1];
  int major = 0;
  int minor = 0;
  int subversion = 0;
  uname(&sysinfo);
  // look for the third non-numberic character.
  memset(tmp_buf,'\0',(SWTRPOCMGT_SMALL_WRKBUF+1)*sizeof(char));
  sscanf(sysinfo.release,scan_fmt,&major,&minor,&subversion,&tmp_buf);
  switch(ctrl->version_id) {
    case SWTRPCCMGT_STRUCT_V1:
      ctrl->mgt.v1.kernel_major = major;
      ctrl->mgt.v1.kernel_minor = minor;
      ctrl->mgt.v1.kernel_subversion = subversion;
      break;
    case SWTRPCCMGT_STRUCT_V2:
      ctrl->mgt.v2.kernel_major = major;
      ctrl->mgt.v2.kernel_minor = minor;
      ctrl->mgt.v2.kernel_subversion = subversion;
      break;
    default:
      break;
  };
  return result;
};
#ifdef __cplusplus
}
#endif

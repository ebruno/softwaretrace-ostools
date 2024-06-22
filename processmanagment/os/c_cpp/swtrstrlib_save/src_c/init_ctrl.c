/*! \file
  \brief Initialize control block.
 */
#include <string.h>
#include "swtrpocmgt.h"
#ifdef __cplusplus
extern "C" {
#endif
int swtrprcmgt_init_ctrl(SWTPROC_MGT *ctrl,int version) {
  int result = SWTRPCCMGT_SUCCESS;
  
  if (ctrl != NULL) {
    memset(ctrl,0,sizeof(struct SWTPROC_MGT));
    ctrl->version_id = version;

    switch (version) {
    case SWTRPCCMGT_STRUCT_V1:
      ctrl->mgt.v1.proc_system_root = SWTRPCCMGT_PROCFS_ROOT;
      break;
    case SWTRPCCMGT_STRUCT_V2:
      result = SWTRPCCMGT_SUCCESS;
      ctrl->mgt.v2.proc_system_root = SWTRPCCMGT_PROCFS_ROOT;
      break;
    default:
      result = SWTRPCCMGT_FAILURE;
      break;
    };
  }
  if (result == SWTRPCCMGT_SUCCESS) {
      swtrprcmgt_set_maxpid(ctrl);
      swtrprcmgt_set_kernel_version(ctrl);
  };
  return result;
}
#ifdef __cplusplus
}
#endif

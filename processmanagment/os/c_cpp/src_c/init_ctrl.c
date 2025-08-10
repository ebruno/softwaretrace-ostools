/*! \file
  \brief Initialize process management control block.

 */
// cppcheck-suppress-begin missingIncludeSystem
#include <string.h>
#include "swtrprocmgt.h"
// cppcheck-suppress-end missingIncludeSystem

#ifdef __cplusplus
extern "C" {
#endif
  /*!  \brief Initialize the process managment control block.
       Under under Linux the /proc file system is used.
       Under FreeBSD the sysctl mibs are used my the
       underlying routines.

       \param ctrl      Pointer to control block.
       \param version   Version of the control block to initialize.

       \return  \ref SWTRPCCMGT_SUCCESS or \ref SWTRPCCMGT_FAILURE
   */
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

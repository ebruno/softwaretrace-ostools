/*! \file
  \brief Example of reaping zombie processes exit status.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

#include "swtrpocmgt.h"



int main(int argc, char **argv) {
  SWTPROC_MGT ctrl;
  int result = 0;
  int count = 0;
  pid_t my_pid = getpid();
  SWTPROC_INIT_MGTCTRL(&ctrl);
  return result;
}

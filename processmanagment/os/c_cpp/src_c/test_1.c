#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

#include "swtrpocmgt.h"

int main(int argc, char **argv) {
  SWTPROC_MGT ctrl = {"/proc"};
  int result = 0;
  int count = 0;
  pid_t my_pid = getpid();
  my_pid = 2;
  count = count_children(&ctrl,my_pid,SWTRPOCMGT_ZOMBIE_C);
  fprintf(stdout,"num zombies: %d\n",count);
  count = count_children(&ctrl,my_pid,SWTRPROCMG_ALL_STATES);
  fprintf(stdout,"num zombies: %d\n",count);
  return result;
}

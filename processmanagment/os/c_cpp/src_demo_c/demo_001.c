/*! \file
  \brief Example of reaping zombie processes exit status.
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>

#include "swtrprocmgt.h"

/*! \brief Create child processes and leave them in a zombie state.
  Each child will exit with a status of zero.

  @param count Number or zombies to create.

*/
void create_zombies(int count) {
  pid_t child_pid;
  for (int index=0; index < count; index++) {
    child_pid = fork();
    if (child_pid == 0) {
      /* wait bit before having the child exit. */
      sleep(2);
      fprintf(stdout,"Child %d pid %d, terminating.\n",index,getpid());
      exit(0);
    }
  }

}


int main(int argc, char **argv) {
  SWTPROC_MGT ctrl;
  int result = 0;
  int count = 0;
  int num_zombies = 5;
  pid_t my_pid = getpid();
  SWTPROC_INIT_MGTCTRL(&ctrl);
  fprintf(stdout,"Creating %d children.\n",num_zombies);
  create_zombies(num_zombies);
  // Wait for the children to exit
  fprintf(stdout,"Waiting for children to exit.\n");
  sleep(num_zombies * 2);
  fprintf(stdout,"The number of zombies should be equal to number of children.\n");
  count = swtrprcmgt_count_children(&ctrl,my_pid,SWTRPOCMGT_ZOMBIE_C);
  fprintf(stdout,"Number of children that are zombies: %d\n",count);
#if defined (__linux__)
  fprintf(stdout,"Enter the command 'ps -aef | grep %d | grep defunct'\nin another window to see the zombie/defunct processes assocated with this pid\n",getpid());
#elif defined (__FreeBSD__)
  fprintf(stdout,"Enter the command 'ps -aj | grep %d | grep defunct'\nin another window to see the zombie/defunct processes assocated with this pid\n",getpid());
#endif
  fprintf(stdout,"Waiting 60 seconds before continuing...\n");
  sleep(60);
  fprintf(stdout,"Reap the status of all the children that are zombies.");
  count = swtrprcmgt_reapzombie_status(&ctrl,my_pid,NULL);
  fprintf(stdout,"reaped status of %d zombies.\n",count);
  count = swtrprcmgt_count_children(&ctrl,my_pid,SWTRPOCMGT_ZOMBIE_C);
  fprintf(stdout,"Remaing zombies should now be zero. Number of zombies: %d\n",count);
  return result;
}

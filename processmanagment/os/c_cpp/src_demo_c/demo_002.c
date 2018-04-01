/*! \file
  \brief Example of monitoring a processes resource usage..
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/time.h>
#include <sys/resource.h>

#include "swtrpocmgt.h"



int main(int argc, char **argv) {
  SWTPROC_MGT ctrl;
  int result = 0;
  int count = 0;
  int num_zombies = 5;
  pid_t my_pid = getpid();
  SWTPROC_INIT_MGTCTRL(&ctrl);
  int num_loops = 8000;
  char *tmp_ptrs[num_loops];
  struct rusage myusage;
  long last_maxrss = 0;
  fprintf(stdout,"Allocate Memory my pid is %d\n",my_pid);
  for(int index=0; index < num_loops; index++) {
    tmp_ptrs[index] = NULL;
    if (getrusage(RUSAGE_SELF,&myusage) == 0) {
      if (last_maxrss != myusage.ru_maxrss) {
	fprintf(stdout,"maximum resident set_size   : %ld\n",myusage.ru_maxrss);
	fprintf(stdout,"integral shared memory suze : %ld\n",myusage.ru_ixrss);
	fprintf(stdout,"integral unshared data size : %ld\n",myusage.ru_idrss);
	fprintf(stdout,"integral unshared stack size: %ld\n",myusage.ru_isrss);
	last_maxrss = myusage.ru_maxrss;
      }
      tmp_ptrs[index] = (char *) malloc(4096*sizeof(char));
    };
  };
  sleep(120);
  fprintf(stdout,"Free Memory\n");
  for(int index=0; index < num_loops; index++) {
    if (tmp_ptrs[index] != NULL) {
      free(tmp_ptrs[index]);
      tmp_ptrs[index] = NULL;
    }
    if (getrusage(RUSAGE_SELF,&myusage) == 0) {
      if (last_maxrss != myusage.ru_maxrss) {
	fprintf(stdout,"maximum resident set_size   : %ld\n",myusage.ru_maxrss);
	fprintf(stdout,"integral shared memory suze : %ld\n",myusage.ru_ixrss);
	fprintf(stdout,"integral unshared data size : %ld\n",myusage.ru_idrss);
	fprintf(stdout,"integral unshared stack size: %ld\n",myusage.ru_isrss);      
	last_maxrss = myusage.ru_maxrss;
      }
    }
  }; 
  return result;
};

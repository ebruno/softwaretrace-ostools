/*! \file
  \brief Example of reaping zombie processes exit status.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>

#include "swtrpocmgt.h"
#include "swtrstrlib.h"
/*! \brief Create child processes and leave them in a zombie state. 
  Each child will exit with a status of zero.

  @param count Number or zombies to create.

*/

int main(int argc, char **argv) {
  SWTPROC_MGT ctrl;
  int result = 0;
  int count = 0;
  int num_zombies = 5;
  pid_t my_pid = getpid();
  SWTPROC_INIT_MGTCTRL(&ctrl);
  SWTPROC_STAT_INFO proc_info;
  result = swtrprcmgt_get_process_stat(&ctrl, my_pid, &proc_info);
  fprintf(stdout,"mypid = %d\n",my_pid);
  fprintf(stdout," %d ", proc_info.stat.kernel_3_5.pid);
  fprintf(stdout,"%s ", proc_info.stat.kernel_3_5.comm);
  fprintf(stdout,"%c ", proc_info.stat.kernel_3_5.state);
  fprintf(stdout,"%d ", proc_info.stat.kernel_3_5.ppid);
  fprintf(stdout,"%d ", proc_info.stat.kernel_3_5.pgrp);
  fprintf(stdout,"%d ", proc_info.stat.kernel_3_5.session);
  fprintf(stdout,"%d ", proc_info.stat.kernel_3_5.tty_nr);
  fprintf(stdout,"%d ", proc_info.stat.kernel_3_5.tpgid);
  fprintf(stdout,"%u ", proc_info.stat.kernel_3_5.flags);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.minflt);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.cminflt);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.majflt);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.cmajflt);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.utime);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.stime);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.cutime);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.cstime);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.priority);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.nice);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.num_threads);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.itrealvalue);
  fprintf(stdout,"%llu ", proc_info.stat.kernel_3_5.starttime);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.vsize);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.rss);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.rsslim);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.startcode);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.endcode);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.startstack);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.kstkesp);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.kstkeip);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.signal);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.blocked);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.sigignore);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.sigcatch);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.wchan);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.nswap);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.cnswap);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.exit_signal);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.processor);
  fprintf(stdout,"%u ", proc_info.stat.kernel_3_5.rt_priority);
  fprintf(stdout,"%u ", proc_info.stat.kernel_3_5.policy);
  fprintf(stdout,"%llu ", proc_info.stat.kernel_3_5.delayacct_blkio_ticks);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.guest_time);
  fprintf(stdout,"%ld ", proc_info.stat.kernel_3_5.cguest_time);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.start_data);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.end_data);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.start_brk);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.arg_start);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.arg_end);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.env_start);
  fprintf(stdout,"%lu ", proc_info.stat.kernel_3_5.env_end);
  fprintf(stdout,"%d\n", proc_info.stat.kernel_3_5.exit_code);



  fprintf(stdout,"pid: %d ", proc_info.stat.kernel_3_5.pid);
  fprintf(stdout,"comm:'%s' ", proc_info.stat.kernel_3_5.comm);
  fprintf(stdout,"state: %c ", proc_info.stat.kernel_3_5.state);
  fprintf(stdout,"ppid: %d ", proc_info.stat.kernel_3_5.ppid);
  fprintf(stdout,"pgrp: %d ", proc_info.stat.kernel_3_5.pgrp);
  fprintf(stdout,"session: %d ", proc_info.stat.kernel_3_5.session);
  fprintf(stdout,"tty_nr: %d\n", proc_info.stat.kernel_3_5.tty_nr);
  fprintf(stdout,"tpgid: %d ", proc_info.stat.kernel_3_5.tpgid);
  fprintf(stdout,"flags: %u ", proc_info.stat.kernel_3_5.flags);
  fprintf(stdout,"minflt : %lu ", proc_info.stat.kernel_3_5.minflt);
  fprintf(stdout,"cminflt: %lu ", proc_info.stat.kernel_3_5.cminflt);
  fprintf(stdout,"majflt: %lu ", proc_info.stat.kernel_3_5.majflt);
  fprintf(stdout,"cmajflt: %lu\n", proc_info.stat.kernel_3_5.cmajflt);
  fprintf(stdout,"utime: %lu ", proc_info.stat.kernel_3_5.utime);
  fprintf(stdout,"stime: %lu ", proc_info.stat.kernel_3_5.stime);
  fprintf(stdout,"cutime: %ld ", proc_info.stat.kernel_3_5.cutime);
  fprintf(stdout,"cstime: %ld ", proc_info.stat.kernel_3_5.cstime);
  fprintf(stdout,"priority: %lu ", proc_info.stat.kernel_3_5.priority);
  fprintf(stdout,"nice: %ld\n", proc_info.stat.kernel_3_5.nice);
  fprintf(stdout,"num_threads: %ld ", proc_info.stat.kernel_3_5.num_threads);
  fprintf(stdout,"itrealvalue: %ld ", proc_info.stat.kernel_3_5.itrealvalue);
  fprintf(stdout,"starttime: %llu ", proc_info.stat.kernel_3_5.starttime);
  fprintf(stdout,"vsize: %lu ", proc_info.stat.kernel_3_5.vsize);
  fprintf(stdout,"rss: %ld ", proc_info.stat.kernel_3_5.rss);
  fprintf(stdout,"rsslim: %lu\n", proc_info.stat.kernel_3_5.rsslim);
  fprintf(stdout,"startcode: %lu ", proc_info.stat.kernel_3_5.startcode);
  fprintf(stdout,"endcode: %lu ", proc_info.stat.kernel_3_5.endcode);
  fprintf(stdout,"startstack: %lu\n", proc_info.stat.kernel_3_5.startstack);
  fprintf(stdout,"kstkesp: %lu ", proc_info.stat.kernel_3_5.kstkesp);
  fprintf(stdout,"kstkeip: %lu\n", proc_info.stat.kernel_3_5.kstkeip);
  fprintf(stdout,"signal: %lu ", proc_info.stat.kernel_3_5.signal);
  fprintf(stdout,"blocked: %lu ", proc_info.stat.kernel_3_5.blocked);
  fprintf(stdout,"sigignore: %lu\n", proc_info.stat.kernel_3_5.sigignore);
  fprintf(stdout,"sigcatch: %lu ", proc_info.stat.kernel_3_5.sigcatch);
  fprintf(stdout,"wchan: %lu ", proc_info.stat.kernel_3_5.wchan);
  fprintf(stdout,"nswap: %lu ", proc_info.stat.kernel_3_5.nswap);
  fprintf(stdout,"cnswap: %lu ", proc_info.stat.kernel_3_5.cnswap);
  fprintf(stdout,"exit_signal: %ld\n", proc_info.stat.kernel_3_5.exit_signal);
  fprintf(stdout,"processor: %lu ", proc_info.stat.kernel_3_5.processor);
  fprintf(stdout,"rt_priority: %u\n", proc_info.stat.kernel_3_5.rt_priority);
  fprintf(stdout,"policy: %u ", proc_info.stat.kernel_3_5.policy);
  fprintf(stdout,"delayacct_blkio_ticks: %llu ", proc_info.stat.kernel_3_5.delayacct_blkio_ticks);
  fprintf(stdout,"guest_time: %lu ", proc_info.stat.kernel_3_5.guest_time);
  fprintf(stdout,"cguest_time: %ld\n", proc_info.stat.kernel_3_5.cguest_time);
  fprintf(stdout,"start_data: %lu ", proc_info.stat.kernel_3_5.start_data);
  fprintf(stdout,"end_data: %lu ", proc_info.stat.kernel_3_5.end_data);
  fprintf(stdout,"start_brk: %lu ", proc_info.stat.kernel_3_5.start_brk);
  fprintf(stdout,"arg_start: %lu ", proc_info.stat.kernel_3_5.arg_start);
  fprintf(stdout,"arg_end: %lu ", proc_info.stat.kernel_3_5.arg_end);
  fprintf(stdout,"env_start: %lu ", proc_info.stat.kernel_3_5.env_start);
  fprintf(stdout,"env_end: %lu\n", proc_info.stat.kernel_3_5.env_end);
  fprintf(stdout,"exit_code: %d\n", proc_info.stat.kernel_3_5.exit_code);
  return result;
}

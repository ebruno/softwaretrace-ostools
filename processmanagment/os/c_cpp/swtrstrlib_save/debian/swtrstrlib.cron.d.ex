#
# Regular cron jobs for the swtrstrlib package
#
0 4	* * *	root	[ -x /usr/bin/swtrstrlib_maintenance ] && /usr/bin/swtrstrlib_maintenance

import os
import sys
import types
import glob


class ChildMgt(object):
    """ Provides basic management of Child Processes.
    """
    running = 'R'
    zombie = 'Z'
    sleeping = 'S'
    uninterdisksleep = 'D'
    trace_stopped = 'T'
    paging = 'W'
    ## Constructor
    ##
    ## @param self pointer to instance of the class.
    ## @param pid  Parent PID to find children of.
    ## @param proc_filesystem root directory of the proc filesystem
    ## @param logger logger to for debugging
    ## @param verbose Enables verbose logging.
    ## @param trace Enables trace mode for logging.
    def __init__(self,pid=None,proc_filesystem='/proc',logger=None,verbose=False,trace=False):
        """ Constructor
        """
        ## Major version Number
        self._major = 1
        ## Minor version Number
        self._minor = 0
        self._subversion = 0
        self._version = "{0}.{1}.{2}".format(self._major,self._minor,self._subversion)
        if pid == None:
            self._pid = os.getpid()
        else:
            self._pid = pid

        if os.path.exists(proc_filesystem) == False:
            msg = '{0} does not exist.'.format(proc_filesystem)
            raise ValueError(msg)
        self._proc_root = proc_filesystem
        self._process_states = [self.running, self.zombie,self.trace_stopped,self.uninterdisksleep,self.sleeping,self.paging]
            
    def countChildren(self,state=None):
        """
        One  character  from  the string "RSDZTW" where R is running, S is sleeping in an interruptible wait, D is waiting in
            uninterruptible disk sleep, Z is zombie, T is traced or stopped (on a signal), and W is paging.
        """
        result = 0
        search_pattern = os.path.join(self._proc_root,'[0-9]*','stat')
        items = glob.iglob(search_pattern)
        # Note process may terminate before the list is walked so just ignore missing processes.
        # 
        for item in items:
                try:
                    with open(item) as proc_entry:
                        info = proc_entry.read().split()
                        if state != None:
                            if (info[2] == state) and (int(info[3]) == self._pid):
                                result += 1
                        elif int(info[3]) == self._pid:
                            result += 1
                except IOError as e:
                    pass
                except Exception as e:
                    pass
            
        return result

    def countZombiedChild(self):
        result = self.countChildren(state=self.zombie)
        return result

    def childrenInState(self,state=None):
        """
        One  character  from  the string "RSDZTW" where R is running, S is sleeping in an interruptible wait, D is waiting in
            uninterruptible disk sleep, Z is zombie, T is traced or stopped (on a signal), and W is paging.
        """
        result = {'R':[],'S':[],'D':[],'Z':[],'T':[],'W':[]}
        if type(state) is types.StringType:
            state_list = [state]
        else:
            state_list = state

        search_pattern = os.path.join(self._proc_root,'[0-9]*','stat')
        items = glob.iglob(search_pattern)
        # Note process may terminate before the list is walked so just ignore missing processes.
        # 
        for item in items:
                try:
                    with open(item) as proc_entry:
                        info = proc_entry.read().split()
                        if state != None:
                            if (info[2] in state) and (int(info[3]) == self._pid):
                                result[info[2]].append(int(info[0]))
                        elif int(info[3]) == self._pid:
                            result[info[2]].append(int(info[0]))
                except IOError as e:
                    pass
                except Exception as e:
                    pass
        return result

    def reapChildStatus(self,children=None):
        """ The children parameter can be a list of pids if set to none the function will attempt 
        to locate all child processes.
        The return value is None if no zombie children were found.  
        Otherwise a dictionary is returned with PID as the key and child status 
        as the value for the key. If values for children are provided and a specified 
        PID is not found, the entry will be set to None.
        """
        result = {}
        process_states = self.childrenInState()
        for state in self._process_states:
            processes = process_states[state]
            for process in processes:
                if children != None:
                    if process not in children:
                        continue
                tmp_val = os.waitpid(process,os.WNOHANG)
                if (tmp_val[0] == 0) and (tmp_val[1] == 0):
                    continue
                else:    
                   result[process] = tmp_val[1]
        return result

    def reapZombieChildStatus(self,children=None):
        """ The children parameter can be a list of pids if set to none the function will attempt 
        to locate all zombie child processes.
        The return value is None if no zombie children were found.  
        Otherwise a dictionary is returned with PID as the key and child status 
        as the value for the key. If values for children are provided and a specfied 
        PID is not found, the entry will be set to None.
        """
        result = {}
        processes = self.childrenInState(state=self.zombie)
        for process in processes[self.zombie]:
            if children != None:
                if process not in children:
                    continue
            tmp_val = os.waitpid(process,os.WNOHANG)
            if (tmp_val[0] == 0) and (tmp_val[1] == 0):
                continue
            else:    
               result[process] = tmp_val[1]
        return result

    def getAllChildState(self,children=None):
        """ Returns a dictionary of all child processes and their current state.
        One of the following values: "RSDZTW" 
        R is running, 
        S is sleeping in an interruptible wait, 
        D is waiting in uninterruptible disk sleep, Z is zombie, 
        T is traced or stopped (on a signal), and W is paging.
        If no children are found None is returned.
        """
        result = {}

        search_pattern = os.path.join(self._proc_root,'[0-9]*','stat')
        items = glob.iglob(search_pattern)
        # Note process may terminate before the list is walked so just ignore missing processes.
        # 
        for item in items:
                try:
                    with open(item) as proc_entry:
                        info = proc_entry.read().split()
                        if children == None:
                            if int(info[3]) == self._pid:
                                result[info[0]] = info[2]
                        elif info[0] in children:
                            if int(info[3]) == self._pid:
                                result[info[0]] = info[2]
                            
                except IOError as e:
                    pass
                except Exception as e:
                    pass
        return result

    def getStatusAsDictionary(self,pids=None):
        """ Provides much of the information in /proc/[pid]/stat  
        and  /proc/[pid]/status see the proc man page for more information.
        will return list of dictionaries or None if zero processes are located.
        """
        result = {}

        search_pattern = os.path.join(self._proc_root,'[0-9]*','status')
        items = glob.iglob(search_pattern)
        # Note process may terminate before the list is walked so just ignore missing processes.
        # 
        for item in items:
                try:
                    with open(item) as proc_entry:
                        lines = proc_entry.read().split('\n')
                        tmp_result = {}
                        for line in lines:
                            tmp_entry = line.split(':')
                            key = tmp_entry[0]
                            if len(tmp_entry) == 2:
                                tmp_result[key] = tmp_entry[1].lstrip().rstrip()
                        if pids != None:
                            if (int(tmp_result['Pid']) in pids) and (int(tmp_result['PPid']) == self._pid):
                                result[int(tmp_result['Pid'])] = tmp_result
                        elif int(tmp_result['PPid']) == self._pid:
                            result[int(tmp_result['Pid'])] = tmp_result
                            
                except IOError as e:
                    pass
                except Exception as e:
                    pass
        return result
    
    def getVersion(self,as_dictionary=False):
        result = self._version
        if as_dictonary == True:

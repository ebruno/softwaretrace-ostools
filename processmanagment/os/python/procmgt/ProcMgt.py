import os
import sys
import types
import glob


class ProcMgt(object):
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
    ## @param pid PID of process. If None all processes.
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
        self._pid = pid

        if os.path.exists(proc_filesystem) == False:
            msg = '{0} does not exist.'.format(proc_filesystem)
            raise ValueError(msg)
        self._proc_root = proc_filesystem
        self._process_states = [self.running, self.zombie,self.trace_stopped,self.uninterdisksleep,self.sleeping,self.paging]
            
    def countProcess(self,state=None):
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
                        if not isinstance(state,type(None)):
                            if (info[2] == state):
                                if ((int(info[0]) == self._pid) or (isinstance(self._pid,type(None)))):
                                          result += 1
                        elif ((int(info[0]) == self._pid) or (isinstance(self._pid,type(None)))):
                            result += 1
                except IOError as e:
                    pass
                except Exception as e:
                    pass
            
        return result

    def processInState(self,state=None):
        """
        One  character  from  the string "RSDZTW" where R is running, S is sleeping in an interruptible wait, D is waiting in
            uninterruptible disk sleep, Z is zombie, T is traced or stopped (on a signal), and W is paging.
        """
        result = {'R':[],'S':[],'D':[],'Z':[],'T':[],'W':[]}
        if type(state) is bytes:
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
                            if (info[2] in state):
                                if ((int(info[0]) == self._pid) or (isinstance(self._pid,type(None)))):
                                    result[info[2]].append(int(info[0]))
                        elif ((int(info[0]) == self._pid) or (isinstance(self._pid,type(None)))):
                            result[info[2]].append(int(info[0]))
                except IOError as e:
                    pass
                except Exception as e:
                    pass
        return result

    def getAllPIDs(self):
        result = []
        tmp_list = self.getAllProcessState().keys()
        for item in tmp_list:
            result.append(int(item))
        result = sorted(result)
        return result

    def getAllProcessState(self,process=None):
        """ Returns a dictionary of all processes and their current state.
        One of the following values: "RSDZTW" 
        R is running, 
        S is sleeping in an interruptible wait, 
        D is waiting in uninterruptible disk sleep, Z is zombie, 
        T is traced or stopped (on a signal), and W is paging.
        If no process are found None is returned.
        """
        result = {}
        have_child = {}

        search_pattern = os.path.join(self._proc_root,'[0-9]*','stat')
        items = glob.iglob(search_pattern)
        # Note process may terminate before the list is walked so just ignore missing processes.
        # Spaces can be in the process name we need to deal with that case.
        for item in items:
                try:
                    with open(item) as proc_entry:
                        info_orig = proc_entry.read()
                        start_proc_name = info_orig.index('(')
                        end_proc_name = info_orig.index(')')
                        pid = info_orig[0:start_proc_name].rstrip().lstrip()
                        process_name = info_orig[start_proc_name:end_proc_name+1]
                        info = [pid,process_name]
                        info.extend(info_orig[end_proc_name+2:].split())
                        if process == None:
                            if ((int(info[0]) == self._pid) or (isinstance(self._pid,type(None)))):
                                result[info[0]] = {'state': info[2], 'children': []}
                                try:
                                    have_child[info[3]].append(int(info[0]))
                                except KeyError:
                                    have_child[info[3]] = [int(info[0])]
                                    pass
                        elif info[0] in process:
                            if ((int(info[0]) == self._pid) or (isinstance(self._pid,type(None)))):
                                result[info[0]] = { 'state' : info[2] }
                                try:
                                    have_child[info[3]].append(int(info[0]))
                                except KeyError:
                                    have_child[info[3]] = [int(info[0])]
                                    pass
                            
                except IOError as e:
                    pass
                except Exception as e:
                    pass
                
# remove process 0 (swap process) if it is the list as a parent.

        have_child.pop('0',None)
        for key in have_child.keys():
            tmp_item = result[key]
            tmp_item['children'] = have_child[key]
            result[key] = tmp_item
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
                        else:
                            result[int(tmp_result['Pid'])] = tmp_result
                            
                except IOError as e:
                    pass
                except Exception as e:
                    pass
        return result
    
    def getVersion(self,as_dictionary=False):
        result = self._version
        if as_dictionary == True:
            result = {'major': self._major, 'minor': self._minor, 'subversion': self._subversion }

        return result

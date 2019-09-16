#!/usr/bin/env python3
from __future__ import print_function
import sys
import os
import time
sys.path.append('..')
import childmgt.ChildMgt

def create_children(num_children=5):
    for child_num in range(0, num_children):
        child_pid = os.fork()
        if child_pid == 0:
            time.sleep(3)
            sys.exit(0)
    for child_num in range(0, num_children):
        child_pid = os.fork()
        if child_pid == 0:
            time.sleep(3)
            sys.exit(1)


def main():
    result = 0
    create_children()
    yyy = childmgt.ChildMgt.ChildMgt()
    print("Checking Count Zombies=",yyy.countZombiedChild())
    print("Sleeping wait for children to exit.")
    time.sleep(30)
    print("back from sleep")
    print("Count Zombies=",yyy.countZombiedChild())
    print("Reaping Status.")
    child_status = yyy.reapZombieChildStatus()
    for key in child_status.keys():
        if os.WIFEXITED(child_status[key]) is True:
            print("pid:", key, "status:",os.WEXITSTATUS(child_status[key]))
        else:    
            print("pid:", key, "status:",child_status[key])

    print("Child status: ",child_status)
    print("Sleeping for 120 seconds")
    time.sleep(120)
    
    return result


if __name__ == "__main__":
    result = main()
    sys.exit(result)
    

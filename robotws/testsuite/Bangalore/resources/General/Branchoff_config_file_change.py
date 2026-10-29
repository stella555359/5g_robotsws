""""Python program for porting CRT branch .json folder.

Whenever branch off happens this program creates new branch folder and copy the required .json files to it
For Example: SBTS23R1,SBTS23R2, SBTS23R3 etc

"""

import os
import sys
import time
import shutil


def new_branch(root, old_b, new_b):
    # Author:Bhuvaneshwari Sikkargol@Nokia.com
    startstime = time.time()
    print(os.listdir(root))
    for path, subdirs, files in os.walk(root):
        for name in subdirs:
            if name == "config":
                src_path = os.path.join(path + "/config/"+old_b)
                dst_path = os.path.join(path + "/config/"+new_b)
                if os.path.exists(src_path):
                    cmd = os.system("rm -rf " + os.path.join(path + "/config/"+new_b))
                    shutil.copytree(src_path, dst_path)
                    print(new_b, "folder created and updated")
                else:
                    print(old_b, "folder not found")
    endtime = time.time()
    totaltime = endtime-startstime
    print(totaltime)


if __name__ == "__main__":
    new_branch("/home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/", "SBTS25R1", "SBTS25R2")

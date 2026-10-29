""""Python program for CRT porting.

this program removes old branch tag and add new branch tag in .robot file and also modifies the .qc files accordingly
For Example: SBTS23R1,SBTS23R2, SBTS23R3 etc
"""


import os
import sys
import time


def new_tag_addition(root, old_tag, new_tag, old_qc_pattern, new_qc_pattern):
    # Author:Bhuvaneshwari.sikkargfol@nokia.com
    for dir, subdirs, names in os.walk(root):
        for name in names:
            if name.endswith(".robot"):
                path = os.path.join(dir, name)
                text = open(path).read()
                if old_tag in text:
                    open(path, 'w').write(text.replace(old_tag, new_tag))
                    continue
            elif name.endswith(".qc"):
                path = os.path.join(dir, name)
                text = open(path).read()
                if old_qc_pattern in text:
                    open(path, 'w').write(text.replace(old_qc_pattern, new_qc_pattern, 2))
            else:
                continue


if __name__ == "__main__":
    new_tag_addition("/home/ute/robotws/testsuite/Bangalore/RRM/5GET_BLR/", "SBTS22R4", "SBTS23R1", "22R4", "23R1")

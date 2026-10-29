import re
import os
from random import shuffle

log_start_num = 1
# robot_cmd = "robot -L trace -v SNAPSHOT_FLAG:pass:False,fail:False -v SOS_REPORT_FLAG:pass:False,fail:False " \
#             "-v PM_COUNTER_INTERVAL:1min -d /home/ute"
robot_cmd = "robot -L trace"
robot_file_list = """
"""
cases_to_execute = robot_file_list.strip().splitlines()
current_dir = os.getcwd()
case_file = os.path.join(current_dir, "cases_list.txt")
# shuffle(cases_to_execute)

print("cases list: %s" % len(cases_to_execute))
with open(case_file, "w") as fd:
    for i in range(len(cases_to_execute)):
        fd.write("%s -l log_%03d.html -o output_%03d.xml '%s'\n" %
                 (robot_cmd, i + log_start_num, i + log_start_num, cases_to_execute[i]))

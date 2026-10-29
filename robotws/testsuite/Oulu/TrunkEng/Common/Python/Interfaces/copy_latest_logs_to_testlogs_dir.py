r"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

With this script users who are using local environments are able to save logs that are created after robot test run to
test testrun logs, f.ex. log.html. If logs are not copied to test log folder they will be overwritten when next test run
is done.

This script can be run after robot test run by adding: "& python testsuite\Oulu\TrunkEng\Common\Python\Interfaces\
copy_latest_logs_to_testlogs_dir.py" after test run command
For example:
robot testsuite\Oulu\TrunkEng\OMKPI\Robot\TestCases\omkpi_block_unblock_all_cells.robot & python
testsuite\Oulu\TrunkEng\Common\Python\Interfaces\copy_latest_logs_to_testlogs_dir.py

NOTE it is assumed that the files found from robotws test run folder are from the latest test run, if f.ex. debug.log is
there, but it is not started in the latest run it will be collected anyway.
"""

import os
import shutil

current_dir = os.getcwd()
print("Current dir: {}".format(current_dir))

sub_dirs = [d for d in os.listdir('.') if os.path.isdir(d)]
latest_subdir = max(sub_dirs, key=os.path.getmtime)
print("Latest subdir: {}".format(latest_subdir))

log_html = os.path.join(current_dir, "log.html")
report_html = os.path.join(current_dir, "report.html")
output_xml = os.path.join(current_dir, "output.xml")
debug_log = os.path.join(current_dir, "debug.log")

if os.path.exists(log_html):
    shutil.copy(log_html, os.path.join(latest_subdir, "log.html"))
    print("log.html copied to folder {}".format(latest_subdir))
if os.path.exists(report_html):
    shutil.copy(log_html, os.path.join(latest_subdir, "report.html"))
    print("report.html copied to folder {}".format(latest_subdir))
if os.path.exists(output_xml):
    shutil.copy(log_html, os.path.join(latest_subdir, "output.xml"))
    print("output.xml copied to folder {}".format(latest_subdir))
if os.path.exists(debug_log):
    shutil.copy(log_html, os.path.join(latest_subdir, "debug.log"))
    print("debug.log copied to folder {}".format(latest_subdir))

#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#prerequisite: the specified load is already downloaded, activated
# and operational, eg. json installed
#Executes the TC 5GC000791_AC07TDD_SA.robot
#does not send the report to reporting portal
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV328/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GC000791/TestCases/5GC000791_AC07TDD_SA.robot\
 --tc-log-dir /home/localuser/CV328_ExecLogs_EDA_Feat791/\
 --username ncaudy

# --qc-report\
# --qc-file ../../../5GC000791/TestCases/5GC000791.qc

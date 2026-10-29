#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Executes the TC 5GC002093_A05_A11_A14_D3_D6.robot
#sends the report to reporting portal which updates Quality Center only if the test is PASS
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV328/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-robot-opts "\-\-dryrun"\
 --tc-files-or-dirs\
   ../../../5GC002093/tests/5GC002093_A05_A11_A14_D3_D6.robot\
 --tc-log-dir ~/CV328_ExecLogs_Feat2093/\
 --username ncaudy

# --gnb-dl-only\

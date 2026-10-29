#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#prerequisite: the specified load is already downloaded, activated
# and operational, eg. json installed
#Executes the TC 5GC002093_A05_A11_A14_D3_D6.robot
#sends the report to reporting portal which updates Quality Center only if the test is PASS
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV328/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GC002093/tests/5GC002093_A05_A11_A14_D3_D6.robot\
 --tc-robot-opts "\-\-dryrun"\
 --tc-log-dir ~/CV328_ExecLogs_Feat2093/\
 --username ncaudy

#python ${runner_dir}/../python/tc_runner.py\
# --conf-dir ~/TafProject/robotws/testsuite/Paris/RRM/ST/5GC002093/tests/CV328/\
# --gnb-builds $1\
# --gnb-target-directory /5gswload/CIT_load/\
# --tc-files-or-dirs\
#   ../../../5GC002093/tests/5GC002093_A05_A11_A14_D3_D6.robot\
# --tc-log-dir ../../../5GC002093/tests/logs/\
# --username ncaudy\
# --qc-report\
# --qc-file ../../../5GC002093/tests/5GC002093_A05_A11_A14_D3_D6.qc

# --qc-report\
# --qc-file ../../../5GC002093/tests/5GC002093_A05_A11_A14_D3_D6.qc

#   ../../../5GC002093/tests/5GC002093_A05_A11_A14_D3_D6.robot\
# --gnb-target-directory /5gswload/CIT_load/\
# --tc-robot-opts "\-\-dryrun"
# --gnb-dl-only
# --gnb-yaft\
# --tc-robot-opts "\-\-dryrun \-i B_361 \-i C_423"\

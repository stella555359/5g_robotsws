#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/TafProject/robotws/config_CV45/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC000511/TestCases/5GC000511_E_132_133_NSA_trunk.robot\
   ../../../5GC000517/TestCases/\
   ../../../5GC001301/TestCases/5GC001301_AA_3_trunk.robot\
   ../../../5GC001304/TestCases/5GC001304_RR_004_trunk.robot\
   ../../../5GC001695/TestCases/\
 --tc-log-dir /tmp\
 --tc-robot-opts "\-i B_361 \-i C_423"\
 --qc-report\
 --qc-file\
   ../../../5GC000511/TestCases/5GC000511.qc\
 --username crasnie1


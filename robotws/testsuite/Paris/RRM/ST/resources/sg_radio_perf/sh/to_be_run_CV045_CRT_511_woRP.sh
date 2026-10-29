#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC000511/TestCases/5GC000511_E_132_133_NSA_trunk.robot\
 --tc-log-dir /tmp\
 --tc-robot-opts "\-e E_133"\
 --username crasnie1



#--tc-robot-opts ""\
# --qc-report\
# --qc-file\
#   ../../../5GC000511/TestCases/5GC000511.qc\

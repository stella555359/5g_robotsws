#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC000517/TestCases/\
 --tc-log-dir /tmp\
 --tc-robot-opts "\-i B_361 \-i C_423"\
 --qc-report\
 --qc-file\
   ../../../5GC000517/TestCases/5GC000517.qc\
 --username crasnie1



#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC000517/TestCases/\
 --tc-log-dir /tmp\
 --tc-robot-opts "\-e B_255 \-e B_256 \-e B_359 \-e B_361 \-e C_422"\
 --qc-report\
 --qc-file\
   ../../../5GC000517/TestCases/5GC000517.qc\
 --username crasnie1



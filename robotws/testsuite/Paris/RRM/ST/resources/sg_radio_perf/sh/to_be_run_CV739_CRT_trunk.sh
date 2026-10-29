#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV739/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../CB008406/TestCases/CB008406_5G_A_005-UL_007-DL.robot\
 --tc-log-dir /tmp\
 --tc-robot-opts ""\
 --qc-report\
 --username crasnie1

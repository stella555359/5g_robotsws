#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC001695/TestCases/5GC001695_A_024_class_coam_qualcomm_Trunk.robot\
 --tc-log-dir /tmp\
 --tc-robot-opts ""\
 --qc-report\
 --username crasnie1

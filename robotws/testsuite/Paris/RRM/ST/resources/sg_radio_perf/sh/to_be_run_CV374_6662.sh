#!/bin/bash
runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV374/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/\
 --gnb-dl-only\
 --tc-files-or-dirs\
   ../../../CB006662/TestCases/\
 --tc-log-dir /tmp\
 --tc-robot-opts ""\
 --qc-report\
 --qc-file\
  ../../../CB006662/TestCases/CB006662.qc\
 --username tmariko

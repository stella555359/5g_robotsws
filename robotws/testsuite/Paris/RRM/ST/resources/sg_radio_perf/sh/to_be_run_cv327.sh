#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLOUDSV327/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../CNI_71783/tests/CNI71783.robot\
 --tc-log-dir /tmp\
 --qc-report\
 --qc-file ../../../CNI_71783/tests/CNI71783.qc\
 --username mbouaddi

# --gnb-dl-only\

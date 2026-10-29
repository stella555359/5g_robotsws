#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV048/\
 --gnb-builds $1\
 --gnb-dl-only\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
    ../../../CB008124/tests/CB008124A.robot\
    --tc-log-dir /tmp\
 --qc-report\
 --qc-file ../../../CB008124/tests/CB008124.qc\
 --tc-robot-opts "\-e B_255 \-e B_256 \-e B_359 \-e C_422"\
 --username gbonhaur

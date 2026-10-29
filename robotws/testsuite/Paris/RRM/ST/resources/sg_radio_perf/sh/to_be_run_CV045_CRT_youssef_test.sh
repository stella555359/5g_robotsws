#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/ --gnb-builds $1 --gnb-target-directory /5gswload/CIT_load/ --gnb-dl-only\
 --tc-files-or-dirs\
   ../../../5GC001695/TestCases/\
   ../../../5GC000511/TestCases/5GC000511_E_132_133_NSA_trunk.robot\
 --tc-log-dir /tmp --tc-robot-opts "\-\-dryrun \-e B_255 \-e B_256 \-e B_359 \-e C_422"\
 --qc-report --username yleulmi

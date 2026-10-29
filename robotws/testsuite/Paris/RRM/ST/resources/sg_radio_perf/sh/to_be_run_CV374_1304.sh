#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV374/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/\
 --tc-files-or-dirs\
   ../../../5GC001304/TestCases/5GC001304_RR_004.robot\
 --tc-log-dir /tmp\
 --qc-report\
 --qc-file\
  ../../../5GC001304/TestCases/5GC001304.qc\
 --username dutheil1


# --tc-robot-opts "\-\-dryrun"\
# --tc-robot-opts "\-\-dryrun \-i B_361 \-i C_423"\
# --gnb-dl-only\
#   ../../../5GC000511/TestCases/5GC000511_E_132_133_NSA_trunk.robot\

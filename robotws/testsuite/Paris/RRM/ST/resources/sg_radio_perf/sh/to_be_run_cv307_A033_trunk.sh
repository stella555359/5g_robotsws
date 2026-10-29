#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV307/\
 --gnb-builds $1\
 --gnb-target-directory /tmp\
 --gnb-dl-only\
 --tc-files-or-dirs\
   ../../../5GC000937A/tests/5GC000937A033trunk.robot\
 --tc-log-dir ~/test_results\
 --qc-report\
 --qc-file ../../../5GC000937A/tests/5GC000937A.qc\
 --username crasnie1



# --tc-robot-opts "\-\-dryrun"\
# --qc-report\
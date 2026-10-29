#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV307/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS23R2/\
 --tc-files-or-dirs\
   ../../../5GC000937A/tests/5GC000937A021.robot\
 --tc-log-dir ~/test_results\
 --username crasnie1
# --qc-report\


# --qc-file ../../../5GC000937A/tests/5GC000937A.qc\

# --gnb-dl-only\
# --tc-robot-opts "\-\-dryrun"\
# --gnb-target-directory /tmp\


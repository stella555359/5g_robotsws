#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV307/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS24R3/\
 --tc-files-or-dirs\
   ../../../5GC000937A/tests/5GC000937A031A054.robot\
 --tc-log-dir ~/test_results\



# --qc-report\
# --qc-file ../../../5GC000937A/tests/5GC000937A.qc\
# --username crasnie1



# --gnb-dl-only\
# --tc-robot-opts "\-\-dryrun"\
#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV307/\
 --gnb-builds $1\
 --gnb-target-directory /tmp\
 --tc-files-or-dirs\
   ../../../5GC000937A/tests/5GC000937A053trunk.robot\
 --tc-log-dir ~/test_results

# --gnb-dl-only\
# --qc-report\
# --tc-robot-opts "\-\-dryrun"\
# --qc-file ../../../5GC000937A/tests/5GC000937A.qc\
# --username ncaudy

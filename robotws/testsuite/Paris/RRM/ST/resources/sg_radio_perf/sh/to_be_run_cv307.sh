#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV307/\
 --gnb-builds $1\
 --gnb-target-directory /tmp\
 --gnb-dl-only\
 --tc-files-or-dirs\
   ../../../5GC000937A/tests/5GC000937A021.robot\
   ../../../5GC000937A/tests/5GC000937A022.robot\
   ../../../5GC000937A/tests/5GC000937A031.robot\
   ../../../5GC000937A/tests/5GC000937A032.robot\
 --tc-log-dir ~/test_results\
 --tc-robot-opts "\-\-dryrun"\
 --username mmiloudi

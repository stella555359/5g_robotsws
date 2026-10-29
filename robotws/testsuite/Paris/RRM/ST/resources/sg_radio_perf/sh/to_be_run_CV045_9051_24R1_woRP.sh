#!/bin/bash
runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $1\
 --gnb-dl-only\
 --gnb-target-directory /5gswload/SBTS24R1/\
 --tc-files-or-dirs\
   ../../../CB009051/TestCases/\
 --tc-log-dir ~/test_results\
 --username crasnie1


# --tc-robot-opts "\-\-dryrun"\
# --gnb-dl-only\
#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --username ymaurin\
 --gnbs  10.14.49.123\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV112/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GCounters/TestCases/Counters_5G_1000.robot\
 --tc-log-dir /home/localuser/Traces/auto/test_$2\
 --qc-report\
 --qc-file ../../../5GCounters/TestCases/Counters_5G_1000.qc

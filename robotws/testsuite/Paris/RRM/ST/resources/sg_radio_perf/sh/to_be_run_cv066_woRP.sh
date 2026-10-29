#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV066\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../CB008172/TestCases/5GC008172_PRISMA.robot\
 --tc-log-dir /tmp\
 --username ncaudy

#  --tc-robot-opts "\-\-dryrun"\
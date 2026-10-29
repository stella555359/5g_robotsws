#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --username nsoumaho\
 --gnbs  10.14.49.123\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV112/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GC006662/TestCases/5GC006662_S0_IntraDU_MeasA3_Qualcomm.robot\
 --tc-log-dir /home/localuser/Traces/auto/test_$2\
 --qc-report\
 --qc-file ../../../5GC006662/TestCases/5GC006662_SA.qc

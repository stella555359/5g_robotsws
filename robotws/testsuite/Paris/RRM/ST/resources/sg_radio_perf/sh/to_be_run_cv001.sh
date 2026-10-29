#!/bin/bash
runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV001/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/\
 --gnb-dl-only\
 --tc-files-or-dirs\
   ../../../5GC000LA/TestCases/5GC000LA3T.robot\
   --tc-log-dir /tmp\
 --tc-robot-opts "-v LA_TESTNAME:FB2323_23R4_AWGN_ABIO_6db -v LA_IATTEN:14 -v LA_FATTEN:74 -v LA_TRAFICTYPE:DL -v LA_STEP:1 "\
 --username mmiloudi

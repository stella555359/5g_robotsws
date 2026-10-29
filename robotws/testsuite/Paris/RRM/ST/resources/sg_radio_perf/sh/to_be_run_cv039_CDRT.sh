#!/bin/bash
runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV039/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/\
 --tc-files-or-dirs\
   ../../../5GC000533_A/5GC000533_A_102_L1L2_Pattern_Configreq_Checker_1116_0ms_96_beamset1_60deg_10ms.robot\
   --tc-log-dir /traces/\
 --qc-report\
 --qc-file ../../../5GC000533_A/5GC000533_A.qc\
 --username tmariko

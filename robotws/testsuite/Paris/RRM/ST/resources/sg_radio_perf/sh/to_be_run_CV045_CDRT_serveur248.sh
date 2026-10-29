#!/bin/bash
runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/TafProject/robotws/config_CV45_trafficserveur_10.0.106.248/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC000517/TestCases/\
   ../../../5GC001301/TestCases/5GC001301_AA_3_trunk.robot\
   ../../../5GC001304/TestCases/5GC001304_RR_004_trunk.robot\
   ../../../5GC000791/TestCases/5GC000791_AC2FDD_AC4FDD_AC5TDD_AC6TDD_NSA_Trunk.robot\
 --tc-log-dir /tmp\
 --tc-robot-opts "\-e B_255 \-e B_256 \-e B_359 \-e C_422"\
 --qc-report\
 --username crasnie1

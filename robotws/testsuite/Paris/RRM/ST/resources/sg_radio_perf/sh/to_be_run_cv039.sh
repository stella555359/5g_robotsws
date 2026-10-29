#!/bin/bash
runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV039/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/\
 --gnb-dl-only\
 --tc-files-or-dirs\
   ../../../5GC000533_A/5GC000533_A_102_L1L2_Pattern_Configreq_Checker_1116_0ms_96_beamset1_60deg_10ms.robot\
   ../../../FGCR_3077B/FGCR_3077B_001_002_007_BC_RefinementOff_SRB3Off_DL2x2MIMO_NSA.robot\
   --tc-log-dir /tmp/traces\
 --tc-robot-opts "\-\-dryrun"\
 --username tmariko

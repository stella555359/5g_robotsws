#!/bin/bash
runner_dir=`dirname "$(realpath $0)"`

python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV039/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/\
 --tc-files-or-dirs\
   ../../../FGCR_3077B/FGCR_3077B_001_002_007_BC_RefinementOff_SRB3Off_DL2x2MIMO_NSA.robot\
 --tc-log-dir /traces\
 --qc-report\
 --qc-file ../../../FGCR_3077B/FGCR_3077B.qc\
 --username tmariko

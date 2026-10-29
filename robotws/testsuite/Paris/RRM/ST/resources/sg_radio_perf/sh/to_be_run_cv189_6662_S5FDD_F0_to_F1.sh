#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --username nsoumaho\
 --gnbs  10.14.49.164\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV112/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GC006662/TestCases/5GC006662_S5FDD_IntraDU_TDD_F0_FDD_F1_Qualcomm.robot\
 --tc-log-dir /home/localuser/Traces/auto/test_$2\
 --qc-report\
 --qc-file ../../../5GC006662/TestCases/5GC006662_SA.qc

 

#Re run tc found in xml found in the list dir for the specified loads
# python ${runner_dir}/../python/tc_runner.py\
#  --conf-dir ~/dev/testline_configuration/CV112\
#  --gnb-builds $1\
#  --gnb-target-directory /5gswload/CIT_load/\
#  --gnb-dl-only\
#  --tc-log-dir /tmp/\
#  --tc-robot-opts "\-\-dryrun"\
#  --tc-rerunfailed\
#     /tmp/5GC000706_S7MIMO/20220315-163516/\
#  #--qc-report


# JUST FOR EXAMPLE
#Execute every tc found on the directory and report to qc for the two specified loads
#python ${runner_dir}/tc_runner.py\
 #--conf-dir ~/dev/testline_configuration/CV112
 #--gnb-builds SBTS00_ENB_9999_220310_000007 SBTS00_ENB_9999_220310_000007\
 #--gnb-target-directory /5gswload/CIT_load/\
 #--gnb-dl-only\
 #--tc-files-or-dirs\
    #../../../5GC000706/TestCases/5GC000706_S0_IntraDU_MeasA3_Qualcomm_asik_withOnlyJ.robot\
 #--tc-log-dir /tmp\
 #--qc-report

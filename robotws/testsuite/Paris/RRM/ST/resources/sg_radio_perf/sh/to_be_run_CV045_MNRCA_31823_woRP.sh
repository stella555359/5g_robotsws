#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../MNRCA_31823/TestCases/MNRCA_31823_class_coam_qualcomm_NSA_Trunk.robot\
 --tc-log-dir /tmp\
 --tc-robot-opts ""\
 --username crasnie1

# --qc-report\
# --qc-file\
#   ../../../5GC000791/TestCases/5GC000791_AC7FDD_NSA.robot\
#   ../../../5GC000511/TestCases/5GC000511.qc\
# --tc-robot-opts "\-\-dryrun \-i B_361 \-i C_423"\
# --gnb-dl-only\

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

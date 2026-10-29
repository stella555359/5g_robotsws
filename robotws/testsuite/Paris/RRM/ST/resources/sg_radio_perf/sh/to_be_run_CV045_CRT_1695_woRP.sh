#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV045/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC001695/TestCases/5GC001695_A_024_class_coam_qualcomm_Trunk.robot\
   ../../../5GC001695/TestCases/5GC002522_FC_002_class_coam_qualcomm_Trunk.robot\
 --tc-log-dir /tmp\
 --tc-robot-opts ""\
 --username crasnie1


# --tc-robot-opts "\-\-dryrun"\
# --tc-robot-opts "\-\-dryrun \-i B_361 \-i C_423"\
# --gnb-dl-only\
#   ../../../5GC000511/TestCases/5GC000511_E_132_133_NSA_trunk.robot\

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



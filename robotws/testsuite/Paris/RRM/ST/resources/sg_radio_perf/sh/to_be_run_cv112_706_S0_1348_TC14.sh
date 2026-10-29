#!/bin/bash

# --username nsoumaho\
# --qc-report\
# --qc-file ../../../5GC000706/TestCases/5GC000706_SA.qc

runner_dir=`dirname "$(realpath $0)"`


#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --gnbs  10.14.49.123\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV112/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GC000706/TestCases/5GC000706_S0_IntraDU_MeasA3_Qualcomm_asik_withOnlyJ.robot\
 --tc-log-dir /home/localuser/Traces/auto/test_$2\


 
 
#Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --gnbs  10.14.49.123\
 --conf-dir ~/testline_configuration/7_20_UTE5GCLASSSV112/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/CIT_load/\
 --tc-files-or-dirs\
   ../../../5GC001348/TestCases/5GC001348_A_014_SA_Uplink_Channel_Multiplexing_ON_1_Ue_PUSCH_FDM_7827.robot\
 --tc-log-dir /home/localuser/Traces/auto/test_$2\



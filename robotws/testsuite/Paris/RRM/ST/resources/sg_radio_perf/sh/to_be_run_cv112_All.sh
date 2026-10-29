#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

# Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/TafProject/robotws5g/config_CV112_updated/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GC001348/TestCases/5GC001348_A_014_SA_Uplink_Channel_Multiplexing_ON_1_Ue_PUSCH_FDM_7827.robot\
 --tc-log-dir /home/localuser/Traces/auto/test_$2\
 --qc-report\
 --gnb-dl-only\
 --qc-file ../../../5GC001348/TestCases/5GC001348_A.qc\
 --username mmiloudi
 
# Add part to change scf auto
# Execute as dryrun every tc found on the list for the specified load
python ${runner_dir}/../python/tc_runner.py\
 --conf-dir ~/TafProject/robotws5g/config_CV112_updated/\
 --gnb-builds $1\
 --gnb-target-directory /5gswload/SBTS00_TRUNK/\
 --tc-files-or-dirs\
   ../../../5GC000706/TestCases/5GC000706_S0_IntraDU_MeasA3_Qualcomm_asik_withOnlyJ.robot\
 --tc-log-dir /home/localuser/Traces/auto/test_$2\
 --qc-report\
 --qc-file ../../../5GC000706/TestCases/5GC000706_SA.qc\
 --username 'mmiloudi'\
 --gnb-dl-only

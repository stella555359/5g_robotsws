#!/bin/bash

runner_dir=`dirname "$(realpath $0)"`

#Execute as dryrun every tc found on the list for the specified load
#python ${runner_dir}/tc_runner.py\
 #--conf-dir ~/dev/youssef/robotws5g_read_only_to_keep/config/7_20_CLASS5GPSIV039\
 #--gnb-builds SBTS00_ENB_9999_220202_000001\
 #--gnb-target-directory /5gswload/CIT_load/\
 #--gnb-dl-only\
 #--tc-files-or-dirs\
    #../../../5GC002515_A_AD/TestCases\
    #~/dev/youssef/robotws5g/testsuite/RRM/NPS_IV/5GC001348/TestCases/5GC001348_A_015_SA_Uplink_Channel_Multiplexing_OFF_Check_Call_Success.robot\
 #--tc-log-dir /tmp\
 #--tc-robot-opts "\-\-dryrun"\

#Execute every tc found on the directory and report to qc for the two specified loads
#python ${runner_dir}/tc_runner.py\
 #--conf-dir ~/dev/youssef/robotws5g_read_only_to_keep/config/7_20_CLASS5GPSIV039\
 #--gnb-builds SBTS00_ENB_9999_220202_000001 SBTS00_ENB_9999_220202_000001\
 #--gnb-target-directory /5gswload/CIT_load/\
 #--gnb-dl-only\
 #--tc-files-or-dirs\
    #../../../5GC002515_A_AD/TestCases\
 #--tc-log-dir /tmp\
 #--qc-report

#Re run tc found in xml found in the list dir for the specified loads
python ${runner_dir}/tc_runner.py\
 --conf-dir ~/dev/youssef/robotws5g_read_only_to_keep/config/7_20_CLASS5GPSIV039\
 --gnb-builds SBTS00_ENB_9999_220202_000001\
 --gnb-target-directory /5gswload/CIT_load/\
 --gnb-dl-only\
 --tc-log-dir /tmp/pouet/\
 --tc-robot-opts "\-\-dryrun"\
 --tc-rerunfailed\
    /tmp/5GC002515_A/20220223-113802/\
    /tmp/5GC002515_A/20220223-113802/5GC002515_A_8_5GC002515_A_TC_08_NSA_CLASSICAL_FR1_TDD_eCPRI_UL_4RX_SU_MIMO_with_Traffic_2SSB_output.xml\
 --qc-report

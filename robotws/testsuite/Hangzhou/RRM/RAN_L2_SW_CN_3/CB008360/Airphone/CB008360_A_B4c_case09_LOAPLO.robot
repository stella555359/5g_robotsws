# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang 
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_case09_LOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D4U_LOAPLO.xml
# ${WTS_NAME}    wts_8360_case1_LOAPLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          1
# ${UE_ID2}          2
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${BIP_TAG}    srs
# ${FILTER}           uldata_puschreceivereq&&!(3gpp.rnti==65535)
# @{titles}   UlData.patternId_item
# @{Rdparameter}    0x58037C:1    0x58054D:1
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2	
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${phr_override_profile_1_CMD}    phr_override_testmode_nr profile_id\=1 phr_mode\=Fixed phr_start\=2
# ...    phr_min\=2 phr_max\=40 phr_step_size\=1 phr_period\=20 pc_max\=30
# ${phr_activate_p1_CMD}    ue_testmode_set_nr id\=1,2,4 scell\=primary testmode\=phr_override profile_id\=1 action\=activate
# ${UE_NUM}         8
# ${UE_ID}          1
# ${UE_ID2}          2
# ${UE_ID3}          3
# ${UE_ID4}          4
# ${UE_ID5}          5
# ${UE_ID6}          6
# ${UE_ID7}          7
# ${UE_ID8}          8
# ${SLICE_ID}       1				  
# 					  
# *** Test Cases ***
# CB008360_A_B4c_case09_4_rank1_Mix_Ues_paired_and_MU_SINR_estimation
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set multiue traffic type to internal
#     Attach '4' ue to 5g cell
#     Set ue position
#     SA send dl and ul data    ${UE_ID}    number=1    dl_data=10M    ul_data=70M
#     SA send dl and ul data    ${UE_ID2}    number=1    dl_data=10M    ul_data=70M    pdu_id=2
#     SA send dl and ul data    3    number=1    dl_data=10M    ul_data=70M    pdu_id=3
#     SA send dl and ul data    4    number=1    dl_data=10M    ul_data=70M    pdu_id=4
# 	airphone_execute_egate_command   ${phr_override_profile_1_CMD}
# 	airphone_execute_egate_command   ${phr_activate_p1_CMD}
#     #Start collect bip log
#     Start collect ttitrace
#     Wait for '4s' to stop ttitrace with name'tti'
#     #Wait for '0s' to stop bip log with name'bip'
#     run keyword and continue on failure    Check ue tput is correct
#     Detach '4' UE
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     check bler and pair is correct in ttitrace 
# *** Keywords ***
# Attach '${uenum}' ue to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible	
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# Ttitrace
# 	Start collect ttitrace
# 	Wait for '1s' to stop ttitrace with name'tti'
# 	run keyword and continue on failure    check SAthroughput
# 	run keyword and continue on failure    check bler and pair is correct in ttitrace  
# Test NSA ue
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 	Execute AP Command before attach
# 	Start collect ttitrace
#     Attach LTE 2UE
# 	Set ue position
# 	NSA send ue 100M UL data 100M DL data
# 	Wait for '2s' to stop ttitrace with name'tti'
#     run keyword and continue on failure    check throughput
#     Airphone NSA Detach    ${UE_ID}
#     Airphone NSA Detach    ${UE_ID_2}
# 	run keyword and continue on failure    airphone_cleanup_egate_console_log
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     check bler and pair is correct in ttitrace   
# #Prepare test
#     #Active GNB L2 feature debug traces
#     #Modify 8360 Swconfig
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=8    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000	
# Check SAthroughput
#     Wait until keyword succeeds    60s    5s    Verify SAthroughput
# Verify SAthroughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>50000		
# Wait '${time}' for stabible
#     sleep    ${time}
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     airphone_execute_egate_command    ${X2_CMD}
# Attach LTE 2UE
#     Airphone Nsa Attach    ${UE_ID}	
# 	Airphone Nsa Attach    ${UE_ID2}	
# Regist SA 2ue	
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${UE_ID}
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    ${UE_ID2}    PDU_ID=2    GW_ID=2	
# SA send ue 100M UL data 100M DL data	
#     SA send dl and ul data    ${UE_ID}    number=1   ul_data=100M    dl_data=100M
#     SA send dl and ul data    ${UE_ID2}    number=1  ul_data=100M    dl_data=100M    pdu_id=2	
# check bler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case02.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check lowsinr in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_case02_lowsinr.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 		
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '1s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '1s' for stabible	
# 	  Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Wait '1s' for stabible
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
# Set SAue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_SAPROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_SAPROFILE2}
# Modify 8360 Swconfig
#     #Add GNB swconfig    @{Rdparameter}
# Wait time to stable
#     sleep    2s
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     ${dl_tput3}    ${ul_tput3}    Obtain one sa ue dl and ul throught    3    pdu_id=3
#     ${dl_tput4}    ${ul_tput4}    Obtain one sa ue dl and ul throught    4    pdu_id=4
#     run keyword and continue on failure    Should be true    ${ul_tput1}+${ul_tput2}+${ul_tput3}+${ul_tput4}>130000    
#     
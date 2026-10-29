# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS23R1
# ...   CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_b_case03_MPAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_b_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD_LOAPLO.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# @{Rdparameter}   
#     ...    0x58054E:1    0x580549:19    0x580548:40    0x58054C:0    0x58054D:11    0x58054B:5
#     ...    0x580547:1    0x580546:10    0x58054A:1    0x580543:50    0x580544:3    0x580545:2
#     ...    0x58059A:1    0x58059B:1
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=2 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# 
# *** Test Cases ***
# #CB008360_B_B1a_case03_two_rank1_Ues_8DL8UL_Max_4Layer_without_tapering     #penny
# CB008360_B_B1a_case03_two_rank2_Ues_16DL8UL_Max_4Layer_onlinechange_actUlMuEnhance_without_tapering
# 	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    t2r4_n2    1	   PDU_ID=1    GW_ID=1
#     Attach SA ue to 5g cell    t2r4_n2    2    PDU_ID=2    GW_ID=2
#     Set ue position
# 
#     SA send dl and ul data    1    number=3    dl_data=10M    ul_data=160M	  pdu_id=1
#     SA send dl and ul data    2    number=3    dl_data=10M    ul_data=160M    pdu_id=2
#     Stop egate log and unzip with name'pair'
# 
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Wait Until Keyword Succeeds    60s    2s   check_tp
# 
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'b_case3_stable'
#     
#     run keyword and continue on failure     Check pair funcition is correct
#     DeRegister UE from '1' to '2'
# 	
# *** Keywords ***
# check_tp
# 	check throughput from UE '1' to '1' with tp '100'
# 	check throughput from UE '2' to '2' with tp '100'
# 
# check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
# 
# Prepare test
#     Active GNB L2 feature debug traces
#     Add GNB swconfig    @{Rdparameter}
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     should be true    ${ul_tput1}>100000
#     should be true    ${ul_tput2}>100000
# 
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
# 
# Check pair funcition is correct
#     Check Log With Au2anlysis    ${CURDIR}/ini/tti_b_case3_MOAPLO.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible

# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_pennwang    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    
# ...   CLOUD_5G_I_MO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8360_case4_MOAPLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQB_1CELL_LOAPLO.xml
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${WTS_NAME}    BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD_LOAPLO.cfg
# ${UE_ID}          1
# ${UE_ID2}          2
# @{Rdparameter}    
#     ...    0x58054E:1    0x580549:19    0x580548:40    0x58054C:0    0x58054D:11    0x58054B:5
#     ...    0x580547:1    0x580546:10    0x58054A:1    0x580543:50    0x580544:3    0x580545:2
#     ...    0x58059A:1    0x58059B:1        
#     ...    0x580550:7  
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=2 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=3 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=4 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# *** Test Cases ***
# CB008360_A_B4a_case04_4_rank1_Ues_paired_without_power_limit
#     Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    1    PDU_ID=1    GW_ID=1
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    2    PDU_ID=2    GW_ID=2
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    3    PDU_ID=3    GW_ID=3
#     Attach SA ue to 5g cell    t2r4_n2_pusch_1layer    4    PDU_ID=4    GW_ID=4
#     Set ue position
#      
#     SA send dl and ul data    1    number=2    dl_data=1M    ul_data=50M    pdu_id=1
#     SA send dl and ul data    2    number=2    dl_data=1M    ul_data=50M    pdu_id=2
#     SA send dl and ul data    3    number=2    dl_data=1M    ul_data=50M    pdu_id=3
#     SA send dl and ul data    4    number=2    dl_data=1M    ul_data=50M    pdu_id=4  
#     
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'case4'
#     
#     Stop egate log and unzip with name'pair'
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     run keyword and continue on failure    Check ue tput is correct
#     
#     Check pair funcition is correct
#     
#     airphone_sa_detach    ue_id=1    timeout=5
#     airphone_sa_detach    ue_id=2    timeout=5
#     airphone_sa_detach    ue_id=3    timeout=5
#     airphone_sa_detach    ue_id=4    timeout=5
#     
# 
# *** Keywords ***
# Prepare test
#     Active GNB L2 feature debug traces
#     Modify 8360 Swconfig
# 
# 
# Modify 8360 Swconfig
#     Add GNB swconfig    @{Rdparameter}
# 
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
#     Wait '2s' for stabible
# 
# 
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=2
#     ${dl_tput3}    ${ul_tput3}    Obtain one sa ue dl and ul throught    3    pdu_id=3
#     ${dl_tput4}    ${ul_tput4}    Obtain one sa ue dl and ul throught    4    pdu_id=4
#     should be true    ${ul_tput1}>35000
#     should be true    ${ul_tput2}>35000
#     should be true    ${ul_tput3}>35000
#     should be true    ${ul_tput4}>35000
# 
# Check pair funcition is correct
#     Check Log With Au2anlysis    ${CURDIR}/ini/tti_case4_LOAPLO.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 

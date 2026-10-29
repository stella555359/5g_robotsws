# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_NUM}          2
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${PDU_ID1}         1
# ${PDU_ID2}         2
# ${GW_ID1}          1
# ${GW_ID2}          1
# ${SLICE_ID}       1
# ${DU_SCF}        SCFC_VDU_8247_case25.xml
# ${CU_SCF}        SCFC_VCU_8247_case25.xml
# ${AIRPHONE_NAME}    iphy_2CELL.xml
# ${WTS_CFG}       basic_setup_loaplo.cfg
# @{LOG_NAME_LIST}    egatelog
# ${SET_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${SET_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# 
# 
# *** Test Cases ***
# CB009444_CB008247_A_b5_case25_two_UE_t2r4_frequency_multiplexing_SA_vran
#     AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
#     airphone_cleanup_egate_console_log
#     Set UE1 and UE2 Pos
#     Attach SA UE1 and UE2
#     Internal send DL data
#     Wait '30s' for stabible
#     run keyword and continue on failure    Check ue tput is correct
#     Collet VDU and VCU syslog
#     ${id}    VDU Start TTiTrace Log
#     Wait '5s' for stable
#     VDU Stop TTiTrace Log    ${id}
#     VDU Decode TTiTrace Log
#     #bip, default to capture l1,l2bip
#     VDU Start Collect Bip Logs
#     VDU Stop Collect And Download Bip Logs
# 
# 
# 
# *** Keywords ***
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    SA send mutiple trf dl data    ${num}    5    175M    pdu_id=${num}
#     \    Wait '3s' for stabible
# 
# 
# Wait '${time}' for stabible
#     sleep    ${time}
# 
# Set UE1 and UE2 Pos
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=1 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=3 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=100 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=5
# Attach SA UE1 and UE2
#     Airphone Set Traffic Type    ${UE_ID1}    ${PDU_ID1}    internal
#     Airphone Set Traffic Type    ${UE_ID2}    ${PDU_ID2}    internal
#     Airphone SA Attach    ue_id=${UE_ID1}
#     Airphone Pdu Session Setup    ${UE_ID1}    ${PDU_ID1}    ${SLICE_ID}    ${GW_ID1}
#     Wait '5s' for stabible
#     Airphone SA Attach    ue_id=${UE_ID2}
#     Airphone Pdu Session Setup    ${UE_ID2}    ${PDU_ID2}    ${SLICE_ID}    ${GW_ID2}
#     Wait '5s' for stabible
#     #airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Wait '10s' for stabible
# Check ue tput is correct
#     ${dl_tput1}    ${ul_tput1}    Obtain one sa ue dl and ul throught    ${UE_ID1}    pdu_id=${PDU_ID1}
#     ${dl_tput2}    ${ul_tput2}    Obtain one sa ue dl and ul throught    ${UE_ID2}    pdu_id=${PDU_ID2}
#     should be true    ${dl_tput1}>530000
#     should be true    ${dl_tput2}>530000
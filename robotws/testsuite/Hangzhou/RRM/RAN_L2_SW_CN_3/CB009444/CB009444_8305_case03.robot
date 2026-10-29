# *** Settings ***
# Test Timeout      60 minutes
# Suite Setup       AiC Common Suite Setup
# Suite Teardown    AiC Common Suite Teardown
# Test Setup        AiC Common Test Setup
# Test Teardown     AiC Common Test Teardown
# Force Tags        CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS00
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${CELL_ID}        0
# ${UE_NUM}          2
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${PDU_ID1}         1
# ${PDU_ID2}         2
# ${GW_ID1}          1
# ${GW_ID2}          1
# ${SLICE_ID}       1
# ${DU_SCF}        SCFC_VDU_8305.xml
# ${CU_SCF}        SCFC_VCU.xml
# ${AIRPHONE_NAME}    iphy_2CELL.xml
# ${WTS_CFG}       basic_setup_loaplo.cfg
# @{LOG_NAME_LIST}    egatelog
# ${SET_PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# ${SET_PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed test_type\=SRS init_quad_pos\=0 init_sub_quad_pos\=0
# ...    dtx_start\=10 num_dtx\=255 trigger_puxch_update\=0
# @{MO_DN_LIST}         MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1
# @{UPDATED_PARAS_DICT_LIST}    ${Modify_Params1}
# @{Modify_Params1}    dlMuMimoCorrThd:50
# @{Modify_Params2]}    dlMuMimoCorrThd:100
# *** Test Cases ***
# CB008305_A_B2_case03_two_rank2_Ues_paired_with_correlation_checking_vran
#     AIC Perform Full Commission And Reach Onair    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${DU_SCF}    
# 	...    ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/WTS/${WTS_CFG}     ${CONFIG_DIR_PATH}/${VDU_SW_BRANCH}/SCF/${CU_SCF}
#     airphone_cleanup_egate_console_log
#     Set UE1 and UE2 Pos
#     Attach SA UE1 and UE2
#     Internal send DL data
#     Wait '30s' for stabible
#     run keyword and continue on failure    Check ue tput is correct
#     Collet VDU and VCU syslog
#     #${id}    VDU Start TTiTrace Log
#     #Wait '5s' for stable
#     #VDU Stop TTiTrace Log    ${id}
#     #VDU Decode TTiTrace Log    csv_dir=${TEST_LOG_DIRECTORY()}/All/tti1/
#     #run keyword and continue on failure    Check mupair in ttitrace
#     #Online change correlation to 0
# 
# 
# 
# 
# *** Keywords ***
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    SA send mutiple trf dl data    ${num}    4    175M    pdu_id=${num}
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
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2
#     Wait '10s' for stabible
# Check ue tput is correct
#     ${dl_tput1}    Airphone Get Throughput On Specific Scell    ${UE_ID1}    ${CELL_ID}    type=pdsch
#     ${dl_tput2}    Airphone Get Throughput On Specific Scell    ${UE_ID2}    ${CELL_ID}    type=pdsch
#     should be true    ${dl_tput1}>530000
#     should be true    ${dl_tput2}>530000
# Check ue tput is correct for nopair
#     ${dl_tput1}    Airphone Get Throughput On Specific Scell    ${UE_ID1}    ${CELL_ID}    type=pdsch
#     ${dl_tput2}    Airphone Get Throughput On Specific Scell    ${UE_ID2}    ${CELL_ID}    type=pdsch
#     should be true    ${dl_tput1}>270000
#     should be true    ${dl_tput2}>270000
# Online change correlation to 0
#     Log To Console    online change correlation to 0...
#     VDU Online Change Parameters    ${MO_DN_LIST}      ${UPDATED_PARAS_DICT_LIST}
#     Wait '30s' for stabible
#     Check ue tput is correct for nopair
#     #${id}    VDU Start TTiTrace Log
#     #Wait '5s' for stable
#     #VDU Stop TTiTrace Log    ${id}
#     #VDU Decode TTiTrace Log    ${csv_dir}=${TEST_LOG_DIRECTORY()}/All/tti2
#     #Check mupair in ttitrace correlation 0
# 
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tti1
# 
# 
# Check mupair in ttitrace correlation 0
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tti2

# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD    owner_l10wang    AP
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_NUM}         5
# ${UE_ID}          1
# ${UE_5}           5
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      CNI70851_SCFC_2AEQE.xml
# ${AIRPHONE_NAME}    IPHY_2AEQE.xml
# ${WTS_NAME}       CNI70851_2AEQE_multiUE.cfg
# ${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# ${AP_SWCONFIG_NAME}     ap_swconfig.txt
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE1_A1_EVENT}    ue_measurement_send_nr id\=1 meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# *** Test Cases ***
# CNI71820_B_case14_Aperiodic_CSI_TDD_CA_with_scell_active_deactive_SA
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set multiue traffic type to internal
#     Attach SA UE
#     MultiUE send A1 Event
#     Start collect ttitrace
#     Send DL data to UE1 to UE5
#     Wait for '1s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Check throughput
#     Start collect ttitrace
#     Decrase DL data of UE5
#     Send little DL data to UE5
#     Wait for '1s' to stop ttitrace with name'tti1'
#     Check throughput
#     Check ttitrace again
#     Stop data transfer
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Detach UE
# 
# *** Keywords ***
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# Attach SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible
# MultiUE send A1 Event
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
#     \    Wait '2s' for stabible
# 
# Send DL data to UE1 to UE5
#     Send full DL and UL data to UE1 to UE4
#     Send little DL data to UE5
# 
# 
# Send full DL and UL data to UE1 to UE4
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}
#     \    Airphone SA Start Data Traffic    ${num}    DL    175M    pdu_id=${num}    duration=6000s    trf_id=${num}
#     \    Wait '1s' for stabible
# 
# 
# Send little DL data to UE5
#     Airphone SA Start Data Traffic    ${UE_5}    DL    50M    pdu_id=5     duration=6000s    trf_id=1
#     Wait '5s' for stabible
#     Check Scell active
# 
# Wait time to check throughput
#     ${remaining_time}    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '5s' for stabible
# 	
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
# 
# Check throughput
#     Wait '5s' for stabible
#     : FOR    ${num}    IN RANGE    1    6
#     \    Get and verify DL throughput average per ue    ${num}
# 
# Decrase DL data of UE5
#     Airphone SA Start Data Traffic    ${UE_5}    DL    10M    pdu_id=${UE_5}     duration=6000s    trf_id=1
#     Check Scell deactive
# 
# Get and verify DL throughput average per ue
#     [Arguments]    ${num}
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${dl_throughput_scell1}>0
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_acsi.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check ttitrace again
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_acsi_1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

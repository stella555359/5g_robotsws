# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4
# ...   CLOUD_5G_I_BLLL_AP_LOO
# Library           ta_a2a
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_1729_2CELL_case52_LO.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_lo_case52.xml
# ${WTS_NAME}       WTS_1729.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'    L2HI_L2LO_MIRRORING='true'
# @{LOG_NAME_LIST}    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${PMCOUNTERTIME}           120s
# @{Rdparameter}    0x10041:1
# *** Test Cases ***
# 5GC001729_Case52_B_4d_RLQ_based_scell_deactivation_with_drx
#     Modify Swconfig for AP
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     Set traffic type to internal
#     Attach ue with '2x2_2cc'capability to 5g cell
#     Internal send DL data
#     Check throughput
#     Override Scell CQI trigger bad threshold
#     #Check DRX counter
#     Override Scell CQI trigger good threshold and scell resume
#     Override Scell CQI trigger bad threshold
#     Check Scell deactive
#     Stop data transfer
#     Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Modify Swconfig for AP
#     Modify AP swconfig    @{Rdparameter}
# 
# Wait time to check throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     sleep    ${remaining_time}
# 
# Override Scell CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=2 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# Check Pcell throughput
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}==0
# 
# Override Scell CQI trigger good threshold and scell resume
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Check throughput
# 
# 
# Check PM counter scell no throughput
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01006    cell_id=2
#     run keyword if    ${PM_counter_value}>0    Check PM counter scell no throughput again
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Check PM counter Pcell have throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01006    cell_id=1
#     should be true    ${PM_counter_value}>0
# 
# 
# Check PM counter scell have throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01006    cell_id=2
#     should be true    ${PM_counter_value}>0
# 
# Internal send DL data
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    pdu_id=${PDU_ID}    duration=6000s    trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    pdu_id=${PDU_ID}    duration=6000s    trf_id=2
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    pdu_id=${PDU_ID}    duration=6000s    trf_id=3
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    pdu_id=${PDU_ID}    duration=6000s    trf_id=4
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    pdu_id=${PDU_ID}    duration=6000s    trf_id=5
# 
# 
# Check throughput
#      Wait '10s' for stabible
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}>0
# 
# 
# Check PM counter scell no throughput again
#     Wait time to check PM counter
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01006    cell_id=2
#     should be true    ${PM_counter_value}==0
# 
# 
# 
# analyse scelladd in rrclog
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/RRC_scelladd.ini    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check DRX counter
#     Wait '60s' for stabible
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_active}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=2
#     ${PM_counter_value_sleep}=     get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=2
#     ${value}    Evaluate    float(${PM_counter_value_sleep})/float(${PM_counter_value_active})
#     should be true   ${value}>6.98
#     should be true   ${value}<7.02
# 

# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    SBTS22R2    SBTS22R4
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      CNI70851_SCFC_case2.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_2CELL_CNI70851_case2.xml
# ${WTS_NAME}       SANSA7922_CNI70851_mutilue.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# ${CSI_CMD1}    csi_override_testmode_nr profile_id\=2 cqi\=15 ri_mode\=fixed ri\=1
#                ...     pmi_mode\=fixed pmi\=124 cri_mode\=fixed cri\=0 li_mode\=fixed li\=1
# ${CSI_CMD2}   ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2
# ${UE1_A1_EVENT}    ue_measurement_send_nr id\=1 meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=50
# @{Rdparameter}    0x340000:15
# *** Test Cases ***
# CNI70851_case02_interL2RT_SA_5GC002200_DRX_VONR
#     Modify Swconfig for GNB
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Override CSI For UE
#     Attach SA UE
#     UE SEND A1 EVENT
#     Internal send mutiple trf '5' for each '175M' DL data
#     Add 5Q5 PDU Session
#     Add 5Q1 PDU Session
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Check throughput
#     Check 5QI1 counter
#     Release VONR
#     Check throughput
#     Check 5QI1 counter release	
#     Stop data transfer
#     Collect AP egate log    ${EGATE_TAG}	
#     Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
#     
# 
# *** Keywords ***
# Modify Swconfig for GNB
#     Add GNB swconfig    @{Rdparameter}
# Attach SA UE
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Wait '5s' for stabible
# Override CSI For UE
#     airphone_execute_egate_command    ${CSI_CMD1}
#     airphone_execute_egate_command    ${CSI_CMD2}
# UE SEND A1 EVENT
#     airphone_execute_egate_command    ${UE1_A1_EVENT}
#     Wait '5s' for stabible
# Release VONR
#     Airphone Pdu Session Modify    qosflows_to_del=3
# 	Wait '5s' for stabible
# Start DL data on QFI1
# 
# Add 5Q5 PDU Session
#     Airphone Pdu Session Modify    qosflows_to_add=2    by=amf
#     Wait '2s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 mbps\=5 dir\=dl protocol\=tcp
#     Wait '2s' for stabible
# 
# Add 5Q1 PDU Session
#     Airphone Pdu Session Modify    qosflows_to_add=3    by=amf
#     Wait '5s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=5 dir\=dl
#     Wait '5s' for stabible
# Wait time to check throughput
#     ${remaining_time}    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 	
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Check 5QI1 counter value
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=1
#     ${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=2
#     should be true    ${PM_counter_value_Pcell}>0
#     should be true    ${PM_counter_value_Scell}==0
# 	
# Check 5QI1 counter value0
#     Wait '60s' for stabible
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=1
# 	${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=2
#     should be true    ${PM_counter_value_Pcell}==0
# 	should be true    ${PM_counter_value_Scell}==0	
# 	
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>0
# 	
# Check 5QI1 counter release
#     Wait time to check throughput
#     Check 5QI1 counter value0	
# 	
# Check 5QI1 counter
#     Wait time to check throughput
#     Check 5QI1 counter value
# 	
# Check throughput
#      ${pcell_tp}=    airphone_get_throughput_on_specific_scell    1    0    type=pdsch    tput_type=ave
#      ${scell_tp}=    airphone_get_throughput_on_specific_scell    1    1    type=pdsch    tput_type=ave
#      should be true    ${pcell_tp}>0
#      should be true    ${scell_tp}>0
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_csi.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

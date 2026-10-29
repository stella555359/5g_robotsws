# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R1    owner_ny    SBTS23R1
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      CNI70851_case5_scfc.xml
# ${AIRPHONE_NAME}    CNI70851_Case5_IPHY_AEHC.xml
# ${WTS_NAME}       SANSA7922_CNI70851_mutilue.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          1
# ${UE_ID_2}        2
# ${EGATE_TAG}      ADD
# ${DRX_TAG}      DRX
# ${DRXV_TAG}      DRXV
# ${UE_TOTALNUM}    10
# ${UE_NUM}         10
# ${CAUE_NUM}       2
# ${STABLETIME}     10s
# ${PMI}            csi_override_testmode_nr profile_id\=2 cqi\=15 ri_mode\=fixed ri\=1 pmi_mode\=fixed
#                   ...     pmi\=13 cri_mode\=fixed cri\=1 li_mode\=fixed li\=1
#              
# *** Test Cases ***
# CNI70851_case05_interL2RT_SA_5GC002200_multiUE_DRX
#     Modify counter Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set multiue traffic type to internal
#     Attach '2' ue to 5g cell
#     Collect AP egate log    ${DRX_TAG}
#     Analyse drx setup in rrclog
#     Add 5Q5 PDU Session
#     Add 5Q1 PDU Session
#     Collect AP egate log    ${DRXV_TAG}
#     Analyse drxv setup in rrclog
#     Internal send 5QI8 DL data
#     Internal send ue2 5QI8 DL data
#     Set '2' PMI
#     Verify CAUE throughput
#     Check 5QI1 counter
#     Release VONR
#     Verify CAUE throughput
#     Check 5QI1 counter release
#     Start collect ttitrace
#     Wait for '5s' to stop ttitrace with name'tti'
#     Check ttitrace
#     Collect AP egate log    ${EGATE_TAG}
#     Stop capture gnb and ap syslog in 'after_onair' file
#     Stop data transfer
#     Detach '2' UE
# 
# *** Keywords ***
# Set '${uenum}' PMI
#     airphone_execute_egate_command    ${PMI}
# 	: FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=2 scell\=0-1 
# 	
# Attach '${uenum}' ue to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible
# 
# Verify CAUE throughput
#     : FOR    ${num}    IN RANGE    1    ${CAUE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>50000
#     \    should_be_true    ${dl_throughput_scell1}>50000
# 
# Verify NCAUE throughput
#     : FOR    ${num}    IN RANGE    6    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>20000
# 
# Check throughputnew
#     Wait until keyword succeeds    60s    5s    Verify throughput
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# Release VONR
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_del\=3
#     Wait '40s' for stabible
# 
# Add 5Q5 PDU Session
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=2 by\=amf
#     Wait '2s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 mbps\=5 dir\=dl protocol\=tcp
#     Wait '2s' for stabible
# 
# Add 5Q1 PDU Session
#     airphone_execute_egate_command    ue_pdu_session_modify ue\=1 pdu\=1 qosflows_to_add\=3 by\=amf
#     Wait '5s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=5 dir\=dl
#     Wait '5s' for stabible
# 
# Wait time to check throughput
#     ${remaining_time}    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap
# 
# Check PM counter scell have throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value5qi8}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01008    cell_id=2
#     ${PM_counter_value5qi5}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01005    cell_id=2
#     ${PM_counter_value5qi1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01001    cell_id=2
#     should be true    ${PM_counter_value5qi8}>0
#     should be true    ${PM_counter_value5qi5}==0
#     should be true    ${PM_counter_value5qi1}==0
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
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=1
#     ${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=2
#     should be true    ${PM_counter_value_Pcell}==0
#     should be true    ${PM_counter_value_Scell}==0
# 
# Internal send 5QI8 DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=2 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=3 mbps\=175 dir\=dl
# 
# Internal send ue2 5QI8 DL data
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=2 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=3 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 qfi\=1 trf_id\=4 mbps\=175 dir\=dl
#     Wait time to stable
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    DL    175M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     \    Wait time to stable
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
#     Wait time to check throughput
#     Wait '60s' for stabible
#     Check Pcell throughput
#     Check PM counter scell have throughput
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# Modify counter Swconfig
#     Add GNB swconfig    0x340000:15  
#     Modify GNB swconfig	   0x340000:15
# Wait time to stable
#     sleep    ${STABLETIME}
# 
# Check ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_pmi.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	
# Analyse drx setup in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drx.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${DRX_TAG}_egate	
# 	
# Analyse drxv setup in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/drxv.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${DRXV_TAG}_egate		
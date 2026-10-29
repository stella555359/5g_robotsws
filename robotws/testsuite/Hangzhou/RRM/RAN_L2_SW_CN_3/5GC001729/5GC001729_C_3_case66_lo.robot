# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    #Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     #Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang    SBTS22R4    SBTS23R1
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_66_lo.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_lo.xml
# ${WTS_NAME}       WTS_1729_vonr_lo.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# ${STABLETIME}     10s
# 
# 
# *** Test Cases ***
# 5GC001729_Case66_C3_non_GB_vonr_blindadd_and_blindactivation
#     Modify counter Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Attach '1' ue to 5g cell  
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
# 	Check Scell active
# 	Add 5Q1 PDU Session Star VONR 
# 	Add 5Q8 PDU Session
#     Internal send 5QI8 DL data	
#     Verify CAUE throughput
# 	Check 5QI1 counter
# 	Release VONR
#     Verify CAUE throughput
# 	Check 5QI1 counter release	
#     Stop data transfer
#     Collect AP egate log    ${EGATE_TAG}	
#     Detach UE
# 
# *** Keywords ***
# Attach '${uenum}' ue to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible
# Verify CAUE throughput
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>800000
#     should_be_true    ${dl_throughput_scell1}>800000
# Release VONR
#     Airphone Pdu Session Modify    qosflows_to_del=2
# 	Wait '5s' for stabible
# 	
# Add 5Q1 PDU Session Star VONR 
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=5 dir\=dl protocol\=tcp
#     Wait '2s' for stabible
#     Airphone Pdu Session Modify    qosflows_to_add=2    by=amf
# 	Wait '2s' for stabible
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 mbps\=5 dir\=dl	
# 	Wait '5s' for stabible
# 	
# Add 5Q8 PDU Session
#     Airphone Pdu Session Modify    qosflows_to_add=3    by=amf
# 	Wait '5s' for stabible
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
# 	${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=2
#     should be true    ${PM_counter_value_Pcell}>0
# 	should be true    ${PM_counter_value_Scell}==0
# 	
# Check 5QI1 counter value0
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=1
# 	${PM_counter_value_Scell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C23002    cell_id=2
#     should be true    ${PM_counter_value_Pcell}==0
# 	should be true    ${PM_counter_value_Scell}==0	
# Wait time to stable
#     sleep    ${STABLETIME}	
# Internal send 5QI8 DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=2 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=3 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=4 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=5 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=6 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=7 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=8 mbps\=175 dir\=dl	
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=9 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=10 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=11 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=12 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=13 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=14 mbps\=175 dir\=dl
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=15 mbps\=175 dir\=dl
#     Wait time to stable
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>0
# 	
# Check 5QI1 counter release
#     Wait time to check throughput
# 	Wait '30s' for stabible
#     Check 5QI1 counter value0	
# 	
# Check 5QI1 counter
#     Wait time to check throughput
#     Check 5QI1 counter value
# 	
# Check throughput
#     Wait time to check throughput
# 	Wait '60s' for stabible
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
# 	Add GNB swconfig    0x340000:15  
#     Modify GNB swconfig	   0x340000:15
# 
# Online change to blind addition active
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1/NRREL-0    sCellAdditionMethod    blind    online
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAddition    false    online
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAdditionNsa    false    online
#     Perform online change value    MRBTS-1/NRBTS-2    sCellActivationMethod    bufferbased    online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
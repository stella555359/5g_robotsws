# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        SBTS00    RAN_5G_TDD    RAN_5G    owner_changyli    AP    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../resources/KISS/robot/common_resource.robot
# Resource    ../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# #${GNB_SWCONFIG_NAME}    gnb_swconfig.txt
# #${AP_SWCONFIG_NAME}    ap_swconfig.txt
# ${CONFIG_DIR_PATH}         ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_24.xml
# ${AIRPHONE_NAME}    IPHY_AEHC.xml
# ${WTS_NAME}       WTS_1729.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# ${B_S}       beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-50
# 
# *** Test Cases ***
# 5GC001729_Case24_A_5e_BufferAndRLQualityBased_scell_activation_A1addition_BF
#     Enable RD syslog in AP Swconfig
#     Add counter timer in gnb Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
# 	Set SSB Beam
#     Attach ue with '2x2_2cc'capability to 5g cell
#     UE send A1 event
#     Internal send DL data
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
#     Check throughput
# 	Stop data to trigger deactive
# 	Check Scell deactive
# 	resume data to trigger good threshold and scell resume
# 	Check Scell active
#     Start capture gnb and ap syslog in 'RLQ' file
#     Override Scell CQI trigger bad threshold
#     Check Scell RLQ deactive    
#     Override Scell CQI trigger good threshold and scell not resume
#     Stop data transfer
#     Collect AP egate log    ${EGATE_TAG}	
#     Detach UE
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# *** Keywords ***
# Set SSB Beam
#     airphone_execute_egate_command    ${B_S}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach
# 	
# Stop data to trigger deactive
#     Airphone SA Stop Data Traffic    ue_id=1    direction=dl
#     Wait time to check throughput
#     Check PM counter scell no throughput
# 	
# resume data to trigger good threshold and scell resume
#     Internal send DL data
# 
# Add counter timer in gnb Swconfig
#         Add GNB swconfig    0x340000:15
# 
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:1
# 
# Wait time to check throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 
# Override Scell CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
# 	Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell no throughput
# 	
# Override Scell CQI trigger morebad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=2
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell no throughput
# 	
# Override Scell CQI trigger good threshold and scell resume
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1 scell\=1
#     Check PM counter scell have throughput
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# Check PM counter scell no throughput
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
#     ${PM_counter_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55310C01006    cell_id=2
#     run keyword if    ${PM_counter_value}>0    Check PM counter scell no throughput again
# 
# Check Scell deactive
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap_after_onair
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb_after_onair
# 	
# Check Scell RLQ deactive  
#     wait_for_message_in_syslog_file    SCellIndex 1 deactivated successfully    timeout=300    alias=collect_ap_RLQ
#     wait_for_message_in_syslog_file    ModifType:DEACTIVATE    timeout=300    alias=collect_gnb_RLQ
# 
# Check Scell active
#     wait_for_message_in_syslog_file    SCellIndex 1 activated successfully    timeout=30    alias=collect_ap_after_onair
#     Check throughput
# 	
# Override Scell CQI trigger good threshold and scell not resume
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Check PM counter scell no throughput
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# Check PM counter scell have throughput
#      Wait until keyword succeeds    200s    20s   Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Internal send DL data
#     Internal send mutiple trf '4' for each '175M' DL data
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>100000
# 
# Check throughput
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     Check PM counter scell have throughput
#     Wait until keyword succeeds    60s    15s    Check Pcell throughput
# 
# Check PM counter scell no throughput again
#     Wait until keyword succeeds    120s    20s    Check pm counter M55310C01006 in cell 2 is expected == 0
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 #cqi_mode\=fixed
# 
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Online change to blind addition active
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-2/NRCELL-1/NRREL-0    sCellAdditionMethod    covBasedA1    online
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAddition    true    online
#     Perform online change value    MRBTS-1/NRBTS-2    actMeasBasedSCellAdditionNsa    true    online
#     Perform online change value    MRBTS-1/NRBTS-2    sCellActivationMethod    bufferAndRLQualityBased     online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Start capture gnb and ap syslog in '${file_name}' file
#     ute_syslog.Start Syslog    file_limit=${GNB_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/All/syslog_${file_name}
#     ...    log_name=${file_name}_gnb    ip=${GNB_SYSLOG.ip}    alias=collect_gnb_${file_name}
#     ute_syslog.Start Syslog    file_limit=${AP_SYSLOG.file_limit}    log_dir=${TEST_LOG_DIRECTORY()}/All/syslog_${file_name}
#     ...    log_name=${file_name}_ap    ip=${AP_SYSLOG.ip}    alias=collect_ap_${file_name}
# 
# Stop capture gnb and ap syslog in '${file_name}' file
#     ute_syslog.Collect Syslog Results    alias=collect_gnb_${file_name}    unzip=${False}
#     ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_gnb.tar.gz
#     ute_syslog.Collect Syslog Results    alias=collect_ap_${file_name}    unzip=${False}
#     ...    destination=${TEST_LOG_DIRECTORY()}${/}All${/}syslog_${file_name}${/}${file_name}_ap.tar.gz

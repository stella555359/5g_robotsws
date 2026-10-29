# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00    RAN_5G_TDD    RAN_5G    SBTS22R1    owner_ningyang    SBTS22R2    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_BLLL_AP_LOO
# ...               AP
# Resource          ../resources/KISS/robot/common_resource.robot
# Resource          ../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCFC_3_ABIO.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_lo.xml
# ${WTS_NAME}       WTS_1729.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${EGATE_TAG}    ADD
# 
# 
# *** Test Cases ***
# 5GC001729_Case3_A_2_2CC_CA_blindaddition_blindActivation
#     Enable RD syslog in AP Swconfig
#     Add counter timer in gnb Swconfig
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair' file
#     airphone_cleanup_egate_console_log
#     Set traffic type to internal
#     Attach ue with '2x2_2cc'capability to 5g cell
#     Internal send mutiple trf '4' for each '175M' DL data
#     Collect AP egate log    ${EGATE_TAG}
#     analyse scelladd in rrclog
# 	Check Scell active
# 	
# 5GC001729_Case9_A_4c_Single_UE_DL_nonGBR_Data_transmission_BlindActivation_Blindaddition
#     Check throughput
#     Stop data transfer
#     Detach UE
# 	
# *** Keywords ***
# Check throughput
#         ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#         ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=1    type=pdsch    tput_type=ave
#         should_be_true    ${dl_throughput_pcell}>50000
#         should_be_true    ${dl_throughput_scell1}>50000
# Enable RD syslog in AP Swconfig
#         Modify AP swconfig    0x10041:1
# Add counter timer in gnb Swconfig
#         Add GNB swconfig    0x340000:15	
# Wait time to check throughput
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait '${remaining_time}s' for stabible
# 
# Override Scell CQI trigger bad threshold
#     Airphone Cqi Param    nr_cqi=5
#     Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell no throughput
# 	
# Override Scell CQI trigger morebad threshold
#     Airphone Cqi Param    nr_cqi=1
#     Check PM counter scell no throughput
# 	
# Override Scell CQI trigger good threshold and scell resume
#     Airphone Cqi Param    nr_cqi=15
#     Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell have throughput
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
# Override Scell CQI trigger good threshold and scell not resume
#     Airphone Cqi Param    nr_cqi=15
#     Check Pcell throughput
#     Wait time to check throughput
#     Check PM counter scell no throughput
# 
# Check PM counter scell have throughput
#      Wait until keyword succeeds    200s    20s   Check pm counter M55310C01006 in cell 2 is expected > 0
# 
# Check Pcell throughput
#     ${sa_dl_tput}=    Airphone SA Get Throughput    ${UE_ID}    DL    ${PDU_ID}
#     run keyword and continue on failure    Should be true    ${sa_dl_tput}>100000
# 
# Check PM counter scell no throughput again
#     Wait '60s' for stabible
#     Check pm counter M55310C01006 in cell 2 is expected == 0
# 
# Stop data transfer
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    direction=dl
# 
# Detach UE
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 	
# Analyse scelladd in rrclog
#     check_log_with_au2anlysis    ${CURDIR}/ini/RRC_scelladd_51.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
